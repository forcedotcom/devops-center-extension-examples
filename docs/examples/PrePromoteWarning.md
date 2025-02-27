# Pre-Promotion Warning Message

**Use Case**: As a release manager, I want to provide a warning message to the user that is doing a promotion, with the option to cancel the promotion.

## Overview

The Pre-Promotion Validator can be used to return warning messages. These are intended to present the user with a potential issue and allow them to cancel the promotion process.

![image](../files/warningWhatHappened.png)

## Details

You can use any logic you would like to control the content that is shown in the warning dialog. In this example we show the "What Happened" results from the validator. This allows you to use the standard look and feel of the DevOps Center dialogs.

```
    global override sf_devops.SpiPrePromoteValidationResponse validate(
      sf_devops.SpiPrePromoteContext context
    ) {
      return sf_devops.SpiPrePromoteValidationResponse.warn()
        .whatHappened()
        .withTitle('Warning - What Happened Example')
        .withDetail('Here goes description about the issue')
        .withSuggestion('Here goes info about what to do')
        .withWarningBanner('This is a warning banner')
        .build();
    }

```

You can also use the simple result type with warning dialogs. This allows you to place any Rich Text Format content in the dialog to present to your users. See [Pre-Promote Info](./PrePromoteInfo.md) fo an example implementation.

## Relevant Files

- [WarningPrePromoteProvider.cls](../../force-app/main/default/classes/prePromote/WarningPrePromoteProvider.cls): Implementation of the Pre-Promote Validator
- [sf_devops\_\_Service_Provider.Warning_PrePromote_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Warning_PrePromote_Validator.md-meta.xml): Custom Metadata Type to enable the Pre-Promote Validator

# See Also

[PrePromote Validators](../PrePromoteValidators.md)
