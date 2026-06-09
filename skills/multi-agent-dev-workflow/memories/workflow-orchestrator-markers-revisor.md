---
name: workflow-orchestrator-markers-revisor
description: Marcadores de fim de turno que eu (Revisor) emito e recebo via bistro-orch (orquestrador cmux semi-auto)
metadata: 
  node_type: memory
  type: project
  originSessionId: da91cfd6-e793-459a-9129-a6a6b013dbbe
---

A partir de 2026-05-22, o workflow multi-agente do BistroOps deixou de ser copy-paste manual via Luccas e passou a ser coordenado pelo pane `bistro-orch` (orquestrador) no workspace cmux `BISTRO OPS`. Eu (Revisor, pane `bistro-revisor`) preciso fechar cada turno com um marcador na ÚLTIMA LINHA do output pro orquestrador detectar fim de turno via `cmux read`.

## Topologia cmux

Workspace único: `BISTRO OPS`. 4 panes:
- `bistro-orch` — orquestrador (semi-auto, checkpoint humano em cada paste)
- `bistro-implementador` — código + planos
- `bistro-revisor` — EU
- `bistro-qa` — cobertura + integration

## Marcadores que EU emito (última linha, sozinho)

| Quando | Marcador |
|---|---|
| Plano OK, pode codar | `=== PARECER FECHADO === (APROVADO)` |
| Plano OK com nota | `=== PARECER FECHADO === (APROVADO C/ RESSALVA)` |
| Plano rejeitado, replan | `=== PARECER FECHADO === (REPLAN PEDIDO)` |
| Implementação validada, QA pode começar | `=== HEADS UP QA ===` |
| Implementação com problema antes do QA | `=== FIX PEDIDO ===` |
| OK final pós-QA, próxima fase | `=== FASE FECHADA ===` |
| QA achou bug, volta Implementador | `=== BUG ENCONTRADO PELO QA ===` |
| QA pode editar test file (cascata) | `=== QA TOQUE AUTORIZADO ===` |

## Marcadores que EU recebo (do orquestrador)

- `=== PLANO PROPOSTO ===` (do Implementador) — analisar e dar parecer
- `=== HANDOFF IMPLEMENTADOR → REVISOR ===` — validar implementação vs plano
- `=== HANDOFF QA → REVISOR ===` — veredito final pós-QA

## Modo semi-automático

Luccas aprova cada paste cross-pane via prompt do orquestrador (Y/n/edit). Eu não preciso me preocupar com isso — meu output sai daqui e o orch cuida do encaminhamento. Mas sem o marcador na última linha, o orch não detecta fim e o handoff trava.

## Logs

Cada handoff vira `.md` em `docs/handoff/sprint-N/bloco-X/fase-N/SEQ-from-to.md`. Quem cria é o orch, não eu. Mas se Luccas pedir post-mortem, é lá que tem trace completo.

**Why:** Luccas montou o orquestrador pra reduzir fricção de copy-paste manual sem perder checkpoint humano. Modo full-auto está PROIBIDO — semi-auto sempre. Os 3 agentes (incluindo eu) salvaram os marcadores na memory pra adoção persistente cross-sessão.

**How to apply:** Toda vez que eu fechar um parecer, HEADS UP QA, fix pedido, fase fechada, etc — última linha do output recebe o marcador da tabela acima, sozinho, sem prefixo/sufixo/formatação extra. Sem isso, o pipeline trava no `cmux read` do orch.

Relacionado: [[multi-agent-ipc-options]] (decisão original SUPERSEDED), [[feedback-revisor-handoff-qa.md]] (descritivo QA continua sendo entregue sempre).
