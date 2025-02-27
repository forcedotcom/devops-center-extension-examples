/**
 * Verifies if target stage of promotion is enabled to receive one.
 *
 * To verify this it uses the new custom field Is_Available__c on sf_devops__Pipeline_Stage__c
 * This acts as a gate. When the promotion is attempted, this valdiator verifies the checkbox field.
 * If it is true, it will allow the promotion to continue.
 * If it is false, it will communicate this to the user and override the 'continue' button to actually
 * perform the enabling of target stage. Then on next promotion this check should pass.
 *
 */
global with sharing class WarningPrePromoteProviderOverrideAction extends sf_devops.PrePromoteProvider {
  private final WarningPrePromoteValidatorOverrideAction validator = new WarningPrePromoteValidatorOverrideAction();

  global override sf_devops.PrePromoteValidator getValidator() {
    return this.validator;
  }

  global with sharing class WarningPrePromoteValidatorOverrideAction extends sf_devops.PrePromoteValidator {
    global override String getRunningMessage() {
      return 'Warning Override Validation';
    }

    global override sf_devops.SpiPrePromoteValidationResponse validate(
      sf_devops.SpiPrePromoteContext context
    ) {
      // Will use the context to get target stage name
      Id targetStageId = context.getTargetStageId();
      sf_devops__Pipeline_Stage__c targetStage = [
        SELECT Id, Name, Is_Available__c
        FROM sf_devops__Pipeline_Stage__c
        WHERE Id = :targetStageId
      ];

      // Check if this stage is available to receive a promotion

      if (targetStage.Is_Available__c) {
        return sf_devops.SpiPrePromoteValidationResponse.pass();
      }

      String name = targetStage.Name;
      return sf_devops.SpiPrePromoteValidationResponse.warn()
        .withCustomContinue('Enable ' + name, 'enabling target stage')
        .whatHappened()
        .withTitle('Target Stage Is not available for promotion')
        .withDetail('Target Stage enabling has not been completed.')
        .withSuggestion(
          'Click "Enable" button to complete stage enabling and retry promotion. Click close in case you dont want to make it available to host a promotion yet.'
        )
        .build();
    }

    global override void invokeCustomAction(
      sf_devops.SpiPrePromoteContext context
    ) {
      Id targetStageId = context.getTargetStageId();

      // Update target stage is Available to host promotions.
      // This will make the target stage available from promotion
      update new sf_devops__Pipeline_Stage__c(
        Id = targetStageId,
        Is_Available__c = true
      );
    }
  }
}
