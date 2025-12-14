# PII Redactor Community Rules

Community-contributed PII patterns for [PII Redactor](https://github.com/bunseokbot/pii-redactor).

[![Rule Validation](https://github.com/bunseokbot/pii-redactor-community-rules/actions/workflows/validate.yaml/badge.svg)](https://github.com/bunseokbot/pii-redactor-community-rules/actions/workflows/validate.yaml)

*[한국어](docs/ko/README.md)*

## Overview

This repository contains community-contributed PII detection patterns organized by category and maturity level. Each pattern includes regex rules, test cases, and masking configurations.

## Maturity Levels

Inspired by [Falco rules](https://github.com/falcosecurity/rules), patterns are organized by maturity level:

| Level | Description |
|-------|-------------|
| 🟢 **stable** | Production-ready, extensively tested |
| 🟡 **incubating** | Under active development, may change |
| 🔴 **sandbox** | Experimental, community contributed |
| ⚫ **deprecated** | Scheduled for removal |

## Repository Structure

```
rules/
├── global/                 # Patterns applicable worldwide
│   ├── email.yaml
│   ├── credit-card.yaml
│   └── ...
├── usa/                    # USA-specific patterns
│   ├── ssn.yaml
│   ├── phone.yaml
│   ├── itin.yaml
│   └── ...
├── korea/                  # Korea-specific patterns
│   ├── rrn.yaml
│   ├── phone.yaml
│   └── ...
├── eu/                     # EU-specific patterns
│   └── ...
├── secrets/                # API keys, tokens, credentials
│   ├── aws.yaml
│   ├── github.yaml
│   └── ...
└── compliance/             # Compliance-specific patterns
    ├── pci-dss/
    ├── hipaa/
    └── gdpr/

validators/                 # Custom validation scripts (Lua)
├── luhn.lua
├── rrn-checksum.lua
└── ...

index.yaml                  # Main index file
```

## Pattern Format

```yaml
apiVersion: community.namjun.kim/v1
kind: PIIPattern
metadata:
  name: pattern-name
  version: "1.0.0"
  maturity: stable  # stable, incubating, sandbox, deprecated

spec:
  displayName: "Human Readable Name"
  description: "Description of what this pattern detects"
  category: usa

  patterns:
    - regex: '\b\d{3}-\d{2}-\d{4}\b'
      confidence: high

  validator: luhn  # Optional

  maskingStrategy:
    type: partial
    showFirst: 0
    showLast: 4
    maskChar: "*"

  severity: critical

  testCases:
    shouldMatch:
      - "123-45-6789"
      - "SSN: 123-45-6789"
    shouldNotMatch:
      - "123-456-789"

  references:
    - "https://www.ssa.gov/employer/randomization.html"
  maintainers:
    - "@github-username"
  tags:
    - pii
    - ssn
```

## How to Subscribe

### Basic Subscription

```yaml
apiVersion: pii.namjun.kim/v1alpha1
kind: PIICommunitySource
metadata:
  name: community
  namespace: pii-system
spec:
  type: git
  git:
    url: https://github.com/bunseokbot/pii-redactor-community-rules
    ref: main
    path: rules
  sync:
    interval: "1h"
---
apiVersion: pii.namjun.kim/v1alpha1
kind: PIIRuleSubscription
metadata:
  name: my-subscription
  namespace: pii-system
spec:
  sourceRef:
    name: community
  subscribe:
    - category: usa
      patterns: ["*"]
    - category: secrets
      patterns: ["aws-*", "github-*"]
```

### Specifying Maturity Levels

```yaml
apiVersion: pii.namjun.kim/v1alpha1
kind: PIIRuleSubscription
metadata:
  name: production
  namespace: pii-system
spec:
  sourceRef:
    name: community
  # Only use stable patterns in production
  maturityLevels:
    - stable
  subscribe:
    - category: usa
      patterns: ["*"]
---
apiVersion: pii.namjun.kim/v1alpha1
kind: PIIRuleSubscription
metadata:
  name: development
  namespace: pii-system-dev
spec:
  sourceRef:
    name: community
  # Include experimental patterns in dev
  maturityLevels:
    - stable
    - incubating
    - sandbox
  subscribe:
    - category: secrets
      patterns: ["*"]
```

## Contributing

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/pii-redactor-community-rules.git
cd pii-redactor-community-rules
```

### 2. Create Your Pattern

```bash
make new-pattern CATEGORY=usa NAME=my-pattern
```

### 3. Validate

```bash
make validate
make lint
```

### 4. Submit Pull Request

- New patterns should start with `maturity: sandbox`
- Include at least 2 `shouldMatch` and 1 `shouldNotMatch` test cases

### Maturity Promotion

1. **sandbox → incubating**: After community review and 30 days of usage
2. **incubating → stable**: After 90 days and maintainer approval
3. **any → deprecated**: When better alternatives exist

## Categories

| Category | Description |
|----------|-------------|
| `global` | Patterns applicable worldwide |
| `usa` | USA-specific PII |
| `korea` | Korea-specific PII |
| `eu` | EU-specific PII |
| `secrets` | API keys, tokens, credentials |
| `compliance/*` | Compliance-specific patterns |

## License

Apache License 2.0

## Maintainers

- [@bunseokbot](https://github.com/bunseokbot)
