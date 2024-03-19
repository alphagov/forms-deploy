.DEFAULT: run

.PHONY: run
run:
	CREDS_JSON="$$(aws sts assume-role --role-arn "arn:aws:iam::711966560482:role/deploy-pipeline-visualiser-ecs-task" --role-session-name "run-pipeline-visualiser")"; \
    AWS_ACCESS_KEY_ID="$$(echo "$${CREDS_JSON}" | jq -r '.Credentials.AccessKeyId')" \
    AWS_SECRET_ACCESS_KEY="$$(echo "$${CREDS_JSON}" | jq -r '.Credentials.SecretAccessKey')" \
    AWS_SESSION_TOKEN="$$(echo "$${CREDS_JSON}" | jq -r '.Credentials.SessionToken')" \
	ruby index.rb

.PHONY: dev
dev:
	PIPELINE_VISUALISER_DEV_MODE=true ruby index.rb
