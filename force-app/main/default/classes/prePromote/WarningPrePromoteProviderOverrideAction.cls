/**
 * Similar to WarningPrePromoteProvider will show a warning dialog, but will update behavior when clicking 'continue'
 * Will also update 'continue' with another label
 */
global with sharing class WarningPrePromoteProviderOverrideAction extends PrePromoteProvider {
  private final WarningPrePromoteValidatorOverrideAction validator = new WarningPrePromoteValidatorOverrideAction();

  global override PrePromoteValidator getValidator() {
    return this.validator;
  }

  global with sharing class WarningPrePromoteValidatorOverrideAction extends PrePromoteValidator {
    global override String getRunningMessage() {
      return 'Warning Override Validation';
    }

    global override SpiPrePromoteValidationResponse validate(
      SpiPrePromoteContext context
    ) {
      // Will use the context to get target stage name
      Id targetStageId = context.getTargetStageId();
      sf_devops__Pipeline_Stage__c targetStage = [
        SELECT Id, Name
        FROM sf_devops__Pipeline_Stage__c
        WHERE Id = :targetStageId
      ];

      // Check if this stage is available to receive a promotion

      Stage_Validator__c validator = getValidator(targetStageId);

      if (validator != null && validator.Is_Available__c) {
        return SpiPrePromoteValidationResponse.pass();
      }

      String name = targetStage.Name;
      return SpiPrePromoteValidationResponse.warn()
        .withCustomContinue('Validate ' + name, 'validating target stage')
        .whatHappened()
        .withTitle('Target Stage Validation Missing')
        .withDetail('Target Stage validation has not been completed.')
        .withSuggestion(
          'Click "Validate" button to complete stage valdiation and retry promotion. Click close in case you dont want to validate yet.'
        )
        .build();
    }

    global override void invokeCustomAction(SpiPrePromoteContext context) {
      // This will make the target stage available from promotion
      Id targetStageId = context.getTargetStageId();
      Stage_Validator__c validator = getValidator(targetStageId);

      if (validator == null) {
        Stage_Validator__c targetValidator = new Stage_Validator__c(
          Is_Available__c = true,
          Stage_Id__c = targetStageId
        );
        insert targetValidator;
        return;
      }

      // If we are here it means a validator exists but is not ready to receive a promotion, lets update that.
      validator.Is_Available__c = true;
      update validator;
      //   context.getUnitOfWork()
      //     .registerDirty(
      //       validator,
      //       new List<SObjectField>{ Stage_Validator__c.Is_Available__c }
      //     );
    }

    private Stage_Validator__c getValidator(Id stageId) {
      List<Stage_Validator__c> validators = [
        SELECT Id, Is_Available__c
        FROM Stage_Validator__c
        WHERE Stage_Id__c = :stageId
      ];
      if (validators.isEmpty()) {
        return null;
      }

      return validators[0];
    }
  }
}
