#!/usr/bin/env bash
# designx-cartografa.sh — Hook PreToolUse para cartografia visual
# Modo padrao: BLOQUEIO (excecao a regra universal de hooks de metodo). O modo vem
# de .expx/hooks.json (`.hooks["designx-cartografa"].modo`), como nos outros hooks
# do metodo; `desligado` desliga.
# Falha aberta: se cartografo nao rodar, registra erro e sai com 0
set -uo pipefail

HOOK="designx-cartografa"
PADRAO="bloqueio"
DS_PATH="docs/design-system/DESIGN-SYSTEM.md"

# a raiz pelo `cwd` da entrada do Claude Code; sem jq ou sem entrada, o diretorio atual
ENTRADA=""
[ -t 0 ] || ENTRADA="$(cat)"
CWD=""
if command -v jq >/dev/null 2>&1; then
  CWD="$(printf '%s' "$ENTRADA" | jq -r '.cwd // empty' 2>/dev/null)" || CWD=""
fi
CWD="${CWD:-$PWD}"
RAIZ="$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null)" || RAIZ="$CWD"

MODO=""
if command -v jq >/dev/null 2>&1; then
  MODO="$(jq -r --arg h "$HOOK" '.hooks[$h].modo // .modos[$h] // empty' "$RAIZ/.expx/hooks.json" 2>/dev/null)" || MODO=""
fi
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
if ! find "$RAIZ/src" \( -name "*.tsx" -o -name "*.jsx" -o -name "*.css" \) 2>/dev/null | head -1 | grep -q .; then
  exit 0
fi

# Se modo e aviso, so registra
if [ "$MODO" = "aviso" ]; then
  echo "[designx/hooks — aviso, a acao NAO foi bloqueada] Nenhum DESIGN-SYSTEM.md encontrado. Rode a cartografia visual antes de continuar."
  exit 0
fi

# Modo bloqueio: impede e sugere acao
echo "designx: Nenhum DESIGN-SYSTEM.md encontrado em docs/design-system/. Para criar via cartografia visual, rode: /designx-cartography" >&2
exit 2
