#!/usr/bin/env bash
# As buscas da designx são chamadas das ferramentas Grep e Glob, e acham o que dizem achar.
#
# Os agentes `cartografo-visual` e `auditor-design` têm só Read, Glob e Grep, e a
# ferramenta Grep é o ripgrep. Os blocos de shell tinham `\|` (literal no ERE e no
# ripgrep: a busca de cor não achava nada), `src/**/*.css` como argumento de shell
# e `| grep -vL` (revisão do CodeAnt no expxdev#130 e do Codex). Este teste lê cada
# `Grep {...}` como JSON, roda com `rg` numa árvore de exemplo, e prova os três casos.
set -uo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
command -v rg >/dev/null || { echo "FALHA: rg (ripgrep) ausente; o CI o instala"; exit 1; }
d="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d"' EXIT
mkdir -p "$d/src/a/b" "$d/src/components/ui" "$d/src/pages"
printf ':root { --cor-base: #fff; }\n' > "$d/src/a/b/tema.css"
printf 'export const X = () => <div style={{ color: "#abc" }} className="rgb(1,2,3) hsl(1,2%%,3%%)" />;\n' > "$d/src/a/b/Cor.tsx"
printf 'export const Y = () => <div className="animate-spin" />;\nexport const W = () => <div className="animate-pulse motion-reduce:animate-none" />;\n' > "$d/src/a/b/Gira.tsx"
python3 - "$RAIZ" "$d" <<'PY'
import json, re, subprocess, sys
from pathlib import Path
raiz, arvore = Path(sys.argv[1]), sys.argv[2]
arquivos = sorted((raiz / ".claude" / "agents").glob("*.md")) + [raiz / ".claude/skills/designx/SKILL.md"] + sorted((raiz / ".claude/skills/designx/references").glob("*.md"))
CHAVES = {"pattern", "path", "glob", "output_mode", "-n", "-i", "head_limit", "type", "multiline"}
falhas = []
def rg(d):
    cmd = ["rg", "--no-heading", "-e", d["pattern"]]
    if "glob" in d: cmd += ["--glob", d["glob"]]
    if d.get("-i"): cmd.append("-i")
    if d.get("output_mode") == "files_with_matches": cmd.append("-l")
    else: cmd.append("-n")
    cmd.append(d["path"])
    return subprocess.run(cmd, cwd=arvore, capture_output=True, text=True)
chamadas = []
for f in arquivos:
    texto = f.read_text(encoding="utf-8")
    nome = str(f.relative_to(raiz))
    if f.parent.name == "agents" and re.search(r"^```(bash|sh)\b", texto, re.M):
        falhas.append(f"{nome}: bloco de shell num agente sem Bash")
    for m in re.finditer(r"^\s*(?:grep|ls|cat|find) ", texto, re.M):
        falhas.append(f"{nome}: comando de shell de busca: {texto[m.start():texto.find(chr(10), m.start())].strip()}")
    for m in re.finditer(r"Grep (\{[^`\n]*?\})(?=\s*(?:#|`|$))", texto, re.M):
        try:
            d = json.loads(m.group(1))
        except ValueError as e:
            falhas.append(f"{nome}: JSON invalido: {m.group(1)} ({e})"); continue
        if set(d) - CHAVES: falhas.append(f"{nome}: chave fora da ferramenta: {sorted(set(d) - CHAVES)}")
        if "\\|" in d["pattern"]: falhas.append(f"{nome}: \\| literal no padrao {d['pattern']!r}")
        if d["path"].startswith("<"): continue
        r = rg(d)
        if r.returncode not in (0, 1): falhas.append(f"{nome}: rg rc {r.returncode} em {d}: {r.stderr.strip()}")
        chamadas.append((nome, d, r))
def achou(trecho_padrao, esperado, nao=None):
    for nome, d, r in chamadas:
        if trecho_padrao in d["pattern"] and nome.endswith(("cartografo-visual.md", "auditor-design.md")):
            linhas = [l for l in r.stdout.splitlines() if not (nao and nao in l)]
            return any(esperado in l for l in linhas), linhas
    return None, []
for trecho, esperado, nao, rotulo in [
    ("--[a-z]", "--cor-base", None, "tokens aninhados (glob recursivo)"),
    ("{3,8}", "#abc", None, "cor hex (alternancia)"),
    ("{3,8}", "rgb(1,2,3)", None, "cor rgb (alternancia)"),
    ("animate-", "animate-spin", "motion-reduce", "animacao sem motion-reduce, por linha"),
]:
    ok, linhas = achou(trecho, esperado, nao)
    if ok is None: falhas.append(f"{rotulo}: chamada nao encontrada nos agentes")
    elif not ok: falhas.append(f"{rotulo}: {esperado!r} nao achado em {linhas}")
    else: print(f"ok    {rotulo}")
ok, linhas = achou("animate-", "animate-pulse", "motion-reduce")
if ok: falhas.append("a animacao com motion-reduce na linha virou achado")
else: print("ok    animacao com motion-reduce fica de fora")
print(f"      {len(chamadas)} chamadas de Grep rodadas no rg")
for f in falhas: print("FALHA", f)
sys.exit(1 if falhas else 0)
PY
