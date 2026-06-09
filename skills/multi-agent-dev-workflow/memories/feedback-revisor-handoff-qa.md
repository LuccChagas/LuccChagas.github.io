---
name: feedback-revisor-handoff-qa
description: "Ao fechar parecer de fase (Revisor), sempre entregar descritivo pronto pra Luccas copiar e colar na aba do QA"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: da91cfd6-e793-459a-9129-a6a6b013dbbe
---

Sempre que eu (Revisor) fechar parecer de uma fase do multi-agent workflow, **incluir no final um bloco "descritivo pro QA"** pronto pra copy-paste — sem o Luccas precisar pedir.

**Why:** Luccas opera as 3 abas (Implementador / Revisor / QA) via copy-paste manual. Pedido explícito do Luccas (2026-05-19, após parecer da Fase 1 do Bloco B): "quando acabar sempre me passa o descritivo pra mandar pro qa". Quando o descritivo não vem junto, é uma viagem extra ida-e-volta. Quando vem pronto, ele só copia.

**How to apply:**
- Vale pra qualquer parecer de fase concluída (aprovação ou ressalva).
- Bloco fica ao FINAL do parecer, separado por linha horizontal, dentro de um code block monoespaçado pra facilitar copy-paste.
- Conteúdo do descritivo deve incluir, quando aplicável:
  - O que mudou no repo desde o último ping pro QA (commits, arquivos, decisões)
  - Ajustes que afetam os deliverables pendentes do QA (ex: novo teste pra adicionar ao Deliverable 3)
  - Próximo bloqueio do lado do QA (qual deliverable é o crítico agora)
  - Status do que o QA já entregou (em progresso vs aguardando)
- Se a fase não gera nada pro QA (raro — ex: política `/goal` da Fase 0), mencionar explicitamente "nada pro QA nesta fase" em vez de omitir.
- Não duplicar o parecer inteiro — descritivo é resumo focado no que o QA precisa saber, não auditoria técnica.

Relacionado: [[multi-agent-ipc-options]] — o copy-paste é a IPC atual; minimizar fricção é importante até MCP custom existir.
