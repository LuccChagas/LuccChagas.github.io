# LuccChagas.github.io

Site pessoal — serve em https://luccchagas.github.io/

## Conteúdo atual

- **Multi-Agent Workflow** (`index.md`) — documento agnóstico que descreve o fluxo de trabalho com 4 instâncias Claude Code coordenadas via cmux. Inclui auto-descrições dos agentes, prompts iniciais, marcadores canônicos e apêndice com 22 memórias persistentes que cravam protocolos descobertos durante uso real.

## Setup local (opcional)

Pra preview antes de push:

```bash
# Instalar Ruby + Bundler (Mac via brew)
brew install ruby
gem install bundler jekyll

# Criar Gemfile mínimo
cat > Gemfile <<EOF
source "https://rubygems.org"
gem "github-pages", group: :jekyll_plugins
EOF

bundle install
bundle exec jekyll serve

# Acessar http://localhost:4000
```

## Como GitHub Pages publica

1. Push pra branch `main` (ou `master`) → GitHub Actions builda Jekyll automático
2. Settings → Pages → Source = `Deploy from a branch` + branch `main` + folder `/ (root)`
3. Site fica em `https://luccchagas.github.io/` em 1-2min após push

## Estrutura

```
.
├── index.md              # entry point — Multi-Agent Workflow doc
├── _config.yml           # Jekyll config (tema Cayman + plugins)
├── _includes/
│   └── head_custom.html  # injeta mermaid.js CDN pra renderizar diagramas
└── README.md             # você está aqui
```

## Mermaid diagrams

Diagramas em blocos ` ```mermaid ` são renderizados via mermaid.js (CDN no `head_custom.html`). Se mudar de tema, garanta que o tema novo aceita `head_custom.html` (Cayman aceita).
