# Pre-Promotion Informational Message

**Use Case**: As a release manager, I want to provide an informational message to the user that is doing a promotion.

## Overview

The Pre-Promotion Validator can be used to return informational messages. These messages will halt the promotion dialog and then allow the user to continue.

![image](../files/info.png)

## Details

You can use any logic you would like to control the content that is shown in the informational dialog. In this example, we keep things pretty simple and just return hard coded content.

```
global override sf_devops.SpiPrePromoteValidationResponse validate(
  sf_devops.SpiPrePromoteContext context
) {
  return sf_devops.SpiPrePromoteValidationResponse.info()
    .simple()
    .withTitle('Info Title')
    .withMessage('Info Message')
    .build();
}

```

In this example, we are showing a simple response that allows any RTF content to be displayed to the user. For informational messages, you can also use the What Happened results. See [PrePromote Warning](./PrePromoteWarning.md) for an example of how to specify this response type.

## Relevant Files

- [InfoPrePromoteProvider.cls](../../force-app/main/default/classes/prePromote/InfoPrePromoteProvider.cls): Implementation of the Pre-Promote Validator
- [sf_devops\_\_Service_Provider.Info_PrePromote_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Info_PrePromote_Validator.md-meta.xml): Custom Metadata Type to enable the Pre-Promote Validator

# See Also

[PrePromote Validators](../PrePromoteValidators.md)
