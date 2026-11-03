# Boas praticas de design — as 18 regras

Toda regra tem evidencia: o que acontece sem ela. Violar uma regra e violacao do metodo, nao preferencia de estilo.

Derivadas do cruzamento entre `saas-panel-design-system`, `frontend-design` (Anthropic), `designer-skills` (WCAG/QA) e metodo Expx.

---

## Regras de estrutura (bloqueio)

### B1 — Paginacao adaptativa, nunca fixa

**Bug sem ela:** Tela pela metade em monitor grande. Uma tabela com `PAGE_SIZE = 10` em tela de 1440px mostra 10 linhas e metade da tela branca.

**Deteccao:**
```text
Grep {"pattern": "PAGE_SIZE\\s*=\\s*[0-9]", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
```

**Solucao:** `usePagination(items, { auto: true })` + `<ListCard ref availableHeight>`.

### B2 — Detalhe em modal com secoes, nunca drawer

**Bug sem ela:** Usuario nao consegue comparar registros. Drawer (Sheet) cobre a tela por cima, e nao mostra sidebar de secoes.

**Deteccao:**
```text
Grep {"pattern": "components/ui/sheet", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "files_with_matches", "head_limit": 0}
```

**Solucao:** `<DetailModal>` com sidebar de secoes. Sheet e legitimo apenas em paineis de configuracao e no sidebar principal.

### B3 — Sub-navegacao em rail, nunca tabs

**Bug sem ela:** Perda de contexto em painel denso. Tabs somem com a navegacao e o usuario perde onde esta.

**Deteccao:**
```text
Grep {"pattern": "components/ui/tabs", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "files_with_matches", "head_limit": 0}
```

**Solucao:** `<PageSubnav>` (left rail). Tabs sao legitimos apenas para sub-tabs dentro de um builder.

### B4 — Estado vazio dentro da tabela

**Bug sem ela:** Usuario fica preso sem saida. Um return antecipado esconde header, KPIs e filtros.

**Deteccao:** Inspecionar componentes de lista por `if (empty) return <EmptyState />`.

**Solucao:** Empty state dentro de `<TableBody>`:
```tsx
<TableRow>
  <TableCell colSpan={n} className="text-center py-8 text-muted-foreground">
    {search ? 'Nenhum item encontrado' : 'Nenhum item cadastrado ainda'}
  </TableCell>
</TableRow>
```

### B5 — Acao destrutiva = AlertDialog com nome

**Bug sem ela:** Delete acidental sem confirmacao. `window.confirm` nao nomeia o registro nem a consequencia.

**Deteccao:**
```text
Grep {"pattern": "window.confirm", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
```

**Solucao:** `<AlertDialog>` nomeando o registro e a consequencia.

---

## Regras de estilo (alto)

### A1 — hex hardcoded = proibido

**Bug sem ela:** Dark mode inutilizavel. Cor hardcoded nao tem variante dark e mata toda a paleta.

**Deteccao:**
```text
Grep {"pattern": "#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\\b", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
```

**Solucao:** Usar tokens CSS ou o vocabulario fechado de cores de destaque.

### A2 — Vocabulario fechado de cores de destaque

**Bug sem ela:** Coesao visual perdida. Cores avulsas geram paleta infinita que ninguem consegue manter.

**Cores permitidas:** `emerald`, `sky`, `violet`, `amber`, `rose`, `primary`.

Light usa solid 50/600/700; dark usa /10 + 300/400. Nunca hex novo.

### A3 — Fonte de display nao-generica

**Bug sem ela:** Toda tela parece a mesma. Agentes de IA convergem para Inter, Roboto, Arial — resultado e uniformidade sem identidade.

**Deteccao:**
```text
Grep {"pattern": "font-family.*Inter", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
```

**Solucao:** Escolher fonte com personalidade para titulos. Corpo pode ser generico. Este e o tell-zero; os outros nove padroes concretos de convergencia estao em `references/08-tells-ia.md`.

### A4 — Solid accent com variante dark

**Bug sem ela:** Cor desaparece em fundo escuro. Um verde com 31% de lightness some em fundo #1a1a2e.

**Deteccao:**
```text
Grep {"pattern": "text-primary\\b", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte as linhas que tambem casam com `dark:text-` (a variante dark da cor do texto); outro `dark:` na linha nao conta
```

**Solucao:** `dark:text-primary-glow` para accents solidos em dark mode.

### A5 — Loading/error/empty sempre cobertos

**Bug sem ela:** Tela quebrada sem feedback. Usuario clica e nada acontece.

**Solucao:** Toda lista tem: loading spinner, error com retry, empty message. Sem excecao.

### A6 — Contraste WCAG AA

**Bug sem ela:** Texto ilegivel para usuarios com baixa visao. `muted-foreground` sobre `muted` a 2:1 passa no olho do designer em monitor calibrado e falha em qualquer outro.

**Metrica:** 4.5:1 para texto normal, 3:1 para texto grande (18.66px bold ou 24px+). Aplica a pares foreground/background dos tokens, nos dois temas (light e dark).

**Deteccao:** Verificar os pares fg/bg dos tokens em `tokens.css` com calculadora de contraste (ex: script no build). Pares comuns que falham: `muted-foreground` sobre `muted`, accent 300 sobre fundo dark.

**Solucao:** Ajustar lightness do token ate passar; nunca escurecer ponto-a-ponto com hex.

### A7 — Focus ring visivel, nunca outline none sem substituto

**Bug sem ela:** Navegacao por teclado invisivel. Usuario que nao usa mouse "taba" pela pagina as cegas — foco some e a pagina parece travada.

**Deteccao:**
```text
Grep {"pattern": "outline-none|outline:\\s*none", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
# descarte as linhas que tambem casam com `focus(-visible)?:ring-([1-9]|\[)`, depois de conferir que o ring esta na mesma className do elemento com `outline-none`; a busca e por linha
```

**Solucao:** Todo interativo usa `focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2`. `outline-none` so com substituto `ring` junto.

### A8 — Alvo interativo minimo 36px com nome acessivel

**Bug sem ela:** Clique impreciso — botao de icone de 20px exige pontaria; e sem `aria-label`, screen reader anuncia "botao" sem dizer qual.

**Deteccao:** Inspecionar botoes so-icone: o elemento clicavel (nao o icone) tem `w-9 h-9` ou padding equivalente? Tem `aria-label` quando o texto esta ausente?

**Solucao:** Botao so-icone: `w-9 h-9` + `aria-label="Acao"`. Em tela touch, alvo minimo 44px. Menor que 24px e bloqueio de usabilidade, nao estilo.

### A9 — prefers-reduced-motion respeitado

**Bug sem ela:** Animacao causa desconforto vestibular (vertigem, nausea) em usuarios com `prefers-reduced-motion` ativo. Enfeite para alguns e barreira para outros.

**Deteccao:**
```text
Grep {"pattern": "animate-|\\btransition\\b", "path": "src", "glob": "**/*.{js,jsx,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "(^|[^-\\w])(-(webkit|moz|ms|o)-)?(animation|transition)(-[a-z-]+|[A-Z][A-Za-z]*)?[\"']?\\s*:|(Webkit|Moz|ms)(Animation|Transition)[A-Za-z]*[\"']?\\s*:|@apply", "path": "src", "glob": "**/*.{css,scss,js,jsx,ts,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
Grep {"pattern": "prefers-reduced-motion", "path": "src", "glob": "**/*.{css,scss,js,jsx,ts,tsx}", "output_mode": "content", "-n": true, "head_limit": 0}
```

O primeiro comando lista **todas as ocorrencias** nas classes, sem descartar um arquivo porque outra
animacao nele já usa `motion-reduce`. Revise cada classe retornada e confirme
se ela própria está protegida, também depois de variante (`hover:animate-spin` pede
`motion-reduce:hover:animate-none`);
`animate-none`, `transition-none`, `motion-safe:` e as transições só de cor ou
opacidade (`transition-colors`, `transition-opacity`) não contam. O segundo faz o mesmo com `animation` e `transition` no CSS e no CSS-in-JS
(também `animationName`, `-webkit-animation`, a chave entre aspas e afins, em `.js`,
`.jsx`, `.ts` e `.tsx`; vale o `@media` do mesmo componente), e o
terceiro acha os blocos `prefers-reduced-motion`: só `no-preference` dispensa, e
dentro de `reduce` a animação tem de ser zerada por regra que vence na cascata
(depois da original, ou com `!important`), e por seletor só a duração zero desliga. Um reset
global no bloco `reduce` (`*, *::before, *::after`) protege as transições com
`transition-duration` de no maximo `0.01ms !important`, e as animações só com
`animation-duration` assim e `animation-iteration-count: 1 !important`, porque a
animação `infinite` de 0.01ms continua repetindo. Ele não protege o que tem `!important` próprio, e a
proteção de uma animação ou transição com `!important` também precisa de `!important`
(`motion-reduce:!animate-none`, `motion-reduce:!transition-none`). A regra
completa de descarte esta em `references/03-auditoria.md`.

**Solucao:** Animacoes de entrada e deslocamento guardadas com `motion-reduce:transition-none motion-reduce:animate-none` (ou media query global). Transicoes de cor/opacidade leves podem ficar.

---

## Regras de qualidade visual (medio)

### M1 — Tom estetico declarado por task

**Bug sem ela:** Mistura de estilos na mesma feature. Uma tela brutalista ao lado de uma editorial.

**Solucao:** Campo `tom_estetico` no frontmatter da task: `denso-operacional`, `editorial`, `minimalista-refinado`, `brutalista`.

### M2 — Animacao com proposito, nao enfeite

**Bug sem ela:** Ruido visual que cansa. Transicoes em tudo nao tem destaque em nada.

**Solucao:** Animacao so em: entrada de pagina (stagger), hover de interacao, feedback de acao. Nunca em scroll, nunca em carregamento decorativo.

**Idiomas (ver references/07-qa-checklist.md, secao 3):** silent success em vez de toast comemorativo; optimistic update + Undo em vez de confirmacao; tooltip hover 800ms / focus 0ms; um efeito por hover; overshoot so em interacao fisica; anima so `transform` e `opacity`.

### M3 — Densidade: controles h-9, rows ~52px

**Bug sem ela:** Painel parece landing page. Controles grandes desperdicam espaco em ferramenta que o usuario usa o dia todo.

**Metricas:**
- Controles (button, input, select): h-9 (36px)
- Table head: h-10 (40px)
- Table row: ~52px
- Card: rounded-xl, border, p-5
- Icones: w-4 h-4 em botoes, w-5 h-5 standalone

### M4 — Numeros comparaveis com tabular-nums

**Bug sem ela:** Coluna de valores baguncada. Numeros de largura variavel fazem a coluna "pular" a cada linha.

**Solucao:**
```css
.tabular-nums { font-variant-numeric: tabular-nums; }
```

Valores ausentes renderizam `—`, nunca `R$ 0,00` ou `0%`.
