ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

##
# Environment targets
##
target_environment_set:
	$(if ${TARGET_ENVIRONMENT},,$(error Target environment is not set. Try adding an environment target, such as 'dev' or 'production', before the final target. (e.g. 'make dev apply')))
	@true

.PHONY: dev
dev:
	$(eval export TARGET_ENVIRONMENT = dev)
	$(eval export TFVARS_FILE = dev.tfvars)
	$(eval export BACKEND_TFVARS_FILE = dev.tfvars)
	@true
	
.PHONY: staging
staging:
	$(eval export TARGET_ENVIRONMENT = staging)
	$(eval export TFVARS_FILE = staging.tfvars)
	$(eval export BACKEND_TFVARS_FILE = staging.tfvars)
	@true
	
.PHONY: production
production:
	$(eval export TARGET_ENVIRONMENT = production)
	$(eval export TFVARS_FILE = production.tfvars)
	$(eval export BACKEND_TFVARS_FILE = production.tfvars)
	@true
	
.PHONY: user-research
user-research:
	$(eval export TARGET_ENVIRONMENT = user-research)
	$(eval export TFVARS_FILE = user-research.tfvars)
	$(eval export BACKEND_TFVARS_FILE = user-research.tfvars)
	@true	

##
# Terraform root targets
##
FORMS_TF_ROOTS = $(shell cd infra/deployments; find forms -type d -depth 1 -not -path "*/tfvars" -not -path "*/.terraform")

target_tf_root_set:
	$(if ${TARGET_TF_ROOT},,$(error Target Terraform root is not set. Try adding an Terraform root target before the final target. Terraform root targets are directories relative to 'infra/deployments/', such as 'forms/dns'.))
	@true
	
$(FORMS_TF_ROOTS):
	$(eval export TARGET_TF_ROOT = $@)
	$(eval export TFVARS_DIR = ${ROOT_DIR}/infra/deployments/forms/tfvars)
	@true
	
##
# Action targets
##
aws_credentials_available:
	$(if ${AWS_SESSION_TOKEN},, $(error 'AWS_SESSION_TOKEN' was not found among your environment variables. Make sure you've assumed a role in the AWS account you're targetting.))
	@true
	
show_info:
	@echo "Target environment: $${TARGET_ENVIRONMENT}"
	@echo "Terraform root: $${TARGET_TF_ROOT}"
	
.PHONY: init
init: target_environment_set target_tf_root_set aws_credentials_available show_info
	@terraform \
		-chdir="${ROOT_DIR}/infra/deployments/$${TARGET_TF_ROOT}" \
		init \
		-backend-config "${ROOT_DIR}/infra/deployments/account/tfvars/backends/$${BACKEND_TFVARS_FILE}" \
		-reconfigure

.PHONY: plan
plan: init
	@terraform \
		-chdir="${ROOT_DIR}/infra/deployments/$${TARGET_TF_ROOT}" \
		plan \
		-var-file "$${TFVARS_DIR}/$${TFVARS_FILE}"

.PHONY: apply
apply: init
	@terraform \
		-chdir="${ROOT_DIR}/infra/deployments/$${TARGET_TF_ROOT}" \
		apply \
		-var-file "$${TFVARS_DIR}/$${TFVARS_FILE}"
		
##
# Utility targets
##
.PHONY: generate-completion-word-list
generate-completion-word-list:
	@$(MAKE) -qprRn -f "Makefile" : 2>/dev/null | grep -E "^([[:alnum:][:punct:]]+)\:.*$$" | cut -d ':' -f 1 | sed '/^ *$$/d'