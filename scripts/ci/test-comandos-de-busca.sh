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
printf 'export const Gira = styled.div`\n  animation: styled-gira 1s infinite;\n`;\nexport const Calma = styled.div`\n  animation: calma-gira 1s infinite;\n  @media (prefers-reduced-motion: reduce) {\n    animation: none;\n  }\n`;\n' > "$d/src/a/b/Estilo.tsx"
printf 'export const sx = { animationName: "objeto-gira", animationDuration: "1s" };\nexport const sx2 = { WebkitTransition: "height .2s" };\n' > "$d/src/a/b/Objeto.tsx"
printf '.sobe { transition: transform .3s; }\n.desce { transition: none; }\n' > "$d/src/a/b/movimento.scss"
printf 'export const T = () => <div className="motion-safe:animate-spin animate-none transition-none" />;\n' > "$d/src/a/b/Segura.tsx"
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
printf '.gira { animation: gira 1s infinite; }\n.forte { animation: forte 1s infinite !important; }\n@media (prefers-reduced-motion: reduce) {\n  *, *::before, *::after {\n    animation-duration: 0.01ms !important;\n    transition-duration: 0.01ms !important;\n  }\n}\n' > "$d2/src/estilos/global.css"
printf 'export const Y = () => <div className="animate-spin" />;\nexport const F = () => <div className="!animate-ping" />;\nexport const G = () => <div className="animate-bounce!" />;\n' > "$d2/src/estilos/Gira.tsx"
python3 - "$RAIZ" "$d" "$d2" <<'PY'
import json, re, shutil, subprocess, sys
from pathlib import Path
raiz, arvore, arvore_reset = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
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
def tsx_achados(saida, reset):
    """Sob o reset global, so a classe com `!` continua achado."""
    fora = []
    for l in saida.splitlines():
        if protegida(l): continue
        classes = " ".join(m.group(2) for m in re.finditer(r'\b(?:className|class)=\{?\s*(["\'`])(.*?)\1', l)).split()
        if reset and not any(movimento(c, b) and importante(c) for c in classes for b in ("animate", "transition")): continue
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
def blocos_reduce(textos):
    """Seletor -> zeramentos dentro de @media (prefers-reduced-motion: reduce), com arquivo e posicao; `*` e o reset global."""
    zerados = {}
    for arquivo, texto in textos:
        for m in re.finditer(r"(?:^|[{;])\s*((?:animation|transition)(?:-duration)?)\s*:\s*([^;}]*)", texto, re.M):
            pilha = pilha_em(texto, m.start(1))
            if not any(re.search(r"prefers-reduced-motion:\s*reduce", c) for c in pilha[:-1]): continue
            prop, valor = m.group(1), m.group(2)
            seletores = [s.strip() for s in pilha[-1].split(",")]
            if prop.endswith("-duration") and duracao_de_reset(valor):
                for s in seletores: zerados.setdefault(s, []).append((prop.split("-")[0], True, arquivo, m.start(1)))
            elif not prop.endswith("-duration") and desligada(valor.replace("!important", "")):
                for s in seletores: zerados.setdefault(s, []).append((prop, "!important" in valor, arquivo, m.start(1)))
    return zerados
def reset_global(zerados):
    """`*` nao seleciona ::before e ::after: o reset tem de nomear os tres."""
    return all({"animation", "transition"} <= {z[0] for z in zerados.get(s, [])} for s in ("*", "*::before", "*::after"))
def zera(entradas, prop, importante_, arquivo, pos):
    """O zeramento vence na cascata: mesma prioridade (!important se a original tem) e depois dela no mesmo arquivo,
    ou !important contra declaracao normal; o `none` antes da regra original perde para ela (revisao do Codex)."""
    return any(p == prop and (imp or not importante_) and ((imp and not importante_) or (arq == arquivo and posicao > pos))
               for p, imp, arq, posicao in entradas)
if reset_global(blocos_reduce([("x.css", "@media (prefers-reduced-motion: reduce) { * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; } }")])):
    falhas.append("modelo do reset: `*` sem ::before e ::after valeu como reset global")
def css_achados(r, onde):
    textos = {p: p.read_text(encoding="utf-8") for p in Path(onde).rglob("*") if p.suffix in (".css", ".scss", ".ts", ".tsx")}
    zerados = blocos_reduce(textos.items())
    achados = []
    for l in r.stdout.splitlines():
        caminho, n, conteudo = l.split(":", 2)
        texto = textos[Path(onde) / caminho]
        pos = sum(len(x) + 1 for x in texto.split("\n")[:int(n) - 1])
        if "@apply" in conteudo:
            # o @apply inteiro, que pode continuar nas linhas seguintes
            ini = pos + conteudo.index("@apply")
            classes = re.split(r"[;}]", texto[ini + 6:], maxsplit=1)[0]
            if reset_global(zerados) and not any(importante(c) for c in classes.split()): continue
            if not protegida(f'class="{" ".join(classes.split())}"'): achados.append(l)
            continue
        # tambem com prefixo de fornecedor: -webkit-animation, WebkitTransition (revisao do Codex)
        m = (re.search(r"(?:^|[^-\w])(?:-(?:webkit|moz|ms|o)-)?(animation|transition)(-[a-z-]+|[A-Z][A-Za-z]*)?\s*:\s*([^;}]*)", conteudo)
             or re.search(r"(?:Webkit|Moz|ms)(Animation|Transition)([A-Za-z]*)\s*:\s*([^;}]*)", conteudo))
        prop, suf, valor, ini_prop = m.group(1).lower(), (m.group(2) or "").lower(), m.group(3), m.start(1)
        # transicao so de cor ou opacidade e leve e pode ficar (00-boas-praticas, A9)
        if prop == "transition" and suf in ("", "-property", "property") and leve(valor): continue
        if desligada(valor.replace("!important", "")): continue
        # o reset global perde para o !important proprio da declaracao
        if reset_global(zerados) and "!important" not in valor: continue
        pilha = pilha_em(texto, pos + ini_prop)
        # so `no-preference` dispensa: dentro de `reduce`, a animacao tem de ser zerada
        if any(re.search(r"prefers-reduced-motion:\s*no-preference", c) for c in pilha[:-1]): continue
        # CSS-in-JS (styled.div`...`): vale o @media reduce do mesmo template, depois da declaracao
        if not pilha:
            ini = texto.rfind("`", 0, pos + ini_prop); fim = texto.find("`", pos + ini_prop)
            resto = texto[pos + ini_prop:fim] if ini >= 0 and fim >= 0 else ""
            if re.search(r"@media\s*\(prefers-reduced-motion:\s*reduce\)\s*\{[^}]*\b" + prop + r"\s*:\s*none", resto): continue
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
                             ("objeto-gira", "propriedade camelCase em objeto de estilo"), ("prefixo 1s", "-webkit-animation"),
                             ("WebkitTransition", "WebkitTransition em objeto de estilo"), ("height .2s;", "transicao de cor junto com espacial")):
        if not any(esperado in l for l in achados): falhas.append(f"A9 em CSS: {rotulo} nao virou achado: {achados}")
        else: print(f"ok    A9 em CSS: {rotulo} e achado")
    for fora, rotulo in (("transform .2s", "transicao zerada no bloco reduce"), ("parada", "valor none"),
                         ("--transition-rapida", "propriedade customizada"), ("animate-pulse", "@apply com motion-reduce"),
                         ("entra .3s", "animacao dentro de no-preference"), ("animate-none transition-none", "@apply de animate-none e transition-none"),
                         (".desce", "valor none em .scss"), ("forte3 1s", "!important zerado com !important no bloco reduce"),
                         ("calma-gira", "CSS-in-JS com @media reduce no mesmo componente"), ("color .2s, opacity", "transicao so de cor e opacidade")):
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
    t2 = tsx_achados(saida2, reset=True)
    if not any("animate-spin" in l for l in tsx_achados(saida2, reset=False)): falhas.append("A9: sem o reset, animate-spin deveria ser achado")
    elif any("animate-spin" in l for l in t2): falhas.append("A9: o reset global nao protegeu a classe animate-spin")
    elif not (any("!animate-ping" in l for l in t2) and any("animate-bounce!" in l for l in t2)): falhas.append(f"A9: classe com ! passou pelo reset global: {t2}")
    else: print("ok    A9: o reset global protege as classes, menos as com !")
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
    for regra in ("motion-reduce:transition-none", "motion-reduce:animate-none", "`dark:text-`", "mesma className", "className inteira", "prefers-reduced-motion: reduce", "no-preference", "reset global", "`!important` proprio", "motion-safe:", "`animate-none`", "*::before", "motion-reduce:!transition-none"):
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
