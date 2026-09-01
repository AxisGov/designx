# Deteccao do design system

Como designx descobre se o projeto tem um design system.

---

## Ordem de prioridade

| Prioridade | Caminho | Confianca |
|---|---|---|
| 1 | `docs/design-system/DESIGN-SYSTEM.md` com frontmatter valido | alta |
| 2 | Skill de design system no lock do `.expx/` | alta |
| 3 | Nenhum dos acima | cartografia automatica |

## Verificacao manual

```bash
# DS declarado
test -f docs/design-system/DESIGN-SYSTEM.md && echo "DS declarado"

# DS pronto (com RESUMO)
test -f docs/design-system/RESUMO.md && echo "RESUMO pronto"

# Tokens presentes
grep -rl "primary-glow\|--primary" src/ 2>/dev/null | head -3

# Primitivas presentes
ls src/components/ui/ 2>/dev/null | head -10

# Skill de DS no lock
cat .expx/expx-lock.json 2>/dev/null | jq '.skills | keys'
```

## O que o frontmatter valido precisa ter

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_system
nome: <string obrigatorio>
versao: <string obrigatorio>
origem: <usuario|skill_instalada|cartografia_automatica>
auditavel: <true|false>
consistente: <true|false>
---
```

Sem `expx_schema: 1` e `kind: design_system`, o arquivo e ignorado.

## Regras de prioridade

1. Prioridade 1 ou 2 encontrada → designx usa o DS.
2. Nenhum DS → dispara cartografia (references/02-cartografia.md).
3. Mais de um DS prioridade 1 → o mais recente (`atualizado_em`) vence.
4. Conflito registrado no rastro como `design_system_conflito`.
5. Designx ausente no projeto → nada muda. Nunca trava.

## Sem deteccao = sem trava

A ausencia de design system nunca impede trabalho. Se nao ha DS:
- Cartografia roda (se designx ativo)
- Se cartografia falhar → inerte, sem auditoria
- Sprintx/runx seguem normalmente
