---
name: feedback-smoke-replay-handlers
description: Smoke replay HTTP obrigatório em fase com handlers novos — lição L-23 do bug retroativo Fase 4-6 Bloco B (errHandled)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: da91cfd6-e793-459a-9129-a6a6b013dbbe
---

A partir de Bloco C (Sprint 2) em diante, TODA fase com handlers novos exige **smoke replay HTTP real** do menos-comum-success-path (erro inesperado, mismatch, edge case) ANTES de fechar a fase.

**Why:** Em Bloco B Fase 4-6, helpers de erro-handling (`requireUnitMatch`/`resolveUnitScope`/`checkUnitsSameTenant`) tinham bug em que `return dto.JSONError(c, ...)` retornava `nil` (porque `c.JSON` retorna nil em sucesso). Caller `if err != nil { return err }` nunca disparava → handler continuava processando após escrever resposta de erro → AC-3 unit_id_mismatch + O-B1 transfer_cross_tenant SILENCIOSAMENTE IGNORADAS por 3 fases. Pareceres meus e do QA (cascata mecânica = grep + lint + build + sanity DB) NÃO pegaram. Smoke da Fase 7 (curl com POST cross-tenant) pegou pelo sintoma "DUAS bodies numa request". Fix: sentinel `errHandled` + caller `return nil`.

**How to apply:**
- Ao emitir HEADS UP QA pra fase com handler novo: incluir item `[N] CRÍTICO — SMOKE REPLAY HTTP BLOQUEANTE` no checklist. Mínimo 1 cenário de erro (e.g., AC-3 mismatch, RBAC denied, validation fail) + 1 cenário happy path.
- QA executa via curl em API real (`go run ./cmd/api &` + curl). Sanity rápido — não é integration test completo.
- Validar especialmente: status HTTP correto, body único (sem duplicação), code exato, ausência de efeitos colaterais no DB quando aplicável (`dbCount == 0` após erro).
- **Pattern mecânico anti-double-body v2** (Sprint 3-B Fase 6 refinamento): pra cenários de erro, adicionar `assert.Equal(t, 1, bytes.Count(rec.Body.Bytes(), []byte(`"error"`)))`. **CHAVE: match na key JSON `"error"` com quotes, NÃO substring `error`** — evita false positive em mensagens (e.g. error_code in URL, error em texto). Sem isso, double-body silencioso (regressão tipo Bloco B Fase 4-6) passa despercebido. Pattern: contar marker do envelope error no body bytes — esperar exatamente 1 ocorrência.
- **Cobertura recomendada smoke L-23 (Sprint 3-B Fase 6 evolução)**: 3 cenários por handler novo — (1) RBAC negativo (role sem permission → 403), (2) cross-tenant 404 (caller de tenant B operando em recurso de tenant A — assertar zero side-effect EM AMBOS tenants), (3) happy path (200 + envelope §6.3 byte-level validation se aplicável). Side-effect validation: `dbCount == 0` no error path + `pub.MessagesForSubject empty` no error path.
- Se possível, complementar com integration test que valida ausência de efeitos colaterais (pattern Bloco B Fase 8 G3 — AC-3 e Transfer-CrossTenant-1 verificam `dbCount(WHERE tenant_id=X) == 0` após erro).
- Aplicar a partir do **Bloco C**. Bloco B fechou com fix retroativo + integration validation na Fase 8.

Relacionado: [[orchestrator-operation-mode]], [[feedback-revisor-handoff-qa]]. Lição arquitetural: `c.JSON returns nil em sucesso` é atalho de armadilha em Go-Echo — fácil pular se grep só vê o source.
