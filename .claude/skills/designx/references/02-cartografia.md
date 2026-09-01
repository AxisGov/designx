# Cartografia visual

Quando nenhum design system e encontrado, o agente `cartografo-visual` analisa o projeto e gera um DESIGN-SYSTEM.md candidato.

---

## Quando roda

- Na primeira ativação de designx quando nao ha DS
- Sob demanda: `expx design-cartography`
- Nunca roda se DESIGN-SYSTEM.md ja existe (a menos que `--force`)

## O que o cartografo analisa

| Area | O que procura | Comando |
|---|---|---|
| Tokens CSS | Variaveis `--*` em CSS/SCSS | `grep -rn "\-\-[a-z]" src/**/*.css` |
| Cores | hex, rgb, hsl em componentes | `grep -rnE "#[0-9a-fA-F]{3,8}\|rgb\|hsl" src/**/*.tsx` |
| Tipografia | font-family, pesos, tamanhos | `grep -rn "font-family\|font-size\|text-\[" src/` |
| Espacamento | padrao de gap/padding/margin | Analisar classes Tailwind |
| Componentes | primitivas existentes | Listar `src/components/ui/` |
| Padroes de tela | layouts recorrentes | Analisar imports e estrutura |
| Bordas vs sombras | elevacao predominante | `grep -rn "shadow\|border" src/**/*.tsx` |
| Dark mode | se existe, como | Verificar `dark:` classes |
| Framework visual | Tailwind, CSS modules, etc. | `package.json` + configs |

## Regras da cartografia

1. **Leitura apenas.** O agente nao escreve arquivos.
2. **Nada inventado.** Se nao encontrou, diz "nao encontrado".
3. **Drift e listado, nao corrigido.** O DS espelha o estado atual.
4. **Falha aberta.** Se nao conseguir rodar, designx fica inerte.

## O DESIGN-SYSTEM.md gerado

```yaml
---
expx_schema: 1
expx_tool: designx
kind: design_system
nome: <projeto>-design-system
versao: 0.1.0
origem: cartografia_automatica
stack: [react, tailwind]
auditavel: true
consistente: false
drift_detectado: 4
criado_em: AAAA-MM-DD
atualizado_em: AAAA-MM-DD
---
```

`consistente` e `true` quando `drift_detectado` e 0.

## Ciclo de vida

```
[1] Ausente
     ↓ cartografa
[2] Cartografiado (consistente: false)
     ↓ usuario corrige drift
[3] Cartografiado (consistente: true)
     ↓ ou: usuario substitui por DS declarado
[4] Declarado (origem: usuario)
```

## Como o hook aciona

O hook `designx-cartografa.sh` verifica:
1. DESIGN-SYSTEM.md ja existe? → exit 0
2. Ha UI no projeto? (`*.tsx`, `*.jsx`, `*.css`)
3. Se sim e modo bloqueio → impede e sugere `/designx-cartography`
4. Se modo aviso → registra e avisa

## Sob demanda

```bash
expx design-cartography            # gera DESIGN-SYSTEM.md
expx design-cartography --force    # regenera mesmo se ja existe
```
