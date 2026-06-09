---
name: feedback-spec-research-first
description: Antes de iniciar fase integration com spec externa (Open Delivery, iFood, etc), validar spec REAL contra plan ARCH.md — plan inicial pode estar outdated. Lição Sprint 4-A Fase 4 (decisão Luccas Opção 1)
metadata:
  node_type: memory
  type: feedback
  originSessionId: current
---

**Regra**: antes de implementar fase de integração com spec externa (Open Delivery, iFood, payment provider, etc), buscar e VALIDAR a spec REAL contra o plan do ARCHITECTURE.md ou IMPLEMENTATION_ORDER.md. Plan inicial pode estar outdated. Divergências devem ser reportadas + Luccas decide entre adapt vs preserve.

**Why**: Sprint 4-A Fase 4 (commit `0c74bc4` — Open Delivery base client) descobriu 5 divergências reais entre o outline Fase 2 do plan (escrito pré-research) e a spec real Abrasel openapi.yaml v1.7.0 (~7939 LOC):
1. Plan tinha `X-App-Signature` outbound; spec v1.7.0 só inbound webhook
2. Plan tinha `/v1/batchDecrypt` endpoint; spec real NÃO tem (LGPD lazy decrypt é pattern paralelo, não endpoint)
3. Plan tinha 14 event types polling enum; spec real tem 15 canonical event types (event schema é fonte de verdade)
4. Plan tinha OAuth fields camelCase; spec real exige snake_case (`client_credentials`)
5. Plan tinha `/v1/orders/{id}/cancel`; spec real tem `/v1/orders/{id}/requestCancellation` (semantic directional CANCELLATION_REQUESTED vs CANCELLED_DENIED)

Impl PAUSOU mid-Fase 4 reportando divergências. Luccas decidiu **"Opção 1"**: adaptar Fase 4 pra spec real + manter Fase 2 outline como forward-compat (não jogar fora). Ação fundadora — sem isso, Sprint 4-A teria construído cliente quebrado contra spec real.

Tudo isso só foi capturado porque Impl rodou `WebFetch` na openapi.yaml ANTES de implementar — não confiando cegamente no plan.

**How to apply**:
- Fase de integração externa (REST/gRPC/webhook) → primeiro passo Impl: `WebFetch` ou fetch local da spec real
- Comparar campos, naming convention, endpoints, payload shape, status codes esperados contra outline ARCH.md
- Listar divergências em PR "PAUSE: divergências X, Y, Z" → AskUserQuestion: adaptar à spec OU manter plan?
- Default sane: **adapt à spec real** (Opção 1), manter plan outline como forward-compat se útil (Decryptor interface, EncryptedRef tipo, etc) — documentar em ADR
- ARCH.md plan é DIRECIONAL não FONTE-DE-VERDADE pra spec externa — fonte é o documento upstream (openapi.yaml, openapi.json, proto file, docs developer.X.com.br)
- Aplica-se a Sprint 4-B (99Food), Sprint 4-C+ (outros marketplaces), Sprint 5+ (notify provider Email/SMS/Push), Sprint 6.11 (Fiscal SEFAZ schemas), Sprint 7 (Abacate Pay/Stripe)

**Sinal de alerta**: se Impl começa implementando direto a partir de ARCH.md outline sem ter dado um `WebFetch` na spec real → PAUSAR + pedir spec-research primeiro.

**Update 2026-06-02 — Sprint 4-B Fase 5.5 lição expandida: spec oficial vs sandbox/prod gateway-specific divergence**

Sprint 4-B Fase 5.5 smoke real Abrasel sandbox (`api.opendelivery.com.br`) descobriu que **spec openapi.yaml v1.7.0 (canonical Abrasel) diverge do sandbox real Sensedia API Manager gateway**:
1. **Auth flow**: spec exige `client_id+client_secret` form-encoded body; sandbox real exige `Authorization: Basic base64(id:secret)` header + body só `grant_type+scope`
2. **2 BaseURLs distintos**: spec doc sugere 1 BaseURL; runtime real tem OAuth em `/od/oauth/token` (sem `/sb/v1`) vs APIs em `/od/sb/v1/*`. ARCH.md §8.2 já previa esse pattern ("baseURL for authentication" vs "baseURL for other routes")
3. **Sandbox-exclusive endpoints**: `PUT /sandbox/registration` + `POST /sandbox/orders` simulam Ordering Application — NÃO estão na spec v1.7.0 oficial

Mock httptest BistroOps Sprint 4-A/4-B usa form-encoded (cobre spec v1.7.0 documentado conforme padrão "spec-real-first") → 9 G4 PASS válidos. Mas **sandbox real exige Basic Auth** → dívida O-S4B-7 capturada.

**Lição expandida**:
- Spec oficial (openapi.yaml) é fonte canonical pra cliente SDK
- Sandbox real pode divergir (Sensedia/Apigee/Kong gateway-specific implementations)
- Produção real pode divergir AINDA mais (marketplace-specific tweaks: Keeta vs Food99 vs iFood prod)
- **Cliente SDK deve suportar config flag AuthMode = {FormEncoded, BasicAuth, Bearer}** pra cobrir variações sem refactor cross-marketplace
- **2 URLs structural** (OAuth + APIs) é pattern reusable — adicionar `Config.OAuthURL` separado de `Config.BaseURL` Sprint 4-C+
- Smoke real deve ser parte da fase final (5.5 Sprint 4-B pattern) — descobre runtime gaps que spec não documenta

**How to apply Sprint 4-C+ marketplaces (Rappi/UberEats/etc):**
1. Spec research first (canonical openapi.yaml ou docs developer.X.com.br)
2. Implementar cliente conforme spec
3. **Smoke real obrigatório fase final** — exercitar contra sandbox/staging real
4. Capturar divergências runtime spec vs real
5. Decidir: adapt cliente (config flag) vs document dívida vs forward-compat outline

**Custos vs benefícios**:
- Custo: ~5-15min spec-research adicional no início da fase
- Benefício: evita retrabalho 1-N fases (Sprint 4-A teria sido catastrófico — Fase 4 + 5 + 6 + 7 tinham que ser refeitas)

Relacionado: [[orchestrator-operation-mode]], [[feedback-fases-sequenciais]], [[project-bloco-c-moved-to-sprint-3]], [[project-keeta-sandbox-pending]]
