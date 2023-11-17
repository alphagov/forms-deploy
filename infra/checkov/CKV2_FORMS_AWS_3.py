from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class CKV2_FORMS_AWS_3(BaseResourceCheck):
    def __init__(self):
        # This is the full description of your check
        description = "Check ECS CPU and memory allocations are compatible"

        # This is the Unique ID for your check
        id = "CKV2_FORMS_AWS_3"

        # These are the terraform objects supported by this check (ex: aws_iam_policy_document)
        supported_resources = ['aws_ecs_task_definition']
        
        guideline = "https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"

        # Valid CheckCategories are defined in checkov/common/models/enums.py
        categories = [CheckCategories.CONVENTION]
        super().__init__(name=description, id=id    , categories=categories, supported_resources=supported_resources, guideline=guideline)

    def scan_resource_conf(self, conf):
        cpu_field = conf.get("cpu")
        mem_field = conf.get("memory")

        if cpu_field is None:
            self.details.append("'cpu' field must be set")
            return CheckResult.FAILED
        
        if mem_field is None:
            self.details.append("'memory' field must be set")
            return CheckResult.FAILED

        cpu_value = normalize_cpu_value(int(cpu_field[0]))
        mem_value = int(mem_field[0])
        
        valid_cpu_values = [0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0]
        if cpu_value not in valid_cpu_values:
            self.details.append("'cpu' value is invalid. Valid CPU values are " + valid_cpu_values.join(", "))
            return CheckResult.FAILED
        
        mem_in_gigs = mem_value / 1024
        # Must be a whole number
        if mem_in_gigs % 1 != 0:
            # Unless it's 0.5gb
            if mem_in_gigs != 0.5:
                self.details.append("'memory' value is invalid. Valid CPU values are 512, or multiples of 1024")
                return CheckResult.FAILED

        # 0.25 vCPU
        if cpu_value == 0.25:
            if mem_value in [512, 1024, 2048]:
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED
        # 0.5 vCPU
        elif cpu_value == 0.5:
            if mem_value in [1024, 2048, 3072, 4096]:
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED
        # 1.0 vCPU
        elif cpu_value == 1.0:
            gigs = mem_value/1024
            if gigs in list(range(2, 8+1, 1)):
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED  
        # 2.0 vCPU
        elif cpu_value == 2.0:
            gigs = mem_value/1024
            if gigs in list(range(4, 16+1, 1)):
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED
        elif cpu_value == 4.0:
            gigs = mem_value/1024
            if gigs in list(range(8, 30+1, 1)):
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED
        elif cpu_value == 8.0:
            gigs = mem_value/1024
            if gigs in list(range(16, 60+1, 4)):
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED         
        elif cpu_value == 16.0:
            gigs = mem_value/1024
            if gigs in list(range(32, 120+1, 8)):
                result = CheckResult.PASSED
            else:
                result = CheckResult.FAILED
        else:
            result = CheckResult.FAILED
                    
        if result == CheckResult.FAILED:
            self.details.append("Invalid memory value (%s) for CPU value of '%s'(%s)" % (mem_value, cpu_field[0], cpu_value))
            
        return result


# Noramlizes CPU value to vCPU count
def normalize_cpu_value(value):
    # Over 16 it's probably a CPU units value
    if value > 16:
        return value/1024
    
    # Otherwise it's already a vCPU count
    print("CPU value less than 16 already")
    return value

check = CKV2_FORMS_AWS_3()