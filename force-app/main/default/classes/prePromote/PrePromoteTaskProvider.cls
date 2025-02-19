/**
 * A pre promote validator that will gather the Pre_Prepromote_Task__c items for the work items in the promotion and present them
 * in the promotion dialog.
 */
global with sharing class PrePromoteTaskProvider extends sf_devops.PrePromoteProvider {
    private final sf_devops.PrePromoteValidator validator = new PrePromoteTaskValidator();
  
    global override sf_devops.PrePromoteValidator getValidator() {
      return this.validator;
    }
  
    global with sharing class PrePromoteTaskValidator extends sf_devops.PrePromoteValidator {
      global override String getRunningMessage() {
        return 'Gathering Reminders';
      }
  
      global override Boolean include(sf_devops.SpiPrePromoteContext context) {
        return !this.loadWorkItems(context).isEmpty();
    }


      global override sf_devops.SpiPrePromoteValidationResponse validate(
        sf_devops.SpiPrePromoteContext context
      ) {
        List<sf_devops__Work_Item__c> workItems = this.loadWorkItems(context);
        if (workItems.isEmpty()) {
            return sf_devops.SpiPrePromoteValidationResponse.pass();
        }
        String message = '<ol>';
        for (sf_devops__Work_Item__c wi: workItems) {
            message += '<li><b>' + wi.Name + '</b>: ' + wi.Pre_Promote_Task__c + '</li>';
        }
        message += '</ol>';
        return sf_devops.SpiPrePromoteValidationResponse.info()
          .simple()
          .withTitle('Promotion Reminders')
          .withMessage(message)
          .build();
      }
      /**
       * Helper to load the work items where the pre-promote task field is not blank
       */
      private List<sf_devops__Work_Item__c> loadWorkItems(sf_devops.SpiPrePromoteContext context) {
        final List<sf_devops__Work_Item__c> res = new List<sf_devops__Work_Item__c>();
        final Set<Id> selected = new Set<Id>();
        //We look at all work items, even if they where externally merged.
        for( sf_devops.SpiWorkItem wi: context.getSelectedWorkItems()) {
            selected.add(wi.getId());
        }

        for (sf_devops__Work_Item__c wi :[SELECT Id, Name, Pre_Promote_Task__c FROM sf_devops__Work_Item__c WHERE ID IN :selected]) {
            if (String.isNotBlank(wi.Pre_Promote_Task__c)) {
                res.add(wi);
            }
        }
        return res;
      }
    }
}