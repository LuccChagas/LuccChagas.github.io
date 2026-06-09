---
name: feedback-smoke-visual-ask-luccas
description: "Quando QA cascata chega no item 'visual smoke browser' (fases frontend), perguntar AskUserQuestion ao Luccas: fazer agora ou pular?"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Em cascatas QA de fases frontend (Sprint 6.5 Fase 6/7, Sprint 5 Fase N etc) que incluem item "visual smoke browser" como crítico, eu interrompo o fluxo antes do QA pular esse item e pergunto via AskUserQuestion ao Luccas.

**Why:** Smoke visual exige Luccas no browser (ele que clica, escaneia QR, etc). Sem ele presente, QA tem que pular ou marcar como deferido. Decisão dele saber quando vale parar tudo pra fazer agora vs deferir pra closeout.

**How to apply:**
- Gatilho: QA cascata em fase frontend + item "[N] visual smoke browser" / "[N] E2E manual browser" / "[N] smoke real Luccas" aparece no checklist do Rev
- Ação: ANTES de mandar paste cascata pro QA, OR durante QA cascata se ele pedir Y/n específico pro smoke, eu paro e pergunto via AskUserQuestion: "Hora do smoke visual da Fase X — fazer agora ou pular pra closeout/PR review?"
- Opções padrão:
  1. "Sim, faço agora" → pauso QA cascata + sinalizo Luccas + ele dá OK depois → continuo
  2. "Pular pra closeout (deferido)" → QA marca item como ⏸ deferido + segue cascata + Luccas faz smoke antes de PR
  3. "Smoke parcial agora (só fluxo crítico)" → Luccas faz uma porção curta + QA continua
- Memory NÃO se aplica em fases backend-only (Spike Otimização, Fase 4 worker — sem browser envolvido)

Aplicado primeira vez 2026-06-08 Sprint 6.5 Fase 6 (Admin frontend cardápio QR + mesas — 7 rotas + cascata QA com visual smoke browser obrigatório).

Related: [[feedback-orch-yes-while-away]] [[orchestrator-operation-mode]]
