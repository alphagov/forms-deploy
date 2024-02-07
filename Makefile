ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

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
	$(if ${AWS_SESSION_TOKEN},, $(error 'AWS_SESSION_TOKEN' was not found among your environment variables. Make sure you've assumed a role in the AWS account you're targetting.))
	@true
	
show_info:
	@echo ""
	@echo "========[Terraform target information]"
	@echo "=> Target environment:     $${TARGET_ENVIRONMENT}"
	@echo "=> Target deployment:      $${TARGET_DEPLOYMENT}"
	@echo "=> Terraform root:         $${TARGET_TF_ROOT}"
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
		
.PHONY:
validate: init
	@./support/invoke-terraform.sh -a validate -d "$${TARGET_DEPLOYMENT}" -e "$${TARGET_ENVIRONMENT}" -r "$${TARGET_TF_ROOT}"
##
# Utility targets
##
.PHONY: generate-completion-word-list
generate-completion-word-list:
	@$(MAKE) -qprRn -f "Makefile" : 2>/dev/null | grep -E "^([[:alnum:][:punct:]]+)\:.*$$" | cut -d ':' -f 1 | sed '/^ *$$/d'