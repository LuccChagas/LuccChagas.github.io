# Memórias canônicas — Template

20 memórias agnósticas cravadas durante uso real do workflow multi-agent (cada uma nasceu de incidente concreto). Quando bootstrap em projeto novo, `setup-memories.sh` copia tudo pra `~/.claude/projects/<new-project>/memory/` + cria `MEMORY.md` index.

## ⚠ Importante: generalização necessária

Algumas memórias têm **referências project-specific** (datas reais BistroOps, commit hashes, sprint numbers) preservadas como exemplos do incidente original. Ao replicar em projeto novo:

1. **Não apague** as referências — elas dão contexto histórico do "porquê".
2. **Adapte** o "How to apply" pra se aplicar ao seu projeto/stack.
3. **Calibre** valores numéricos (`feedback-wake-times-half` depende da velocidade dos seus tests; `feedback-session-size-watchdog` 300k é universal).

## Categorias

| Categoria | Slug | O que crava |
|---|---|---|
| Comunicação | `feedback-orchestrator-paste-enter` | Paste 1 linha + 3 Enters (TUI fragmenta com \n) |
| Comunicação | `feedback-auto-forward-total` | Auto-forward 4 eventos padrão sem perguntar humano |
| Comunicação | `feedback-orch-yes-while-away` | Modo Yes total durante saídas do humano |
| Comunicação | `feedback-wake-times-half` | Cortar wake times pela metade do instinto |
| Gating | `feedback-fases-sequenciais` | NUNCA fase N+1 antes N fechar (lição retroativa) |
| Gating | `feedback-compact-vs-clear` | /compact preserva history, NUNCA /clear |
| Gating | `feedback-session-size-watchdog` | >300k tokens red flag pra socket crash |
| Permissões | `feedback-qa-tools-preauthorized` | Wildcards .claude/settings.local.json |
| Permissões | `feedback-handoff-folder-read-access` | Read docs/handoff/** auto-allow |
| Práticas | `feedback-spec-research-first` | Validar spec REAL antes plan (incidente cravado) |
| Práticas | `feedback-smoke-replay-handlers` | Smoke replay HTTP error-path obrigatório |
| Práticas | `feedback-smoke-visual-ask-luccas` | Pergunta humano antes smoke visual frontend |
| Práticas | `feedback-revisor-handoff-qa` | Rev sempre inclui descritivo QA copy-paste |
| Boundaries | `feedback-qa-code-touches` | Impl não mexe em test files do QA por default |
| Boundaries | `feedback-qa-workflow-cascata-enxuta` | QA pode Workflow paralelo (≥5 items independentes) |
| Boundaries | `feedback-secrets-protection` | JAMAIS copiar secrets reais no chat |
| Reference | `workflow-orchestrator-markers-qa` | Markers QA → orch |
| Reference | `workflow-orchestrator-markers-revisor` | Markers Rev → orch |
| Reference | `orchestrator-operation-mode` | Modo operação completo orch (template-base) |
| Reference | `orchestrator-surface-mapping` | Surface mapping fixo por projeto |

## Bootstrap em projeto novo

```bash
# Skill faz isso automatic — esse comando é só pra entender:
bash ~/.claude/skills/multi-agent-dev-workflow/scripts/setup-memories.sh <project-name>
```

O script:
1. Copia os 20 .md pra `~/.claude/projects/<project-mangled>/memory/`
2. Cria `MEMORY.md` index com 1 linha por memória
3. Anota TODO no header: "calibrar feedback-wake-times-half com tempos reais do projeto novo"

## Adicionar memória nova durante uso

Quando descobrir gatilho/precedente novo no projeto, grave em `~/.claude/projects/<project>/memory/<slug>.md` com:

```markdown
---
name: <slug>
description: <síntese 1-linha>
metadata:
  type: feedback | project | reference | user
---

<Regra principal>

**Why:** <por que existe — incidente ou diretriz>

**How to apply:** <protocolo prático>

Related: [[outra-memory]] [[outra-memory-2]]
```

E adicione 1 linha em `MEMORY.md`:

```markdown
- [Título](slug.md) — síntese curta sob 150 chars
```
