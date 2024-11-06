
global with sharing class InfoPrePromoteProvider extends PrePromoteProvider {
    private final InfoPrePromoteValidator validator = new InfoPrePromoteValidator();

    global override PrePromoteValidator getValidator() {
        return this.validator;
    }

    global with sharing class InfoPrePromoteValidator extends PrePromoteValidator {
        global override String getRunningMessage() {
            return 'Info Validation';
        }

        global override SpiPrePromoteValidationResponse validate(
            SpiPrePromoteContext context
        ) {
            return SpiPrePromoteValidationResponse.info()
                .simple()
                .withTitle('Info Title')
                .withMessage('Info Message')
                .build();
        }
    }
}