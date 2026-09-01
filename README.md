<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/banner-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/banner-light.svg">
  <img alt="designx — a camada de design do metodo Expx" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/banner-light.svg" width="100%">
</picture>

<p>
  <img alt="harness: Claude Code" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-claude.svg">
  <img alt="harness: OpenCode" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-opencode.svg">
  <img alt="14 boas praticas" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-14regras.svg">
  <img alt="cartografia visual" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-cartografia.svg">
  <img alt="schema expx v1" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-schema.svg">
  <img alt="docs pt-BR" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-lang.svg">
  <img alt="licenca MIT" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-license.svg">
</p>

<p>
  <a href="https://bittencourtthulio.github.io/expxdev/#designx"><strong>📘 Documentacao do metodo</strong></a>
  &nbsp;·&nbsp;
  <a href="https://bittencourtthulio.github.io/expxdev/#designx">14 boas praticas</a>
  &nbsp;·&nbsp;
  <a href="https://bittencourtthulio.github.io/expxdev/#ecossistema">O ecossistema</a>
  &nbsp;·&nbsp;
  <a href="https://bittencourtthulio.github.io/expxdev/#schema">Contratos</a>
</p>

<strong>A camada de design do metodo Expx</strong> — detecta, cartografa e audita<br>
o design system para <a href="https://claude.com/claude-code">Claude Code</a> e <a href="https://opencode.ai">OpenCode</a>.

</div>

`designx` e uma **camada** — como `stackx`, `legadox`, `memox`. Sozinha nao faz nada. Ela modifica o comportamento de `sprintx` e `runx` quando o projeto tem UI — detectando, cartografando ou auditando o design system.

> **Se o projeto tem UI, tem design system.** Se nao tem declarado, a cartografia descobre. Se tem inconsistencia, a auditoria aponta. Em nenhum caso designx impede o trabalho — ele instrui, avisa e audita.

---

## O ecossistema Expx

O metodo Expx e um conjunto de skills que se compoem, instaladas e mantidas pelo CLI [`expxdev`](https://github.com/bittencourtthulio/expxdev).

| Peca | Papel | Relacao com a `designx` |
|---|---|---|
| **[expxdev](https://github.com/bittencourtthulio/expxdev)** | o CLI: instala, atualiza e diagnostica o ecossistema | e quem instala esta skill (`npx expxdev init`) |
| **[sprintx](https://github.com/bittencourtthulio/sprintx)** | **Build** — feature nova, F1…F6 | designx audita o plano na F5 e injeta contexto de UI na F1/F3/F6 |
| **[runx](https://github.com/bittencourtthulio/runx)** | **Run** — ocorrencia em producao, E1…E5 | designx consulta o DS na E1 e audita no E4 quando a ocorrencia e visual |
| **[legadox](https://github.com/bittencourtthulio/legadox)** | **camada** de codigo legado | — |
| **[stackx](https://github.com/bittencourtthulio/stackx)** | **camada** de convencoes do repositorio | stackx descobre convencoes de codigo; designx descobre convencoes visuais |
| **[mergex](https://github.com/bittencourtthulio/mergex)** | entrega: branch, commit, PR | — |
| **[memox](https://github.com/bittencourtthulio/MemoX)** | **camada** de memoria do projeto | — |
| **[prodx](https://github.com/bittencourtthulio/prodx)** | **camada** de produto | — |

**Camadas** (`legadox`, `stackx`, `memox`, `prodx`, `designx`) sozinhas nao fazem nada — elas modificam o comportamento da `sprintx` e da `runx`. A ausencia de qualquer irmã nunca quebra o fluxo: insumo que nao existe vira aviso do que falta, nunca invencao.

Detalhes do ecossistema inteiro no [README do expxdev](https://github.com/bittencourtthulio/expxdev).

---

## O problema que resolve

Agentes de IA convergem para escolhas genericas — Inter em toda fonte, purple gradients, layouts previsiveis. Isso e o tipo de "colateral" que o metodo Expx existe para impedir. Mas as skills existentes (`sprintx`, `runx`) nao tem nocao de UI: elas planejam e executam sem considerar padrao visual.

`designx` resolve tres coisas:

1. **Deteccao** — o projeto ja tem um design system? Onde? E confiavel?
2. **Cartografia** — se nao tem, o que o codigo existente ja establish? (tokens, componentes, padroes)
3. **Auditoria** — o que foi feito respeita o DS e as boas praticas de UI?

---

## Compatibilidade

`designx` funciona em **Claude Code** e em **OpenCode**, a partir da mesma fonte:

| | Claude Code | OpenCode |
|---|---|---|
| Skill (projeto) | `.claude/skills/designx/` | `.opencode/skills/designx/` |
| Comandos (projeto) | `.claude/commands/` | `.opencode/command/` |
| Skill (global) | `~/.claude/skills/designx/` | a mesma pasta, auto-carregada |
| Comandos (global) | `~/.claude/commands/` | `~/.config/opencode/command/` |
| Agentes | `.claude/agents/` | `.opencode/agent/` |
| Hooks | `.claude/settings.json` | `.opencode/plugin/designx.ts` |

Os dois harnesses descobrem a skill pelo `name` e `description` do frontmatter. Os hooks divergem de mecanismo: a logica mora uma vez em `.claude/hooks/designx/`; o plugin do OpenCode e uma ponte que a invoca e traduz a saida.

---

## Instalacao

### Pelo CLI do metodo (recomendado)

```bash
npx expxdev init --skills sprintx,runx,mergex,designx
```

### Pelo instalador do repositorio

```bash
git clone https://github.com/bittencourtthulio/designx.git
cd designx
./install.sh
```

| Flag | Efeito |
|---|---|
| *(nenhuma)* | instala nos dois harnesses, no projeto atual |
| `--global` | instala no diretorio global do usuario |
| `--claude` | so Claude Code |
| `--opencode` | so OpenCode |
| `--dry-run` | mostra o que faria, sem escrever nada |
| `--force` | sobrescreve instalacao existente |

### Instalacao manual

```bash
# Claude Code + OpenCode
cp -R .claude/skills/designx  ~/.claude/skills/
cp -R .claude/agents/         ~/.claude/agents/
cp -R .claude/hooks/designx/  ~/.claude/hooks/
```

---

## Uso

### O jeito mais simples

Descreva uma task que toca UI. **Nao e preciso dizer `designx`** — a skill dispara sozinha quando detecta que ha UI envolvida:

```
Quero criar uma tela de listagem de clientes com busca e filtro.
```

### Comandos

| Comando | O que faz |
|---|---|
| `/designx-audit` | audita conformidade de design contra o DS |
| `/designx-cartography` | gera o DESIGN-SYSTEM.md via cartografia visual |
| `/designx-status` | mostra o estado do design system e violacoes |

---

## As 14 boas praticas

Toda regra tem evidencia: o que acontece sem ela. Violar uma regra e violacao do metodo, nao preferencia de estilo.

### Estrutura (bloqueio)

| # | Regra | Bug sem ela |
|---|---|---|
| B1 | Paginacao adaptativa, nunca fixa | Tela pela metade em monitor grande |
| B2 | Detalhe em modal com secoes, nunca drawer | Usuario nao compara registros |
| B3 | Sub-navegacao em rail, nunca tabs | Perda de contexto em painel denso |
| B4 | Estado vazio dentro da tabela | Usuario preso sem saida |
| B5 | Acao destrutiva = AlertDialog com nome | Delete acidental sem confirmacao |

### Estilo (alto)

| # | Regra | Bug sem ela |
|---|---|---|
| A1 | hex hardcoded = proibido | Dark mode inutilizavel |
| A2 | Vocabulario fechado de cores | Coesao visual perdida |
| A3 | Fonte de display nao-generica | Toda tela parece a mesma |
| A4 | Solid accent com variante dark | Cor some em fundo escuro |
| A5 | Loading/error/empty cobertos | Tela quebrada sem feedback |

### Qualidade visual (medio)

| # | Regra | Bug sem ela |
|---|---|---|
| M1 | Tom estetico declarado por task | Mistura de estilos |
| M2 | Animacao com proposito | Ruido visual |
| M3 | Densidade: h-9, ~52px rows | Painel parece landing page |
| M4 | tabular-nums em numeros | Coluna baguncada |

---

## Cartografia visual

Se o projeto nao tem um design system declarado, `designx` roda uma **cartografia visual** — o agente `cartografo-visual` analisa o codigo existente e gera o `DESIGN-SYSTEM.md` candidato.

```
[1] Ausente
     ↓ cartografa
[2] Cartografiado (consistente: false)
     ↓ usuario corrige drift
[3] Cartografiado (consistente: true)
     ↓ ou: usuario substitui por DS declarado
[4] Declarado (origem: usuario)
```

A cartografia e leitura apenas — o agente nao inventa, nao sugere, nao corrige. Espelha o estado atual, incluindo os problemas.

---

## Hooks e agentes

| Hook | Quando | Modo inicial | O que garante |
|---|---|---|---|
| `designx-cartografa` | antes de escrever | **bloqueio** | DS existe antes de prosseguir |
| `designx-audit` | apos escrever UI | aviso | Tokens e padroes sao seguidos |

| Agente | Quando | Ferramentas | Papel |
|---|---|---|---|
| `cartografo-visual` | primeira ativacao | leitura apenas | Analisa e gera o DS |
| `auditor-design` | F5 sprintx, E4 runx | leitura apenas | Audita conformidade |

**Todo hook de metodo nasce em `aviso`**, exceto `designx-cartografa` — que nasce em `bloqueio` porque sem DS a auditoria nao tem referencia. A excecao e justificada: auditar sem referencia e violacao falsa.

---

## Contrato de estado

### `design_system` — `docs/design-system/DESIGN-SYSTEM.md`

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_system
nome: meu-projeto-design-system
versao: 0.1.0
origem: cartografia_automatica
auditavel: true
consistente: false
drift_detectado: 4
---
```

### `design_audit` — `docs/design-system/AUDIT.md`

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_audit
trabalho_id: exportacao-csv
auditado_em: 2026-08-30
veredito: aprovado
violacoes: 0
avisos: 2
---
```

Contrato completo em [`references/06-schema.md`](.claude/skills/designx/references/06-schema.md).

---

## O que designx NAO faz

| Nao faz | Por que |
|---|---|
| Nao cria UI | E camada de verificacao, nao de implementacao |
| Nao edita componentes | Quem implementa e o sprintx/runx |
| Nao escolhe o design system | Quem escolhe e o time |
| Nao impede trabalho sem DS | Sem DS = inerte (exceto cartografia) |
| Substitui auditoria de codigo | `revisor-testes` e `qa` continuam existindo |
| Gera screenshots | E camada de metodo, nao de ferramenta visual |

---

## Estrutura do repositorio

```
.claude/
  skills/designx/
    SKILL.md                    identidade, integracao, boas praticas
    references/                 6 documentos de referencia
    assets/
      tokens.css.exemplo        tokens de exemplo
  commands/designx*.md          comandos do Claude Code
  hooks/designx/                hooks da camada
  agents/                       cartografo-visual e auditor-design
.opencode/
  skills/designx/               a mesma skill
  command/designx*.md           comandos do OpenCode
  agent/                        os mesmos agentes
  plugin/designx.ts             ponte para hooks
.expx/hooks.json                modo de cada hook
install.sh                      instalador para Claude Code + OpenCode
```

---

## Licenca

MIT

---

<div align="center">
<sub>Parte do metodo <strong>Expx</strong> ·
<a href="https://github.com/bittencourtthulio/expxdev">expxdev</a> ·
<a href="https://github.com/bittencourtthulio/buildx">buildx</a> ·
<a href="https://github.com/bittencourtthulio/sprintx">sprintx</a> ·
<a href="https://github.com/bittencourtthulio/runx">runx</a> ·
<a href="https://github.com/bittencourtthulio/legadox">legadox</a> ·
<a href="https://github.com/bittencourtthulio/stackx">stackx</a> ·
<a href="https://github.com/bittencourtthulio/mergex">mergex</a> ·
designx</sub>
</div>
