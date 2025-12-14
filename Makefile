.PHONY: help validate lint test clean

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

validate: ## Validate all pattern files
	@echo "Validating pattern files..."
	@find rules -name "*.yaml" -o -name "*.yml" | while read file; do \
		echo "Validating: $$file"; \
		python3 -c "import yaml; yaml.safe_load(open('$$file'))" || exit 1; \
	done
	@echo "All patterns validated successfully!"

lint: ## Lint pattern files
	@echo "Linting pattern files..."
	@# Check for duplicate names
	@names=$$(find rules -name "*.yaml" -o -name "*.yml" -exec grep -h "^  name:" {} \; | sort); \
	duplicates=$$(echo "$$names" | uniq -d); \
	if [ -n "$$duplicates" ]; then \
		echo "Duplicate pattern names found:"; \
		echo "$$duplicates"; \
		exit 1; \
	fi
	@echo "Lint passed!"

test: ## Test patterns with pii-redactor CLI
	@echo "Testing patterns..."
	@if command -v pii-redactor &> /dev/null; then \
		find rules -name "*.yaml" -o -name "*.yml" | while read file; do \
			echo "Testing: $$file"; \
			pii-redactor rules test "$$file" || exit 1; \
		done; \
	else \
		echo "pii-redactor CLI not found. Install with: go install github.com/bunseokbot/pii-redactor/cmd/cli@latest"; \
	fi

count: ## Count total patterns
	@echo "Pattern count by category:"
	@for dir in rules/*/; do \
		count=$$(find "$$dir" -name "*.yaml" -o -name "*.yml" 2>/dev/null | wc -l | tr -d ' '); \
		if [ "$$count" -gt 0 ]; then \
			echo "  $$(basename $$dir): $$count"; \
		fi; \
	done
	@total=$$(find rules -name "*.yaml" -o -name "*.yml" | wc -l | tr -d ' ')
	@echo "Total: $$total patterns"

new-pattern: ## Create a new pattern (usage: make new-pattern CATEGORY=usa NAME=my-pattern)
ifndef CATEGORY
	$(error CATEGORY is not set. Usage: make new-pattern CATEGORY=usa NAME=my-pattern)
endif
ifndef NAME
	$(error NAME is not set. Usage: make new-pattern CATEGORY=usa NAME=my-pattern)
endif
	@mkdir -p rules/$(CATEGORY)
	@cat > rules/$(CATEGORY)/$(NAME).yaml << 'TEMPLATE'
apiVersion: community.namjun.kim/v1
kind: PIIPattern
metadata:
  name: $(NAME)
  version: "1.0.0"
  # Maturity levels: stable, incubating, sandbox, deprecated
  maturity: sandbox

spec:
  displayName: "TODO: Display Name"
  description: "TODO: Description"
  category: $(CATEGORY)

  patterns:
    - regex: 'TODO: your-regex-here'
      confidence: high

  maskingStrategy:
    type: partial
    showFirst: 0
    showLast: 4
    maskChar: "*"

  severity: high

  testCases:
    shouldMatch:
      - "TODO: matching example 1"
      - "TODO: matching example 2"
    shouldNotMatch:
      - "TODO: non-matching example"

  references:
    - "TODO: documentation URL"

  maintainers:
    - "@your-github-username"

  tags:
    - pii
TEMPLATE
	@echo "Created: rules/$(CATEGORY)/$(NAME).yaml"
	@echo "Edit the file and replace TODO placeholders"

clean: ## Clean generated files
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -delete
	@echo "Cleaned!"
