# Development Time

**Use Case**: As a manager, I would like to track the amount of time that work items are In Progress and In Review.

## Overview

This example uses the Lifecycle Platform Events to monitor when a work item changes state and record the amount of time that a work item is In Progress or In Review.

We add 4 custom fields to `Work_Item__c` to accomplish this. For each, In Progress and In Review, we add a field where we can store when the `Work_Item__c` transitions into the state, and a field that accumulates all of the time a work item is in the state. These fields are:

- Begin_In_Progress\_\_c
- Begin_In_Review\_\_c
- Total_In_Progress\_\_c
- Total_In_Review\_\_c

## Details

In Apex, platform events are subscribed to via an Apex trigger. In this example, Work_Item_Lifecycle.trigger is triggered on the `Work_Item_State_Change__e` event. This does very little with the event except invoke the Lifecycle Service.

In the Lifecycle service, we first bulk load all of the `Work_Item__c` objects that have a state change, then process each one individually. For each `Work_Item__c`, we look to see if it is transitioning in to or out of one of the states we care about. If it is transitioning into the state, then we update the appropriate `Begin` field. If it is tranitioning out of a state, then we update the appropriate `Total` field.

```
        Boolean updateWi = false;
        if (event.sf_devops__New_State__c == IN_PROGRESS_STATE) {
            System.debug('Recording In Progress transition for ' + workItem.Name);
            workItem.Begin_In_Progress__c = System.now();
            updateWi = true;
        } else if (event.sf_devops__New_State__c == IN_REVIEW_STATE) {
            System.debug('Recording In Review transition for ' + workItem.Name);
            workItem.Begin_In_Review__c = System.now();
            updateWi = true;
        } else {
            System.debug('Ignoring transition to ' + event.sf_devops__New_State__c + ' for ' + workItem.Name);
        }

        if (event.sf_devops__Previous_State__c == IN_PROGRESS_STATE) {
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
        } else if (event.sf_devops__Previous_State__c == IN_REVIEW_STATE) {
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
```

## Relevant Files

- [LifecycleService.cls](../../force-app/main/default/classes/lifecycle/LifecycleService.cls): Apex logic to accumulate the time spent in development.
- [Work_Item_Lifecycle.trigger](../../force-app/main/default/triggers/Work_Item_Lifecycle.trigger):

# See Also

[Lifecycle Platform Events](../Lifecycle.md)
