---
title: Skills — Claude Code
description: Skills agnósticas pra Claude Code, pré-cravadas com lições de projetos reais.
layout: default
---

# Skills

Skills (extensões reutilizáveis do Claude Code) cravadas durante uso real em projetos. Cada uma trazendo **prompts agnósticos**, **memórias persistentes** com gatilhos/precedentes, e **scripts de bootstrap**.

## Skills disponíveis

### 🎯 multi-agent-dev-workflow

Coordena 4 instâncias Claude Code (Orchestrator + Implementador + Revisor + QA) via [cmux](https://github.com/manaflow-ai/cmux) terminal multiplexer Mac. Bootstrap rápido pra projetos novos com prompts agnósticos, 20 memórias canônicas pré-cravadas, templates de handoff doc, e validação automática dos pré-requisitos.

**Pré-requisitos obrigatórios no repo do projeto**:
- `ARCHITECTURE.md` (fonte da verdade técnica)
- `IMPLEMENTATION_ORDER.md` (ordem das sprints)
- `CLAUDE.md` (convenções do repo)

**Documento agnóstico completo** (852 linhas): [Multi-Agent Workflow](./) — visão geral, marcadores canônicos, fluxo, prompts, memórias.

**Conteúdo da skill** ([browse no GitHub](https://github.com/LuccChagas/LuccChagas.github.io/tree/main/skills/multi-agent-dev-workflow)):

```
multi-agent-dev-workflow/
├── SKILL.md                       # entry point + fluxo + invocação
├── prompts/                       # 4 prompts agnósticos
│   ├── orchestrator.md
│   ├── implementador.md
│   ├── revisor.md
│   └── qa.md
├── memories/                      # 20 memórias canônicas + README
├── templates/                     # 5 templates de handoff docs
│   ├── 01-implementador-handoff-revisor.md.template
│   ├── 02-revisor-aprovado.md.template
│   ├── 03-qa-aprovado-handoff-revisor.md.template
│   ├── 03-qa-bug-encontrado-handoff-impl.md.template
│   └── CLAUDE.md.template
└── scripts/
    ├── bootstrap.sh               # cria projeto novo do zero
    └── setup-memories.sh          # copia 20 memórias + cria MEMORY.md
```

#### Instalação

```bash
# 1. Clone esta pasta pro seu skills dir do Claude Code
mkdir -p ~/.claude/skills
cd ~/.claude/skills

git clone --depth 1 --no-checkout https://github.com/LuccChagas/LuccChagas.github.io.git tmp-clone
cd tmp-clone
git sparse-checkout init --cone
git sparse-checkout set skills/multi-agent-dev-workflow
git checkout

# 2. Mover pro lugar canonical
mv skills/multi-agent-dev-workflow ~/.claude/skills/
cd ~/.claude/skills && rm -rf tmp-clone

# 3. Tornar scripts executáveis
chmod +x ~/.claude/skills/multi-agent-dev-workflow/scripts/*.sh

# 4. Verificar
ls ~/.claude/skills/multi-agent-dev-workflow/
```

#### Uso em projeto novo

```bash
cd ~/projects/<novo-projeto>

# Bootstrap: valida pré-reqs, copia memórias, sinaliza próximos passos
bash ~/.claude/skills/multi-agent-dev-workflow/scripts/bootstrap.sh
```

O script:
1. **Valida** os 3 docs base (`ARCHITECTURE.md`, `IMPLEMENTATION_ORDER.md`, `CLAUDE.md`) — oferece copiar template do CLAUDE.md se faltar
2. **Copia** 20 memórias agnósticas pro `~/.claude/projects/<project>/memory/`
3. **Cria** `MEMORY.md` index
4. **Valida** cmux instalado + workspace ativo
5. **Lista** próximos passos manuais (criar panes, colar prompts)

#### Próximos passos manuais (depois do bootstrap)

1. Abre `cmux` + cria workspace pro projeto (se ainda não existir)
2. Cria 4 panes no workspace (Impl, Rev, QA, Orch)
3. Em cada pane, roda `claude` (Claude Code CLI)
4. Como **primeira mensagem** em cada pane, cola o prompt agnóstico correspondente:

```bash
cat ~/.claude/skills/multi-agent-dev-workflow/prompts/orchestrator.md  # → cola no pane Orch
cat ~/.claude/skills/multi-agent-dev-workflow/prompts/implementador.md  # → cola no pane Impl
cat ~/.claude/skills/multi-agent-dev-workflow/prompts/revisor.md        # → cola no pane Rev
cat ~/.claude/skills/multi-agent-dev-workflow/prompts/qa.md             # → cola no pane QA
```

5. Roda `cmux list-pane-surfaces --workspace <ws>` pra confirmar surface mapping
6. Edita `~/.claude/projects/<project>/memory/orchestrator-surface-mapping.md` com o mapping real
7. Cola o spec da Fase 1 no chat do Orchestrator pra arrancar

---

## Origem

Estas skills nasceram durante o desenvolvimento real do **BistroOps** (SaaS de gestão operacional pra food service brasileiro, cliente fundador Polar Coffee Santana). Cada memória cravou uma lição aprendida com incidente concreto. Documento completo do fluxo: [Multi-Agent Workflow](./).

## Como contribuir

Pull requests bem-vindos. Pra propor mudança numa skill:
1. Fork [LuccChagas/LuccChagas.github.io](https://github.com/LuccChagas/LuccChagas.github.io)
2. Edita `skills/<nome>/`
3. Atualiza este `skills.md` se for skill nova
4. Abre PR

Pra propor memória nova: anexar evidência do incidente que motivou (commit hash, log do bug, etc).
