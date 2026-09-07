---
argument-hint: "[trabalho_id]"
description: "Audita conformidade de design contra o DS e boas praticas"
---

# /designx-audit

Auditoria de design para o trabalho atual ou especificado.

1. Se ha `<trabalho_id>`, audita ese trabalho. Se nao, audita todos.
2. Verifique se `docs/design-system/DESIGN-SYSTEM.md` existe. Se nao, rode cartografia primeiro.
3. Rode o agente `auditor-design` com escopo nos arquivos de UI.
4. Grave o resultado em `docs/design-system/AUDIT.md` (incluindo `adocao_tokens`).
5. Mostre o veredito e os achados por severidade (Observacao → Problema → Fix).
6. Achados nao enderecados entram em `docs/design-system/DIVIDA.md`.
