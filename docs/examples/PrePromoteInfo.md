# Pre Promotion Informational Message

**Use Case**: As a release manager, I want to provide an informational message to the user that is doing a promotion.

## Overview

The PrePromotion Validator can be used to return informational messages. These messages will halt the promotion dialog and then allow the user to continue.

![image](../files/info.png)

## Details

You can use any logic you would like to control the content that is shown in the informational dialog. In this example we keep things pretty simple and just return hard coded content.

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

## Relevant Files

- [InfoPrePromoteProvider.cls](../../force-app/main/default/classes/prePromote/InfoPrePromoteProvider.cls): Implementation of the PrePromote Validator
- [sf_devops\_\_Service_Provider.Info_PrePromote_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Info_PrePromote_Validator.md-meta.xml): Custom Metadata Type to enable the PrePromoteValidator

# See Also

[PrePromote Validators](../PrePromoteValidators.md)
