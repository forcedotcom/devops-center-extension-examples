/**
 * Warning pre promote provider
 */
global with sharing class WarningPrePromoteProvider extends PrePromoteProvider {
  private final WarningPrePromoteValidator validator = new WarningPrePromoteValidator();

  global override PrePromoteValidator getValidator() {
    return this.validator;
  }

  global with sharing class WarningPrePromoteValidator extends PrePromoteValidator {
    global override String getRunningMessage() {
      return 'Warning Validation';
    }

    global override SpiPrePromoteValidationResponse validate(
      SpiPrePromoteContext context
    ) {
      return SpiPrePromoteValidationResponse.warn()
        .whatHappened()
        .withTitle('Warning - What Happened Example')
        .withDetail('Here gows description about the issue')
        .withSuggestion('Here goes info about what to do')
        .withWarningBanner('This is a warning banner')
        .build();
    }
  }
}
