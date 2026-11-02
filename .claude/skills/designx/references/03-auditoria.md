# Auditoria de design

Como o `auditor-design` verifica conformidade.

---

## Quando roda

- sprintx F5 (auditoria do plano) — gate adicional
- runx E4 (QA) — quando `tipo_ocorrencia` e `melhoria-ui` ou `melhoria-ux`
- Sob demanda: `expx design-audit <trabalho_id>`

## Nao roda quando

- O trabalho nao toca UI
- Nao ha design system detectado nem cartografiado
- `design_audit_necessario: false` no orquestrador

## O que audita

### 1. Conformidade com o DS

- Tokens CSS usam variaveis, nao hex hardcoded
- Componentes reutilizam primitivas do DS
- Padroes de tela sao seguidos
- Tom estetico e consistente

### 2. As 18 boas praticas

Ver `references/00-boas-praticas.md` para a lista completa com deteccao.

### 2.5 Os 10 tells de IA

Ver `references/08-tells-ia.md`. Cada tell e um achado nomeado (`T3 — grid de 3 colunas iguais`). **Dois tells na mesma tela = REPROVADO**, mesmo sem violacao de bloqueio — dois padroes de convergencia juntos sao confirmacao de geracao sem revisao.

### 3. Deteccao rapida

```text
# Bloqueios
Grep {"pattern": "PAGE_SIZE\\s*=\\s*[0-9]", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "components/ui/sheet", "path": "src", "glob": "**/*.tsx", "output_mode": "files_with_matches", "head_limit": 0}
Grep {"pattern": "components/ui/tabs", "path": "src", "glob": "**/*.tsx", "output_mode": "files_with_matches", "head_limit": 0}
Grep {"pattern": "#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\\b", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "window.confirm", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}

# Alto
Grep {"pattern": "h-\\[[0-9]+vh\\]", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "text-primary\\b", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte as linhas que tambem casam com `dark:text-` (a variante dark da cor do texto); outro `dark:` na linha nao conta; das que sobram, bastam as 20 primeiras

# Acessibilidade (A7, A9)
Grep {"pattern": "outline-none|outline:\\s*none", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte as linhas que tambem casam com `focus(-visible)?:ring-([1-9]|\[)`, depois de conferir que o ring esta na mesma className do elemento com `outline-none`; a busca e por linha
Grep {"pattern": "animate-|transition-", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
# uma linha so sai se, havendo `animate-*`, tiver `motion-reduce:animate-none`, e, havendo `transition-*`, tiver `motion-reduce:transition-none`, na mesma className; as demais sao achado, mesmo que o arquivo tenha `motion-reduce` em outra

# Tells de IA (T1, T2, T5, T6, T7, T9, T10)
Grep {"pattern": "gradient.*(purple|violet|indigo|fuchsia)", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "bg-clip-text|background-clip:\\s*text", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "border-l-[4-8]|border-r-[4-8]", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "min-h-screen|min-h-\\[100vh\\]", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "blur-3xl.*rounded-full|rounded-full.*blur-3xl", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "transition-all|hover:scale-105", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "acme|nexus|jane doe|john smith|lorem ipsum", "path": "src", "glob": "**/*.tsx", "-i": true, "output_mode": "content", "-n": true, "head_limit": 0}

# Medio
Grep {"pattern": "onChange=.*setSearch", "path": "src", "glob": "**/*.tsx", "output_mode": "content", "-n": true, "head_limit": 0}
Glob {"pattern": "src/**/*.tsx"}
Grep {"pattern": "tabular-nums", "path": "src", "glob": "**/*.tsx", "output_mode": "files_with_matches", "head_limit": 0}
# os arquivos do Glob que o Grep nao lista sao o achado
```

T3 (grid-cols-3) e T4 (card-in-card) exigem inspecao. A6 (contraste) e A8 (alvo + aria-label) tambem — nao tem grep confiavel.

### 3.5 Stamp vs. tela

Tela gerada pelo metodo carimba a primeira linha do CSS (ou do arquivo de componente):

```css
/* designx · padrao: padrao-lista · tom: denso-operacional · refs: componente-busca · ds: nome@1.2.0 */
```

O auditor verifica tres coisas:

1. **Stamp existe?** Tela gerada sem stamp = `stamp_ausente` (medio).
2. **Stamp mente?** O stamp diz `padrao-lista` mas a tela e um form multi-etapa = `stamp_mentiroso` (alto). E o que pega o drift pos-edicao que volta ao default de IA.
3. **Variou?** Cruzar o LOG.md: mesmo par (padrao, tom) em 3+ entradas consecutivas = `variedade_repetida` (medio).

```text
Grep {"pattern": "designx ·", "path": "src", "glob": "**/*.{css,tsx}", "output_mode": "content", "-n": true, "head_limit": 20}
```

## Metrica de adocao de tokens

A auditoria calcula `adocao_tokens`: usos de token / (usos de token + valores brutos) nas categorias cor e espacamento do escopo. A tendencia entre auditorias importa mais que o valor absoluto — adocao caindo e drift crescendo.

## Classificacao

| Severidade | Significado | Acao |
|---|---|---|
| `bloqueio` | Violacao nao-negociavel | Sprint/runx nao avanca |
| `alto` | Padrao proibido pelo DS | Corrigir antes de entregar |
| `medio` | Inconsistencia | Resolver quando possivel |
| `baixo` | Melhoria sugestiva | Opcional |

## Formato do veredito

Cada achado segue **Observacao → Problema → Fix**: primeiro o que se ve (factual, neutro), depois o que esta quebrado e por que importa, depois a mudanca especifica. Achados sem as tres partes estao incompletos.

```markdown
## Design system audit — <escopo>

### Bloqueios (N)
1. `src/arquivo.tsx:34` — PAGE_SIZE fixo em 10.
   → usePagination(sorted, { auto: true })
   Por que importa: tela pela metade em monitor grande.

### Alto (N)
...

### Medio (N)
...

### Baixo (N)
...

### Limpo
[areas que passaram sem violacao]

Veredito: APROVADO | REPROVADO
Fix de maior impacto: <o que remove mais inconsistencia com menos trabalho>
```

## Achados que nao sao corrigidos na hora

Achados medio/baixo nao enderecados pelo trabalho em curso entram no registro de divida `docs/design-system/DIVIDA.md` (kind `design_debt`, ver `references/06-schema.md`), com prioridade **Severidade x Frequencia / Esforco**. A auditoria atualiza o registro — nao recria.

## Onde o resultado e gravado

`docs/design-system/AUDIT.md` com frontmatter:

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_audit
trabalho_id: <id ou null>
auditado_em: AAAA-MM-DD
veredito: aprovado | reprovado
violacoes: N
avisos: N
adocao_tokens: 0.87
regra_mais_frequente: <regra>
escopo: <diretorio ou arquivos>
---
```
