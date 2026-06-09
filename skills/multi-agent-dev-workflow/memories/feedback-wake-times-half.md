---
name: feedback-wake-times-half
description: ScheduleWakeup do bistro-orch — cortar minhas estimativas pela metade. Default mais agressivo que o meu instinto
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Luccas reclamou que meus `ScheduleWakeup delaySeconds` ficavam muito longos.

**Regra**: nas minhas decisões de wake (sem evidência concreta de quanto tempo a task vai levar), **cortar pela metade o valor que eu pensaria intuitivamente**.

**Why**: empiricamente os agentes (Impl/Rev/QA) entregam mais rápido do que eu estimo. Wake longo demora pra eu detectar marcadores; Luccas tem que ficar dizendo "acabou la" pra eu acordar fora do ciclo. Wake curto = mais responsivo + cache da Anthropic (5min) cobre bem reaberturas frequentes.

**How to apply**:

| Tipo de fase | Wake antigo (meu instinto) | Wake novo (regra metade) |
|---|---|---|
| Fase pequena (schema, sqlc, fixes cirúrgicos) | 600s (10min) | **300s (5min)** |
| Fase média (handlers, repos, domain) | 900s (15min) | **450s (~7min)** |
| Fase grande (processor, integration tests) | 1200s (20min) | **600s (10min)** |
| Fase ÚLTIMA / pesada (wiring, PR + ADRs) | 1500s (25min) | **750s (~12min)** |
| Cascata QA pequena | 900s (15min) | **450s (~7min)** |
| Cascata QA grande | 1200s (20min) | **600s (10min)** |
| Rev parecer FASE FECHADA (parecer curto) | 270s | manter (cache 5min) |
| Permission prompt parado / standby | 1500s | **750s** |

**Exceção mantida**: 270s (~4.5min) pra esperar Rev parecer curto fechar fase — cabe dentro do cache 5min, não vale cortar mais.

Validação: se eu já cortei e ainda assim Luccas precisa avisar "acabou la" 2+ vezes no mesmo wake, corta de novo pela metade.

Data da feedback: 2026-06-01.
