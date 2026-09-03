# Schema designx — kinds e campos novos

Extensao ao contrato `expx-schema` v1 para a camada designx.

---

## expx_tool — valor novo

`sprintx` · `runx` · `buildx` · **`designx`**

`designx` e aceito apenas para os kinds `design_system` e `design_audit`.

## ferramenta no rastro — valor novo

Adicionar **`designx`** a lista existente.

## Eventos novos no rastro

| Evento | Quem grava |
|---|---|
| `design_system_cartografado` | hook `designx-cartografa` |
| `design_audit_executado` | agente `auditor-design` |
| `design_violacao_detectada` | hook `designx-audit` |

---

## Kind: `design_system`

Arquivo: `docs/design-system/DESIGN-SYSTEM.md`

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_system
nome: saas-panel-design-system
versao: 1.2.0
origem: usuario
stack: [react, tailwind, shadcn-ui]
tokens: docs/design-system/tokens.css
componentes: docs/design-system/componentes/
padroes: docs/design-system/padroes/
auditavel: true
consistente: true
drift_detectado: 0
criado_em: 2026-08-30
atualizado_em: 2026-08-30
---
```

### Campos

| Campo | Obrigatorio | Tipo | Descricao |
|---|---|---|---|
| `nome` | sim | string | Identificador do DS |
| `versao` | sim | string | Versao semantica |
| `origem` | sim | enum | `usuario` · `skill_instalada` · `cartografia_automatica` |
| `stack` | sim | string[] | Frameworks visuais |
| `tokens` | nao | string | Caminho relativo para tokens CSS |
| `componentes` | nao | string | Caminho relativo para componentes |
| `padroes` | nao | string | Caminho relativo para padroes de tela |
| `auditavel` | sim | boolean | Se true, designx audita contra este DS |
| `consistente` | sim | boolean | Se true, sem drift detectado |
| `drift_detectado` | sim | number | Inconsistencias encontradas |

---

## Kind: `design_audit`

Arquivo: `docs/design-system/AUDIT.md`

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

### Campos

| Campo | Obrigatorio | Tipo | Descricao |
|---|---|---|---|
| `trabalho_id` | nao | string/null | null para auditoria geral do projeto |
| `veredito` | sim | enum | `aprovado` · `reprovado` |
| `violacoes` | sim | number | Bloqueios encontrados |
| `avisos` | sim | number | Achados medio/baixo |
| `regra_mais_frequente` | sim | string | Regra mais violada |
| `escopo` | sim | string | Diretorios ou arquivos auditados |

---

## Campos novos opcionais em kinds existentes

> **Os dois formatos de plano.** Os campos de task abaixo vivem dentro de um item da lista
> `tasks:`, e essa lista existe nos dois kinds que a sprintx e a runx usam para gravar plano:
> `tasks` (formato de tres arquivos) e `plano` (formato condensado, uma sprint de fase unica
> num arquivo so). Como os campos sao da TASK e nao do arquivo, valem igual nos dois — nada
> muda para a designx alem de saber que o kind pode ser um ou outro.

| Campo | Kind | Tipo | Descricao |
|---|---|---|---|
| `design_refs` | `tasks` / `plano` | `string[]` | Componentes/padroes do DS referenciados |
| `tom_estetico` | `tasks` / `plano` | enum | Intencao visual da task |
| `design_deps` | `orquestrador` | `string[]` | Tasks que dependem de design system |
| `violacao_design` | `relatorio_tecnico` | boolean | Se a ocorrencia era violacao de design |
| `padrao_violado` | `relatorio_tecnico` | string | Qual padrao do DS foi violado |

### Valores de `tom_estetico`

| Valor | Significado |
|---|---|
| `denso-operacional` | Painel SaaS, controles h-9, borders |
| `editorial` | Conteudo longo, tipografia expressiva |
| `minimalista-refinado` | Espaco generoso, poucos elementos |
| `brutalista` | Raw, function over form |

---

## Violasoes novas no painel

| Violacao | Severidade | Descricao |
|---|---|---|
| `design_system_ausente` | aviso | Trabalho toca UI mas nao ha DS |
| `token_hardcoded` | alto | Cor/spacing hardcoded em vez de variavel |
| `componente_nao_padronizado` | alto | UI criada do zero quando DS tem componente |
| `padrao_ignorado` | medio | Tela sem seguir padrao do DS |
| `tom_estetico_inconsistente` | medio | Tom diferente do global |
| `design_refs_ausente` | baixo | Task toca UI sem declarar refs |
