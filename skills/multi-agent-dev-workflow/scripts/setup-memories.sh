#!/usr/bin/env bash
# Copia 20 memórias agnósticas do skill pro projeto + cria MEMORY.md index.
#
# Uso:
#   bash ~/.claude/skills/multi-agent-dev-workflow/scripts/setup-memories.sh <project-name>
#
# project-name é qualquer string identificadora (usa pra calcular memory dir mangled).

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Uso: $0 <project-name OR project-path>"
    exit 1
fi

ARG="$1"
SKILL_DIR="$HOME/.claude/skills/multi-agent-dev-workflow"
MEMORIES_SRC="$SKILL_DIR/memories"

# Se for um path existente, usa pra calcular mangled. Senão usa como nome direto.
if [ -d "$ARG" ]; then
    PROJECT_PATH=$(cd "$ARG" && pwd)
    PROJECT_MANGLED=$(echo "$PROJECT_PATH" | sed 's|/|-|g' | sed 's|^-||')
else
    PROJECT_MANGLED="$ARG"
fi

MEMORY_DIR="$HOME/.claude/projects/$PROJECT_MANGLED/memory"
mkdir -p "$MEMORY_DIR"

echo "→ Copiando memórias pra $MEMORY_DIR"

COUNT=0
for f in "$MEMORIES_SRC"/*.md; do
    name=$(basename "$f")
    if [ "$name" = "README.md" ]; then
        continue  # README não é memory
    fi
    if [ -f "$MEMORY_DIR/$name" ]; then
        echo "  ⏸ Skip (já existe): $name"
    else
        cp "$f" "$MEMORY_DIR/$name"
        COUNT=$((COUNT + 1))
        echo "  ✅ $name"
    fi
done

echo ""
echo "→ Criando MEMORY.md index..."

cat > "$MEMORY_DIR/MEMORY.md" <<'EOF'
- [Orchestrator operation mode](orchestrator-operation-mode.md) — modo /loop dinâmico + topologia panes + paste-via-arquivo + política de exceção
- [Surface mapping fixo](orchestrator-surface-mapping.md) — Impl=4 / Rev=1 / Orch=2 / QA=3 — checar ANTES paste cross-pane (AJUSTAR pro seu mapping)
- [Paste cross-pane = 1 linha só](feedback-orchestrator-paste-enter.md) — TUI fragmenta paste por \n; mensagem cross-pane é UMA linha + 3 Enters em rajada
- [Session size watchdog](feedback-session-size-watchdog.md) — >300k tokens red flag; sempre verificar git status antes de propor /compact
- [Auto-forward total](feedback-auto-forward-total.md) — orch auto-forward 4 eventos padrão (Impl→Rev, HEADS UP→QA, QA APROVADO→Rev, FASE FECHADA→Impl) sem Y/n
- [Orch Yes total enquanto humano tá fora](feedback-orch-yes-while-away.md) — gatilhos "vou sair"/"saidinha" → modo Yes total; preserva BUG/PLANO + decisões irreversíveis
- [Wake times cortar metade](feedback-wake-times-half.md) — cortar pela metade meus instintos; calibrar com ritmo real dos seus tests
- [/compact vs /clear](feedback-compact-vs-clear.md) — pane >95% context: SEMPRE recomendar /compact, NUNCA /clear
- [Fases sequenciais — nunca paralelo](feedback-fases-sequenciais.md) — NÃO mandar Impl começar Fase N+1 enquanto QA cascata Fase N + Rev FASE FECHADA
- [Revisor descritivo pro QA](feedback-revisor-handoff-qa.md) — Rev sempre inclui bloco copy-paste pra QA ao final do parecer
- [Markers QA](workflow-orchestrator-markers-qa.md) — marker `=== HANDOFF QA → REVISOR ===` última linha
- [Markers Revisor](workflow-orchestrator-markers-revisor.md) — markers Rev (PARECER FECHADO / FASE FECHADA / HEADS UP QA / FIX PEDIDO)
- [QA tools pré-autorizados](feedback-qa-tools-preauthorized.md) — wildcards em .claude/settings.local.json pra build/test/lint/grep/psql/migrate/curl/git-read
- [QA code touches — cascata mecânica](feedback-qa-code-touches.md) — quando Impl pode (e quando NÃO pode) modificar test files do QA
- [QA pode usar Workflow em cascata enxuta](feedback-qa-workflow-cascata-enxuta.md) — paralelo quando ≥5 itens independentes (3x wall-clock)
- [docs/handoff/ — leitura livre](feedback-handoff-folder-read-access.md) — autorização permanente Read docs/handoff/** sem pedir
- [Spec-research-first principle](feedback-spec-research-first.md) — antes de fase integration externa, validar spec REAL (openapi.yaml etc) contra plan
- [Smoke replay handlers obrigatório](feedback-smoke-replay-handlers.md) — fases com handlers novos exigem smoke HTTP error-path ANTES de fechar fase
- [Smoke visual — perguntar humano](feedback-smoke-visual-ask-luccas.md) — QA cascata frontend chega em item "visual smoke browser" — perguntar humano via AskUserQuestion
- [Secrets protection](feedback-secrets-protection.md) — JAMAIS copiar credenciais reais no chat; referenciar por nome de env var
EOF

echo "  ✅ MEMORY.md criado com $COUNT entradas"
echo ""

# Calibração necessária
echo "✨ Memórias copiadas. AJUSTES NECESSÁRIOS:"
echo ""
echo "1. orchestrator-surface-mapping.md — ajuste o mapping real do seu workspace cmux"
echo "2. feedback-wake-times-half.md — calibre os wakes com tempos reais dos seus tests"
echo "3. Memórias com referências project-specific BistroOps preservadas como exemplo histórico — não delete (dá contexto do 'porquê')"
echo ""
echo "Veja $MEMORIES_SRC/README.md pra mais detalhes."
