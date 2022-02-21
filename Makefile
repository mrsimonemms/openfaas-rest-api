AUTHOR = Simon Emms <https://simonemms.com>
LICENSE = AGPL-3.0
FUNC_FILE ?= './functions.yaml'

all: deps templates install

define check_dependency
	@which $(1) > /dev/null || (echo "$(1) not installed - see $(2) to install" && exit 1)
endef

deps:
	$(call check_dependency,faas,https://docs.openfaas.com/cli/install)
	$(call check_dependency,helm,https://helm.sh/docs/intro/install)
	$(call check_dependency,jq,https://stedolan.github.io/jq/download/)
	$(call check_dependency,kubectl,https://kubernetes.io/docs/tasks/tools)

	@echo "All dependencies are available"
.PHONY: deps

install:
	npm ci

	for template in ./template/* ; do \
		cd $$template; \
		npm ci; \
	done
.PHONY: install

new:
	faas new ${FN_NAME} \
		--lang mongoose-crud \
		--append functions.yaml \
		--handler components/${FN_NAME}

	@jq '.name = "${FN_NAME}"' components/${FN_NAME}/package.json > .tmp
	@mv .tmp components/${FN_NAME}/package.json

	@jq '.private = true' components/${FN_NAME}/package.json > .tmp
	@mv .tmp components/${FN_NAME}/package.json

	@jq '.private = true' components/${FN_NAME}/package.json > .tmp
	@mv .tmp components/${FN_NAME}/package.json

	@jq '.license = "${LICENSE}"' components/${FN_NAME}/package.json > .tmp
	@mv .tmp components/${FN_NAME}/package.json

	@jq '.author = "${AUTHOR}"' components/${FN_NAME}/package.json > .tmp
	@mv .tmp components/${FN_NAME}/package.json

	@jq '.name = "${FN_NAME}"' components/${FN_NAME}/package-lock.json > .tmp
	@mv .tmp components/${FN_NAME}/package-lock.json

	@echo "Created new function: ${FN_NAME}"
.PHONY: new

openfaas:
	@echo "--- OpenFaaS credentials ---"
	@echo "  URL:      http://localhost:8080"
	@echo "  Username: $(shell kubectl get secrets -n openfaas basic-auth -o jsonpath='{.data.basic-auth-user}' | base64 -d)"
	@echo "  Password: $(shell kubectl get secrets -n openfaas basic-auth -o jsonpath='{.data.basic-auth-password}' | base64 -d)"
	@echo "----------------------------"
.PHONY: openfaas

templates:
	faas template pull https://gitlab.com/MrSimonEmms/openfaas-templates
.PHONY: templates
