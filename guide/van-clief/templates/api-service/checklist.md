# API Service — Deliverables Checklist

## Design

- [ ] OpenAPI spec (openapi.yaml) with all endpoints
- [ ] Database schema (migration files)
- [ ] Auth strategy documented

## Auth

- [ ] API key or JWT validation middleware
- [ ] Rate limiting
- [ ] Request logging

## Endpoints

- [ ] All endpoints implemented per spec
- [ ] Input validation on every endpoint
- [ ] Consistent error response shape
- [ ] HTTP status codes correct

## Tests

- [ ] Happy path tests for all endpoints
- [ ] Auth rejection tests
- [ ] Input validation edge cases
- [ ] Rate limit enforcement test

## Documentation

- [ ] README with quickstart (< 5 minutes to first API call)
- [ ] Endpoint reference (generated from OpenAPI)
- [ ] curl examples for each endpoint
- [ ] Python/JS SDK examples

## Deploy

- [ ] Environment variables documented
- [ ] Database provisioned + migrated
- [ ] Deploy verified (curl smoke test against production URL)
