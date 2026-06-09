---
name: feedback-compact-vs-clear
description: "Quando agente atinge ~95% context, usar /compact (preserva história resumida) — NUNCA /clear (apaga tudo)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Pra Impl/Rev/QA atingindo limite de context (>95%), sempre recomendar `/compact` ao Luccas, **nunca** `/clear`.

**Why:** `/clear` apaga a sessão inteira — perde memória conversacional do fluxo multi-agent (decisões tomadas, contexto de bugs descobertos, padrões cravados durante a fase). `/compact` mantém um resumo estruturado e continua a mesma sessão.

**How to apply:**
- Detecto pane com ≥95% context (red zone) → digo ao Luccas: "Pane X em N% — roda `/compact` lá"
- Nunca digo `/clear` exceto se Luccas explicitar
- Após `/compact`, agente continua mesma sessão com history resumida. Releitura de CLAUDE.md/docs/handoff/* recomendada como hint no próximo paste cross-pane
- Posso continuar mandando pastes via cmux normalmente pós-compact (não é nova sessão)

Aplicado primeira vez 2026-06-05 fim Sprint 6 / pré-Sprint 6.4-FIX (Impl 100% + Rev 100% + QA 424k).

Related: [[orchestrator-operation-mode]] [[feedback-session-size-watchdog]]
