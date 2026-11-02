#!/usr/bin/env bash
# O `install.sh --opencode` leva a skill e as referências que os agentes do OpenCode leem.
#
# A origem `.opencode/skills/designx` não existia, e o instalador só avisava e seguia:
# o OpenCode ficava sem a skill (CodeRabbit no designx#6). A skill tem uma fonte só,
# `.claude/skills/designx`, e os agentes do OpenCode apontam a cópia instalada.
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
d="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d"' EXIT
falhas=0
(cd "$d" && bash "$RAIZ/install.sh" --opencode >/dev/null 2>&1) || { echo "FALHA install.sh --opencode saiu com erro"; exit 1; }
for f in SKILL.md references/02-cartografia.md references/03-auditoria.md; do
  [ -f "$d/.opencode/skills/designx/$f" ] || { echo "FALHA sem .opencode/skills/designx/$f"; falhas=$((falhas + 1)); }
done
for agente in "$RAIZ"/.opencode/agent/*.md; do
  while IFS= read -r ref; do
    [ -f "$d/$ref" ] || { echo "FALHA ${agente#"$RAIZ"/} aponta $ref, que a instalacao OpenCode nao tem"; falhas=$((falhas + 1)); }
  done < <(grep -oE '\.opencode/skills/designx/[A-Za-z0-9/_.-]+\.md' "$agente")
done
[ "$falhas" -eq 0 ] || exit 1
echo "ok: install.sh --opencode leva a skill e as referencias dos agentes"
