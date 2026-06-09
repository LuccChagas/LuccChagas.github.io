---
name: feedback-fases-sequenciais
description: Fases SEQUENCIAIS — nunca iniciar nova fase em nenhum agente enquanto a anterior não estiver 100% fechada
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f892e909-d766-43f0-9102-bc0287cc2eb9
---

**Regra reforçada Luccas 2026-05-25 pós-Sprint 2 Bloco B merge**: NUNCA iniciar nova fase em nenhum agente (Impl/Rev/QA) enquanto a fase anterior não estiver **completamente fechada** (Impl entregou + Rev fez parecer LIBERADA + QA fez cascata + Rev marcou FASE FECHADA).

**Why:** Bloco B teve a Fase 7 ficando retroativa porque Impl pulou pra Fase 8 enquanto QA ainda nem tinha executado cascata Fase 7. Resultado: Luccas se confundiu na leitura, pareceres ficaram fora de ordem (Fase 8 antes de Fase 7 fechar), bug fix retroativo gerou ainda mais ambiguidade. Disse verbatim: "n me confundo na leitura e nem nada fica retroativo essas coisas".

**How to apply:**
- **Fluxo sequencial obrigatório**: Impl Fase N HANDOFF → Rev FASE LIBERADA + HEADS UP QA → QA cascata HANDOFF → Rev FASE FECHADA → **só ENTÃO** Impl recebe paste pra começar Fase N+1
- **NÃO mandar paste "Fase N LIBERADA, começa Fase N+1" pro Impl** enquanto QA não fechou cascata Fase N
- **Tradeoff**: ~30-50% mais lento que o paralelo do Bloco A/B, mas elimina confusão e retroatividade
- Exceções razoáveis (continuam permitidas):
  - Impl pode arrumar warnings/refactor pequeno enquanto espera (sem começar fase formal)
  - Bug fix urgente retroativo (como Fase 7 Bloco B) abre exceção — mas registrar e voltar à ordem
- Vale também pra mim (orch): se Impl insistir em começar paralelo, parar e perguntar Luccas

Relacionado: [[orchestrator-operation-mode]] (fluxo geral)
