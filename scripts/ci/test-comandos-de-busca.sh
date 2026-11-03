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
printf 'export const X = () => <div style={{ color: "#abc" }} />;\nexport const X2 = () => <div style={{ color: "rgb(1,2,3)" }} />;\nexport const X3 = () => <div style={{ color: "hsl(1,2%%,3%%)" }} />;\n' > "$d/src/a/b/Cor.tsx"
printf 'export const Y = () => <div className="animate-spin" />;\nexport const W = () => <div className="animate-pulse motion-reduce:animate-none" />;\nexport const V = () => <div className="transition-transform motion-reduce:animate-none" />;\nexport const U = () => <div className="animate-bounce motion-reduce:animate-ping" />;\nexport const S = () => <><i className="animate-wiggle" /><b className="motion-reduce:animate-none" /></>;\nexport const R = () => <><i className="transition-all" /><b className="motion-reduce:transition-none" /></>;\nexport const Q = () => <><i className={`animate-flash`} /><b className={'"'"'motion-reduce:animate-none'"'"'} /></>;\n' > "$d/src/a/b/Gira.tsx"
printf 'export const C = () => <a className="transition-colors hover:bg-muted transition-opacity" />;\n' >> "$d/src/a/b/Gira.tsx"
printf 'export const M = () => <div className="!transition-transform motion-reduce:transition-none" />;\nexport const O = () => <div className="!transition-shadow motion-reduce:!transition-none" />;\n' >> "$d/src/a/b/Gira.tsx"
printf 'export const K = () => <div className="hover:animate-wiggle motion-reduce:animate-none" />;\nexport const L = () => <div className="hover:animate-ping motion-reduce:hover:animate-none" />;\n' >> "$d/src/a/b/Gira.tsx"
printf 'export const I = () => <div className="!animate-wiggle motion-reduce:animate-none" />;\nexport const J = () => <div className="!animate-ping motion-reduce:!animate-none" />;\n' >> "$d/src/a/b/Gira.tsx"
printf 'export const H = () => <div className="hover:animate-spin group-hover:transition-transform" />;\nexport const N = () => <div className="transition hover:opacity-80" />;\n' >> "$d/src/a/b/Gira.tsx"
printf 'export const P = () => <p className="text-primary dark:bg-zinc-900" />;\nexport const Q = () => <p className="text-primary dark:text-primary-foreground" />;\n' > "$d/src/a/b/Texto.tsx"
# A9 em CSS (revisao do CodeAnt no expxdev#133): a busca so olhava .tsx
cat > "$d/src/a/b/movimento.css" <<'CSS'
.gira { animation: gira 1s infinite; }
.desliza {
  transition: transform .2s;
}
.parada { transition: none; }
:root { --transition-rapida: 150ms; }
.pisca { @apply animate-ping; }
.calma { @apply animate-pulse motion-reduce:animate-none; }
.segura { @apply animate-none transition-none; }
.forte2 { animation: forte2 1s !important; }
.forte3 { animation: forte3 1s !important; }
.coment { /* entrada */ animation: coment 1s; }
.prefixo { -webkit-animation: prefixo 1s infinite; }
.cor { transition: color .2s, opacity .2s; }
.longa { animation: longa 1s infinite; }
.longt { transition: transform .4s; }
.durt { transition: transform .5s; }
.inexistente { animation: inexistente 1s infinite; }
.mista { transition: color .2s, height .2s; }
.quebrada {
  @apply rounded
    animate-bounce;
}
.dupla { animation: none, dupla 1s infinite; }
.zero { animation: 0s, zero 1s infinite; }
@media (prefers-reduced-motion: reduce) {
  .desliza { transition: none; }
  .teimosa { animation: teimosa 1s infinite; }
  .forte2 { animation: none; }
  .forte3 { animation: none !important; }
  .longa { animation-name: none; }
  .longt { transition-property: none; }
  .durt { transition-duration: 0s; }
  .inexistente { animation-property: none; }
}
@media (prefers-reduced-motion: no-preference) {
  .entra { animation: entra .3s; }
}
CSS
cat > "$d/src/a/b/invertida.css" <<'CSS'
@media (prefers-reduced-motion: reduce) {
  .invertida { animation: none; }
}
.invertida { animation: invertida 1s infinite; }
CSS
printf 'export const Gira = styled.div`\n  animation: styled-gira 1s infinite;\n`;\nexport const Calma = styled.div`\n  animation: calma-gira 1s infinite;\n  @media (prefers-reduced-motion: reduce) {\n    animation: none;\n  }\n`;\nexport const Nome = styled.div`\n  animation: nome-gira 1s infinite;\n  @media (prefers-reduced-motion: reduce) {\n    animation-name: none;\n  }\n`;\nexport const Prop = styled.div`\n  transition: transform .6s;\n  @media (prefers-reduced-motion: reduce) {\n    transition-property: none;\n  }\n`;\nexport const Falso = styled.div`\n  animation: falso-gira 1s infinite;\n  @media (prefers-reduced-motion: reduce) {\n    animation-property: none;\n  }\n`;\n' > "$d/src/a/b/Estilo.tsx"
printf 'export const sx = { animationName: "objeto-gira", animationDuration: "1s" };\nexport const sx2 = { WebkitTransition: "height .2s" };\n' > "$d/src/a/b/Objeto.tsx"
printf '.sobe { transition: transform .3s; }\n.desce { transition: none; }\n' > "$d/src/a/b/movimento.scss"
printf 'export const T = () => <div className="motion-safe:animate-spin animate-none transition-none" />;\n' > "$d/src/a/b/Segura.tsx"
# .js e .jsx tambem tem JSX e CSS-in-JS (CodeAnt no expxdev#135 e no conselhos#247)
printf 'export const L = () => <div className="animate-legado" style={{ color: "#def" }} />;\n' > "$d/src/a/b/Legado.jsx"
printf 'export const A = () => <div className="animate-antigo" />;\nexport const G = styled.div`\n  animation: js-gira 1s infinite;\n`;\n' > "$d/src/a/b/Antigo.js"
# bordas e sombras definidas em CSS tambem entram na cartografia (CodeRabbit no designx#8)
printf '.cartao { box-shadow: 0 1px 2px var(--sombra); }\n' > "$d/src/a/b/cartao.css"
# reset dentro de outro seletor vale so para ele, nao e global (CodeRabbit no designx#8)
cat > "$d/src/a/b/escopo.css" <<'CSS'
.fora { animation: fora 1s infinite; }
.card {
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.01ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.01ms !important;
    }
  }
}
CSS
# chave entre aspas no CSS-in-JS (CodeAnt no conselhos#247)
cat > "$d/src/a/b/Aspas.tsx" <<'TSX'
export const a1 = { 'animation-name': 'aspas-gira', 'animation-duration': '1s' };
export const a2 = { "transition": "transform .7s" };
export const a3 = { 'WebkitTransition': 'width .3s' };
export const a4 = { '-webkit-transition': 'top .3s' };
export const a5 = { 'transition': 'none', color: 'red' };
export const a6 = { "transition": "opacity .2s" };
export const a7 = { transition: 'none', color: 'red' };
TSX
# T7 com a className em varias linhas: a busca por linha nao juntava blur-3xl e rounded-full
cat > "$d/src/a/b/Aurora.tsx" <<'TSX'
export const A = () => <div className={cn(
  "absolute -z-10 rounded-full",
  "blur-3xl bg-primary/30",
)} />;
export const B = () => <div className="blur-3xl opacity-50" />;
TSX
# reset global numa media query: protege o CSS e as classes de todo o projeto
d2="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d" "$d2"' EXIT
mkdir -p "$d2/src/estilos"
printf '.gira { animation: gira 1s infinite; }\n.forte { animation: forte 1s infinite !important; }\n.conta { animation: conta 1s; }\n.conta { animation-iteration-count: infinite !important; }\n@media (prefers-reduced-motion: reduce) {\n  *, *::before, *::after {\n    animation-duration: 0.01ms !important;\n    animation-iteration-count: 1 !important;\n    transition-duration: 0.01ms !important;\n  }\n}\n' > "$d2/src/estilos/global.css"
printf 'export const Y = () => <div className="animate-spin" />;\nexport const F = () => <div className="!animate-ping" />;\nexport const G = () => <div className="animate-bounce!" />;\n' > "$d2/src/estilos/Gira.tsx"
# reset sem animation-iteration-count: a animacao infinite de 0.01ms continua repetindo, e so a
# transicao fica protegida (CodeAnt no conselhos#247)
d3="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d" "$d2" "$d3"' EXIT
mkdir -p "$d3/src/estilos"
printf '.gira { animation: gira 1s infinite; }\n.desliza { transition: transform .2s; }\n.curta { animation: curta 1s infinite; }\n.zerada { animation: zerada 1s infinite; }\n@media (prefers-reduced-motion: reduce) {\n  *, *::before, *::after {\n    animation-duration: 0.01ms !important;\n    transition-duration: 0.01ms !important;\n  }\n  .curta { animation-duration: 0.01ms; }\n  .zerada { animation-duration: 0s; }\n}\n' > "$d3/src/estilos/global.css"
printf 'export const Y = () => <div className="animate-spin" />;\nexport const T = () => <div className="transition-transform" />;\n' > "$d3/src/estilos/Gira.tsx"
# reset global em objeto de estilo do CSS-in-JS (Global do emotion, makeStyles): chaves camelCase ou entre aspas
d4="$(cd "$(mktemp -d)" && pwd -P)"; trap 'rm -rf "$d" "$d2" "$d3" "$d4"' EXIT
mkdir -p "$d4/src/estilos"
cat > "$d4/src/estilos/Global.tsx" <<'TSX'
export const globais = {
  '@media (prefers-reduced-motion: reduce)': {
    '*, *::before, *::after': {
      animationDuration: '0.01ms !important',
      animationIterationCount: '1 !important',
      'transition-duration': '0.01ms !important',
    },
  },
};
TSX
printf 'export const Y = () => <div className="animate-spin" />;\nexport const sx = { animationName: "objeto-roda", animationDuration: "1s" };\n' > "$d4/src/estilos/Gira.tsx"
python3 - "$RAIZ" "$d" "$d2" "$d3" "$d4" <<'PY'
import json, re, shutil, subprocess, sys
from pathlib import Path
raiz, arvore, arvore_reset, arvore_sem_contagem, arvore_objeto = Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
arquivos = sorted((raiz / ".claude" / "agents").glob("*.md")) + sorted((raiz / ".opencode" / "agent").glob("*.md")) + [raiz / ".claude/skills/designx/SKILL.md"] + sorted((raiz / ".claude/skills/designx/references").glob("*.md"))
CHAVES = {"pattern", "path", "glob", "output_mode", "-n", "-i", "head_limit", "type", "multiline"}
falhas = []
def rg(d, onde=None):
    cmd = ["rg", "--no-heading", "-e", d["pattern"]]
    if "glob" in d: cmd += ["--glob", d["glob"]]
    if d.get("-i"): cmd.append("-i")
    if d.get("output_mode") == "files_with_matches": cmd.append("-l")
    else: cmd.append("-n")
    cmd.append(d["path"])
    return subprocess.run(cmd, cwd=onde or arvore, capture_output=True, text=True)
def include_do_grep(glob):
    """A traducao do SKILL.md: o --include do grep compara so o nome do arquivo, sem `**/` e sem chaves."""
    nome = glob.rsplit("/", 1)[-1]
    m = re.fullmatch(r"(.*)\{([^}]*)\}(.*)", nome)
    return [f"{m.group(1)}{alt}{m.group(3)}" for alt in m.group(2).split(",")] if m else [nome]
def grep_sem_rg(d):
    """A busca sem rg no PATH, como o SKILL.md manda montar."""
    cmd = ["grep", "-rlE" if d.get("output_mode") == "files_with_matches" else "-rnE", "-e", d["pattern"], d["path"]]
    if "glob" in d: cmd += [f"--include={g}" for g in include_do_grep(d["glob"])]
    if d.get("-i"): cmd.append("-i")
    return subprocess.run(cmd, cwd=arvore, capture_output=True, text=True)
def find_sem_include(d):
    """A rota sem --include: o filtro vai para o find, e o grep recebe so os arquivos."""
    cmd = ["find", d["path"], "-type", "f"]
    if "glob" in d:
        nomes = include_do_grep(d["glob"]); cmd.append("(")
        for i, g in enumerate(nomes): cmd += (["-o"] if i else []) + ["-name", g]
        cmd.append(")")
    cmd += ["-exec", "grep", "-lE" if d.get("output_mode") == "files_with_matches" else "-HnE"] + (["-i"] if d.get("-i") else []) + ["-e", d["pattern"], "{}", "+"]
    return subprocess.run(cmd, cwd=arvore, capture_output=True, text=True)
GNU = shutil.which("grep") and "GNU" in subprocess.run(["grep", "--version"], capture_output=True, text=True).stdout
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
    for m in re.finditer(r'"head_limit": [1-9]\d*[^\n]*(?:descart|\n\s*# (?:descarte|uma linha so sai))', texto):
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
def movimento(c, base):
    """A utility depois das variantes (`hover:animate-spin`); `animate-none`, `transition-none` e `motion-safe:` nao animam."""
    partes = c.lstrip("!").split(":")
    if any(v in ("motion-safe", "motion-reduce") for v in partes[:-1]): return False
    util = partes[-1].strip("!")
    # `transition-colors` e `transition-opacity` sao leves e podem ficar (00-boas-praticas, A9)
    if util in ("transition-colors", "transition-opacity"): return False
    return util != f"{base}-none" and (util.startswith(f"{base}-") or (base == "transition" and util == "transition"))
def importante(c):
    """No Tailwind, `!` antes (v3) ou depois (v4) da classe e o !important, que vence o reset global."""
    return c.startswith("!") or c.split(":")[-1].startswith("!") or c.endswith("!")
def protecao_de(c, base, classes):
    """`motion-reduce:` com as mesmas variantes e `-none`: `:hover` e mais especifico, e `hover:animate-spin` pede
    `motion-reduce:hover:animate-none`; com `!` na animacao, a protecao sem `!` perde (revisao do Codex)."""
    variantes = set(c.lstrip("!").split(":")[:-1])
    for p in classes:
        partes = p.lstrip("!").split(":")
        if partes[-1].strip("!") != f"{base}-none" or set(partes[:-1]) != variantes | {"motion-reduce"}: continue
        if importante(c) and not importante(p): continue
        return True
    return False
def protegida(linha):
    """A regra do agente: com animate-*, motion-reduce:animate-none; com transition-*, motion-reduce:transition-none."""
    # className por className: a protecao de outro elemento da mesma linha nao vale
    # aspas duplas ou simples, {"..."}, {`...`} e o class do HTML; classe montada por funcao
    # (cn(), clsx()) fica fora deste modelo e e julgada pelo auditor lendo o elemento
    grupos = [m.group(2) for m in re.finditer(r'\b(?:className|class)=\{?\s*(["\'`])(.*?)\1', linha)] or [linha]
    for grupo in grupos:
        classes = grupo.split()
        # a protecao e o `-none`: `motion-reduce:animate-*` qualquer pode repetir a animacao (revisao do Codex)
        for c in classes:
            for base in ("animate", "transition"):
                if movimento(c, base) and not protecao_de(c, base, classes): return False
    return True
BASE = {"animate": "animation", "transition": "transition"}
def sem_reset(c, b, reset):
    """A classe de movimento que o reset global nao cobre: a da base que ele nao protege, ou a com `!`."""
    return movimento(c, b) and (BASE[b] not in reset or importante(c))
def tsx_achados(saida, reset):
    """Sob o reset global, so a classe com `!` continua achado, e a animacao, se o reset nao a protege."""
    fora = []
    for l in saida.splitlines():
        if protegida(l): continue
        classes = " ".join(m.group(2) for m in re.finditer(r'\b(?:className|class)=\{?\s*(["\'`])(.*?)\1', l)).split()
        if reset and not any(sem_reset(c, b, reset) for c in classes for b in BASE): continue
        fora.append(l)
    return fora
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
    ("{3,8}", "hsl(1,2", None, "cor hsl (alternancia)"),
    ("animate-", "animate-spin", "motion-reduce", "animacao sem motion-reduce, por linha"),
    ("animate-", "transition-transform", "motion-reduce", "transicao protegida so na animacao continua achado"),
    ("animate-", "animate-bounce", "motion-reduce", "motion-reduce que repete a animacao continua achado"),
    ("animate-", "animate-wiggle", "motion-reduce", "protecao em outra className da linha nao vale (animacao)"),
    ("animate-", '<i className="transition-all"', "motion-reduce", "protecao em outra className da linha nao vale (transicao)"),
    ("animate-", "hover:animate-spin", "motion-reduce", "animacao com variante (hover:) continua achado"),
    ("animate-", "!animate-wiggle", "motion-reduce", "animacao com ! protegida sem ! continua achado"),
    ("animate-", "!transition-transform", "motion-reduce", "transicao com ! protegida sem ! continua achado (CodeAnt no designx#7)"),
    ("animate-", "hover:animate-wiggle motion-reduce:animate-none", "motion-reduce", "animacao com hover: protegida sem hover: continua achado"),
    ("animate-", "transition hover:opacity-80", "motion-reduce", "transition sem sufixo e achado"),
    ("animate-", "animate-flash", "motion-reduce", "protecao em outra className com crase ou aspa simples nao vale"),
    ("animate-", "animate-legado", "motion-reduce", "animacao em .jsx"),
    ("animate-", "animate-antigo", "motion-reduce", "animacao com JSX em .js"),
    ("{3,8}", "#def", None, "cor hex em .jsx"),
    ("shadow|border", "box-shadow", None, "sombra em CSS na cartografia"),
    ("text-primary", "dark:bg-zinc-900", "dark:text-", "accent sem dark:text- continua achado"),
]:
    ok, linhas = achou(trecho, esperado, nao)
    if ok is None: falhas.append(f"{rotulo}: chamada nao encontrada nos agentes")
    elif not ok: falhas.append(f"{rotulo}: {esperado!r} nao achado em {linhas}")
    else: print(f"ok    {rotulo}")
bruta = next((r.stdout for nome, d, r in chamadas if "animate-" in d["pattern"] and nome.endswith("auditor-design.md")), "")
if "animate-pulse" not in bruta or "dark:text-primary-foreground" not in next((r.stdout for nome, d, r in chamadas if "text-primary" in d["pattern"] and nome.endswith("auditor-design.md")), ""):
    falhas.append("a busca nao traz a linha protegida: o descarte nao foi testado")
ok, linhas = achou("animate-", "animate-pulse", "motion-reduce")
if ok: falhas.append("a animacao com motion-reduce na linha virou achado")
else: print("ok    animacao com motion-reduce fica de fora")
ok, linhas = achou("animate-", "hover:animate-ping motion-reduce:hover:animate-none", "motion-reduce")
if ok: falhas.append("animacao com hover: protegida com a mesma variante virou achado")
else: print("ok    animacao com hover: protegida com a mesma variante fica de fora")
ok, linhas = achou("animate-", "!transition-shadow motion-reduce:!transition-none", "motion-reduce")
if ok: falhas.append("transicao com ! protegida com ! virou achado")
else: print("ok    transicao com ! protegida com ! fica de fora")
ok, linhas = achou("animate-", "!animate-ping motion-reduce:!animate-none", "motion-reduce")
if ok: falhas.append("animacao com ! protegida com ! virou achado")
else: print("ok    animacao com ! protegida com ! fica de fora")
ok, linhas = achou("animate-", "transition-colors hover:bg-muted", "motion-reduce")
if ok: falhas.append("transition-colors, que e leve, virou achado")
elif "transition-colors hover:bg-muted" not in bruta: falhas.append("a busca nao traz o transition-colors; o descarte nao foi testado")
else: print("ok    transition-colors e transition-opacity ficam de fora")
ok, linhas = achou("animate-", "motion-safe:animate-spin", "motion-reduce")
if ok: falhas.append("motion-safe:, animate-none ou transition-none virou achado")
elif "motion-safe:animate-spin" not in bruta: falhas.append("a busca nao traz o motion-safe:; o descarte nao foi testado")
else: print("ok    motion-safe:, animate-none e transition-none ficam de fora")
ok, linhas = achou("text-primary", "dark:text-primary-foreground", "dark:text-")
if ok: falhas.append("accent com dark:text- virou achado")
else: print("ok    accent com dark:text- fica de fora")
# A9 em CSS: o modelo da regra do auditor, que le os blocos com Read
def pilha_em(texto, pos):
    """Os cabecalhos dos blocos abertos ate `pos`, do mais externo ao mais interno."""
    pilha, cab = [], ""
    for ch in texto[:pos]:
        if ch == "{": pilha.append(cab.strip()); cab = ""
        elif ch == "}": pilha and pilha.pop(); cab = ""
        elif ch == ";": cab = ""
        else: cab += ch
    return pilha
LEVES = {"color", "background-color", "border-color", "outline-color", "text-decoration-color", "fill", "stroke", "opacity",
         "backgroundColor", "borderColor", "outlineColor"}
def leve(valor):
    """Toda entrada da transicao anima so cor ou opacidade."""
    entradas = [e.strip().strip("'\"").split() for e in valor.replace("!important", "").split(",")]
    return all(e and e[0] in LEVES for e in entradas)
def desligada(valor):
    """Toda entrada da lista (separada por virgula) e `none` ou `0s`: `none, gira 1s` ainda anima."""
    return all(re.fullmatch(r"\s*(none|0m?s)\s*", e) for e in valor.split(","))
def duracao_de_reset(valor):
    """No maximo 0.01ms, com !important: `0.1ms` e `0.01s` sao mais longos."""
    m = re.fullmatch(r"\s*(\d*\.?\d+)(ms|s)\s*!important\s*", valor)
    return bool(m) and float(m.group(1)) * (1000 if m.group(2) == "s" else 1) <= 0.01
for valor, esperado in (("0.01ms !important", True), ("0s !important", True), ("0.1ms !important", False),
                        ("0.01s !important", False), ("0.01ms", False), ("0.01ms !important 2s", False)):
    if duracao_de_reset(valor) != esperado: falhas.append(f"modelo do reset: {valor!r} deu {not esperado}")
def curta(valor):
    """Duracao de no maximo 0.01ms, com ou sem !important."""
    m = re.fullmatch(r"\s*(\d*\.?\d+)(ms|s)\s*(?:!important)?\s*", valor)
    return bool(m) and float(m.group(1)) * (1000 if m.group(2) == "s" else 1) <= 0.01
def valor_de(bruto):
    """O valor ate o fim da declaracao; entre aspas, ate a aspa que fecha (`{ transition: 'none', color: 'red' }`)."""
    bruto = bruto.lstrip()
    return bruto[1:].split(bruto[0], 1)[0] if bruto[:1] in ("'", '"') else bruto
def seletor_de(cab):
    """No objeto de estilo, o seletor e a chave entre aspas que abre o bloco: `'*, *::before, *::after': {`."""
    m = re.search(r"([\"'`])([^\"'`]*)\1\s*:\s*$", cab)
    return m.group(2) if m else cab
def blocos_reduce(textos):
    """Seletor -> zeramentos dentro de @media (prefers-reduced-motion: reduce), com arquivo e posicao; `*` e o reset global."""
    zerados = {}
    for arquivo, texto in textos:
        # tambem no objeto de estilo do CSS-in-JS: animationDuration, 'animation-duration', valor entre aspas (revisao do Codex);
        # o valor fica num lookahead, porque no objeto ele vai ate o `}` e engoliria as chaves seguintes
        for m in re.finditer(r"(?:^|[{;,])\s*([\"']?)(animation(?:-duration|-name|-iteration-count|Duration|Name|IterationCount)?|transition(?:-duration|-property|Duration|Property)?)\1\s*:\s*(?=([^;}]*))", texto, re.M):
            pilha = pilha_em(texto, m.start(2))
            if not any(re.search(r"prefers-reduced-motion:\s*reduce", c) for c in pilha[:-1]): continue
            prop = re.sub(r"[A-Z]", lambda c: "-" + c.group(0).lower(), m.group(2))
            valor = valor_de(m.group(3))
            # dentro de outro seletor (`.card { @media ... { * {...} } }`), o `*` e `.card *`: o reset nao e global
            # (CodeRabbit no designx#8). No JS, so a chave entre aspas e seletor: `export const x = {` nao e
            fora = [seletor_de(c) for c in pilha[:-1] if not seletor_de(c).startswith("@")
                    and (seletor_de(c) != c or Path(str(arquivo)).suffix in (".css", ".scss"))]
            seletores = [" ".join(fora + [s.strip()]) for s in seletor_de(pilha[-1]).split(",")]
            base, imp = prop.split("-")[0], "!important" in valor
            # o longhand tambem desliga: animation-name: none, transition-property: none, duracao 0s (CodeRabbit no designx#7);
            # a duracao zera so se for zero: com 0.01ms a animacao infinite continua repetindo, e o 0.01ms so vale no reset
            # global, junto com animation-iteration-count: 1 (CodeAnt no conselhos#247)
            v = valor.replace("!important", "")
            if prop.endswith("-duration"): tipo = "zera" if desligada(v) else "curta" if curta(valor) else None
            elif prop.endswith("-iteration-count"): tipo = "uma" if re.fullmatch(r"\s*1\s*", v) else None
            else: tipo = "zera" if desligada(v) else None
            if tipo:
                for s in seletores: zerados.setdefault(s, []).append((base, imp, arquivo, m.start(2), tipo, prop))
    return zerados
def reset_de(zerados):
    """As bases que o reset global protege. `*` nao seleciona ::before e ::after: o reset tem de nomear os tres."""
    # sem !important, o `*` (especificidade zero) perde para qualquer classe
    def em_todos(cond): return all(any(z[1] and cond(z) for z in zerados.get(s, [])) for s in ("*", "*::before", "*::after"))
    bases = set()
    if em_todos(lambda z: z[0] == "transition"): bases.add("transition")
    # a animacao de 0.01ms ainda repete se for infinite: o reset precisa de animation-iteration-count: 1
    if em_todos(lambda z: z[0] == "animation" and z[4] == "zera") or (
            em_todos(lambda z: z[5] == "animation-duration") and em_todos(lambda z: z[4] == "uma")):
        bases.add("animation")
    return bases
def zera(entradas, prop, importante_, arquivo, pos):
    """O zeramento vence na cascata: mesma prioridade (!important se a original tem) e depois dela no mesmo arquivo,
    ou !important contra declaracao normal; o `none` antes da regra original perde para ela (revisao do Codex)."""
    return any(p == prop and tipo == "zera" and (imp or not importante_) and ((imp and not importante_) or (arq == arquivo and posicao > pos))
               for p, imp, arq, posicao, tipo, _ in entradas)
if reset_de(blocos_reduce([("x.css", "@media (prefers-reduced-motion: reduce) { * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; } }")])):
    falhas.append("modelo do reset: `*` sem ::before e ::after valeu como reset global")
def textos_de(onde):
    return {p: p.read_text(encoding="utf-8") for p in Path(onde).rglob("*") if p.suffix in (".css", ".scss", ".js", ".jsx", ".ts", ".tsx")}
def css_achados(r, onde):
    textos = textos_de(onde)
    zerados = blocos_reduce(textos.items())
    reset = reset_de(zerados)
    # a declaracao que zera, no bloco reduce, e a protecao, nao o achado
    proprias = {(arq, posicao) for entradas in zerados.values() for _, _, arq, posicao, _, _ in entradas}
    achados = []
    for l in r.stdout.splitlines():
        caminho, n, conteudo = l.split(":", 2)
        texto = textos[Path(onde) / caminho]
        pos = sum(len(x) + 1 for x in texto.split("\n")[:int(n) - 1])
        if "@apply" in conteudo:
            # o @apply inteiro, que pode continuar nas linhas seguintes
            ini = pos + conteudo.index("@apply")
            classes = re.split(r"[;}]", texto[ini + 6:], maxsplit=1)[0]
            if reset and not any(sem_reset(c, b, reset) for c in classes.split() for b in BASE): continue
            if not protegida(f'class="{" ".join(classes.split())}"'): achados.append(l)
            continue
        # tambem com prefixo de fornecedor: -webkit-animation, WebkitTransition (revisao do Codex)
        # e com a chave entre aspas no CSS-in-JS: 'animation-name':, "transition": (CodeAnt no conselhos#247)
        m = (re.search(r"(?:^|[^-\w])(?:-(?:webkit|moz|ms|o)-)?(animation|transition)(-[a-z-]+|[A-Z][A-Za-z]*)?[\"']?\s*:\s*([^;}]*)", conteudo)
             or re.search(r"(?:Webkit|Moz|ms)(Animation|Transition)([A-Za-z]*)[\"']?\s*:\s*([^;}]*)", conteudo))
        prop, suf, valor, ini_prop = m.group(1).lower(), (m.group(2) or "").lower(), valor_de(m.group(3)), m.start(1)
        if (Path(onde) / caminho, pos + ini_prop) in proprias: continue
        # transicao so de cor ou opacidade e leve e pode ficar (00-boas-praticas, A9)
        if prop == "transition" and suf in ("", "-property", "property") and leve(valor): continue
        if desligada(valor.replace("!important", "")): continue
        # o reset global perde para o !important proprio da declaracao
        if prop in reset and "!important" not in valor: continue
        pilha = pilha_em(texto, pos + ini_prop)
        # so `no-preference` dispensa: dentro de `reduce`, a animacao tem de ser zerada
        if any(re.search(r"prefers-reduced-motion:\s*no-preference", c) for c in pilha[:-1]): continue
        # CSS-in-JS (styled.div`...`): vale o @media reduce do mesmo template, depois da declaracao
        if not pilha:
            ini = texto.rfind("`", 0, pos + ini_prop); fim = texto.find("`", pos + ini_prop)
            resto = texto[pos + ini_prop:fim] if ini >= 0 and fim >= 0 else ""
            desliga = {"animation": r"animation(?:-name)?\s*:\s*none|animation-duration\s*:\s*0m?s",
                       "transition": r"transition(?:-property)?\s*:\s*none|transition-duration\s*:\s*0m?s"}[prop]
            if re.search(r"@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{[^}]*(?<![-\w])(?:" + desliga + r")\b", resto): continue
        seletores = [s.strip() for s in pilha[-1].split(",")] if pilha else []
        if seletores and all(zera(zerados.get(s, []), prop, "!important" in valor, Path(onde) / caminho, pos + ini_prop) for s in seletores): continue
        achados.append(l)
    return achados
css = [(nome, d, r) for nome, d, r in chamadas if "@apply" in d["pattern"] and nome.endswith("auditor-design.md")]
reduce = [(nome, d, r) for nome, d, r in chamadas if d["pattern"] == "prefers-reduced-motion" and nome.endswith("auditor-design.md")]
if not css or not reduce: falhas.append("auditor-design.md: falta a busca do A9 em CSS e a dos blocos prefers-reduced-motion")
else:
    nome, d, r = css[0]
    achados = css_achados(r, arvore)
    for esperado, rotulo in ((".gira", "animation sem bloco reduce"), ("animate-ping", "@apply de animacao sem motion-reduce"),
                             ("dupla 1s", "none seguido de outra animacao"), ("zero 1s", "0s seguido de outra animacao"),
                             ("teimosa 1s", "animacao nao zerada dentro do bloco reduce"), ("transform .3s", "transicao em .scss"),
                             ("coment 1s", "comentario antes da propriedade"), ("@apply rounded", "@apply em varias linhas"),
                             ("forte2 1s", "!important zerado sem !important no bloco reduce"),
                             ("invertida 1s", "regra original depois do bloco reduce"), ("styled-gira", "CSS-in-JS em .tsx"),
                             ("objeto-gira", "propriedade camelCase em objeto de estilo"),
                             ("inexistente 1s", "propriedade que nao existe (animation-property) nao desliga"),
                             ("falso-gira", "CSS-in-JS com propriedade que nao existe nao desliga"), ("prefixo 1s", "-webkit-animation"),
                             ("WebkitTransition", "WebkitTransition em objeto de estilo"), ("height .2s;", "transicao de cor junto com espacial"),
                             ("js-gira", "CSS-in-JS em .js"), ("aspas-gira", "chave entre aspas simples"),
                             ("transform .7s", "chave entre aspas duplas"), ("width .3s", "WebkitTransition entre aspas"),
                             ("top .3s", "-webkit-transition entre aspas"), ("fora 1s", "reset dentro de outro seletor nao e global")):
        if not any(esperado in l for l in achados): falhas.append(f"A9 em CSS: {rotulo} nao virou achado: {achados}")
        else: print(f"ok    A9 em CSS: {rotulo} e achado")
    for fora, rotulo in (("transform .2s", "transicao zerada no bloco reduce"), ("parada", "valor none"),
                         ("--transition-rapida", "propriedade customizada"), ("animate-pulse", "@apply com motion-reduce"),
                         ("entra .3s", "animacao dentro de no-preference"), ("animate-none transition-none", "@apply de animate-none e transition-none"),
                         (".desce", "valor none em .scss"), ("forte3 1s", "!important zerado com !important no bloco reduce"),
                         ("calma-gira", "CSS-in-JS com @media reduce no mesmo componente"), ("color .2s, opacity", "transicao so de cor e opacidade"),
                         ("longa 1s", "animation-name: none no bloco reduce"), ("transform .4s", "transition-property: none no bloco reduce"),
                         ("transform .5s", "transition-duration: 0s no bloco reduce"),
                         ("nome-gira", "CSS-in-JS com animation-name: none"), ("transform .6s", "CSS-in-JS com transition-property: none"),
                         ("'transition': 'none'", "chave entre aspas com valor none"), ('"opacity .2s"', "chave entre aspas so de opacidade"),
                         ("transition: 'none', color", "valor none entre aspas no objeto")):
        if any(fora in l for l in achados): falhas.append(f"A9 em CSS: {rotulo} virou achado")
        elif fora != "--transition-rapida" and fora not in r.stdout: falhas.append(f"A9 em CSS: a busca nao traz {fora!r}; o descarte nao foi testado")
        else: print(f"ok    A9 em CSS: {rotulo} fica de fora")
    if "prefers-reduced-motion: reduce" not in reduce[0][2].stdout: falhas.append("A9: a busca dos blocos nao acha o @media reduce")
    r2 = rg(d, arvore_reset)
    tsx = next((dd for nn, dd, rr in chamadas if "animate-" in dd["pattern"] and "@apply" not in dd["pattern"] and nn.endswith("auditor-design.md")), None)
    a2 = css_achados(r2, arvore_reset)
    if ".gira" not in r2.stdout or "animate-spin" not in rg(tsx, arvore_reset).stdout: falhas.append("A9: o caso do reset global nao foi exercitado")
    elif any(".gira" in l for l in a2): falhas.append("A9: o reset global nao protegeu o CSS")
    elif not any(".forte" in l for l in a2): falhas.append("A9: declaracao com !important passou pelo reset global, que perde para ela")
    else: print("ok    A9: o reset global protege o CSS, menos o que tem !important proprio")
    # as classes sob o reset: so a com `!` continua achado
    saida2 = rg(tsx, arvore_reset).stdout
    t2 = tsx_achados(saida2, reset=reset_de(blocos_reduce(textos_de(arvore_reset).items())))
    if not any("animate-spin" in l for l in tsx_achados(saida2, reset=set())): falhas.append("A9: sem o reset, animate-spin deveria ser achado")
    elif any("animate-spin" in l for l in t2): falhas.append("A9: o reset global nao protegeu a classe animate-spin")
    elif not (any("!animate-ping" in l for l in t2) and any("animate-bounce!" in l for l in t2)): falhas.append(f"A9: classe com ! passou pelo reset global: {t2}")
    else: print("ok    A9: o reset global protege as classes, menos as com !")
    if not any(".conta { animation-iteration-count" in l for l in a2): falhas.append("A9: animation-iteration-count: infinite !important passou pelo reset global")
    else: print("ok    A9: a contagem infinite com !important proprio vence o reset global")
    # sem animation-iteration-count: 1, o reset protege so a transicao
    r3 = rg(d, arvore_sem_contagem); a3 = css_achados(r3, arvore_sem_contagem)
    t3 = tsx_achados(rg(tsx, arvore_sem_contagem).stdout, reset=reset_de(blocos_reduce(textos_de(arvore_sem_contagem).items())))
    if not any(".gira" in l for l in a3): falhas.append("A9: reset sem animation-iteration-count protegeu a animacao infinite")
    elif any(".desliza" in l for l in a3): falhas.append("A9: reset sem animation-iteration-count deixou de proteger a transicao")
    elif not any("animate-spin" in l for l in t3): falhas.append("A9: reset sem animation-iteration-count protegeu a classe animate-spin")
    elif any("transition-transform" in l for l in t3): falhas.append("A9: reset sem animation-iteration-count deixou de proteger a classe de transicao")
    else: print("ok    A9: o reset sem animation-iteration-count protege so as transicoes")
    if not any(".curta { animation:" in l for l in a3): falhas.append("A9: animation-duration: 0.01ms por seletor zerou a animacao infinite")
    elif any(".zerada { animation:" in l for l in a3): falhas.append("A9: animation-duration: 0s por seletor nao zerou")
    else: print("ok    A9: por seletor, so a duracao zero zera")
    if any("0.01ms !important" in l or "iteration-count: 1" in l for l in a2): falhas.append(f"A9: a declaracao do reset global virou achado: {a2}")
    else: print("ok    A9: as declaracoes do reset global nao sao achado")
    # o reset em objeto de estilo protege igual ao do CSS
    r4 = rg(d, arvore_objeto); a4 = css_achados(r4, arvore_objeto)
    t4 = tsx_achados(rg(tsx, arvore_objeto).stdout, reset=reset_de(blocos_reduce(textos_de(arvore_objeto).items())))
    if "objeto-roda" not in r4.stdout or "animationDuration: '0.01ms" not in r4.stdout: falhas.append("A9: o caso do reset em objeto nao foi exercitado")
    elif a4 or t4: falhas.append(f"A9: o reset global em objeto de estilo nao protegeu: {a4 + t4}")
    else: print("ok    A9: o reset global em objeto de estilo protege, e as chaves dele nao sao achado")
# T7: a className inteira, que pode ocupar varias linhas
def classname_de(texto, pos):
    """O texto da className do elemento que contem `pos`."""
    ini = texto.rfind("className=", 0, pos)
    if ini < 0: return ""
    abre = texto[ini + 10]
    if abre == "{":
        nivel, i = 0, ini + 10
        while i < len(texto):
            nivel += {"{": 1, "}": -1}.get(texto[i], 0)
            if nivel == 0: return texto[ini:i + 1]
            i += 1
        return texto[ini:]
    return texto[ini:texto.find(abre, ini + 11) + 1]
t7 = next(((d, r) for nome, d, r in chamadas if "blur-3xl" in d["pattern"] and nome.endswith("auditor-design.md")), None)
if not t7: falhas.append("auditor-design.md: falta a busca da T7")
else:
    d, r = t7
    achados = []
    for l in r.stdout.splitlines():
        caminho, n, _ = l.split(":", 2)
        linhas_arq = (Path(arvore) / caminho).read_text(encoding="utf-8").split("\n")
        pos = sum(len(x) + 1 for x in linhas_arq[:int(n) - 1]) + linhas_arq[int(n) - 1].find("blur-3xl")
        if re.search(r"(?<![\w:-])rounded-full\b", classname_de("\n".join(linhas_arq), pos)): achados.append(l)
    if not any("bg-primary/30" in l for l in achados): falhas.append(f"T7: aurora com a className em varias linhas nao virou achado: {r.stdout!r}")
    else: print("ok    T7: className em varias linhas e achado")
    if any("opacity-50" in l for l in achados): falhas.append("T7: blur-3xl sem rounded-full virou achado")
    elif "opacity-50" not in r.stdout: falhas.append("T7: a busca nao traz o blur sem rounded-full; o descarte nao foi testado")
    else: print("ok    T7: blur-3xl sem rounded-full fica de fora")
# A rota sem rg: o grep que o SKILL.md manda montar acha o mesmo que o rg (revisao do CodeAnt no conselhos#244)
if GNU:
    divergentes = []
    for nome, d, r in chamadas:
        for rota, g in (("grep", grep_sem_rg(d)), ("find", find_sem_include(d))):
            if g.returncode not in (0, 1): divergentes.append(f"{nome}: {rota} rc {g.returncode} em {d['pattern']!r}: {g.stderr.strip()}"); continue
            if sorted(g.stdout.splitlines()) != sorted(r.stdout.splitlines()):
                divergentes.append(f"{nome}: {rota}: {d['pattern']!r} com {d.get('glob')!r}: rg {len(r.stdout.splitlines())} linhas, {rota} {len(g.stdout.splitlines())}")
    falhas.extend(f"rota sem rg: {x}" for x in divergentes)
    if not divergentes: print("ok    rota sem rg: o grep, com --include e pelo find, acha o mesmo que o rg em todas as chamadas")
else:
    print("pulo  rota sem rg: o grep do PATH nao e o GNU")
rota = (raiz / ".claude/skills/designx/SKILL.md").read_text(encoding="utf-8")
if 'grep -rnE -e "<pattern>"' not in rota: falhas.append("SKILL.md: a rota sem rg nao passa o padrao com -e (`--[a-z]` vira opcao)")
if "-rlE" not in rota: falhas.append("SKILL.md: a rota sem rg nao diz que files_with_matches vira -rlE")
if "-exec grep -HnE -e" not in rota: falhas.append("SKILL.md: falta a rota sem --include, pelo find")
if '--include="<glob>"' in rota: falhas.append("SKILL.md: a rota sem rg passa o glob inteiro ao --include, que so compara o nome do arquivo")
for f in sorted((raiz / ".opencode" / "agent").glob("*.md")):
    if ".claude/" in f.read_text(encoding="utf-8"):
        falhas.append(f"{f.relative_to(raiz)}: aponta .claude/, que a instalacao so OpenCode nao copia")
# A regra do descarte e a mesma no agente e na tabela que a sessao principal le (revisao do Codex)
for alvo in (".claude/agents/auditor-design.md", ".claude/skills/designx/SKILL.md", ".claude/skills/designx/references/03-auditoria.md"):
    texto_regra = (raiz / alvo).read_text(encoding="utf-8")
    for regra in ("motion-reduce:transition-none", "motion-reduce:animate-none", "`dark:text-`", "mesma className", "className inteira", "prefers-reduced-motion: reduce", "no-preference", "reset global", "`!important` proprio", "motion-safe:", "`animate-none`", "*::before", "motion-reduce:!transition-none", "animation-iteration-count: 1 !important", "`.jsx`", "`'animation-name':`"):
        if regra not in texto_regra: falhas.append(f"{alvo}: a regra de descarte nao cita {regra}")
    if re.search(r"descartando as linhas com `dark:`", texto_regra): falhas.append(f"{alvo}: descarta qualquer dark:")
    if re.search(r"descart[a-z]* (?:o|todo o) arquivo", texto_regra, re.I): falhas.append(f"{alvo}: descarta o arquivo inteiro")
skill = (raiz / ".claude/skills/designx/SKILL.md").read_text(encoding="utf-8")
if "rg" not in skill or "sessao principal" not in skill:
    falhas.append("SKILL.md: falta dizer como a sessao principal, sem Grep, faz a mesma busca com rg")
print(f"      {len(chamadas)} chamadas de Grep rodadas no rg")
for f in falhas: print("FALHA", f)
sys.exit(1 if falhas else 0)
PY
