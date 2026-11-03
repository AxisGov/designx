#!/usr/bin/env bash
# designx-cartografa.sh — Hook PreToolUse para cartografia visual
# Modo padrao: BLOQUEIO (excecao a regra universal de hooks de metodo). O modo vem
# de .expx/hooks.json (`.hooks["designx-cartografa"].modo`), como nos outros hooks
# do metodo; `desligado` desliga. Sem a chave, vale DESIGNX_CARTOGRAFA_MODO, a forma
# antiga; sem o arquivo e sem ela, bloqueio.
# Falha aberta: se cartografo nao rodar, registra erro e sai com 0
set -uo pipefail

HOOK="designx-cartografa"
PADRAO="bloqueio"
DS_PATH="docs/design-system/DESIGN-SYSTEM.md"

# a raiz pelo `cwd` da entrada do Claude Code. Sem jq, a entrada nao se le, e o
# diretorio atual pode ser de outro projeto: falha aberta. Sem entrada (o plugin
# do OpenCode), o diretorio atual
ENTRADA=""
[ -t 0 ] || ENTRADA="$(cat)"
CWD=""
if command -v jq >/dev/null 2>&1; then
  CWD="$(printf '%s' "$ENTRADA" | jq -r '.cwd // empty' 2>/dev/null)" || CWD=""
elif [ -n "$ENTRADA" ]; then
  exit 0
fi
CWD="${CWD:-$PWD}"
RAIZ="$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)" || RAIZ="$CWD"

CFG="$RAIZ/.expx/hooks.json"
MODO=""
if [ -f "$CFG" ]; then
  # arquivo presente que nao se le (sem jq, JSON invalido): falha aberta
  command -v jq >/dev/null 2>&1 && jq -e . "$CFG" >/dev/null 2>&1 || exit 0
  MODO="$(jq -r --arg h "$HOOK" '.hooks[$h].modo // .modos[$h] // empty' "$CFG" 2>/dev/null)" || MODO=""
fi
[ -n "$MODO" ] || MODO="${DESIGNX_CARTOGRAFA_MODO:-}"
case "$MODO" in aviso|bloqueio|desligado) ;; *) MODO="$PADRAO" ;; esac
[ "$MODO" = "desligado" ] && exit 0

# Se DS ja existe, nao faz nada
if [ -f "$RAIZ/$DS_PATH" ]; then
  exit 0
fi

# Se designx nao esta ativo (sem .expx/designx.json), sai silenciosamente
if [ ! -f "$RAIZ/.expx/designx.json" ]; then
  exit 0
fi

# Verifica se ha UI no projeto
# so a saida conta: o `head` fecha o pipe cedo, e o SIGPIPE do `find` sob pipefail
# faria um projeto com muita UI parecer sem UI
[ -n "$(find "$RAIZ/src" \( -name "*.tsx" -o -name "*.jsx" -o -name "*.css" \) 2>/dev/null | head -1)" ] || exit 0

# Modo aviso: nos dois canais. O Claude Code nao mostra ao Claude o stdout em texto de
# um PreToolUse que sai 0; o `additionalContext` do JSON, sim
if [ "$MODO" = "aviso" ]; then
  MSG="[designx/hooks — aviso, a acao NAO foi bloqueada] Nenhum DESIGN-SYSTEM.md encontrado. Rode a cartografia visual antes de continuar."
  printf '%s\n' "$MSG" >&2
  # a mensagem e fixa, sem aspa nem barra invertida: o JSON sai sem jq
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"%s"}}\n' "$MSG"
  exit 0
fi

# Modo bloqueio: impede e sugere acao
echo "designx: Nenhum DESIGN-SYSTEM.md encontrado em docs/design-system/. Para criar via cartografia visual, rode: /designx-cartography" >&2
exit 2
