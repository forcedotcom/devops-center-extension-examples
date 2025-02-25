# Pre Promotion with custom continue

**User Case**: As the release manager, I would like to presnt the user with a warning dialog, and if the user cancels the promotion I would like to execute some custom Apex code.

## Overview

In some cases knowing that the user canceled the promotion as a result of a warning is needed to completly implement the business process. The PrePromote Validator framework allows this by specifing a continue override action.

![image](../files/customContinue.png)

In this simple example, we would like to have the user acknowledge the promotion to a stage. We show a warning dialog with the continue override, and when the user presses the "enable" button we will set a flag on the `Pipeline_Stage__c` to mark it as enabled.

## Details

### Validate

The validator uses a new custom field we added called `Is_Available__c`. It will load the `Pipeline_Stage__c` and see if this field has been set. If set, then the validator will pass. If not, then the validator will return the "What Happened" dialog with the custom continue override.

```
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

```

### InvokeCustomAction

When the user selects the custom continue button, the promotion process will be terminated and the DevOps Center will call the `invokeCustomAction()` method on the PrePromote Validator. This is where follow on business logic can be applied. In this case we simple set the `Is_Available__c` flag on the target stage to true.

```
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
```

## Relevant Files

- [WarningPrePromoteProviderOverrideAction.cls](../../force-app/main/default/classes/prePromote/WarningPrePromoteProviderOverrideAction.cls): Implementation of the PrePromote Validator
- [sf_devops\_\_Service_Provider.WarningOverride_PrePromote_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.WarningOverride_PrePromote_Validator.md-meta.xml): Custom Metadata Type to enable the PrePromoteValidator

# See Also

[PrePromote Validators](../PrePromoteValidators.md)
