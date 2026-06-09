---
name: feedback-auto-forward-total
description: bistro-orch — autorização permanente pra auto-forward pastes cross-pane SEM AskUserQuestion. Só pergunta em BUG/FIX/decisões reais
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Luccas autorizou (2026-06-01) auto-forward total em pastes cross-pane do orch.

**Regra**: NÃO chamar `AskUserQuestion` antes de mandar paste pros 4 eventos padrão:

| Evento | Origem (marker) | Destino |
|---|---|---|
| Handoff fim de fase | `=== HANDOFF IMPLEMENTADOR → REVISOR ===` | Rev (s:8) |
| Rev libera cascata | `=== HEADS UP QA ===` / `=== FASE LIBERADA ===` | QA (s:9) |
| QA aprovou cascata | `=== HANDOFF QA → REVISOR ===` | Rev (s:8) |
| Rev fechou fase | `=== FASE FECHADA ===` | Impl (s:7) liberar próxima fase |

Em todos esses casos: salvar doc handoff + mandar paste 1-linha com 3 Enters + ScheduleWakeup. Não perguntar.

**Avisar Luccas DEPOIS** — texto curto resumindo o que foi forward (1-2 linhas + commit hash + wake).

**Quando AINDA perguntar (excepções)**:
1. **BUG / FIX PEDIDO** pelo Rev — pergunto Y/n se forward o fix-request pro Impl
2. **BUG ENCONTRADO PELO QA** — pergunto antes de mandar pro Rev/Impl
3. **PLANO PROPOSTO** (planejamento de sprint) — pergunto antes de mandar pro Rev revisar
4. **Decisões D1-D6** pendentes pro Luccas decidir (override Rev, etc)
5. **Permission prompts pendentes** nos panes — só relato, não tento bypass
6. **Tokens em red zone** (>300k pane específico ou >600k Rev) — pergunto se /clear antes de forward grande
7. **Cross-binary mudanças** ou tocar em código fora da branch atual
8. **Sprint kickoff** novo (plano novo) — pergunto antes de mandar pro Impl planejar

**Why mudou**: fluxo Y/n a cada step custa ~5 perguntas × N fases = 50+ perguntas/sprint. Slow + alta ergonomia. Auto-forward em eventos padrão (sem decisão real) elimina ruído sem sacrificar controle nas decisões que importam.

**How to apply**: começando agora (2026-06-01T12:15 BRT), em vez de "Forward X pro Y?" via AskUserQuestion, mando paste direto + escrevo no chat: "Forward X→Y enviado, wake Nmin" como texto curto.

Validação: se Luccas reclamar de algum forward específico, restaurar Y/n só pra aquela situação.

**Lição 2026-06-03 — fechar loop SEMPRE pós-Rev parecer final**: cometi erro Sprint 5 Fase 8 onde Rev marcou `=== SPRINT 5 IMPLEMENTAÇÃO 100% CONCLUÍDA ===` (equivalente a FASE FECHADA + sprint closeout) e EU NÃO fiz auto-forward Rev→Impl. Impl ficou idle 20min sem saber que Rev validou as 3 condições + respondeu 3 perguntas + sprint estava fechada. Luccas percebeu antes de mim ("se perdeu no fluxo fio?"). Variants de marker que disparam auto-forward Rev→Impl além de `=== FASE N FECHADA ===`:
- `=== SPRINT N FECHADA ===` / `=== SPRINT N IMPLEMENTAÇÃO 100% CONCLUÍDA ===`
- `=== HEADS UP IMPLEMENTADOR ===` / `=== ARRANCA FASE N+1 ===`
- Quando Rev responde 3+ perguntas opcionais do Impl + valida resultados — auto-forward o resumo das respostas pro Impl mesmo se não tem marker explícito de fase nova
Regra geral: depois de QUALQUER turno do Rev que produza decisão + responda Impl, fechar loop com paste pro Impl. Não esperar marker exato. Senão fluxo para silencioso.
