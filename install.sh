#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/.claude/skills/designx"
AGENTS_SRC="$SCRIPT_DIR/.claude/agents"
HOOKS_SRC="$SCRIPT_DIR/.claude/hooks/designx"
COMMANDS_SRC="$SCRIPT_DIR/.claude/commands"
OPENCODE_SKILL_SRC="$SCRIPT_DIR/.opencode/skills/designx"
OPENCODE_COMMAND_SRC="$SCRIPT_DIR/.opencode/command"
OPENCODE_AGENT_SRC="$SCRIPT_DIR/.opencode/agent"
OPENCODE_PLUGIN_SRC="$SCRIPT_DIR/.opencode/plugin"
CLAUDE_SKILL=".claude/skills/designx"
CLAUDE_AGENTS=".claude/agents"
CLAUDE_HOOKS=".claude/hooks/designx"
CLAUDE_COMMANDS=".claude/commands"
OPENCODE_SKILL=".opencode/skills/designx"
OPENCODE_COMMAND=".opencode/command"
OPENCODE_AGENT=".opencode/agent"
OPENCODE_PLUGIN=".opencode/plugin"
EXPX_DIR=".expx"
GLOBAL=false; CLAUDE_ONLY=false; OPENCODE_ONLY=false; DRY_RUN=false; FORCE=false
for arg in "$@"; do case "$arg" in
  --global) GLOBAL=true ;; --claude) CLAUDE_ONLY=true ;; --opencode) OPENCODE_ONLY=true ;;
  --dry-run) DRY_RUN=true ;; --force) FORCE=true ;;
  --help|-h) echo "Uso: ./install.sh [--global] [--claude|--opencode] [--dry-run] [--force]"; exit 0 ;;
esac; done
[ "$GLOBAL" = true ] && TARGET="$HOME" || TARGET="."
instalar() {
  local src="$1" dst="$2" label="$3"
  [ ! -e "$src" ] && echo "  AVISO: $src nao encontrado" && return
  [ -e "$dst" ] && [ "$FORCE" = false ] && echo "  PULO: $dst ja existe" && return
  [ "$DRY_RUN" = true ] && echo "  CRIARIA: $dst" && return
  mkdir -p "$(dirname "$dst")" && cp -R "$src" "$dst" && echo "  OK: $dst"
}
echo "=== designx - Instalador ===" && echo ""
if [ "$OPENCODE_ONLY" = false ]; then
  echo "Claude Code:"
  instalar "$SKILL_SRC" "$TARGET/$CLAUDE_SKILL" "skill"
  instalar "$AGENTS_SRC" "$TARGET/$CLAUDE_AGENTS" "agents"
  instalar "$HOOKS_SRC" "$TARGET/$CLAUDE_HOOKS" "hooks"
  instalar "$COMMANDS_SRC" "$TARGET/$CLAUDE_COMMANDS" "commands"
  echo ""
fi
if [ "$CLAUDE_ONLY" = false ]; then
  echo "OpenCode:"
  instalar "$OPENCODE_SKILL_SRC" "$TARGET/$OPENCODE_SKILL" "skill"
  instalar "$OPENCODE_COMMAND_SRC" "$TARGET/$OPENCODE_COMMAND" "commands"
  instalar "$OPENCODE_AGENT_SRC" "$TARGET/$OPENCODE_AGENT" "agents"
  instalar "$OPENCODE_PLUGIN_SRC" "$TARGET/$OPENCODE_PLUGIN" "plugin"
  echo ""
fi
if [ "$DRY_RUN" = false ]; then
  mkdir -p "$TARGET/$EXPX_DIR"
  [ ! -f "$TARGET/$EXPX_DIR/hooks.json" ] && cp "$SCRIPT_DIR/.expx/hooks.json" "$TARGET/$EXPX_DIR/hooks.json" && echo "  OK: $TARGET/$EXPX_DIR/hooks.json" || echo "  PULO: hooks.json ja existe"
fi
echo "" && echo "Concluido. Reinicie a sessao do harness."
