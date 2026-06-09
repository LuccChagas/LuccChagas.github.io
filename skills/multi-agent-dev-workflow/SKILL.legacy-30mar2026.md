# Multi-Agent Workflow — Implementação de Projetos

## Quando usar
Sempre que iniciar um novo projeto ou feature complexa que envolva:
- Criação de novo repositório a partir de template
- Implementação com múltiplas fases (modelo de dados, frontend, backend, testes)
- Necessidade de revisão independente antes de executar

## As 4 sessões

### Aba 1 — Implementador (Plan Mode)
Abre com: `claude` no diretório do projeto
Inicia em Plan Mode: Shift+Tab duas vezes
Responsabilidade: Lê o CLAUDE.md, entende o contexto completo, cria plano por fases com arquivos afetados. NÃO executa até aprovação explícita.
Fluxo: Planeja → você itera → você aprova → Shift+Tab → executa

### Aba 2 — Revisor
Abre com: `claude` no mesmo diretório
Quando abrir: Após a Aba 1 gerar o plano
Responsabilidade: Recebe o plano colado pelo usuário, lê o CLAUDE.md, faz revisão implacável. Avalia: modelo de dados, migrations, riscos de quebrar funcionalidades existentes, ordem das fases, gaps.
Parecer final: APROVADO | APROVADO COM RESSALVAS | REPROVADO

### Aba 3 — QA / Testes
Abre com: `claude` no mesmo diretório
Quando abrir: Em paralelo com a Aba 1, não precisa esperar o plano
Responsabilidade: Escreve testes baseados na spec ANTES de ver o código. Backend em Go (tabela de casos). Frontend em BDD (dado/quando/então).

### Aba 4 — Arquiteto (opcional)
Abre com: `claude` no mesmo diretório
Quando abrir: Para decisões técnicas complexas ou quando o revisor reprovar
Responsabilidade: Mantém contexto macro, avalia alternativas arquiteturais, desempata decisões técnicas.

## Regras do workflow
- Todas as abas rodam no mesmo diretório do projeto
- O revisor NUNCA vê o código sendo escrito — só recebe o plano pronto
- Aba 3 é independente e pode rodar desde o início
- Só avança para execução após aprovação do plano
- Quando revisor retornar bloqueantes: voltar na Aba 1 com os problemas antes de executar
- Notificações do iTerm2 avisam quando qualquer aba precisa de input

## Estrutura do prompt da Aba 1
Sempre incluir:
- Repositório git
- Contexto do cliente/projeto
- Modelo de dados esperado
- Fonte da verdade (planilha, doc, spec)
- Identidade visual se houver
- Plano esperado por fases com: arquivos afetados, dependências, riscos
- Instrução explícita: NÃO execute, apenas planeje

## Slash commands por projeto
Cada projeto tem seus próprios prompts em .claude/commands/:
- /implementador — prompt da Aba 1 com contexto do cliente
- /revisor — prompt da Aba 2
- /qa — prompt da Aba 3
