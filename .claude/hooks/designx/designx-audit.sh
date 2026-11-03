#!/usr/bin/env bash
# designx-audit.sh — Hook PostToolUse para auditoria continua de design
# Evento: PostToolUse em Write/Edit
# Modo padrao: AVISO. O modo vem de .expx/hooks.json (`.hooks["designx-audit"].modo`),
# como nos outros hooks do metodo; `desligado` desliga.
# Verifica: hex hardcoded, com o descarte do A1, e cor arbitraria do Tailwind
set -uo pipefail

HOOK="designx-audit"
PADRAO="aviso"
DS_PATH="docs/design-system/DESIGN-SYSTEM.md"

# sem jq nao se le a entrada nem o modo: falha aberta
command -v jq >/dev/null 2>&1 || exit 0

ENTRADA=""
[ -t 0 ] || ENTRADA="$(cat)"
# o Claude Code entrega `tool_input.file_path`; `filePath` e `input.args.filePath`
# sao a forma antiga, e DESIGNX_FILE e o que o plugin do OpenCode passa
ARQUIVO="$(printf '%s' "$ENTRADA" | jq -r '.tool_input.file_path // .filePath // .input.args.filePath // empty' 2>/dev/null)" || ARQUIVO=""
[ -n "$ARQUIVO" ] || ARQUIVO="${DESIGNX_FILE:-}"
[ -n "$ARQUIVO" ] || exit 0
CWD="$(printf '%s' "$ENTRADA" | jq -r '.cwd // empty' 2>/dev/null)" || CWD=""
CWD="${CWD:-$PWD}"
RAIZ="$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)" || RAIZ="$CWD"
case "$ARQUIVO" in
  /*|[A-Za-z]:[\\/]*) ;;
  *) ARQUIVO="$CWD/$ARQUIVO" ;;
esac

MODO="$(jq -r --arg h "$HOOK" '.hooks[$h].modo // .modos[$h] // empty' "$RAIZ/.expx/hooks.json" 2>/dev/null)" || MODO=""
case "$MODO" in aviso|bloqueio|desligado) ;; *) MODO="$PADRAO" ;; esac
[ "$MODO" = "desligado" ] && exit 0

# Se DS nao existe, nao audita
[ -f "$RAIZ/$DS_PATH" ] || exit 0

# Filtra: so arquivos de UI
case "$ARQUIVO" in
  *.tsx|*.jsx|*.css|*.scss) ;;
  *) exit 0 ;;
esac
[ -f "$ARQUIVO" ] || exit 0
CSS=0
case "$ARQUIVO" in *.css|*.scss) CSS=1 ;; esac

# Verificacao 1: hex hardcoded, com o descarte do A1 (references/00-boas-praticas.md):
# o valor de `--nome:` (a definicao do token), o comentario (tambem de varias
# linhas), a referencia `url(#...)` do SVG e, em CSS e SCSS, o seletor de id. Uma
# passada de awk, caractere a caractere, apaga esses trechos numa copia; a linha
# que sobra com hex sai como esta no arquivo. A variavel do SCSS (`$nome:`)
# continua achado. Sem gsub do jq: num CSS de milhares de linhas ele levava segundos.
# shellcheck disable=SC2016
HEX_AWK='
function palavra(c) { return c ~ /[A-Za-z0-9_]/ }
function apaga(l, c) { if (M[l, c] != "\n") M[l, c] = " " }
{
  linha[NR] = $0; n = length($0); N[NR] = n
  for (i = 1; i <= n; i++) M[NR, i] = substr($0, i, 1)
}
END {
  bloco = 0; token = 0; sl = 1; sc = 1
  for (l = 1; l <= NR; l++) {
    n = N[l]; comlinha = 0
    for (i = 1; i <= n; i++) {
      c = M[l, i]; prox = (i < n) ? M[l, i + 1] : ""; ant = (i > 1) ? substr(linha[l], i - 1, 1) : ""
      if (bloco) { if (c == "*" && prox == "/") { apaga(l, i); apaga(l, i + 1); i++; bloco = 0 } else apaga(l, i); continue }
      if (comlinha) { apaga(l, i); continue }
      if (c == "/" && prox == "*") { bloco = 1; apaga(l, i); apaga(l, i + 1); i++; continue }
      if (c == "/" && prox == "/" && ant != ":" && ant != "/" && !palavra(ant)) { comlinha = 1; apaga(l, i); continue }
      if (token) { if (c == ";" || c == "}") token = 0; else { apaga(l, i); continue } }
      if (c == "-" && prox == "-" && !palavra(ant) && ant != "-" && match(substr(linha[l], i), /^--[A-Za-z0-9_-]+([ \t]|\/\*([^*]|\*+[^*\/])*\*+\/)*:/)) { token = 1; apaga(l, i); continue }
      if (c == "u" && match(substr(linha[l], i), /^url\([ \t]*["\047]?#[A-Za-z0-9_-]+/)) { for (k = i; k < i + RLENGTH; k++) apaga(l, k); i += RLENGTH - 1; continue }
      if (css && (c == ";" || c == "}")) { sl = l; sc = i + 1; continue }
      if (css && c == "{") {
        # o seletor do bloco: do ultimo `;`, `{` ou `}` ate esta chave
        for (ll = sl; ll <= l; ll++) for (k = (ll == sl ? sc : 1); k <= (ll == l ? i - 1 : N[ll]); k++) apaga(ll, k)
        sl = l; sc = i + 1
      }
    }
  }
  achados = 0
  for (l = 1; l <= NR && achados < 5; l++) {
    n = N[l]
    for (i = 1; i <= n; i++) {
      if (M[l, i] != "#") continue
      k = i + 1; while (k <= n && M[l, k] ~ /[0-9A-Fa-f]/) k++
      h = k - i - 1
      if ((h == 3 || h == 4 || h == 6 || h == 8) && (k > n || !palavra(M[l, k]))) { print l ":" linha[l]; achados++; break }
    }
  }
}'
HEX_VIOLATIONS="$(LC_ALL=C awk -v css="$CSS" "$HEX_AWK" "$ARQUIVO" 2>/dev/null)" || HEX_VIOLATIONS=""

# Verificacao 2: cor arbitraria do Tailwind
TOKEN_VIOLATIONS=""
if grep -q "className" "$ARQUIVO" 2>/dev/null; then
  if grep -nE "bg-\[#|text-\[#|border-\[#" "$ARQUIVO" 2>/dev/null | head -3 | grep -q .; then
    TOKEN_VIOLATIONS="cores hardcoded detectadas"
  fi
fi

VIOLACOES=""
if [ -n "$HEX_VIOLATIONS" ]; then
  VIOLACOES="${VIOLACOES}hex hardcoded: ${HEX_VIOLATIONS}; "
fi
if [ -n "$TOKEN_VIOLATIONS" ]; then
  VIOLACOES="${VIOLACOES}${TOKEN_VIOLATIONS}; "
fi

# Sem violacoes
if [ -z "$VIOLACOES" ]; then
  exit 0
fi

# Registrar no rastro, com o arquivo relativo a raiz
REL="${ARQUIVO#"$RAIZ"/}"
RESULTADO=aviso
[ "$MODO" = "bloqueio" ] && RESULTADO=bloqueado
RASTRO="$RAIZ/docs/eventos/designx.jsonl"
mkdir -p "$(dirname "$RASTRO")"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
# As ocorrencias vem do arquivo com aspas, barras e quebras de linha: o jq (o mesmo
# que ja leu o evento) serializa, e cada evento sai numa linha JSON valida.
jq -cn --arg ts "$TIMESTAMP" --arg detalhe "$VIOLACOES" --arg arquivo "$REL" --arg resultado "$RESULTADO" \
  '{ts:$ts, expx_eventos:1, trabalho_id:"designx", ferramenta:"designx", origem:"hook", evento:"design_violacao_detectada", fase:"audit", task:null, agente:"principal", resultado:$resultado, detalhe:$detalhe, arquivos:[$arquivo]}' \
  >> "$RASTRO"

# Se modo e aviso, so registra
if [ "$MODO" = "aviso" ]; then
  echo "[designx/hooks — aviso, a acao NAO foi bloqueada] Violacao de design detectada em ${REL}: ${VIOLACOES}" >&2
  exit 0
fi

# Modo bloqueio
echo "designx: Violacao de design em ${REL}. ${VIOLACOES}" >&2
exit 2
