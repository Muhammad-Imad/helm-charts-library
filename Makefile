SHELL := /bin/bash
CHARTS := common web-service worker
APP_CHARTS := web-service worker
HELM ?= helm
CT ?= ct

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: deps
deps: ## Update chart dependencies (pulls the common library into app charts).
	@for c in $(APP_CHARTS); do \
		echo ">> helm dependency update charts/$$c"; \
		$(HELM) dependency update charts/$$c; \
	done

.PHONY: lint
lint: ## Lint all charts with chart-testing.
	$(CT) lint --config ct.yaml --all

.PHONY: template
template: deps ## Render templates for the application charts.
	@for c in $(APP_CHARTS); do \
		echo "=== charts/$$c ==="; \
		$(HELM) template demo charts/$$c; \
	done

.PHONY: test
test: deps ## Run helm-unittest suites.
	$(HELM) unittest $(addprefix charts/,$(APP_CHARTS))

.PHONY: package
package: deps ## Package each chart into ./.cr-release-packages.
	@mkdir -p .cr-release-packages
	@for c in $(CHARTS); do \
		$(HELM) package charts/$$c --destination .cr-release-packages; \
	done

.PHONY: docs
docs: ## Regenerate README value tables with helm-docs.
	@command -v helm-docs >/dev/null 2>&1 || { echo "helm-docs not installed: https://github.com/norwoodj/helm-docs"; exit 1; }
	helm-docs --chart-search-root charts

.PHONY: schema
schema: ## Validate values against each chart's values.schema.json.
	@for c in $(APP_CHARTS); do \
		echo ">> $(HELM) lint --strict charts/$$c"; \
		$(HELM) lint --strict charts/$$c; \
	done

.PHONY: clean
clean: ## Remove build artifacts.
	rm -rf .cr-release-packages charts/*/charts charts/*/Chart.lock rendered
