module "automated_test_parameters" {
  count = (
    var.deploy-forms-product-page-container.disable_end_to_end_tests ||
    var.deploy-forms-runner-container.disable_end_to_end_tests ||
    var.deploy-forms-api-container.disable_end_to_end_tests
  ) == false ? 1 : 0

  source           = "../../../modules/automated-test-parameters"
  environment_name = var.environment_name
}
