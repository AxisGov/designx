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
Grep {"pattern": "PAGE_SIZE\\s*=\\s*[0-9]", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "components/ui/sheet", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "files_with_matches", "head_limit": 0}
Grep {"pattern": "components/ui/tabs", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "files_with_matches", "head_limit": 0}
Grep {"pattern": "#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\\b", "path": "src", "glob": "**/*.{css,scss,js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte o hex que e so o valor de uma propriedade customizada `--nome:` (a definicao do token), o que esta em comentario (`/* */` ou `//`, tambem de varias linhas: confira com Read), o seletor de id do CSS (`#add {`) e a referencia `url(#fade)`, que aponta para um elemento do SVG; a variavel do SCSS (`$nome:`) continua achado, porque e de compilacao e nao muda no dark mode
Grep {"pattern": "window.confirm", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}

# Alto
Grep {"pattern": "h-\\[[0-9]+vh\\]", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "text-primary\\b", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte as linhas que tambem casam com `dark:text-` (a variante dark da cor do texto); outro `dark:` na linha nao conta; das que sobram, bastam as 20 primeiras

# Acessibilidade (A7, A9)
Grep {"pattern": "outline-none|outline:\\s*none", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte as linhas que tambem casam com `focus(-visible)?:ring-([1-9]|\[)`, depois de conferir que o ring esta na mesma className do elemento com `outline-none`; a busca e por linha
Grep {"pattern": "animate-|\\btransition\\b", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# uma linha so sai se, havendo `animate-*`, tiver `motion-reduce:animate-none`, e, havendo `transition-*`, tiver `motion-reduce:transition-none`, na mesma className; as demais sao achado, mesmo que o arquivo tenha `motion-reduce` em outra. Antes de descartar, leia com Read a className inteira do elemento: ela pode ocupar mais de uma linha. A utility conta tambem depois de variante (`hover:animate-spin`), e a protecao tem de levar as mesmas variantes (`motion-reduce:hover:animate-none`), porque `:hover` e mais especifico; `transition` sem sufixo e transicao. Nao contam `animate-none`, `transition-none`, a classe com `motion-safe:`, que so roda sem a preferencia, e as transicoes leves `transition-colors` e `transition-opacity`. Se a animacao ou a transicao tem `!` (`!animate-spin`, `animate-spin!`, `!transition-transform`), a protecao sem `!` perde para ela: exija `motion-reduce:!animate-none` ou `motion-reduce:!transition-none` (ou com `!` no fim)
Grep {"pattern": "(^|[^-\\w])(-(webkit|moz|ms|o)-)?(animation|transition)(-[a-z-]+|[A-Z][A-Za-z]*)?[\"']?\\s*:|(Webkit|Moz|ms)(Animation|Transition)[A-Za-z]*[\"']?\\s*:|@apply", "path": "src", "glob": "**/*.{css,scss,js,jsx,ts,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "prefers-reduced-motion", "path": "src", "glob": "**/*.{css,scss,js,jsx,ts,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# em CSS, e no CSS-in-JS (`styled.div`, `css`) de `.js`, `.jsx`, `.ts` e `.tsx`, leia com Read cada bloco que a segunda busca achou. Nao conta a declaracao em que toda entrada da lista (separada por virgula) e `none` ou `0s`, nem a `transition` (ou `transition-property`) que so anima cor ou opacidade (`color`, `background-color`, `border-color`, `opacity` e afins), nem a que esta dentro de `@media (prefers-reduced-motion: no-preference)`. Dentro de `@media (prefers-reduced-motion: reduce)`, a animacao que o bloco nao zera continua achado. O `@apply` segue a regra da className acima, lido inteiro: a lista pode continuar nas linhas seguintes. As demais so saem se um bloco `@media (prefers-reduced-motion: reduce)` desliga o mesmo seletor (`animation: none`, `animation-name: none` ou `animation-duration: 0s`; `transition: none`, `transition-property: none` ou `transition-duration: 0s`; uma duracao que nao e zero, como `0.01ms`, nao desliga o seletor) e vence na cascata: depois da regra original no mesmo arquivo, ou com `!important`; com `!important` quando a declaracao original tem `!important`. No CSS-in-JS (tambem `animationName`, `transitionDuration` em objeto de estilo, e a chave entre aspas: `'animation-name':`, `"transition":`; o valor entre aspas vai ate a aspa que fecha), vale o `@media (prefers-reduced-motion: reduce)` do mesmo componente, depois da declaracao, que a zera; sem ele, so o reset global protege. Um reset global nesse bloco (`*, *::before, *::after`, fora de outro seletor: dentro de `.card` ele vale so para `.card`; `*` sozinho nao pega os pseudo-elementos; vale igual num objeto de estilo, com `animationDuration` ou `'animation-duration'`) protege as transicoes, no CSS e nas classes, com `transition-duration` de no maximo `0.01ms !important`, e as animacoes com `animation-duration` de no maximo `0.01ms !important` e `animation-iteration-count: 1 !important`: sem a contagem, a animacao `infinite` (como `animate-spin`, `animate-ping`, `animate-pulse` e `animate-bounce`) continua repetindo e e achado. O reset nao protege a declaracao com `!important` proprio (no Tailwind, a classe com `!` antes ou depois), que vence o reset e continua achado

# Tells de IA (T1, T2, T5, T6, T7, T9, T10)
Grep {"pattern": "gradient.*(purple|violet|indigo|fuchsia)", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "bg-clip-text|background-clip:\\s*text", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "border-l-[4-8]|border-r-[4-8]", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "min-h-screen|min-h-\\[100vh\\]", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "blur-3xl", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# T7 e a linha cuja className tambem tem `rounded-full`; leia com Read a className inteira do elemento, que pode ocupar mais de uma linha (`cn(`, `clsx(`, crase)
Grep {"pattern": "transition-all|hover:scale-105", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "acme|nexus|jane doe|john smith|lorem ipsum", "path": "src", "glob": "**/*.{js,jsx,tsx}", "-i": true, "output_mode": "content", "-n": true, "head_limit": 0}

# Medio
Grep {"pattern": "onChange=.*setSearch", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Glob {"pattern": "src/**/*.{js,jsx,tsx}"}
Grep {"pattern": "tabular-nums", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "files_with_matches", "head_limit": 0}
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
Grep {"pattern": "designx ·", "path": "src", "glob": "**/*.{css,js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 20}
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
