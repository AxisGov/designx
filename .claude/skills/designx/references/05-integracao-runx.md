# Integracao com runx

Pontos exatos onde designx modifica o comportamento da runx.

---

## E1 — Investigacao

Se `tipo_ocorrencia` e `melhoria-ui` ou `melhoria-ux`:

1. O investigador consulta o DS para verificar se o comportamento atual e uma violacao do padrao.
2. O achado entra na causa raiz como evidencia.
3. Campo `violacao_design: true` no `01-CAUSA-RAIZ.md`.

### Instrucao na skill

> Se o tipo e melhoria-ui ou melhoria-ux, o investigador deve consultar
> `docs/design-system/DESIGN-SYSTEM.md` e verificar se o comportamento
> atual viola algum padrao do DS. O resultado entra como evidencia na
> causa raiz.

## E2 — Plano

O fix de UI referencia o padrao correto do DS no campo `design_refs`:

```yaml
tasks:
  - id: T-01.01
    titulo: Corrigir modal de detalhe
    design_refs: [padrao-detalhe-modal]
```

### Instrucao na skill

> Tasks de UI devem declarar `design_refs` apontando para o padrao do DS
> que o fix deve seguir.

## E3 — Fix

O implementador segue o padrao do DS ao corrigir.

### Instrucao na skill

> Antes de corrigir componente de UI, leia `docs/design-system/RESUMO.md`.
> Siga o padrao declarado em `design_refs`. Se o DS nao tem componente
> para o caso, crie seguindo as boas praticas (references/00-boas-praticas.md).

## E4 — QA

O checklist de QA inclui itens de design quando a ocorrencia e visual.

### Checklist de design no QA

- [ ] Tokens utilizados, nao hex hardcoded
- [ ] Componente segue o padrao do DS
- [ ] Estado vazio/loading/error cobertos
- [ ] Acessibilidade preservada
- [ ] Tom estetico consistente

### Instrucao na skill

> Se o tipo e melhoria-ui ou melhoria-ux, adicione ao checklist de QA
> os itens de design acima. O veredito de design e independente do
> veredito funcional — os dois precisam ser APROVADO.

## E5 — Relatorio

O relatorio tecnico acrescenta campo:

```yaml
relatorio_tecnico:
  violacao_design: true
  padrao_violado: padrao-detalhe-modal
```

### Instrucao na skill

> Se a ocorrencia era violacao de design, mencione no relatorio tecnico:
> - `violacao_design: true`
> - `padrao_violado: <nome do padrao>`
> No relatorio de uso, explique em linguagem do cliente o que mudou
> na tela.
