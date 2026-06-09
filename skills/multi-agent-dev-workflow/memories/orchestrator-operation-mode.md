---
name: orchestrator-operation-mode
description: "Modo de operação do bistro-orch (Orquestrador multi-agente do BistroOps) — /loop dinâmico, panes alvo, paste-via-arquivo, política de exceção"
metadata: 
  node_type: memory
  type: project
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

A partir de 2026-05-22 o pane `bistro-orch` (workspace cmux `BISTRO OPS`) opera em **modo `/loop` dinâmico como premissa**, não cutucada manual. Decisão do Luccas no kickoff da Sprint 2.

## Topologia

Workspace `BISTRO OPS` (workspace:4) tem 4 panes:
- `bistro-orch` (surface:10, pane:7) — EU, não ler/escrever em mim mesmo
- `bistro-implementador` (surface:7, pane:5 tab 1)
- `bistro-revisor` (surface:8, pane:5 tab 2)
- `bistro-qa` (surface:9, pane:6)

Implementador e Revisor **compartilham `pane:5`** como tabs/surfaces — sempre targetar por `--surface surface:N`, nunca por `--workspace` (que pega só o foco do pane).

## Ciclo /loop dinâmico

A cada wake:
1. `cmux read-screen --surface surface:7|8|9 --lines 30` nos 3 panes alvo
2. Procura marcadores (tabela em CLAUDE.md §9 + memories `workflow-orchestrator-markers*`)
3. Se nenhum marcador → `ScheduleWakeup` 1200-1800s (cache out, mas tarefa idle, ok)
4. Se algum marcador → para o auto-pace, extrai conteúdo via `cmux capture-pane --scrollback --lines 600`, salva `docs/handoff/sprint-N/bloco-X/fase-N/SEQ-from-to.md` com frontmatter (`approved_by_luccas_at: null`), mostra resumo inline, pede Y/n/edit via `AskUserQuestion`
5. Aprovação Y → encaminha via `cmux send --surface` (mensagem CURTA apontando pro `.md`) + `cmux send-key Enter`, atualiza frontmatter, volta pro loop

## Lição-mestre — paste-via-arquivo

**Nunca** colar texto grande (>500 chars) inline via `cmux send`. O Claude Code TUI compacta em `[Pasted text #N +X lines]` e o agente destino pode não desenrolar corretamente. Sempre:

1. Salvar conteúdo completo em `.md` no disco (já é parte do fluxo)
2. Mensagem cross-pane = preâmbulo curto + path do `.md` + instrução `Lê com Read tool (pula frontmatter linhas 1-12)`
3. Agente abre com Read em formato canônico, sem fragmentação

Incidente que originou a regra: 2026-05-22, paste de 8.7KB do plano da Sprint 2 chegou chunked ao Revisor → ele parou antes de emitir marcador. Registrado em `docs/handoff/sprint-2/planning/01b-revisor-rejection-incomplete-paste.md`.

## Política de exceção (`/loop` NÃO auto-aprova)

Mesmo no loop, parar e perguntar explicitamente antes de encaminhar se o conteúdo contém:

- Nova dependência Go (`go get`) ou Node (`npm install` / `pnpm add`)
- Criação de tabela não listada em `ARCHITECTURE.md`
- Mudança de tipo de coluna existente (`ALTER TYPE`)
- Novo serviço externo (SaaS, API, provider)
- Mudança de provider (email, payment, cloud, etc)
- Mexer em `apps/desktop/` ou `apps/landing/` fora da sprint correta
- Mensagem começando com `PAUSE:` de qualquer agente
- Agente perguntando "posso fazer X?" — isso é pra Luccas, não pra mim

Formato da pergunta de exceção: `⚠ EXCEÇÃO DETECTADA — não posso auto-encaminhar. Motivo: {gatilho}. Texto relevante: {trecho exato}. Quer que eu encaminhe assim mesmo? [Y/n/edit]`

## Estrutura docs/handoff/

```
docs/handoff/sprint-N/bloco-{a|b|c|planning}/fase-N/
  SEQ-from-to.md
```

Frontmatter padrão:
```yaml
sprint: N · bloco: X · fase: N · seq: SEQ · from: <pane> · to: <pane>
marker: <texto exato sem === ===>
timestamp: ISO-8601 BRT
approved_by_luccas_at: null | ISO-8601 BRT
```

README em `docs/handoff/README.md` documenta o schema.

## Cadência de wake (versão 2026-05-22 feedback Luccas: cadência menor por padrão)

**Default = curto. Só estender quando Impl está em codificação REAL ativa.**

| Situação | Delay |
|---|---|
| **Default** (qualquer estado idle/standby/aguardando paste/agente processando review pequeno) | **120-180s** |
| Revisor/QA avaliando handoff (não codificando) | 180s |
| Pós-marcador, agente acabou de receber paste | 180s |
| Agente próximo do fim (5/6 tasks done, bloqueado em prompt de permissão) | 120-180s |
| Impl em codificação ATIVA real (≥1 task in_progress que envolve `Write/Edit`, sem prompt pendente, <50% progresso) | 600-900s |
| Impl em codificação ativa, ≥50% progresso visível | 270-360s |

Nunca 300s (worst-of-both — paga cache miss sem amortizar). 270s ok (cache in margem).

**Why mudou pra default curto**:
- Feedback Luccas 2026-05-22: cadência de 270-600s ainda frustra quando Impl bloqueia em prompt de permissão (ele esperou eu acordar pra ver que era trivial). Wakes baratos > esperar inútil.
- Cache miss em 180s × várias vezes < 1 wake de 1200s pra Luccas precisar me cutucar.
- Cadência conservadora demais (1200s+) só justifica pra Impl ATIVAMENTE codando algo grande sem prompts esperados.

**Heurística antes de armar wake**:
1. Ler pane atual: está com `esc to interrupt` (rodando)? `Do you want to proceed?` (bloqueado)? Prompt vazio (idle)?
2. Se bloqueado → 120-180s (Luccas pode aprovar a qualquer momento, eu pego rápido)
3. Se idle aguardando paste cross-pane meu → 120-180s (decisão do Luccas pode chegar a qualquer momento)
4. Se rodando review/análise pequena (Revisor/QA) → 180s (precedentes 1-5min)
5. Se Impl rodando Write/Edit em entities → 600s (precedentes 5-15min)
6. Se Impl recém começou e tem ~10 entregáveis pela frente → 600-900s

## Soft rule: retro-handoff opcional pra mudanças fora do orch

Quando Luccas faz mudança DIRETA com um agente (sem passar pelo orch — típico: typo em CLAUDE.md, valor em config, fix trivial 1-linha), opção semi-formal pra preservar audit trail:

1. **Default**: Luccas mantém flexibilidade. Mudanças triviais podem ir direto sem orch
2. **Retro-handoff**: quando Luccas sinaliza "fiz X direto no Y" ou eu detecto via `git log` commit cujo conteúdo não aparece em `docs/handoff/`, **eu crio entry retroativa** em `docs/handoff/sprint-N/bloco-X/fase-N/SEQ-direct-<curta-descrição>.md` com:
   - Frontmatter `from: luccas-direct`, `to: <pane>`, `marker: (direct, fora do orch)`, `approved_by_luccas_at: <timestamp>`
   - Conteúdo: commit hash + diff summary + razão (se Luccas der) + nota "fora do fluxo do orch — retro-documentado pelo bistro-orch"

**Why**: incidente 2026-05-22 commit `9531a52` (CNPJ Polar fix Luccas-Impl direto) ficou sem entry no `docs/handoff/`. Revisor flagou na validação subsequente: "audit trail incompleto pra post-mortem". Solução intermediária: retro-handoff opcional preserva audit sem matar flexibilidade.

**How to apply**: monitorar `git log` no boot de cada wake. Se aparecer commit cujo conteúdo não está em nenhum `.md` de `docs/handoff/` da fase atual, perguntar pro Luccas se quer retro-handoff (não criar sem aprovação).

## Cross-sessão

Boot em sessão nova lê: este `MEMORY.md` (carrega ciclo) → `CLAUDE.md §9` (carrega marcadores e topologia) → `docs/handoff/` ordenado por mtime (carrega último estado) → `cmux read-screen` nos 3 panes (estado vivo). Boot deve durar <30s.

## Marcadores resumidos

Tabela canônica está em [[workflow-orchestrator-markers]] (Implementador), [[workflow-orchestrator-markers-revisor]] (Revisor), [[workflow-orchestrator-markers-qa]] (QA). CLAUDE.md §9 tem a versão consolidada.

**Why**: o Luccas quer o orquestrador como premissa permanente do projeto (todos os blocos, todas as sprints), não experiência ad-hoc. Esta memória é o ponto de verdade pra próximo boot.

**How to apply**: toda sessão do `bistro-orch` (boot ou continuação) opera neste modo. Cutucada manual só como fallback quando o `/loop` for explicitamente desativado pelo Luccas. `/loop` quando ativo é o estado normal, não o excepcional.

Relacionado: [[multi-agent-ipc-options]] (decisão original SUPERSEDED em 2026-05-22).
