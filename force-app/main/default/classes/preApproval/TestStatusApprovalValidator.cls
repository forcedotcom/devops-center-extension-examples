/**
 * Verify the latest Test_Status for this work item is Passed.
 */
global with sharing class TestStatusApprovalValidator extends sf_devops.PreApprovalValidator {

    global override sf_devops.SpiPreApprovalValidationResponse validate(
        sf_devops.SpiPreApprovalContext context
    ) {
        List<Test_Status__c> statuses = [SELECT Status__c FROM Test_Status__c WHERE Work_Item__c = :context.getWorkItemId() ORDER BY CREATEDDATE DESC LIMIT 1];
        if (statuses.size() == 0){
            return sf_devops.SpiPreApprovalValidationResponse.fail('Missing QA', 'This work item does not have a status');
        }
        else if (statuses[0].Status__c != 'Passed'){
            return sf_devops.SpiPreApprovalValidationResponse.fail('Failed QA', 'Please complete QA on this work item.  See the <a target="_blank" href="/' + 
            statuses[0].Id + '">QA Record</a>');
        }
        return sf_devops.SpiPreApprovalValidationResponse.pass();
    }

}