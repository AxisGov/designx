---
argument-hint: "[--force]"
description: "Gera o DESIGN-SYSTEM.md via cartografia visual do projeto"
---

# /designx-cartography

Cartografia visual do projeto.

1. Verifique se `docs/design-system/DESIGN-SYSTEM.md` ja existe. Se sim e sem `--force`, avise e pare.
2. Rode o agente `cartografo-visual` com escopo no `src/`.
3. Gere o `DESIGN-SYSTEM.md` com frontmatter valido.
4. Marque `origem: cartografia_automatica`.
5. Se drift > 0, marque `consistente: false`.
6. Grave em `docs/design-system/DESIGN-SYSTEM.md`.
7. Gere `RESUMO.md` com tokens, componentes e padroes.
8. Registre `design_system_cartografado` no rastro.
