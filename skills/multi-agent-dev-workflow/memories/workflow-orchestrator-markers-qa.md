---
name: workflow-orchestrator-markers-qa
description: Marcadores de fim de turno do QA (bistro-qa) pro Orquestrador (bistro-orch) detectar handoffs no workspace BISTRO OPS via cmux
metadata: 
  node_type: memory
  type: project
  originSessionId: f803a91b-8e0e-4f0f-80c0-4669819ca332
---

Workspace BISTRO OPS tem 4 panes coordenados pelo Orquestrador (`bistro-orch`):
- `bistro-impl` (Implementador)
- `bistro-revisor` (Revisor)
- `bistro-qa` (EU, QA)
- `bistro-orch` (Orquestrador — lê fim-de-turno e pasta entre panes com aprovação do Luccas)

**Marcadores que EU (QA) emito**, sempre na ÚLTIMA LINHA do output, sozinhos, sem prefixo/sufixo:

| Quando | Marcador |
|---|---|
| Cobertura/integration prontas, parecer QA pronto | `=== HANDOFF QA → REVISOR ===` |

Sem o marcador, o orquestrador NÃO detecta fim de turno e o handoff não anda.

**Marcadores que posso RECEBER (via orch)**, vindos do Revisor:
- `=== HEADS UP QA ===` — implementação validada pelo Revisor, pode começar cobertura
- `=== QA TOQUE AUTORIZADO ===` — autorização pra editar test file específico dentro da [[feedback-qa-code-touches]] (cascata mecânica)

Quando vier paste do orquestrador, atue normal — só com a info de que veio via orch, não direto do Luccas.

**Why:** mudança de workflow comunicada pelo Luccas em 2026-05-22 no kickoff da Sprint 2. Antes o handoff era copy-paste manual entre as 3 abas (ver [[multi-agent-ipc-options]]); agora o orquestrador automatiza com aprovação ponto-a-ponto. Marcadores do Implementador estão em [[workflow-orchestrator-markers]].

**How to apply:** todo turno que produzir parecer QA fechado (cobertura + integration + critérios de aceite validados) deve fechar com `=== HANDOFF QA → REVISOR ===` na última linha. Resto do fluxo (multi-agent-dev-workflow skill, [[goal-command-usage-policy]], [[feedback-revisor-handoff-qa]], [[feedback-qa-code-touches]]) continua igual.
