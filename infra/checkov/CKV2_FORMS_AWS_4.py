from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
from typing import List


class CKV2_FORMS_AWS_4(BaseResourceCheck):
    def __init__(self):
        # This is the full description of your check
        description = "Check autoscaling target minimums are not greater than maximums"

        # This is the Unique ID for your check
        id = "CKV2_FORMS_AWS_4"

        # These are the terraform objects supported by this check (ex: aws_iam_policy_document)
        supported_resources = ["aws_appautoscaling_target"]

        # Valid CheckCategories are defined in checkov/common/models/enums.py
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=description, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        max = conf.get("max_capacity")
        min = conf.get("min_capacity")
        
        if max is None:
            self.details.append("'max_capacity' field must be set")
            return CheckResult.FAILED
        
        if min is None:
            self.details.append("'min_capacity' field must be set")
            return CheckResult.FAILED
        
        if min[0] > max[0]:
            self.details.append("'min_capacity' value (%d) must be less or equal to 'max_capacity' value (%d)"%(min[0], max[0]))
            return CheckResult.FAILED
        
        return CheckResult.PASSED
    
    def get_evaluated_keys(self) -> List[str]:
        return ['max_capacity/[0]', 'min_capacity/[0]']


check = CKV2_FORMS_AWS_4()