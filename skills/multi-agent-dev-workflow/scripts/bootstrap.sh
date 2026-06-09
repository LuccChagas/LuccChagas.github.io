#!/usr/bin/env bash
# Bootstrap multi-agent workflow num projeto existente.
#
# Pré-requisitos:
#   - cmux instalado e workspace criado pro projeto
#   - Claude Code CLI disponível
#   - git remote configurado pro projeto
#
# Uso:
#   bash ~/.claude/skills/multi-agent-dev-workflow/scripts/bootstrap.sh [<project-path>]
#
# Sem argumento: usa $PWD como project-path.

set -euo pipefail

PROJECT_PATH="${1:-$PWD}"
SKILL_DIR="$HOME/.claude/skills/multi-agent-dev-workflow"

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Project path não existe: $PROJECT_PATH" >&2
    exit 1
fi

if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo "❌ $PROJECT_PATH não é um repo git" >&2
    exit 1
fi

PROJECT_NAME=$(basename "$PROJECT_PATH")
PROJECT_MANGLED=$(echo "$PROJECT_PATH" | sed 's|/|-|g' | sed 's|^-||')
MEMORY_DIR="$HOME/.claude/projects/$PROJECT_MANGLED/memory"

echo "🎯 Multi-Agent Workflow Bootstrap"
echo "Project:       $PROJECT_NAME"
echo "Path:          $PROJECT_PATH"
echo "Memory dir:    $MEMORY_DIR"
echo ""

# 1. Validar docs base
echo "→ Validando docs base..."
for doc in ARCHITECTURE.md IMPLEMENTATION_ORDER.md CLAUDE.md; do
    if [ ! -f "$PROJECT_PATH/$doc" ]; then
        echo "  ⚠ Falta: $doc"
        case "$doc" in
            CLAUDE.md)
                read -p "  Quer copiar template CLAUDE.md.template pra criar? [y/N] " resp
                if [[ "$resp" =~ ^[Yy]$ ]]; then
                    cp "$SKILL_DIR/templates/CLAUDE.md.template" "$PROJECT_PATH/$doc"
                    echo "  ✅ Copiado. EDITE pra customizar pro projeto."
                fi
                ;;
            ARCHITECTURE.md|IMPLEMENTATION_ORDER.md)
                echo "  ❌ Sem $doc, fluxo não funciona. Crie antes de continuar."
                ;;
        esac
    else
        echo "  ✅ $doc"
    fi
done
echo ""

# 2. Setup memórias
echo "→ Setup memórias persistentes..."
if [ -d "$MEMORY_DIR" ] && [ -n "$(ls -A "$MEMORY_DIR" 2>/dev/null)" ]; then
    echo "  ⚠ $MEMORY_DIR já existe e não está vazio"
    read -p "  Sobrescrever (mantém conteúdo existente que não conflita)? [y/N] " resp
    if [[ ! "$resp" =~ ^[Yy]$ ]]; then
        echo "  Skip memories — você roda manualmente: bash $SKILL_DIR/scripts/setup-memories.sh $PROJECT_NAME"
    else
        bash "$SKILL_DIR/scripts/setup-memories.sh" "$PROJECT_NAME"
    fi
else
    bash "$SKILL_DIR/scripts/setup-memories.sh" "$PROJECT_NAME"
fi
echo ""

# 3. Validar cmux + surface mapping
echo "→ Validando cmux..."
if ! command -v cmux >/dev/null 2>&1; then
    echo "  ❌ cmux não instalado. Veja https://github.com/manaflow-ai/cmux"
    exit 1
fi
if ! cmux ping >/dev/null 2>&1; then
    echo "  ⚠ cmux app não está rodando. Abra cmux app antes de continuar."
    exit 1
fi
echo "  ✅ cmux OK"
echo ""

cmux list-workspaces 2>&1 | head -10
echo ""
echo "→ Identifique qual workspace é deste projeto + anote surface mapping em:"
echo "  $MEMORY_DIR/orchestrator-surface-mapping.md"
echo ""

# 4. Setup hooks
echo "→ Validando pre-commit hooks..."
if [ -f "$PROJECT_PATH/.githooks/pre-commit" ]; then
    HOOK_PATH=$(cd "$PROJECT_PATH" && git config --get core.hooksPath 2>/dev/null || echo "")
    if [ "$HOOK_PATH" = ".githooks" ]; then
        echo "  ✅ Pre-commit hook ativo"
    else
        echo "  ⚠ Pre-commit hook existe mas não está ativado. Rode: cd $PROJECT_PATH && git config core.hooksPath .githooks"
    fi
else
    echo "  ⚠ Sem .githooks/pre-commit no projeto. Considere criar pra Layer-1+2 (gofmt + lint)."
fi
echo ""

# 5. Próximos passos
echo "✅ Bootstrap completo. Próximos passos manuais:"
echo ""
echo "1. Abra cmux + crie workspace pro projeto (se ainda não criou)"
echo "2. Crie 4 panes no workspace (Impl, Rev, QA, Orch)"
echo "3. Em cada pane, rode 'claude' (Claude Code CLI)"
echo "4. Como PRIMEIRA mensagem em cada pane, cole o prompt agnóstico:"
echo "   - Orchestrator: cat $SKILL_DIR/prompts/orchestrator.md"
echo "   - Implementador: cat $SKILL_DIR/prompts/implementador.md"
echo "   - Revisor: cat $SKILL_DIR/prompts/revisor.md"
echo "   - QA: cat $SKILL_DIR/prompts/qa.md"
echo "5. Rode 'cmux list-pane-surfaces --workspace <ws>' pra confirmar surface mapping"
echo "6. Edite $MEMORY_DIR/orchestrator-surface-mapping.md com o mapping real"
echo "7. Coloque o spec da Fase 1 no chat do Orchestrator pra arrancar"
echo ""
echo "Workflow doc completo: https://luccchagas.github.io/"
