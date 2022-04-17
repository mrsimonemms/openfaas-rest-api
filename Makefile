AUTHOR = Simon Emms <https://simonemms.com>
LICENSE = AGPL-3.0
FUNC_FILE ?= './functions.yaml'
K3D_CONFIG ?= './k3d.config.yaml'

all: deps destroy templates install provision

define check_dependency
	@which $(1) > /dev/null || (echo "$(1) not installed - see $(2) to install" && exit 1)
endef

deps:
	$(call check_dependency,docker,https://docs.docker.com/get-docker/)
	$(call check_dependency,faas,https://docs.openfaas.com/cli/install)
	$(call check_dependency,helm,https://helm.sh/docs/intro/install)
	$(call check_dependency,jq,https://stedolan.github.io/jq/download/)
	$(call check_dependency,k3d,"https://k3d.io/#installation")
	$(call check_dependency,kubectl,https://kubernetes.io/docs/tasks/tools)

	@echo "All dependencies are available"
.PHONY: deps

destroy:
	skaffold config unset local-cluster
	skaffold config unset default-repo
	skaffold config unset kube-context
	#k3d cluster delete --config ${K3D_CONFIG} # @todo(sje): use when https://github.com/k3d-io/k3d/pull/1054 merged
	k3d cluster delete openfaas
	rm -Rf build
.PHONY: destroy

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

provision:
	k3d cluster create --config ${K3D_CONFIG} || true
	skaffold config set local-cluster false
	skaffold config set default-repo registry.localhost:5000
	kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
.PHONY: provision

templates:
	faas template pull https://gitlab.com/MrSimonEmms/openfaas-templates
.PHONY: templates
