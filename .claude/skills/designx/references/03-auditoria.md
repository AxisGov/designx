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

### 3. Deteccao rapida

```bash
# Bloqueios
grep -rn "PAGE_SIZE\s*=\s*[0-9]" src --include=*.tsx
grep -rln "components/ui/sheet" src --include=*.tsx
grep -rln "components/ui/tabs" src --include=*.tsx
grep -rnE "#[0-9a-fA-F]{6}\b" src --include=*.tsx
grep -rn "window.confirm" src --include=*.tsx

# Alto
grep -rn "h-\[[0-9]\+vh\]" src --include=*.tsx
grep -rn "text-primary\b" src --include=*.tsx | grep -v "dark:" | head -20

# Acessibilidade (A7, A9)
grep -rn "outline-none\|outline:\s*none" src --include=*.tsx | grep -v "ring"
grep -rln "animate-\|transition-" src --include=*.tsx | grep -vL "motion-reduce"

# Medio
grep -rn "onChange=.*setSearch" src --include=*.tsx
grep -rLn "tabular-nums" src --include=*.tsx
```

A6 (contraste) e A8 (alvo + aria-label) exigem inspecao dos pares de token e dos botoes so-icone — nao tem grep confiavel.

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
