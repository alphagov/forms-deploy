from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class CKV2_FORMS_AWS_2(BaseResourceCheck):
    def __init__(self):
        # This is the full description of your check
        description = "Ensure ECS task counts can be distributed evenly across availability zones"

        # This is the Unique ID for your check
        id = "CKV2_FORMS_AWS_2"

        # These are the terraform objects supported by this check (ex: aws_iam_policy_document)
        supported_resources = ['aws_ecs_service']

        # Valid CheckCategories are defined in checkov/common/models/enums.py
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=description, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        task_count = conf.get("desired_count")[0]
        if (task_count % 3) == 0:
            return CheckResult.PASSED

        self.details.append("'desired_count' must be a multiple of 3. It is %s." % task_count)
        return CheckResult.FAILED


check = CKV2_FORMS_AWS_2()