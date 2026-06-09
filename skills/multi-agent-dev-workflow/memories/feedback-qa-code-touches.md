---
name: feedback-qa-code-touches
description: Quando Implementador pode (e quando NÃO pode) modificar código do QA — padrão da cascata mecânica
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 29287022-f728-4570-865a-da585d7288c2
---

**Regra:** Implementador NÃO modifica código do QA por default. Exceção: cascata mecânica de mudança de schema/contrato aprovada, com justificativa precisa documentada no commit.

**Why:** QA escreve contratos de teste como source-of-truth do que handler deve fazer. Implementador mexer nos testes pode mascarar bugs OU adaptar teste indevidamente à implementação. Mas algumas mudanças (schema NOT NULL nova, scheme de driver, cleanup entre subtests pra resolver collision determinística) são puramente mecânicas — testes precisam ser atualizados sem mudar intenção.

**How to apply:**

Posso tocar em código QA apenas quando ALL:
1. A mudança é mecânica (não muda intenção semântica do teste, só conforma o teste a uma decisão arquitetural aprovada)
2. Foi causada por mudança aprovada noutro lugar (migration, query signature, decisão de design escalada pro Luccas)
3. O commit documenta: causa raiz + por que é mecânico + qual decisão aprovada gerou a cascata
4. Mantenho registro do precedente pra Revisor decidir se aprova retroativamente

**Histórico de toques aprovados retroativamente:**

| # | Bloco | Arquivo QA | Causa | Status |
|---|---|---|---|---|
| 1 | Bloco A | `internal/testkit/postgres.go` (helper QA) | Driver `golang-migrate/pgx/v5` usa scheme `pgx5://`, testcontainers retorna `postgres://`. Adicionei `MigrateDSN` helper | ✅ Aprovado |
| 2 | Bloco B Fase 2 | `sqlc_e2e_test.go`, `isolation_test.go` (fixtures) | Migration 000002 adicionou `tenants.slug NOT NULL`. Fixtures precisaram passar slug | ✅ Aprovado |
| 3 | Bloco B Fase 5 | `signup_test.go` (TestSignup_SlugSanitizes) | 4 dos 5 subtests slugificam pra valores idênticos → UNIQUE constraint → retry com sufixo → assertEqual falha. Cleanup TRUNCATE entre subtests | ✅ Aprovado |

**⚠ Aviso do Revisor (final do parecer Fase 5):** "3ª vez consecutiva — vai virar memória persistente se acontecer no Bloco C+ sem precedente claro." Significa: se 4ª ocorrer SEM justificativa óbvia de cascata, eu preciso pausar e ESCALAR antes de tocar. A barra sobe a cada ocorrência.

**O que eu NÃO devo fazer:**
- Tocar em código QA pra "corrigir" teste que reflete contrato divergente da minha impl (resolver via mudança na MINHA impl, não no teste)
- Tocar em código QA por preferência de estilo
- Tocar em código QA sem documentar a cascata no commit
- Acumular toques implícitos — cada toque é commit isolado pra Revisor inspecionar

Relacionado: [[goal-command-usage-policy]] (mock externo no /goal exige AskUserQuestion — segue mesmo princípio).
