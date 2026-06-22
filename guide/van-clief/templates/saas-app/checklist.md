# SaaS App — Deliverables Checklist

## Database

- [ ] Migration files for all tables (users, subscriptions, domain objects)
- [ ] Seed data for development

## Authentication

- [ ] Sign up / login / logout
- [ ] Session management
- [ ] Password reset flow
- [ ] Protected route middleware

## Core Product

- [ ] API endpoints (CRUD for main domain)
- [ ] Input validation on all endpoints
- [ ] Error handling + HTTP status codes

## Billing

- [ ] Stripe checkout session
- [ ] Webhook handler (subscription created/updated/deleted)
- [ ] Plan enforcement (free vs paid feature gates)

## Frontend

- [ ] Auth pages (sign in, sign up, forgot password)
- [ ] Dashboard layout with navigation
- [ ] Core product screens wired to API
- [ ] Loading and error states

## Testing

- [ ] Auth flow tests
- [ ] Core API endpoint tests
- [ ] Billing webhook tests

## Deploy

- [ ] Environment variables documented
- [ ] Vercel project configured
- [ ] Production database provisioned
- [ ] Deploy verified (smoke test after deploy)
