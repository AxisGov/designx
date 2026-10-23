<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/banner-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/banner-light.svg">
  <img alt="designx — a camada de design do metodo Expx" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/banner-light.svg" width="100%">
</picture>

<p>
  <img alt="harness: Claude Code" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-claude.svg">
  <img alt="harness: OpenCode" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-opencode.svg">
  <img alt="18 boas praticas" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-18regras.svg">
  <img alt="acessibilidade WCAG AA" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-a11y.svg">
  <img alt="cartografia visual" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-cartografia.svg">
  <img alt="schema expx v1" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-schema.svg">
  <img alt="docs pt-BR" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-lang.svg">
  <img alt="licenca MIT" src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/badge-license.svg">
</p>

<p>
  <a href="https://bittencourtthulio.github.io/expxdev/#designx"><strong>📘 Documentacao do metodo</strong></a>
  &nbsp;·&nbsp;
  <a href="#as-18-boas-praticas">18 boas praticas</a>
  &nbsp;·&nbsp;
  <a href="#a-auditoria">Auditoria</a>
  &nbsp;·&nbsp;
  <a href="https://bittencourtthulio.github.io/expxdev/#ecossistema">O ecossistema</a>
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

**Camadas** (`legadox`, `stackx`, `memox`, `prodx`, `designx`) sozinhas nao fazem nada — elas modificam o comportamento da `sprintx` e da `runx`. A ausencia de qualquer irma nunca quebra o fluxo: insumo que nao existe vira aviso do que falta, nunca invencao.

Detalhes do ecossistema inteiro no [README do expxdev](https://github.com/bittencourtthulio/expxdev).

---

## O problema que resolve

Agentes de IA convergem para escolhas genericas — Inter em toda fonte, purple gradients, layouts previsiveis. Isso e o tipo de "colateral" que o metodo Expx existe para impedir. Mas as skills existentes (`sprintx`, `runx`) nao tem nocao de UI: elas planejam e executam sem considerar padrao visual.

`designx` resolve quatro coisas:

1. **Deteccao** — o projeto ja tem um design system? Onde? E confiavel?
2. **Cartografia** — se nao tem, o que o codigo existente ja establish? (tokens, componentes, padroes)
3. **Auditoria** — o que foi feito respeita o DS e as boas praticas de UI?
4. **Divida** — o que nao foi corrigido fica registrado e priorizado, nao acumula mudamente

---

## Como a camada se encaixa

<img src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/diagrama-fluxo.svg" alt="Diagrama: onde o designx toca sprintx e runx — F1/F3/F5/F6 no build, E1-E4 no run, com DESIGN-SYSTEM.md, RESUMO.md, AUDIT.md e DIVIDA.md no meio" width="100%">

A camada expoe quatro artefatos de estado: `DESIGN-SYSTEM.md` (o sistema), `RESUMO.md` (o contexto carregado por quem executa), `AUDIT.md` (o veredito + metrica de adocao de tokens) e `DIVIDA.md` (o registro vivo do que ficou para tras).

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
| `/designx-audit` | audita conformidade de design contra o DS (emite veredito + adocao de tokens + divida) |
| `/designx-cartography` | gera o DESIGN-SYSTEM.md via cartografia visual |
| `/designx-status` | mostra o estado do design system e violacoes |

---

## As 18 boas praticas

<img src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/diagrama-regras.svg" alt="Quadro das 18 boas praticas organizadas por severidade: bloqueio (B1-B5), alto (A1-A9, incluindo as regras de acessibilidade A6-A9) e medio (M1-M4)" width="100%">

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

### Acessibilidade (alto)

| # | Regra | Bug sem ela |
|---|---|---|
| A6 | Contraste WCAG AA — 4.5:1 texto, 3:1 grande | Texto ilegivel para baixa visao |
| A7 | Focus ring visivel, nunca `outline: none` sem substituto | Teclado navega as cegas |
| A8 | Alvo interativo >= 36px + nome acessivel (`aria-label`) | Clique impreciso; botao sem nome para screen reader |
| A9 | `prefers-reduced-motion` respeitado | Enfeite vira barreira vestibular |

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

<img src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/diagrama-ciclo.svg" alt="Diagrama do ciclo de vida do design system: ausente, cartografado, consistente, declarado e auditando — com saidas para o painel de violacoes e o registro de divida" width="100%">

A cartografia e leitura apenas — o agente nao inventa, nao sugere, nao corrige. Espelha o estado atual, incluindo os problemas.

### Tiers de token

Todo token encontrado e classificado em um de tres tiers — e o componente nunca fala com o valor bruto:

<img src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/diagrama-tokens.svg" alt="Diagrama dos tiers de token: global (raw), alias (semantico) e componente — com os padroes de drift de tier que a cartografia lista" width="100%">

---

## A auditoria

O agente `auditor-design` verifica conformidade com o DS e as 18 regras. Cada achado sai em tres partes — **observacao** (o que se ve), **problema** (o que esta quebrado e por que importa) e **fix** (a mudanca especifica) — e a auditoria produz dois artefatos:

<img src="https://raw.githubusercontent.com/bittencourtthulio/designx/main/.github/assets/diagrama-auditoria.svg" alt="Diagrama da auditoria: escopo passa pelo auditor-design, gera veredito com observacao, problema e fix, e alimenta AUDIT.md com adocao de tokens e DIVIDA.md com prioridade severidade vezes frequencia sobre esforco" width="100%">

### Adocao de tokens

`adocao_tokens` e a fracao de propriedades visuais usando tokens em vez de valor bruto (cor e espacamento). O numero absoluto importa menos que a **tendencia entre auditorias** — adocao caindo e drift crescendo.

### Registro de divida

Achados nao enderecados entram no `DIVIDA.md` (kind `design_debt`) com prioridade **severidade x frequencia / esforco**:

- **Quick wins** (esforco baixo, frequencia alta) entram na proxima sprint
- **Estruturais** viram task propria com `design_refs`
- **Write-offs** (baixo trafego + redesign planejado) ficam diferidos com justificativa

O registro e vivo: itens resolvidos sao marcados, nunca apagados.

### QA checklist

No E4 da runx, o veredito de design e independente do funcional — os dois precisam ser APROVADO. O checklist completo (`references/07-qa-checklist.md`) cobre: precisao visual, os cinco estados do componente (default/hover/focus/active/disabled), layout, conteudo, acessibilidade e teclado.

---

## Hooks e agentes

| Hook | Quando | Modo inicial | O que garante |
|---|---|---|---|
| `designx-cartografa` | antes de escrever | **bloqueio** | DS existe antes de prosseguir |
| `designx-audit` | apos escrever UI | aviso | Tokens e padroes sao seguidos |

| Agente | Quando | Ferramentas | Papel |
|---|---|---|---|
| `cartografo-visual` | primeira ativacao | leitura apenas | Analisa, classifica tiers e gera o DS |
| `auditor-design` | F5 sprintx, E4 runx | leitura apenas | Audita conformidade e alimenta DIVIDA.md |

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
auditado_em: 2026-09-07
veredito: aprovado
violacoes: 0
avisos: 2
adocao_tokens: 0.87
---
```

### `design_debt` — `docs/design-system/DIVIDA.md`

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_debt
criado_em: 2026-09-07
itens_abertos: 4
---
```

Cada item do registro carrega severidade, categoria, frequencia, esforco, prioridade calculada, status e evidencia (`arquivo:linha`).

Contrato completo em [`references/06-schema.md`](.claude/skills/designx/references/06-schema.md).

---

## O que designx NAO faz

| Nao faz | Por que |
|---|---|
| Nao cria UI | E camada de verificacao, nao de implementacao |
| Nao edita componentes | Quem implementa e o sprintx/runx |
| Nao escolhe o design system | Quem escolhe e o time |
| Nao corrige drift na cartografia | O DS e espelho; a correcao e do time |
| Nao impede trabalho sem DS | Sem DS = inerte (exceto cartografia) |
| Substitui auditoria de codigo | `sprintx-revisor-testes`, `runx-revisor-testes` e `qa` continuam existindo |
| Gera screenshots | E camada de metodo, nao de ferramenta visual |

---

## Estrutura do repositorio

```
.claude/
  skills/designx/
    SKILL.md                    identidade, integracao, 18 boas praticas
    references/                 7 documentos de referencia
      00-boas-praticas.md       as 18 regras com evidencia
      01-deteccao.md            como detectar o DS
      02-cartografia.md         como gerar o DS (tiers de token)
      03-auditoria.md           como auditar conformidade
      04-integracao-sprintx.md  pontos de integracao com sprintx
      05-integracao-runx.md     pontos de integracao com runx
      06-schema.md              kinds e campos novos (design_debt)
      07-qa-checklist.md        checklist de QA de design (runx E4)
    assets/
      tokens.css.exemplo        tokens de exemplo com os 3 tiers
  commands/designx*.md          comandos do Claude Code
  hooks/designx/                hooks da camada
  agents/                       cartografo-visual e auditor-design
.opencode/
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
