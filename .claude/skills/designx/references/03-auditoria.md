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

### 2. As 14 boas praticas

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

# Medio
grep -rn "onChange=.*setSearch" src --include=*.tsx
grep -rLn "tabular-nums" src --include=*.tsx
```

## Classificacao

| Severidade | Significado | Acao |
|---|---|---|
| `bloqueio` | Violacao nao-negociavel | Sprint/runx nao avanca |
| `alto` | Padrao proibido pelo DS | Corrigir antes de entregar |
| `medio` | Inconsistencia | Resolver quando possivel |
| `baixo` | Melhoria sugestiva | Opcional |

## Formato do veredito

```markdown
## Design system audit — <escopo>

### Bloqueios (N)
1. `src/arquivo.tsx:34` — descricao
   → solucao
   Por que importa: impacto.

### Alto (N)
...

### Medio (N)
...

### Baixo (N)
...

Veredito: APROVADO | REPROVADO
```

Feche com o fix de maior impacto.

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
regra_mais_frequente: <regra>
escopo: <diretorio ou arquivos>
---
```
