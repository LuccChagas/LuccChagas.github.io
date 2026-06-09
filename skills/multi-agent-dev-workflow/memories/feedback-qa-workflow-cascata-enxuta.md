---
name: feedback-qa-workflow-cascata-enxuta
description: QA pode usar Workflow tool pra paralelizar cascata de checks INDEPENDENTES; recusar pra cascatas com interdependências sequenciais (schema cycle/migration)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

QA pode usar Workflow tool dentro do contexto dele pra paralelizar itens de checklist quando são totalmente independentes entre si. Luccas autorizou 2026-06-08 Sprint 6.5 Fase 5 (workflow `wdt0g9bqd` 6 checks paralelos: lint/ADR/G9-14/integration/greps/spec ref).

**Why:** Cascata enxuta com itens isolados (sem ordem de execução obrigatória) ganha 3x wall-clock paralelo (1m24s vs ~5min sequencial). Trade-off aceitável: ~140k tokens vs ~30-50k sequencial (3-5x token cost).

**How to apply:**
- **Autorizar QA → Workflow** quando: checklist tem 5+ itens independentes (cada item = comando isolado: build / lint / grep / test isolated / file existence) E nenhum item depende do output do outro
- **Recusar QA → Workflow** quando: cascata exige ordem (schema migration cycle DB up/down → tests → cleanup) OR um único item domina critical path (integration full ~3min sozinho não ganha com paralelo)
- **Eu (orch) NÃO uso Workflow** pra orquestrar fases do Impl — quebra fluxo multi-agent (Rev/QA precisam ver entrega completa pra validar). Workflow é ferramenta INTERNA do agente individual, não do orquestrador.
- **Avisar Luccas** se QA tentar Workflow em fase com interdependências (Fase 1 schema cycle, Fase 7 frontend testing canal único) — provável desperdício de tokens
- **Memory `feedback-orch-yes-while-away` autoriza** o Y/Sim em prompts de workflow do QA durante saídas

Casos cravados:
- 2026-06-08 Sprint 6.5 Fase 5 — Workflow OK (cascata enxuta 6 itens, ganho 3x wall-clock confirmado)
- Recusas anteriores (Sprint 6.4-FIX + início Sprint 6.5) — eram pra orchestrator paralelizar FASES do Impl, contexto diferente

Related: [[feedback-fases-sequenciais]] [[feedback-orch-yes-while-away]] [[multi-agent-ipc-options]]
