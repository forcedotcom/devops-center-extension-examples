/**
 * Basic implementation of a PrePromoteProvider.
 * It returns a Warning result with a WhatHappened structure.
 */
global with sharing class WarningPrePromoteProvider extends sf_devops.PrePromoteProvider {
  private final WarningPrePromoteValidator validator = new WarningPrePromoteValidator();

  global override sf_devops.PrePromoteValidator getValidator() {
    return this.validator;
  }

  global with sharing class WarningPrePromoteValidator extends sf_devops.PrePromoteValidator {
    global override String getRunningMessage() {
      return 'Warning Validation';
    }

    global override sf_devops.SpiPrePromoteValidationResponse validate(
      sf_devops.SpiPrePromoteContext context
    ) {
      return sf_devops.SpiPrePromoteValidationResponse.warn()
        .whatHappened()
        .withTitle('Warning - What Happened Example')
        .withDetail('Here gows description about the issue')
        .withSuggestion('Here goes info about what to do')
        .withWarningBanner('This is a warning banner')
        .build();
    }
  }
}
