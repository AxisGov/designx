# QA checklist de design

Checklist materializado do E4 (runx) e do F5 (sprintx). O veredito de design e independente do veredito funcional — os dois precisam ser APROVADO.

QA contra a especificacao do DS, nao contra memoria. Teste com conteudo real, nao lorem ipsum.

---

## Quando usar

- runx E4 — quando `tipo_ocorrencia` e `melhoria-ui` ou `melhoria-ux`
- sprintx F5 — gate do auditor-design em tasks que tocam UI
- Sob demanda — revisao manual antes de entregar

## 1. Precisao visual

- [ ] Cores batem com tokens (nenhum hex hardcoded) — A1
- [ ] Tipografia segue a escala declarada no DS
- [ ] Espacamento e dimensoes seguem a densidade do tom (M3)
- [ ] Raio, sombra e opacidade conforme o DS
- [ ] Icones no tamanho e cor certos (w-4 em botao, w-5 standalone)

Deteccao:
```bash
grep -rnE "#[0-9a-fA-F]{6}\b" src --include=*.tsx
```

## 2. Estados do componente

Todo componente interativo renderiza os cinco estados — nao so o feliz:

- [ ] default
- [ ] hover
- [ ] focus (ring visivel — A7)
- [ ] active/pressed
- [ ] disabled

E os tres estados de dados em toda lista (A5):

- [ ] loading (spinner/skeleton)
- [ ] error (com retry)
- [ ] empty (dentro da tabela — B4)

## 3. Layout

- [ ] Alinhamento com o grid do DS
- [ ] Comportamento responsivo nos breakpoints declarados
- [ ] Conteudo reflow sem overflow/clipping inesperado
- [ ] Larguras min/max respeitadas
- [ ] Paginacao adaptativa, nao fixa (B1)

## 4. Conteudo

- [ ] Conteudo real cabe no layout (sem lorem ipsum em producao)
- [ ] Truncacao funciona onde especificado
- [ ] Numeros comparaveis com `tabular-nums` (M4)
- [ ] Valor ausente renderiza `—`, nunca `0,00`
- [ ] Mensagens de erro corretas e especificas

## 5. Acessibilidade

- [ ] Contraste WCAG AA nos pares fg/bg dos tokens, light e dark (A6)
- [ ] Focus indicators visiveis em todo interativo (A7)
- [ ] Alvos interativos >= 36px; botoes so-icone com `aria-label` (A8)
- [ ] Ordem de tabulacao logica
- [ ] `prefers-reduced-motion` respeitado (A9)
- [ ] Roles/ARIA corretos em componentes compostos (dialog, select, tabs)

## 6. Teclado

- [ ] Toda acao alcancavel por teclado
- [ ] `Esc` fecha modal/popover; foco volta ao trigger
- [ ] Foco preso dentro de modal (focus trap)
- [ ] Atalhos nao conflitam com navegador

## Saida

Cada item reprovado segue o formato Observacao → Problema → Fix (ver `references/03-auditoria.md`). O veredito final:

- **APROVADO** — zero bloqueios, avisos registrados
- **REPROVADO** — qualquer bloqueio (B1-B5) ou regra alto (A1-A9) violada
