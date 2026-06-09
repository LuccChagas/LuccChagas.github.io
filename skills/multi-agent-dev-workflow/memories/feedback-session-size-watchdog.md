---
name: feedback-session-size-watchdog
description: Sessões dos agentes alvo (Impl/Revisor/QA) acumulam contexto; >300k tokens é red flag pra socket crash. Vigiar e sugerir /clear preventivo entre fases grandes
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

Cada turno do orquestrador deve **olhar o footer dos panes alvo** procurando texto tipo `new task? /clear to save Xk tokens`. Quando X passa de **300k tokens**, alertar o Luccas pra rodar `/clear` no pane antes da próxima fase grande começar.

**Why**: incidente 2026-05-23T00:42-03:09 BRT — sessão do `bistro-implementador` em 349.2k tokens cresceu durante 4 fases consecutivas (Fase 1 → 4) + retomada pós-pausa. Recebeu paste da Fase 5, **API Error: socket connection closed unexpectedly** após `✻ Worked for 1h 2m 55s` sem produzir uma linha de código. Trabalho não foi perdido (nada foi escrito), mas 1h de tempo agente desperdiçado em retry/loop interno.

Hipóteses:
- Tamanho de contexto + load do servidor Anthropic = timeout de socket
- Tooling caro repetido (Bash, Read, Write em sequência) excede budget de sessão
- Recovery interno do agent fica em loop sem checkpoint

**How to apply** — protocolo:

1. Antes de cada check de marcador, ler footer do pane via read-screen (já estamos fazendo). Se vir `/clear to save Xk tokens`:
   - X < 200k → ok, segue
   - 200k ≤ X < 300k → anotar; mencionar pro Luccas no próximo turno relevante
   - X ≥ 300k → **flag vermelho**, recomendar `/clear` antes da próxima fase
2. Janela boa pra `/clear`: **entre marcadores `=== FASE FECHADA ===` e `=== HANDOFF IMPLEMENTADOR → REVISOR ===` da próxima fase**. Nada in-flight, contexto pode resetar limpo.
3. Após `/clear`, o agent boota lendo `MEMORY.md` + `CLAUDE.md` + último `.md` em `docs/handoff/` da fase atual. Não precisa replay manual de instruções de processo.
4. Re-encaminhar o paste pendente normalmente (1-linha + 3 Enters protocolo). Agent volta produtivo.

**Sintomas de socket crash já em curso** (detectar pelo capture-pane):
- `⎿ API Error: The socket connection was closed unexpectedly`
- `✻ Worked for X` muito alto (>30min) sem nenhum `Bash(`/`Write(`/`Update(` no scrollback recente
- Cursor parado no prompt sem `esc to interrupt`

Quando vir esses 3 → diagnóstico imediato + recomendar `/clear` ao Luccas + verificar git status pra confirmar trabalho perdido vs uncommitted.

**Não destruir sem confirmar**: SEMPRE rodar `git status` + `ls` do diretório alvo antes de propor `/clear` — pode haver código não-commitado que vale recuperar manualmente.

Relacionado: [[orchestrator-operation-mode]] (cadência de wake), [[feedback-orchestrator-paste-enter]] (re-paste pós-clear segue protocolo 1-linha).
