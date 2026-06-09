---
name: feedback-secrets-protection
description: JAMAIS copiar credenciais reais (API tokens, access keys, secrets) no chat history. Lição Sprint 5 Fase 2 R2 vazamento — rotacionar imediatamente se vazar.
metadata:
  node_type: memory
  type: feedback
  originSessionId: current
---

**Regra**: JAMAIS copiar credenciais reais no chat history dos agentes (Impl/Rev/QA/orch). Token API, access key, secret, certificado, password — NADA. Sempre referenciar por nome de env var.

**Why**: Sprint 5 Fase 2 (2026-06-03, commit `f2d42a4`) Impl debugou R2 Cloudflare wire e copiou 3 credenciais reais no chat:
- Cloudflare API Token Bearer (`cfat_pm17Jr...`)
- R2 Access Key ID (`85a059cb...`)
- R2 Secret Access Key (`5a44717b...`)

Esses tokens dão acesso completo ao bucket `bistro-ops` R2 (read/write/delete). Chat history pode ser persistido localmente (logs Claude Code) ou em backups — quem tiver acesso pode usar essas credenciais sem autorização. Risk window indefinido até Luccas rotacionar via Cloudflare dashboard.

**How to apply**:

PRA AGENTES (Impl/Rev/QA):
- **NUNCA** copiar valor real de:
  - API tokens (Bearer, OAuth, Cloudflare API token, GitHub PAT, etc)
  - Access keys (R2, S3, AWS IAM, GCP service account JSON)
  - Secrets (database password, JWT signing key, encryption key)
  - Certificados (mTLS client cert, fiscal A1/A3, etc)
  - Connection strings com password embedded (`postgres://user:PASS@host`)
- **SEMPRE** referenciar por nome:
  - "R2_ACCESS_KEY_ID está em apps/api/.env.example"
  - "Cloudflare API Token configurado em GitHub Actions secrets CLOUDFLARE_API_TOKEN"
  - "DATABASE_URL em .env (sem expor password)"
- **Smoke tests** com credenciais reais: rodar localmente, NUNCA postar output incluindo tokens
  - Se precisar mostrar comando: `aws s3 ls s3://bucket/ --profile bistroops` (sem expor key/secret)
  - Output: descrever resultado, NÃO copiar response que pode incluir token em URL/header

PRA REV (após detecção vazamento):
- **FIX OBRIGATÓRIO PRÉ-MERGE**: rotacionar TODAS credenciais vazadas via provider dashboard
- Documentar em PR description: "credenciais rotacionadas em <data> via <provider>"
- Verificar logs de uso unauthorized entre vazamento e rotação (defesa em profundidade)
- Considerar curto blackout do bucket/recurso se evidência de abuso

PRA LUCCAS (action items):
- Rotacionar Cloudflare R2 tokens via dashboard → R2 → Manage API tokens → Roll
- Update local `.env` + GitHub Actions secrets (`R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `CLOUDFLARE_API_TOKEN`)
- Verificar Cloudflare audit log entre 2026-06-03 (vazamento) e rotação por uso anômalo

**Aplica-se a TODOS futuros providers que usam credenciais**:
- Cloudflare (R2, Workers, KV)
- AWS/GCP/Azure
- iFood (Sprint 3-A, memory `project-ifood-credentials-pending`)
- Keeta (Sprint 4-A, memory `project-keeta-sandbox-pending`)
- Stripe + Abacate Pay (Sprint 7 payments)
- Resend (email transactional)
- SEFAZ (Sprint 6.11 fiscal certificados A1/A3)

**Sinal de alerta**:
- Se Impl/QA pede "qual é o valor de X_SECRET?" → PAUSAR + remind: referenciar por nome
- Se algum agente copia string que parece token (UUID-like, base64-ish 32+ chars) → revisar contexto

**Custos vs benefícios**:
- Custo: ~zero (apenas hábito de referenciar nome em vez de valor)
- Benefício: zero credenciais expostas em chat history = zero risk de uso unauthorized

Relacionado: [[project-ifood-credentials-pending]], [[project-keeta-sandbox-pending]]. Lição arquitetural: chat history dos agentes é ephemeral pra agente MAS persistente pra quem tem acesso ao log — tratar como public log.
