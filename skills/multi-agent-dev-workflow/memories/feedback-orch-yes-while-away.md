---
name: feedback-orch-yes-while-away
description: Luccas autorizou orch dar Y/Sim em qualquer prompt pendente nos 3 panes Impl/Rev/QA durante saídinhas (2026-06-06 Sprint 6.5 kickoff)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Quando Luccas avisa que vai dar saidinha ("vou ter que dar uma saidinha", "vou sair", "fica aí cuidando"), autorizo orch a:

1. **Auto-respond Yes** em todo prompt pendente Y/n que ver scrollback nos panes (Impl=4, Rev=1, QA=3)
2. **Permission prompts** dos próprios agentes (tool execution, file edits, bash run dangerous, etc) → "1. Yes" or "2. Yes, don't ask again for [tool]" — escolha contextual
3. Continuar **auto-forward total** 4 eventos padrão + qualquer evento que precisaria Y/n (memory `feedback-auto-forward-total` expandida)

**Why:** Luccas confia no Rev/QA pra qualidade (eles bloqueiam ruim antes). Workflow não pode parar esperando aprovação humana enquanto ele tá fora. Risco: agentes consomem tokens errantes — mitigação memory `feedback-session-size-watchdog` cuida.

**How to apply:**
- Verbo gatilho: "saidinha", "vou sair", "fica aí", "saio agora" etc → modo "Yes total"
- Modo fica ativo até Luccas voltar e dizer "voltei", "parei aqui", "qual estado" — quando ele pede status, modo desativa
- Quando paste cross-pane chega num pane com Y/n prompt segurando a fila → resolvo Yes primeiro, depois mando o paste
- BUG ENCONTRADO, FIX PEDIDO, PLANO PROPOSTO marker do Impl/Rev → **MESMO COM "Yes total"** pauso e gravo num doc pra Luccas ver quando voltar (não despacho sem ele)
- Decisões irreversíveis (merge PR main, force push, deploy prod, rm files) → **NUNCA Yes auto** mesmo com modo on; aguardo Luccas

**CRÍTICO — cadência de wake durante Yes total** (lição 2026-06-07 ~10h dormindo):
- /loop dynamic só age nos wakes que eu agendo via `ScheduleWakeup`. Sem isso, fico dormindo permanente
- Quando Luccas avisa que vai sair → SEMPRE armar `Monitor persistent: true` em algo observable (file change `docs/handoff/**/*.md`, OR poll cmux scrollback per pane) PRIMEIRO antes do wake
- Wake de fallback nunca > 600s durante Luccas-FORA (10min máximo); padrão 300-450s
- Memory `feedback-wake-times-half` ainda vale (corte pela metade meus instintos) mas piso 60s
- Toda vez que dou Enter num pane → verificar resultado + agendar PRÓXIMO wake antes de finalizar turn (sem isso paro por horas)
- Lição: orch ficou 10h sem agir entre fim de turno 14:04 wake e próximo `/loop` manual do Luccas — Impl Fase 0 entregue ~4min depois mas Rev não recebeu paste de Fase 0 até Luccas voltar e disparar /loop. 10h perdidas.

Aplicado primeira vez 2026-06-06 ~01:30 fim Sprint 6.4-FIX merge + Sprint 6.5 kickoff Fase 0 research.
Falha cadência confirmada 2026-06-07 — usuário fora ~10h sem ação minha entre Impl entregar e Rev receber.

Related: [[feedback-auto-forward-total]] [[orchestrator-operation-mode]] [[feedback-session-size-watchdog]]
