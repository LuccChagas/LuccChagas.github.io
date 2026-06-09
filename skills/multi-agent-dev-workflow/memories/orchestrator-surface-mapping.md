---
name: orchestrator-surface-mapping
description: "Mapping fixo dos cmux surfaces do workspace BISTRO OPS — orch=2, Impl=4, Rev=1, QA=3 — checar SEMPRE antes paste cross-pane"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Mapping dos cmux surfaces no workspace `BISTRO OPS` (window:1, workspace:1):

- **pane:1 / surface:4** → `bistro-implementador` (Impl)
- **pane:2 / surface:1** → `bistro-revisor` (Rev)
- **pane:3 / surface:2** → `bistro-orch` (EU MESMO)
- **pane:4 / surface:3** → `bistro-qa` (QA)

**Why:** Em 2026-06-03 cometi erro grave mandando paste QA→Rev pra `surface:2` (achando que era Rev) — mas surface:2 = orch (eu mesmo). Mensagens "QA APROVOU COM RESSALVA Fase 6" + "fecha Fase 6?" foram enviadas pra mim mesmo. Por sorte Rev já tinha o parecer ready idle quando reenviei surface:1 correto, sem perda de tempo, mas em fase crítica isso poderia atrasar cronograma.

**How to apply:**
- ANTES de qualquer `cmux send --surface surface:X`, lembrar: surface:1=Rev / surface:3=QA / surface:4=Impl. NÃO confiar em memória short-term — confundi 2/3 porque ambos têm "1" no nome.
- Se inseguro, rodar `cmux tree --workspace workspace:1` pra confirmar antes de paste cross-pane.
- Erro de surface tem custo alto: paste pra surface errado vira ruído no chat (Luccas vê paste estranho) + agente alvo não recebe handoff + sleep loop dispara em vazio.
- Auto-forward standard events (Impl→Rev / Rev→QA / QA→Rev / Rev→Impl) usam destinos diferentes — atenção dobrada.

Related: [[orchestrator-operation-mode]] [[feedback-auto-forward-total]]
