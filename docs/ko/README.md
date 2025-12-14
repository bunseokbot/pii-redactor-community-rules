# PII Redactor 커뮤니티 규칙

[PII Redactor](https://github.com/bunseokbot/pii-redactor)를 위한 커뮤니티 기여 PII 패턴 저장소입니다.

[![Rule Validation](https://github.com/bunseokbot/pii-redactor-community-rules/actions/workflows/validate.yaml/badge.svg)](https://github.com/bunseokbot/pii-redactor-community-rules/actions/workflows/validate.yaml)

*[English](../../README.md)*

## 개요

이 저장소는 카테고리와 성숙도 수준별로 정리된 커뮤니티 기여 PII 탐지 패턴을 포함하고 있습니다. 각 패턴에는 정규식 규칙, 테스트 케이스, 마스킹 설정이 포함되어 있습니다.

## 성숙도 수준

[Falco rules](https://github.com/falcosecurity/rules)에서 영감을 받아 패턴을 성숙도 수준별로 구분합니다:

| 수준 | 설명 |
|------|------|
| 🟢 **stable** | 프로덕션 준비 완료, 광범위하게 테스트됨 |
| 🟡 **incubating** | 활발히 개발 중, 변경될 수 있음 |
| 🔴 **sandbox** | 실험적, 커뮤니티 기여 |
| ⚫ **deprecated** | 제거 예정 |

## 저장소 구조

```
rules/
├── global/                 # 전 세계 공통 패턴
│   ├── email.yaml
│   ├── credit-card.yaml
│   └── ...
├── usa/                    # 미국 전용 패턴
│   ├── ssn.yaml
│   ├── phone.yaml
│   ├── itin.yaml
│   └── ...
├── korea/                  # 한국 전용 패턴
│   ├── rrn.yaml
│   ├── phone.yaml
│   └── ...
├── eu/                     # EU 전용 패턴
│   └── ...
├── secrets/                # API 키, 토큰, 자격증명
│   ├── aws.yaml
│   ├── github.yaml
│   └── ...
└── compliance/             # 컴플라이언스 전용 패턴
    ├── pci-dss/
    ├── hipaa/
    └── gdpr/

validators/                 # 커스텀 검증 스크립트 (Lua)
├── luhn.lua
├── rrn-checksum.lua
└── ...

index.yaml                  # 메인 인덱스 파일
```

## 패턴 형식

```yaml
apiVersion: community.namjun.kim/v1
kind: PIIPattern
metadata:
  name: pattern-name
  version: "1.0.0"
  maturity: stable  # stable, incubating, sandbox, deprecated

spec:
  displayName: "사람이 읽을 수 있는 이름"
  description: "이 패턴이 탐지하는 내용에 대한 설명"
  category: usa

  patterns:
    - regex: '\b\d{3}-\d{2}-\d{4}\b'
      confidence: high

  validator: luhn  # 선택사항

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

## 구독 방법

### 기본 구독

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

### 성숙도 수준 지정

```yaml
apiVersion: pii.namjun.kim/v1alpha1
kind: PIIRuleSubscription
metadata:
  name: production
  namespace: pii-system
spec:
  sourceRef:
    name: community
  # 프로덕션에서는 stable 패턴만 사용
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
  # 개발 환경에서는 실험적 패턴 포함
  maturityLevels:
    - stable
    - incubating
    - sandbox
  subscribe:
    - category: secrets
      patterns: ["*"]
```

## 기여하기

### 1. Fork 및 Clone

```bash
git clone https://github.com/YOUR_USERNAME/pii-redactor-community-rules.git
cd pii-redactor-community-rules
```

### 2. 패턴 생성

```bash
make new-pattern CATEGORY=usa NAME=my-pattern
```

### 3. 검증

```bash
make validate
make lint
```

### 4. Pull Request 제출

- 새 패턴은 `maturity: sandbox`로 시작해야 합니다
- 최소 2개의 `shouldMatch`와 1개의 `shouldNotMatch` 테스트 케이스를 포함해야 합니다

### 성숙도 승격

1. **sandbox → incubating**: 커뮤니티 리뷰 및 30일 사용 후
2. **incubating → stable**: 90일 경과 및 메인테이너 승인 후
3. **any → deprecated**: 더 나은 대안이 존재할 때

## 카테고리

| 카테고리 | 설명 |
|----------|------|
| `global` | 전 세계 공통 패턴 |
| `usa` | 미국 전용 PII |
| `korea` | 한국 전용 PII |
| `eu` | EU 전용 PII |
| `secrets` | API 키, 토큰, 자격증명 |
| `compliance/*` | 컴플라이언스 전용 패턴 |

## 라이선스

Apache License 2.0

## 메인테이너

- [@bunseokbot](https://github.com/bunseokbot)
