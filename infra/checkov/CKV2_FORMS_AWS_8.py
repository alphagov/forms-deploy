from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck
import os

class CKV2_FORMS_AWS_8(BaseResourceCheck):
    def __init__(self):
        # This is the full description of your check
        description = "Check that ALB listener rule priorities are distinct for all aws_lb_listener_rule within the same directory"

        # This is the Unique ID for your check
        id = "CKV2_FORMS_AWS_8"

        # These are the terraform objects supported by this check (ex: aws_iam_policy_document)
        supported_resources = ['aws_lb_listener_rule']

        # Valid CheckCategories are defined in checkov/common/models/enums.py
        categories = [CheckCategories.NETWORKING]

        # Hash of encountered_priorities
        # [directory] => [listener_arn] => string array
        self.encountered_priorities = {}

        super().__init__(name=description, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        file_name = self.entity_path.split(":")[0]
        dir_name = os.path.dirname(file_name)
        priority = conf["priority"][0]
        listener_arn = conf["listener_arn"][0]

        existing_modules = self.encountered_priorities.get(dir_name)

        if existing_modules == None:
            self.encountered_priorities[dir_name] = {listener_arn: [priority]}
            return CheckResult.PASSED
        else:
            existing_listener_priorities = existing_modules.get(listener_arn)
            if existing_listener_priorities == None:
                self.encountered_priorities[dir_name][listener_arn] = [priority]
                return CheckResult.PASSED
            else:
                if priority in existing_listener_priorities:
                    self.details.append(f"Priority value {priority} is not unique for {listener_arn} in {dir_name}")
                    self.details.append(f"Previously seen values are: {existing_listener_priorities}")
                    return CheckResult.FAILED
                else:
                    self.encountered_priorities[dir_name][listener_arn].append(priority)
                    return CheckResult.PASSED



check = CKV2_FORMS_AWS_8()