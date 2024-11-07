global with sharing class InfoPrePromoteProvider extends sf_devops.PrePromoteProvider {
  private final InfoPrePromoteValidator validator = new InfoPrePromoteValidator();

  global override sf_devops.PrePromoteValidator getValidator() {
    return this.validator;
  }

  global with sharing class InfoPrePromoteValidator extends sf_devops.PrePromoteValidator {
    global override String getRunningMessage() {
      return 'Info Validation';
    }

    global override sf_devops.SpiPrePromoteValidationResponse validate(
      sf_devops.SpiPrePromoteContext context
    ) {
      return sf_devops.SpiPrePromoteValidationResponse.info()
        .simple()
        .withTitle('Info Title')
        .withMessage('Info Message')
        .build();
    }
  }
}
