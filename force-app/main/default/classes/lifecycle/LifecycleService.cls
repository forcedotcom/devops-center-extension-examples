/**
 * Handles the Work_Item_State_Change platform event.  This will look at the Pervious/New states on the event and update the correct
 * field on the work item that we use to track time in a given state.
 * @author molson
 */
public with sharing class LifecycleService {

    public void handleStageChanges(List<sf_devops__Work_Item_State_Change__e> events) {
        Set<Id> workItemIds = new Set<Id>();
        //First, gather all the IDs so we can load the work items
        for (sf_devops__Work_Item_State_Change__e event: events) {
            workItemIds.add(event.sf_devops__Work_Item_Id__c);
        }

        Map<Id, sf_devops__Work_Item__c> workItems = new Map<Id, sf_devops__Work_Item__c>(
            [SELECT Id, CreatedDate, Name,Begin_In_Progress__c,Begin_In_Review__c,Total_In_Progress__c,Total_In_Review__c from sf_devops__Work_Item__c WHERE Id IN :workItemIds]
        );

        for (sf_devops__Work_Item_State_Change__e event: events) {
            this.process(event, workItems.get(event.sf_devops__Work_Item_Id__c));
        }
    }


    private void process(sf_devops__Work_Item_State_Change__e event, sf_devops__Work_Item__c workItem ) {
        if (String.isBlank(event.sf_devops__Previous_State__c )) {
            System.debug('Event for ' + workItem.Name + ' does not have a previous state, ignoring');
            return;
        }
        Boolean updateWi = false;
        if (event.sf_devops__New_State__c == 'In Progress') {
            System.debug('Recording In Progress transition for ' + workItem.Name);
            workItem.Begin_In_Progress__c = System.now();
            updateWi = true;
        } else if (event.sf_devops__New_State__c == 'In Review') {
            System.debug('Recording In Review transition for ' + workItem.Name);
            workItem.Begin_In_Review__c = System.now();
            updateWi = true;
        } else {
            System.debug('Ignoring transition to ' + event.sf_devops__New_State__c + ' for ' + workItem.Name);
        }

        if (event.sf_devops__Previous_State__c == 'In Progress') {
            System.debug('Recording In Progress completed for ' + workItem.Name);
            DateTime start = workItem.Begin_In_Progress__c;
            if (start == null) {
                //Assume normal development flow.  This is to handle the case where a work item moves
                //from New to In Review by external means.
                start = workItem.CreatedDate;
            }
            Double orig = workItem.Total_In_Progress__c;
            if (orig == null) {
                orig = 0;
            }
            workItem.Total_In_Progress__c = orig + (System.now().getTime() - start.getTime())/(1000.0*60);
            updateWi = true;
        } else if (event.sf_devops__Previous_State__c == 'In Review') {
            System.debug('Recording In Review completed for ' + workItem.Name);
            DateTime start = workItem.Begin_In_Review__c;
            if (start == null) {
                //Assume normal development flow.  This is to handle the case where a work item moves
                //from New to Approved by external means.
                start = workItem.CreatedDate;
            }
            Double orig = workItem.Total_In_Review__c;
            if (orig == null) {
                orig = 0;
            }
            workItem.Total_In_Review__c = orig + (System.now().getTime() - start.getTime())/(1000.0*60);
            updateWi = true;
        } else {
            System.debug('Ignoring transition from ' + event.sf_devops__Previous_State__c + ' for ' + workItem.Name);
        }


        if (updateWi) {
            update workItem;
        }


    }


}