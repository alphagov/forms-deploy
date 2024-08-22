ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
CODEBUILD_CI ?= false
SHELL=/usr/bin/env bash

##
# Environment targets
##
target_environment_set:
	$(if ${TARGET_ENVIRONMENT},,$(error Target environment is not set. Try adding an environment target, such as 'dev' or 'production', before the final target. (e.g. 'make dev apply')))
	@true

.PHONY: dev development
dev development:
	$(eval export TARGET_ENVIRONMENT = dev)
	@true

.PHONY: staging
staging:
	$(eval export TARGET_ENVIRONMENT = staging)
	@true

.PHONY: prod production
prod production:
	$(eval export TARGET_ENVIRONMENT = production)
	@true

.PHONY: user-research
user-research:
	$(eval export TARGET_ENVIRONMENT = user-research)
	@true

.PHONY: deploy
deploy:
	$(eval export TARGET_ENVIRONMENT = deploy)
	@true

##
# Terraform root targets
#
# You may be tempted to simplify "-mindepth 1 -maxdepth 1" to "-depth 1" but this will only work on developer machines,
# and will break in CI/CD environments which use a newer version of find which has deprecate "-depth N".
##
FORMS_TF_ROOTS = $(shell cd infra/deployments; find forms -mindepth 1 -maxdepth 1 -type d -not -path "*/tfvars" -not -path "*/.terraform")
DEPLOY_TF_ROOTS = $(shell cd infra/deployments; find deploy -mindepth 1 -maxdepth 1 -type d -not -path "*/tfvars" -not -path "*/.terraform")

target_tf_root_set:
	$(if ${TARGET_TF_ROOT},,$(error Target Terraform root is not set. Try adding an Terraform root target before the final target. Terraform root targets are directories relative to 'infra/deployments/', such as 'forms/dns'.))
	@true

# "$(@:forms/%=%)" is removing the "forms/" prefix from the chosen root.
# The prefix is useful for a user, but when scripting we want only the
# name of the directory.
$(FORMS_TF_ROOTS):
	$(eval export TARGET_DEPLOYMENT = forms)
	$(eval export TARGET_TF_ROOT = $(@:forms/%=%))
	@true

$(DEPLOY_TF_ROOTS):
	$(eval export TARGET_DEPLOYMENT = deploy)
	$(eval export TARGET_TF_ROOT = $(@:deploy/%=%))
	@true

account:
	$(eval export TARGET_DEPLOYMENT = account)
	$(eval export TARGET_TF_ROOT = account)
	@true

##
# Action targets
##
aws_credentials_available:
	@if [ "${CODEBUILD_CI}" = false ]; then \
		if [ -z "${AWS_SESSION_TOKEN}" ]; then \
		 	>&2 echo "'AWS_SESSION_TOKEN' was not found among your environment variables. Make sure you've assumed a role in the AWS account you're targetting."; \
		 	false; \
	 	fi; \
 	else \
 		>2& echo "CodeBuild detected. Assuming credentials are present in the environment."; \
 	fi;
	@true

show_info:
	@echo ""
	@echo "========[Terraform target information]"
	@echo "=> Target environment:     $${TARGET_ENVIRONMENT}"
	@echo "=> Target deployment:      $${TARGET_DEPLOYMENT}"
	@echo "=> Terraform root:         $${TARGET_TF_ROOT}"
	@if env | grep "TF_VAR_" >/dev/null 2>&1; then \
  		echo "=> Overridden Terraform variables:"; \
  		env | grep TF_VAR_ | sed 's/^TF_VAR_//g' | xargs printf "\t%s\n"; \
  	fi
	@echo "========"
	@echo ""

.PHONY: init
init: target_environment_set target_tf_root_set aws_credentials_available show_info
	@./support/invoke-terraform.sh -a init -d "$${TARGET_DEPLOYMENT}" -e "$${TARGET_ENVIRONMENT}" -r "$${TARGET_TF_ROOT}"

.PHONY: plan
plan: init
	@./support/invoke-terraform.sh -a plan -d "$${TARGET_DEPLOYMENT}" -e "$${TARGET_ENVIRONMENT}" -r "$${TARGET_TF_ROOT}"

.PHONY: apply
apply: init
	@./support/invoke-terraform.sh -a apply -d "$${TARGET_DEPLOYMENT}" -e "$${TARGET_ENVIRONMENT}" -r "$${TARGET_TF_ROOT}"

.PHONY: validate
validate: init
	@./support/invoke-terraform.sh -a validate -d "$${TARGET_DEPLOYMENT}" -e "$${TARGET_ENVIRONMENT}" -r "$${TARGET_TF_ROOT}"

##
# Utility targets
##
.PHONY: generate-completion-word-list
generate-completion-word-list:
	@$(MAKE) -qprRn -f "Makefile" : 2>/dev/null | grep -E "^([[:alnum:][:punct:]]+)\:.*$$" | cut -d ':' -f 1 | sed '/^ *$$/d'

.PHONY: fmt
fmt:
	terraform fmt -recursive infra/

.PHONY: lint
lint: checkov spec lint_ruby

.PHONY: lint_ruby
lint_ruby:
	bundle install
	bundle exec rubocop

.PHONY: checkov
checkov:
	checkov -d infra/ --external-checks-dir infra/checkov/ --framework terraform --quiet --skip-download

.PHONY: spec
spec:
	(cd infra; bundle install; bundle exec rspec;)
	(cd support/pipeline-visualiser; bundle install; bundle exec rspec;)
	(cd infra/deployments/forms/pipelines/pipeline-invoker; bundle install; bundle exec rspec;)

##
# Help text
# Keep it at the bottom so it can grow as necessary without cluttering everything above.
# The formatting may look off in this file, but it should be correct when written to stdout.
##
define help_usage_text
PURPOSE
	This Makefile has two general use cases:
	1. Running Terraform
	2. Running tasks

RUNNING TERRAFORM
	To run Terraform code use the command

		make <ENV> <ROOT> <ACTION>

	where <ENV> is an environment name, <ROOT> is a Terraform root,
	and <ACTION> is an action to take with the Terraform code.

	The valid options for <ENV>, <ROOT>, and <ACTION> are documented below.

	To run the Terraform code, you will need to have credentials for the
	relevant environment. You should use GDS CLI to get them. For example

		gds aws forms-dev-readonly -- make dev forms/environment plan

RUNNING OTHER TASKS
	To run other tasks use the command

		make <TASK>

	where <TASK> is one of the other tasks documented below.

endef
export help_usage_text

define help_environments
ENVIRONMENTS
	deploy		Central account for things like image repositories, and
			image building pipelines.
			n.b. deployments do not take place in this account. The
			name is a legacy from when they did.

	dev/development		The development environment
	staging			The staging environment
	user-research		The user-research environment
	prod/production		The production environment

endef
export help_environments

define help_actions
ACTIONS
	validate	Validate the syntax of the Terraform files
	init		Initialise the Terraform root
	plan		Run a Terraform plan
	apply		Apply the Terraform

endef
export help_actions

define help_tasks
TASKS
	help		This help text
	fmt		Automatically format all Terraform code
	lint		Run all linting tasks
	checkov		Run Checkov (a Terraform linter) against all Terraform code
	lint_ruby	Run Rubocop against all Ruby code
	spec		Run Rspec tests against Ruby and Terraform code
endef
export help_tasks

.PHONY: help
help:
	@echo "$$help_usage_text"
	@echo "$$help_environments"
	@echo "ROOTS"
	@for r in $(sort account $(FORMS_TF_ROOTS) $(DEPLOY_TF_ROOTS)); do \
  		printf "\t%s\n" $$r; \
	done; \
	echo "" \

	@echo "$$help_actions"
	@echo "$$help_tasks"
	@true
