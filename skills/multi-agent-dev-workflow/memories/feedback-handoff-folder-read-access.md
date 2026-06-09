---
name: feedback-handoff-folder-read-access
description: docs/handoff/** está em allow do .claude/settings.local.json — Read passa sem prompt quando Luccas/orch pedir leitura
metadata: 
  node_type: memory
  type: feedback
  originSessionId: da91cfd6-e793-459a-9129-a6a6b013dbbe
---

`Read(docs/handoff/**)` foi adicionado em `.claude/settings.local.json` em 2026-05-25 como permission auto-allowed. Sentido prático: quando Luccas (ou orchestrator) mandar "lê arquivo X em docs/handoff/...", o Read passa direto sem disparar prompt de permissão. Configuração TÉCNICA do Claude Code, não autorização semântica de princípio. A pasta é alimentada continuamente pelo `bistro-orch` (orquestrador) com:

- Planos de fase (`{seq}-implementador-to-revisor-plano.md` ou similar)
- Handoffs de implementação (`01-implementador-to-revisor.md`)
- Pareceres do Revisor (eu próprio escrevo via orchestrator)
- Pareceres do QA (`03-qa-to-revisor.md`, `05-qa-to-revisor.md`)
- Retro-handoffs pra mudanças fora do fluxo (`02b-luccas-direct-*.md`)

Estrutura hierárquica: `docs/handoff/sprint-N/bloco-X/fase-N/SEQ-from-to.md` (decidida em [[workflow-orchestrator-markers-revisor]]).

**Why:** Sem essa entrada no allow, cada Read em `docs/handoff/sprint-N/...` dispararia prompt "Allow Read on file?" → fricção desnecessária num fluxo onde o Luccas frequentemente pede "lê arquivo X em docs/handoff/...". Auto-allow tira esse atrito. Pasta inteira é dirigida pelo orch + segura (só docs de fluxo, sem secrets).

**How to apply:**
- Quando Luccas/orchestrator mandar "lê arquivo X em docs/handoff/...", chamar Read direto — sem prompt de permissão vai aparecer pro Luccas.
- Vale pra qualquer subpasta de `docs/handoff/` (sprint-1/sprint-2/sprint-3/...).
- Allow é em `.claude/settings.local.json` (NÃO settings.json) — específico desta máquina/sessão. Se Luccas trocar de máquina, replicar o settings.local.json ou re-adicionar a entrada.
- NÃO se estende automaticamente a outros caminhos sob `docs/` (ex: `docs/adr/`, `docs/multi-agent/`) — esses ainda disparam prompt no Read.

Relacionado: [[workflow-orchestrator-markers-revisor]] (define a estrutura dos arquivos), [[feedback-revisor-handoff-qa]] (QA tem pasta também — eu não leio os arquivos deles a menos que o orch passe explicitamente).
