#!/usr/bin/env bash
# Os comandos de busca dos agentes acham o que dizem achar.
#
# Revisão do CodeAnt no expxdev#130: `grep -E` com `\|` casa um `|` literal e
# não achava cor nenhuma; `src/**/*.css` sem `globstar` só desce um nível; e
# `| grep -vL` lia os nomes de arquivo como texto. Cada comando roda, como está
# no agente, numa árvore de exemplo com o caso aninhado.
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
d="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d"' EXIT
mkdir -p "$d/src/a/b"
printf ':root { --cor-base: #fff; }\n' > "$d/src/a/b/tema.css"
printf 'export const X = () => <div style={{ color: "#abc" }} className="rgb(1,2,3) hsl(1,2%%,3%%)" />;\n' > "$d/src/a/b/Cor.tsx"
printf 'export const Y = () => <div className="animate-spin" />;\n' > "$d/src/a/b/Gira.tsx"
printf 'export const Z = () => <div className="animate-spin motion-reduce:animate-none" />;\n' > "$d/src/a/Calmo.tsx"
falhas=0
comando() { # comando <arquivo> <trecho que identifica a linha>
  grep -m1 -F -- "$2" "$RAIZ/$1" | sed 's/^ *//; s/ 2>\/dev\/null//'
}
confere() { # confere <nome> <saida> <esperado>
  if printf '%s' "$2" | grep -qF -- "$3"; then echo "ok    $1"; else echo "FALHA $1 (esperado $3 em: ${2:-vazio})"; falhas=$((falhas + 1)); fi
}
c="$(comando .claude/agents/cartografo-visual.md '[a-z]" src')"; confere tokens-aninhados "$(cd "$d" && bash -c "$c" 2>/dev/null)" "--cor-base"
c="$(comando .claude/agents/cartografo-visual.md '{3,8}')"; s="$(cd "$d" && bash -c "$c" 2>/dev/null)"
confere cor-hex "$s" "#abc"; confere cor-rgb "$s" "rgb(1,2,3)"
c="$(comando .claude/agents/auditor-design.md 'motion-reduce')"; s="$(cd "$d" && bash -c "$c" 2>/dev/null)"
confere animacao-sem-motion-reduce "$s" "Gira.tsx"
if printf '%s' "$s" | grep -qF "Calmo.tsx"; then echo "FALHA animacao-com-motion-reduce-acusada"; falhas=$((falhas + 1)); else echo "ok    animacao-com-motion-reduce-fica-de-fora"; fi
for f in .claude/agents/*.md .claude/skills/designx/references/*.md .opencode/agent/*.md; do
  if grep -n 'src/\*\*/' "$RAIZ/$f" >/dev/null; then echo "FALHA glob-recursivo-em-$f"; falhas=$((falhas + 1)); fi
done
[ "$falhas" -eq 0 ] || exit 1
echo "ok: comandos de busca"
