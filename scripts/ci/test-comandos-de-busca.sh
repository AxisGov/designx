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
printf 'export const Y = () => <div className="animate-spin" />;\nexport const W = () => <div className="animate-pulse motion-reduce:animate-none" />;\nexport const V = () => <div className="transition-transform motion-reduce:animate-none" />;\nexport const U = () => <div className="animate-bounce motion-reduce:animate-ping" />;\nexport const S = () => <><i className="animate-wiggle" /><b className="motion-reduce:animate-none" /></>;\nexport const R = () => <><i className="transition-colors" /><b className="motion-reduce:transition-none" /></>;\n' > "$d/src/a/b/Gira.tsx"
printf 'export const P = () => <p className="text-primary dark:bg-zinc-900" />;\nexport const Q = () => <p className="text-primary dark:text-primary-foreground" />;\n' > "$d/src/a/b/Texto.tsx"
python3 - "$RAIZ" "$d" <<'PY'
import json, re, subprocess, sys
from pathlib import Path
raiz, arvore = Path(sys.argv[1]), sys.argv[2]
arquivos = sorted((raiz / ".claude" / "agents").glob("*.md")) + sorted((raiz / ".opencode" / "agent").glob("*.md")) + [raiz / ".claude/skills/designx/SKILL.md"] + sorted((raiz / ".claude/skills/designx/references").glob("*.md"))
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
    if re.search(r"grep commands", texto, re.I):
        falhas.append(f"{nome}: manda usar grep de shell")
    if f.parent.name in ("agents", "agent") and re.search(r"^```(bash|sh)\b", texto, re.M):
        falhas.append(f"{nome}: bloco de shell num agente sem Bash")
    pos = 0
    while (pos := texto.find("Grep {", pos)) >= 0:
        try:
            d0, fim = json.JSONDecoder().raw_decode(texto, pos + 5)
        except ValueError:
            falhas.append(f"{nome}: Grep com JSON invalido perto de: {texto[pos:pos + 80]!r}"); pos += 6; continue
        pos = fim
        if d0.get("output_mode") not in ("content", "files_with_matches", "count"):
            falhas.append(f"{nome}: Grep sem output_mode (o padrao lista so arquivos): {m.group(1)}")
        if "head_limit" not in d0:
            falhas.append(f"{nome}: Grep sem head_limit (o padrao corta em 250; 0 e sem limite): {m.group(1)}")
    if re.search(r"`Grep` de ", texto):
        falhas.append(f"{nome}: busca descrita em prosa (`Grep` de ...): use a entrada da ferramenta")
    for m in re.finditer(r"^\s*(?:grep|ls|cat|find|test -[fd]) ", texto, re.M):
        falhas.append(f"{nome}: comando de shell de busca: {texto[m.start():texto.find(chr(10), m.start())].strip()}")
    # o limite corta antes do descarte: os achados validos podiam sumir atras dos descartados
    for m in re.finditer(r'"head_limit": [1-9]\d*[^\n]*\n\s*# descarte', texto):
        falhas.append(f"{nome}: head_limit antes do descarte")
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
def protegida(linha):
    """A regra do agente: com animate-*, motion-reduce:animate-none; com transition-*, motion-reduce:transition-none."""
    # className por className: a protecao de outro elemento da mesma linha nao vale
    grupos = re.findall(r'className="([^"]*)"', linha) or [linha]
    for grupo in grupos:
        classes = grupo.split()
        anima = any(c.startswith("animate-") for c in classes)
        trans = any(c.startswith("transition-") for c in classes)
        # a protecao e o `-none`: `motion-reduce:animate-*` qualquer pode repetir a animacao (revisao do Codex)
        if anima and "motion-reduce:animate-none" not in classes: return False
        if trans and "motion-reduce:transition-none" not in classes: return False
    return True
def achou(trecho_padrao, esperado, nao=None):
    for nome, d, r in chamadas:
        if trecho_padrao in d["pattern"] and nome.endswith(("cartografo-visual.md", "auditor-design.md")):
            if nao == "motion-reduce":
                linhas = [l for l in r.stdout.splitlines() if not protegida(l)]
            else:
                linhas = [l for l in r.stdout.splitlines() if not (nao and nao in l)]
            return any(esperado in l for l in linhas), linhas
    return None, []
for trecho, esperado, nao, rotulo in [
    ("--[a-z]", "--cor-base", None, "tokens aninhados (glob recursivo)"),
    ("{3,8}", "#abc", None, "cor hex (alternancia)"),
    ("{3,8}", "rgb(1,2,3)", None, "cor rgb (alternancia)"),
    ("animate-", "animate-spin", "motion-reduce", "animacao sem motion-reduce, por linha"),
    ("animate-", "transition-transform", "motion-reduce", "transicao protegida so na animacao continua achado"),
    ("animate-", "animate-bounce", "motion-reduce", "motion-reduce que repete a animacao continua achado"),
    ("animate-", "animate-wiggle", "motion-reduce", "protecao em outra className da linha nao vale (animacao)"),
    ("transition-", "transition-colors", "motion-reduce", "protecao em outra className da linha nao vale (transicao)"),
    ("text-primary", "dark:bg-zinc-900", "dark:text-", "accent sem dark:text- continua achado"),
]:
    ok, linhas = achou(trecho, esperado, nao)
    if ok is None: falhas.append(f"{rotulo}: chamada nao encontrada nos agentes")
    elif not ok: falhas.append(f"{rotulo}: {esperado!r} nao achado em {linhas}")
    else: print(f"ok    {rotulo}")
ok, linhas = achou("animate-", "animate-pulse", "motion-reduce")
if ok: falhas.append("a animacao com motion-reduce na linha virou achado")
else: print("ok    animacao com motion-reduce fica de fora")
ok, linhas = achou("text-primary", "dark:text-primary-foreground", "dark:text-")
if ok: falhas.append("accent com dark:text- virou achado")
else: print("ok    accent com dark:text- fica de fora")
for f in sorted((raiz / ".opencode" / "agent").glob("*.md")):
    if ".claude/agents/" in f.read_text(encoding="utf-8"):
        falhas.append(f"{f.relative_to(raiz)}: aponta .claude/agents, que a instalacao so OpenCode nao copia")
# A regra do descarte e a mesma no agente e na tabela que a sessao principal le (revisao do Codex)
for alvo in (".claude/agents/auditor-design.md", ".claude/skills/designx/SKILL.md", ".claude/skills/designx/references/03-auditoria.md"):
    texto_regra = (raiz / alvo).read_text(encoding="utf-8")
    for regra in ("motion-reduce:transition-none", "motion-reduce:animate-none", "`dark:text-`", "mesma className"):
        if regra not in texto_regra: falhas.append(f"{alvo}: a regra de descarte nao cita {regra}")
    if re.search(r"descartando as linhas com `dark:`", texto_regra): falhas.append(f"{alvo}: descarta qualquer dark:")
skill = (raiz / ".claude/skills/designx/SKILL.md").read_text(encoding="utf-8")
if "rg" not in skill or "sessao principal" not in skill:
    falhas.append("SKILL.md: falta dizer como a sessao principal, sem Grep, faz a mesma busca com rg")
print(f"      {len(chamadas)} chamadas de Grep rodadas no rg")
for f in falhas: print("FALHA", f)
sys.exit(1 if falhas else 0)
PY
