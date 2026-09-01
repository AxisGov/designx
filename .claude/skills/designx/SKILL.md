---
name: designx
description: Camada de design para sprintx e runx. Detecta ou cartografa o design system do projeto, audita conformidade visual e integra boas praticas de UI no metodo Expx. Use quando o projeto tem UI, quando uma task toca componentes ou telas, ou quando voce precisa auditar consistencia visual.
license: MIT
compatibility: Requer uma skill de metodo instalada (sprintx ou runx). Funciona em qualquer stack visual — Tailwind, CSS modules, styled-components. Nao depende de framework especifico.
metadata:
  version: "1.0.0"
  part-of: "metodo-expx"
  body-language: "pt-BR"
  contract: "CONTRATO-designx-v1"
---

# designx

Camada de design para o metodo Expx. Modifica o comportamento de `sprintx` e `runx` quando o projeto tem UI — detectando, cartografando ou auditando o design system.

> **Se o projeto tem UI, tem design system.** Se nao tem declarado, a cartografia descobre. Se tem inconsistencia, a auditoria aponta. Em nenhum caso designx impede o trabalho — ele instrui, avisa e audita.

---

## 0. Primeiro: o que ja existe aqui?

Antes de escrever qualquer componente, verifique o estado do design system:

```bash
test -f docs/design-system/DESIGN-SYSTEM.md && echo "DS declarado"
test -f docs/design-system/RESUMO.md && echo "RESUMO pronto"
grep -rl "primary-glow\|--primary" src/ 2>/dev/null | head -3   # tokens presentes?
ls src/components/ui/ 2>/dev/null | head -10                    # primitivas?
```

- **Nenhum DS, designx ativo** → rode a cartografia primeiro: leia `references/02-cartografia.md`
- **DS cartografiado, `consistente: false`** → ha drift; resolva antes de auditar
- **DS declarado ou cartografiado `consistente: true`** → va para as boas praticas (secao 5)

Nao aplique o metodo pela metade. Tela com cores certas mas pagina fixa e drawer para detalhe nao e "quase conforme" — quebra as regras que o usuario mais percebe.

---

## 1. O que designx e (e o que nao e)

| designx faz | designx NAO faz |
|---|---|
| Detecta design system existente | Cria UI por voce |
| Cartografa o vocabulario visual do projeto | Edita componentes existentes |
| Audita conformidade contra o DS | Escolhe o design system |
| Integra boas praticas no sprintx/runx | Forca upgrade de versao do DS |
| Grava estado de audit para o painel | Substitui auditoria de codigo |
| Gera rastro de eventos de design | Gera screenshots ou mockups |

**Camada** — como `stackx`, `legadox`, `memox`. Sozinha nao faz nada. Modifica sprintx/runx quando ha UI.

---

## 2. Detecção

Designx procura um design system nesta ordem:

| Prioridade | Caminho | Confianca |
|---|---|---|
| 1 | `docs/design-system/DESIGN-SYSTEM.md` com frontmatter valido | alta |
| 2 | Skill de design system no lock do `.expx/` | alta |
| 3 | Nenhum dos acima | cartografia automatica |

**Regras:**
- Prioridade 1 ou 2 → usa o DS encontrado. Origem: `usuario` ou `skill_instalada`.
- Nenhum DS → dispara cartografia (references/02-cartografia.md). Origem: `cartografia_automatica`.
- Mais de um DS prioridade 1 → o mais recente vence. Conflito registrado no rastro.
- Designx ausente no projeto → nada muda. Nunca trava.

---

## 3. Integracao com sprintx

### F1 — Ingestao

1. Designx verifica se DESIGN-SYSTEM.md existe.
2. Se nao existe → dispara cartografia, grava o arquivo.
3. Le o DS e gera `RESUMO.md` em `docs/design-system/`:
   - Tokens disponiveis
   - Componentes prontos
   - Padroes de tela documentados
   - Tom estetico declarado
4. Sprintx carrega o RESUMO.md como contexto.

### F2 — Descoberta

Cada PROPOSTA verifica se o DS ja resolve. Instrucao: "antes de propor UI nova, consulte RESUMO.md."

### F3 — Plano

Tasks que tocam UI carregam campos novos:

```yaml
tasks:
  - id: T-01.01
    titulo: Listagem de clientes
    design_refs: [padrao-lista, componente-busca]
    tom_estetico: denso-operacional
```

### F5 — Auditoria

`auditor-design` roda como gate adicional. Se reprova, sprint nao avanca.

### F6 — Execucao

Implementador le RESUMO.md antes de escrever UI.

---

## 4. Integracao com runx

| Estagio | O que designx adiciona |
|---|---|
| E1 | Se `melhoria-ui/ux`, investigador consulta DS |
| E2 | Fix referencia padrao correto do DS |
| E3 | Implementador segue padrao do DS |
| E4 | QA inclui checklist de design |
| E5 | Relatorio menciona `violacao_design` |

---

## 5. As 14 boas praticas

Toda regra tem evidencia: o que acontece sem ela. Violar e violacao do metodo, nao preferencia de estilo.

### Regras de estrutura (bloqueio)

| # | Regra | Bug sem ela | Deteccao |
|---|---|---|---|
| B1 | Paginacao adaptativa, nunca fixa | Tela pela metade em monitor grande | `grep -rn "PAGE_SIZE" src` |
| B2 | Detalhe em modal com secoes, nunca drawer | Usuario nao consegue comparar registros | `grep -rn "Sheet" src` |
| B3 | Sub-navegacao em rail, nunca tabs | Perda de contexto em painel denso | `grep -rn "Tabs" src/pages` |
| B4 | Estado vazio dentro da tabela | Usuario fica preso sem saida | Inspecionar retorno antecipado |
| B5 | Acao destrutiva = AlertDialog com nome | Delete acidental sem confirmacao | `grep -rn "window.confirm" src` |

### Regras de estilo (alto)

| # | Regra | Bug sem ela | Deteccao |
|---|---|---|---|
| A1 | hex hardcoded = proibido | Dark mode inutilizavel | `grep -rnE "#[0-9a-fA-F]{6}" src` |
| A2 | Vocabulario fechado de cores de destaque | Coesao visual perdida | Verificar cores fora do token map |
| A3 | Fonte de display nao-generica | Toda tela parece a mesma | `grep -rn "font-family.*Inter" src` |
| A4 | Solid accent com variante dark | Cor desaparece em fundo escuro | `grep -rn "text-primary" src \| grep -v dark` |
| A5 | Loading/error/empty sempre cobertos | Tela quebrada sem feedback | Inspecionar componentes de lista |

### Regras de qualidade visual (medio)

| # | Regra | Bug sem ela | Deteccao |
|---|---|---|---|
| M1 | Um tom estetico declarado por task | Mistura de estilos na mesma feature | Campo `tom_estetico` ausente |
| M2 | Animacao com proposito, nao enfeite | Ruido visual que cansa | `grep -rn "transition" src` sem criterio |
| M3 | Densidade: controles h-9, rows ~52px | Painel parece landing page | Medir altura de componentes |
| M4 | Numeros comparaveis com tabular-nums | Coluna de valores baguncada | `grep -rn "tabular-nums" src` |

### Valores de `tom_estetico`

| Valor | Significado | Quando usar |
|---|---|---|
| `denso-operacional` | Painel SaaS, controles h-9, borders | CRMs, admin, analytics |
| `editorial` | Conteudo longo, tipografia expressiva | Blogs, docs, wikis |
| `minimalista-refinado` | Espaco generoso, poucos elementos | Landing pages, portfolios |
| `brutalista` | Raw, sem polimento, function over form | Ferramentas internas, hackathons |

---

## 6. Hooks

### `designx-cartografa` — primeira deteccao

```bash
# hooks/designx/designx-cartografa.sh
# Evento: PreToolUse
# Modo padrao: BLOQUEIO (excecao a regra universal)
# Falha aberta: se cartografo nao rodar, registra erro e sai com 0
```

Nasce em **bloqueio** porque sem DS a auditoria nao tem referencia — auditar sem referencia e violacao falsa.

### `designx-audit` — auditoria continua

```bash
# hooks/designx/designx-audit.sh
# Evento: PostToolUse em Write/Edit
# Modo padrao: AVISO
# Verifica: tokens hardcoded, componentes nao padronizados, padroes ignorados
```

### `designx-token-check` — verificacao pesada (sob demanda)

```bash
# hooks/designx/designx-token-check.sh
# Evento: PreToolUse em Bash (build)
# Ativado com --full ou sob demanda
```

---

## 7. Agentes

### `cartografo-visual`

```yaml
name: cartografo-visual
description: Analisa um projeto existente e extrai o vocabulario visual em uso
tools: Read, Glob, Grep
```

Leitura apenas. Nao inventa, nao sugere, nao corrige. Descreve o que existe com evidencia (arquivo:linha).

### `auditor-design`

```yaml
name: auditor-design
description: Audita conformidade contra o design system e boas praticas de UI
tools: Read, Glob, Grep
```

Leitura apenas. Classifica achados por severidade (bloqueio/alto/medio/baixo). Emite veredito: aprovado ou reprovado.

---

## 8. Contrato de estado

### `design_system` — `docs/design-system/DESIGN-SYSTEM.md`

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_system
nome: meu-projeto-design-system
versao: 0.1.0
origem: cartografia_automatica
stack: [react, tailwind]
auditavel: true
consistente: false
drift_detectado: 4
criado_em: 2026-08-30
atualizado_em: 2026-08-30
---
```

### `design_audit` — `docs/design-system/AUDIT.md`

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_audit
trabalho_id: exportacao-csv-relatorios
auditado_em: 2026-08-30
veredito: aprovado
violacoes: 0
avisos: 2
regra_mais_frequente: token_nao_utilizado
escopo: src/components/relatorios/
---
```

---

## 9. Violasoes no painel

| Violacao | Severidade | O que significa |
|---|---|---|
| `design_system_ausente` | aviso | Trabalho toca UI mas nao ha DS |
| `token_hardcoded` | alto | Cor/spacing hardcoded em vez de variavel |
| `componente_nao_padronizado` | alto | UI criada do zero quando DS tem componente |
| `padrao_ignorado` | medio | Tela sem seguir padrao do DS |
| `tom_estetico_inconsistente` | medio | Tom diferente do global |
| `design_refs_ausente` | baixo | Task toca UI sem declarar refs |

---

## 10. Ciclo de vida do DESIGN-SYSTEM.md

```
[1] Ausente
     ↓ cartografa
[2] Cartografiado (consistente: false)
     ↓ usuario corrige drift
[3] Cartografiado (consistente: true)
     ↓ ou: usuario substitui por DS declarado
[4] Declarado (origem: usuario)
     ↓ auditando
[5] Violacoes detectadas → painel mostra
```

---

## 11. O que nao fazer

| Nunca | Por que |
|---|---|
| Hex hardcoded em componente | Mata dark mode e variantes /10 |
| Drawer (Sheet) para detalhe de registro | Usuario nao compara registros |
| Tabs para sub-navegacao de pagina | Perde contexto em painel denso |
| Pagina fixa (PAGE_SIZE = 10) | Tela pela metade em monitor grande |
| Empty state como return antecipado | Esconde filtros, prende usuario |
| Animação sem proposito | Ruido visual que cansa |
| Fonte generica (Inter, Roboto) em titulo | Convergencia de IA, toda tela igual |
| Acao destrutiva sem AlertDialog | Delete acidental sem confirmacao |

---

## Estrutura do repositorio

```
.claude/
  skills/designx/
    SKILL.md                    este arquivo
    references/
      00-boas-praticas.md       as 14 regras com evidencia
      01-deteccao.md            como detectar o DS
      02-cartografia.md         como gerar o DS
      03-auditoria.md           como auditar conformidade
      04-integracao-sprintx.md  pontos de integracao com sprintx
      05-integracao-runx.md     pontos de integracao com runx
      06-schema.md              kinds e campos novos
    assets/
      tokens.css.exemplo        tokens de exemplo para cartografia
  commands/designx*.md          comandos do Claude Code
  hooks/designx/                hooks da camada
  agents/                       cartografo-visual e auditor-design
.opencode/
  skills/designx/               a mesma skill
  command/designx*.md           comandos do OpenCode
  agent/                        os mesmos agentes
  plugin/designx.ts             ponte para hooks
.expx/hooks.json                modo de cada hook
```

---

## Licenca

MIT
