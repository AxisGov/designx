---
argument-hint: "[trabalho_id]"
description: "Audita conformidade de design contra o DS e boas praticas"
---

# /designx-audit

Auditoria de design para o trabalho atual ou especificado.

## Instrucoes

1. Se ha `<trabalho_id>`, audita ese trabalho. Se nao, audita todos os trabalhos com UI.
2. Verifique se `docs/design-system/DESIGN-SYSTEM.md` existe. Se nao, rode cartografia primeiro.
3. Rode o agente `auditor-design` com escopo nos arquivos de UI do trabalho.
4. Grave o resultado em `docs/design-system/AUDIT.md`.
5. Mostre o veredito e os achados por severidade.

## Formato de saida

```
## Design system audit — <trabalho_id>

### Bloqueios (N)
1. `arquivo:linha` — descricao → solucao

### Alto (N)
...

### Medio (N)
...

### Baixo (N)
...

Veredito: APROVADO | REPROVADO
```
