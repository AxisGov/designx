#!/usr/bin/env bash
# Os hooks da designx com a entrada real do Claude Code.
#
# O designx-audit lia `.filePath` e o Claude Code entrega `.tool_input.file_path`:
# ele nunca rodava. Os dois hooks liam o modo de variavel de ambiente, e o
# `desligado` do .expx/hooks.json, que o `expx init` compoe, nao desligava nada.
# E o hex do audit nao tinha o descarte do A1 (0.13.5): a definicao do token
# `--nome:`, o comentario, o `url(#...)` e o seletor de id. Cada hook roda
# fora da raiz do projeto, para provar que ele a acha pelo `.cwd` da entrada.
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
H="$RAIZ/.claude/hooks/designx"
command -v jq >/dev/null || { echo "FALHA: jq ausente"; exit 1; }
d="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d"' EXIT
OK=0; FALHAS=0
ok() { OK=$((OK + 1)); echo "ok    $1"; }
falha() { FALHAS=$((FALHAS + 1)); echo "FALHA $1"; }

# proj <nome> [sem-ds] — repositorio com DESIGN-SYSTEM.md (ou sem ele)
proj() {
  local p="$d/$1"
  mkdir -p "$p/src" "$p/docs/design-system" "$p/.expx"
  git init -q "$p"
  [ "${2:-}" = sem-ds ] || printf '# Design system\n' > "$p/docs/design-system/DESIGN-SYSTEM.md"
  printf '%s' "$p"
}
# modo <proj> <id> <modo>
modo() { jq -n --arg h "$2" --arg m "$3" '{expx_hooks: 1, hooks: {($h): {modo: $m, tipo: "metodo"}}}' > "$1/.expx/hooks.json"; }
# audit <proj> <arquivo relativo> — PostToolUse do Claude Code, rodado em /; rc em RC, stderr em ERR
audit() {
  local e
  e="$(jq -cn --arg f "$1/$2" --arg c "$1" '{hook_event_name: "PostToolUse", tool_name: "Write", tool_input: {file_path: $f, content: ""}, cwd: $c}')"
  OUT="$( cd / && printf '%s' "$e" | bash "$H/designx-audit.sh" 2>"$d/err" )"; RC=$?; ERR="$(cat "$d/err")"
}
# cartografa <proj> — PreToolUse de Bash do Claude Code, rodado em /
cartografa() {
  local e
  e="$(jq -cn --arg c "$1" '{hook_event_name: "PreToolUse", tool_name: "Bash", tool_input: {command: "ls"}, cwd: $c}')"
  SAIDA="$( cd / && printf '%s' "$e" | ${SEM_JQ:+env PATH="$SEM_JQ"} bash "$H/designx-cartografa.sh" 2>&1 )"; RC=$?
}

# --- designx-audit -----------------------------------------------------------
p="$(proj solto)"
printf '.fundo { background-color: #0a111c; }\n' > "$p/src/a.css"
audit "$p" src/a.css
if [ "$RC" = 0 ] && printf '%s' "$ERR" | grep -q 'hex hardcoded' && printf '%s' "$ERR" | grep -q '#0a111c'; then ok "audit: hex solto em .css, com a entrada do Claude Code, avisa"
else falha "audit: hex solto nao avisou (rc $RC): $ERR"; fi
if printf '%s' "$OUT" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse" and (.hookSpecificOutput.additionalContext | contains("#0a111c"))' >/dev/null 2>&1; then ok "audit: o aviso chega ao Claude no stdout, em additionalContext"
else falha "audit: sem additionalContext no stdout: $OUT"; fi
r="$p/docs/eventos/designx.jsonl"
if [ -f "$r" ] && jq -e 'select(.evento == "design_violacao_detectada" and .arquivos == ["src/a.css"] and .resultado == "aviso")' "$r" >/dev/null; then ok "audit: uma linha JSON valida no rastro, com o arquivo relativo a raiz"
else falha "audit: rastro ausente ou invalido: $(cat "$r" 2>/dev/null)"; fi

p="$(proj token)"
cat > "$p/src/tema.css" <<'CSS'
:root { --fundo: #0a111c; --texto: #fafafa; }
:root { --nota/* comentario */: #abcdef; }
[data-x="a{b"] #fad { color: var(--texto); }
:root { --longa /* comentario
   de varias linhas */ : #fedcba; }
/*
  paleta antiga #123abc
*/
.recorte { clip-path: url(#fade); }
.bloco { color: var(--texto); /* antes #654321 */ }
.linha { color: var(--texto); } /* fim #a1b2c3
   continua #b2c3d4 */
#add { color: var(--fundo); }
.container #bad, .menu #fade:hover { color: var(--texto); }
CSS
printf '$marca: var(--fundo);\n// legado #dddddd\n' > "$p/src/tema.scss"
printf 'export const k = cor// legado #a1a1a1;\nexport const t = "a"; // nota #b2b2b2\nexport const P = () => <p>Don\047t</p>;\n// nota #b3b3b3\nexport const X = () => <div />; // antes #abcdef\nexport const Y = () => <div>{/* cor #fedcba */}</div>;\n' > "$p/src/Comenta.tsx"
audit "$p" src/tema.css; a="$RC|$ERR"
audit "$p" src/tema.scss; b="$RC|$ERR"
audit "$p" src/Comenta.tsx; c="$RC|$ERR"
if [ "$a" = "0|" ] && [ "$b" = "0|" ] && [ "$c" = "0|" ] && [ ! -e "$p/docs/eventos/designx.jsonl" ]; then ok "audit: token, comentario (tambem de varias linhas e dentro do bloco), url(#) e seletor de id nao avisam"
else falha "audit: descarte do A1: css [$a] scss [$b] tsx [$c]"; fi

p="$(proj duo)"
printf '.duo { --base: #111; color: #222222; }\n$marca: #fe0c0d;\n.uso { color: var(--base) #333333; }\n@include botao(#444444) { }\n@if $c == #555555 {\n}\n' > "$p/src/duo.scss"
audit "$p" src/duo.scss
if printf '%s' "$ERR" | grep -q '#222222' && printf '%s' "$ERR" | grep -q '#fe0c0d' && printf '%s' "$ERR" | grep -q '#333333' \
  && printf '%s' "$ERR" | grep -q '#444444' && printf '%s' "$ERR" | grep -q '#555555'; then ok "audit: a cor solta ao lado do token, depois de var(--x), na at-rule do SCSS e a variavel do SCSS avisam"
else falha "audit: duo: $ERR"; fi

p="$(proj tsx)"
printf 'export const X = () => <div style={{ color: "#abc" }} />;\n' > "$p/src/X.tsx"
audit "$p" src/X.tsx
if printf '%s' "$ERR" | grep -q '#abc'; then ok "audit: hex em .tsx avisa"; else falha "audit: tsx: $ERR"; fi
printf 'export const Z = () => <a href="https://x.com/#abc" />;\nexport const W = () => <a href="file:///tmp/#def" />;\nexport const V = () => <a href="//cdn.exemplo/#e1e1e1" />;\nexport const s = "a//b #f1f1f1";\n' > "$p/src/Url.tsx"
printf '.u { background: url(//cdn.exemplo/#c1c1c1); }\n' > "$p/src/u.scss"
printf '.u { background: url(//cdn.exemplo/#d1d1d1); }\n' > "$p/src/u.css"
audit "$p" src/Url.tsx
u="$ERR"; audit "$p" src/u.scss; u="$u|$ERR"; audit "$p" src/u.css; u="$u|$ERR"; ERR="$u"
if printf '%s' "$ERR" | grep -q 'x.com/#abc' && printf '%s' "$ERR" | grep -q 'tmp/#def' && printf '%s' "$ERR" | grep -q '#e1e1e1' \
  && printf '%s' "$ERR" | grep -q '#f1f1f1' && printf '%s' "$ERR" | grep -q '#c1c1c1' && printf '%s' "$ERR" | grep -q '#d1d1d1'; then ok "audit: o // de URL (com e sem protocolo), de string e de url() sem aspas nao e comentario"; else falha "audit: URL: $ERR"; fi
printf '# nota #abc\n' > "$p/src/nota.md"
audit "$p" src/nota.md
if [ "$RC|$ERR" = "0|" ]; then ok "audit: arquivo que nao e de UI fica mudo"; else falha "audit: .md: $RC|$ERR"; fi

p="$(proj sem-ds sem-ds)"
printf '.x { color: #0a111c; }\n' > "$p/src/a.css"
audit "$p" src/a.css
if [ "$RC|$ERR" = "0|" ]; then ok "audit: sem DESIGN-SYSTEM.md fica mudo"; else falha "audit: sem DS: $RC|$ERR"; fi

p="$(proj desligado)"
printf '.x { color: #0a111c; }\n' > "$p/src/a.css"
modo "$p" designx-audit desligado
audit "$p" src/a.css
if [ "$RC|$ERR" = "0|" ] && [ ! -e "$p/docs/eventos/designx.jsonl" ]; then ok "audit: desligado no .expx/hooks.json fica mudo"; else falha "audit: desligado: $RC|$ERR"; fi
modo "$p" designx-audit bloqueio
audit "$p" src/a.css
if [ "$RC" = 2 ] && printf '%s' "$ERR" | grep -q '^designx:'; then ok "audit: bloqueio no .expx/hooks.json sai 2"; else falha "audit: bloqueio: rc $RC: $ERR"; fi
if [ "$(jq -r '.resultado' "$p/docs/eventos/designx.jsonl" 2>/dev/null)" = aviso ]; then ok "audit: no PostToolUse a escrita ja aconteceu, e o rastro diz aviso tambem no bloqueio"
else falha "audit: resultado do rastro no bloqueio: $(cat "$p/docs/eventos/designx.jsonl" 2>/dev/null)"; fi
printf '{ invalido\n' > "$p/.expx/hooks.json"
audit "$p" src/a.css
if [ "$RC|$ERR|$OUT" = "0||" ]; then ok "audit: .expx/hooks.json invalido e falha aberta"; else falha "audit: hooks.json invalido: $RC|$ERR"; fi

p="$(proj antiga)"
printf '.x { color: #0a111c; }\n' > "$p/src/a.css"
ERR="$( cd "$p" && printf '{"filePath":"src/a.css"}' | bash "$H/designx-audit.sh" 2>&1 >/dev/null )"
if printf '%s' "$ERR" | grep -q '#0a111c'; then ok "audit: a entrada antiga (filePath relativo) segue aceita"; else falha "audit: forma antiga: $ERR"; fi
ERR="$( cd "$p" && DESIGNX_FILE=src/a.css bash "$H/designx-audit.sh" 2>&1 >/dev/null </dev/null )"
if printf '%s' "$ERR" | grep -q '#0a111c'; then ok "audit: DESIGNX_FILE, que o plugin do OpenCode passa, e aceito"; else falha "audit: DESIGNX_FILE: $ERR"; fi

p="$(proj grande)"
for i in $(seq 1 1500); do printf ':root { --c%s: #0a111c; }\n/* nota %s #123456 */\n.x%s { color: var(--c%s); }\n' "$i" "$i" "$i" "$i"; done > "$p/src/grande.css"
printf '.fim { color: #abcdef; }\n' >> "$p/src/grande.css"
ini=$(date +%s); audit "$p" src/grande.css; dur=$(( $(date +%s) - ini ))
if printf '%s' "$ERR" | grep -q '4501:.fim' && [ "$(printf '%s' "$ERR" | grep -o '#' | wc -l | tr -d ' ')" = 1 ] && [ "$dur" -le 5 ]; then ok "audit: CSS de 4501 linhas, um so achado, em ${dur}s"
else falha "audit: CSS grande: ${dur}s: $(printf '%s' "$ERR" | cut -c1-200)"; fi

# --- designx-cartografa ------------------------------------------------------
p="$(proj carto sem-ds)"
printf '{}\n' > "$p/.expx/designx.json"
printf 'export const X = () => <div />;\n' > "$p/src/X.tsx"
cartografa "$p"
if [ "$RC" = 2 ]; then ok "cartografa: sem DS, com UI e designx ativo, bloqueia (o padrao)"; else falha "cartografa: padrao: rc $RC: $SAIDA"; fi
modo "$p" designx-cartografa desligado
cartografa "$p"
if [ "$RC|$SAIDA" = "0|" ]; then ok "cartografa: desligado no .expx/hooks.json nao bloqueia"; else falha "cartografa: desligado: $RC|$SAIDA"; fi
printf '{ invalido\n' > "$p/.expx/hooks.json"
cartografa "$p"
if [ "$RC" = 0 ]; then ok "cartografa: .expx/hooks.json invalido e falha aberta"; else falha "cartografa: hooks.json invalido: rc $RC"; fi
SEM_JQ="$d/semjq"; mkdir -p "$SEM_JQ"; for b in bash cat git find head env dirname; do ln -sf "$(command -v "$b")" "$SEM_JQ/$b"; done
modo "$p" designx-cartografa desligado
cartografa "$p"
if [ "$RC" = 0 ]; then ok "cartografa: sem jq, com .expx/hooks.json, e falha aberta"; else falha "cartografa: sem jq: rc $RC: $SAIDA"; fi
SEM_JQ=""
jq -n '{expx_hooks: 1, hooks: {}}' > "$p/.expx/hooks.json"
SAIDA="$( cd / && printf '{"cwd":"%s"}' "$p" | DESIGNX_CARTOGRAFA_MODO=aviso bash "$H/designx-cartografa.sh" 2>/dev/null )"; RC=$?
if [ "$RC" = 0 ] && printf '%s' "$SAIDA" | jq -e '.hookSpecificOutput.additionalContext | contains("NAO foi bloqueada")' >/dev/null 2>&1; then ok "cartografa: sem a chave no .expx/hooks.json, DESIGNX_CARTOGRAFA_MODO vale, e o aviso vai em additionalContext"
else falha "cartografa: variavel antiga: $RC|$SAIDA"; fi
modo "$p" designx-cartografa aviso
cartografa "$p"
if [ "$RC" = 0 ] && printf '%s' "$SAIDA" | grep -q 'NAO foi bloqueada'; then ok "cartografa: aviso avisa e nao bloqueia"; else falha "cartografa: aviso: $RC|$SAIDA"; fi
rm -f "$p/.expx/hooks.json"
mkdir -p "$p/src/muitos"; for i in $(seq 1 3000); do : > "$p/src/muitos/C$i.tsx"; done
cartografa "$p"
if [ "$RC" = 2 ]; then ok "cartografa: com milhares de arquivos de UI, bloqueia (sem o SIGPIPE do find)"; else falha "cartografa: muitos arquivos: rc $RC"; fi
printf '# DS\n' > "$p/docs/design-system/DESIGN-SYSTEM.md"
cartografa "$p"
if [ "$RC|$SAIDA" = "0|" ]; then ok "cartografa: com DESIGN-SYSTEM.md nao faz nada"; else falha "cartografa: com DS: $RC|$SAIDA"; fi

echo "      $OK ok, $FALHAS falha(s)"
[ "$FALHAS" = 0 ]
