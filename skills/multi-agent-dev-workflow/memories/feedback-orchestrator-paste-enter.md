---
name: feedback-orchestrator-paste-enter
description: Mensagens cross-pane do bistro-orch DEVEM ser 1 linha só (sem \n internos); paste-grouping do Claude Code TUI fragmenta em N mensagens separadas
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

O Claude Code TUI faz **paste-grouping por newlines** quando recebe texto via terminal: cada bloco delimitado por `\n` vira um "paste batch" separado. O primeiro Enter submete só o 1º batch (geralmente o cabeçalho); o resto fica como mensagens pendentes no input.

**Falha original observada**: mensagem cross-pane com 5-10 linhas (cabeçalho + payload + checklist + marker) → 1º Enter submete só o cabeçalho 📋; resend Enter submete o resto **como nova mensagem separada**. Agente destino recebe 2-3 turnos fragmentados, reagindo ao primeiro vazio com "Paste vazio de novo, pede re-paste".

**Regra antiga (INSUFICIENTE)**: "verificar Enter pós-paste via read-screen, resend se necessário" — resend não corrige; só fragmenta mais.

**Regra correta**: **mensagem cross-pane do orquestrador é UMA ÚNICA LINHA**, sem `\n` internos. Aponta pro `.md` no disco e deixa o conteúdo lá. Exemplo:

```
📋 Paste vindo do bistro-orch (aprovado pelo Luccas). HANDOFF QA → REVISOR Fase 1 Bloco A — lê docs/handoff/sprint-2/bloco-a/fase-1/03-qa-to-revisor.md com Read e fecha turno com === FASE FECHADA === ou === BUG ENCONTRADO PELO QA ===.
```

Tudo em 1 linha. Sem listas numeradas no payload. Sem código fence. Sem tabelas. Toda informação detalhada vive no `.md`.

**Protocolo pós-paste atualizado (versão final 2026-05-22)**:

1. Construir mensagem 1-linha (200-600 chars, sem `\n` internos)
2. `cmux send --surface X "<mensagem-1-linha>"`
3. **Enviar 3 Enters em rajada** dentro do mesmo Bash chain: `send-key Enter && sleep 1 && send-key Enter && sleep 1 && send-key Enter` — empiricamente os pastes 1-linha precisam de 1-3 Enters pra submeter (variável imprevisível). Enviar 3 de uma vez é safe (1-linha não fragmenta) e mais barato que poll-wait-resend.
4. `cmux read-screen --surface X --lines 25` ← **mínimo 20-25 linhas**, não 8. TUI renderiza recap longo no topo e empurra estado novo pra baixo. Ler pouco = falso negativo.
5. Procurar marcadores de processamento: `⏺ Read…`, `⏺ Reading 1 file`, `✻ Cooked/Mulling/Composing/Crunching/Nucleating/Concocting/Booping/Brewing/Baking/Sautéing/Churning/Hatching/Drizzling/Transfiguring/Prestidigitating/Stewing`, `esc to interrupt` no footer
6. SE confirmado processando → atualizar `approved_by_luccas_at`, completar task, rearmar wake
7. **SE paste tem `\n` internos** (NÃO deveria — viola regra 1-linha) → NÃO multi-resend (cria fragmento). Avisar Luccas, pedir Enter manual.

**Why mudou de "1 Enter + verify + resend se necessário" pra "3 Enters de rajada"**: empiricamente os 5 últimos pastes pra surface:7/8/9 precisaram de 1-3 Enters cada (variabilidade alta, sem padrão claro). Tentativas isoladas economizam 0 e custam 1 round-trip cmux + 1 read-screen. Mandar 3 de uma vez é determinístico e barato.

**Why**: incidente 2026-05-22, 2 pastes consecutivos (heads-up QA + handoff-QA-to-Revisor) fragmentaram porque continham listas + tabelas + múltiplas linhas. Em ambos, primeiro Enter só submeteu o cabeçalho. Resend criou turnos separados confusos. Luccas flagou o padrão visualmente.

**How to apply**: começando agora (2026-05-22T20:50 BRT), toda chamada `cmux send` do bistro-orch contém texto sem `\n`. O `cat > /tmp/paste-X.txt <<EOF...` deixa de existir; usar `cmux send --surface X "mensagem 1-linha-só aqui"` direto via shell.

Relacionado: [[orchestrator-operation-mode]] (regra paste-via-arquivo permanece — agora reforçada com restrição de 1 linha).
