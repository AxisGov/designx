# Integracao com sprintx

Pontos exatos onde designx modifica o comportamento da sprintx.

---

## F1 — Ingestao

1. Designx verifica se `docs/design-system/DESIGN-SYSTEM.md` existe.
2. Se nao existe → dispara cartografia (references/02-cartografia.md).
3. Le o DS e gera `docs/design-system/RESUMO.md` com:
   - Tokens disponiveis
   - Componentes prontos
   - Padroes de tela documentados
   - Tom estetico declarado
4. Sprintx carrega o RESUMO.md como contexto.

### Instrucao na skill

Adicionar ao SKILL.md da sprintx, na F1:

> Se designx esta ativo, verifique `docs/design-system/DESIGN-SYSTEM.md`.
> Se nao existe, rode a cartografia antes de prosseguir.
> Se existe, leia o `RESUMO.md` e carregue como contexto.

## F2 — Descoberta

Cada PROPOSTA de feature verifica se o DS ja resolve.

### Instrucao na skill

> Antes de propor UI nova, consulte RESUMO.md.
> Se o DS tem componente ou padrao que resolve, referencie-o em `design_refs`.

## F3 — Plano

Tasks que tocam UI carregam campos novos no frontmatter:

```yaml
tasks:
  - id: T-01.01
    titulo: Listagem de clientes
    design_refs: [padrao-lista, componente-busca]
    tom_estetico: denso-operacional
```

### Campos novos

| Campo | Tipo | Obrigatorio |
|---|---|---|
| `design_refs` | `string[]` | nao |
| `tom_estetico` | enum | nao |

### Campo no orquestrador

```yaml
orquestrador:
  design_system_detectado: <nome do DS>
  design_audit_necessario: true
  tom_estetico_global: denso-operacional
```

## F5 — Auditoria

`auditor-design` roda como gate adicional, junto com `auditor-plano`.

Se `design_audit_necessario: true` e o agente reprova, a sprint nao avanca.

### Instrucao na skill

> Se designx esta ativo e ha design_audit_necessario, rode o agente
> `auditor-design` apos o `auditor-plano`. Os dois vereditos precisam
> ser APROVADO para a F6 iniciar.

## F6 — Execucao

Implementador le RESUMO.md antes de escrever UI.

### Instrucao na skill

> Antes de criar componente ou tela, leia `docs/design-system/RESUMO.md`.
> Copie de assets quando possivel. Nao reescreva do zero.
> Siga o tom_estetico declarado na task.
