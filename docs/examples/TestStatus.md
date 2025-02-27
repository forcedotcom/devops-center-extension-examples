# Test Status

**Use Case**: As a development manager, I want to ensure certain quality gates are passed before a work item is allowed to enter the pipeline.

## Overview

In this example, we implement a simple quality gating mechanism on work items. We enforce that the gates have passed before we allow the work item to be approved for promotion.

To accomplish this, we introduce a new Custom Object called `Test_Status__c`. In the real world, this custom object would probably have more fields to track the status of some external quality gates as it is run against the work item's feature branch. Envision a Github action (or something simliar) that is run on the work item feature branch to verify code quality and/or other metrics. After it has run, it will change the `Status__c` field on the `Test_Status__c` to signal if it passed or failed.

We then add a Pre-Approval Validator for a work item. It looks at the work item that is requesting approval and at the latest `Test_Status__c` related to the `Work_Item__c`. If the `Status__c` is not `Passed`, then we don't allow the work item to be approved.

Lastly, we need a mechanisim to insert a `Test_Status__c` on a work item. To accomplish this, we use two flows that are triggered by platform events. One of the flows creates a `Test_Status__c` child on a work item when a review is created. Another watches for commits on the work item. If the work item is in review, it resets the `Test_Status__c`.

## Details

### Pre-Approval Validator

The logic to gate the approval is fairly straight forward. First we query the latest test status on the work item from the context. If there is no `Test_Status__c` or the latest is not in the `Passed` state, we return a message blocking the approval. Otherwise, we pass the approval. In this example we provide a bit of markup in the message that provides a link to the `Test_Status__c` that's not passing.

```
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

```

### Change Request Monitor Flow

![image](../files/Change%20Request%20Monitor%20Flow.png)

This flow is the first that inserts a `Test_Status__c` on a work item. When the Open Change Request event is dispatched, we first load the work item. We then look at the work item to decide if we need a `Test_Status__c`. Remember, we also get this event when the work item is promoted through the pipeline. If this is a promoted work item, then we don't want to insert a `Test_Status__c`. However, if this is a `Work_Item__c` that is in development, then we insert a `Test_Status__c` in the state of `Needed`.

### Commit Monitor Flow

![image](../files/Commit%20Monitor%20Flow.png)

To handle the case where additional commits are made to the feature branch after a review has been created, we have the Commit Monitor flow. This is triggered when the `Work_Item_Commit__e` event is dispatched. As with the other flow, the first thing we do is load the work item. We want to update Test_Status records only if the work item is In Review. If it isn't, then we terminate the flow. If it's in review, the first thing we do is transition all old `Test_Status__c` records to canceled. This means if the work item was in a `Passed` state, it can no longer be approved until the quality gate is run with the new commit.

After we transition the previous `Test_Status__c` we insert a new `Test_Status__c` in the state of `Needed`.

## Relevant Files

- [TestStatusApprovalValidator.cls](../../force-app/main/default/classes/preApproval/TestStatusApprovalValidator.cls): Pre-Approval Validator
- [sf_devops\_\_Service_Provider.Test_Status_PreApproval_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Test_Status_PreApproval_Validator.md-meta.xml): Custom Metadata to enable the validator
- [Change_Request_Monitor.flow-meta.xml](../../force-app/main/default/flows/Change_Request_Monitor.flow-meta.xml): Flow to monitor change requests
- [Commit_Monitor.flow-meta.xml](../../force-app/main/default/flows/Commit_Monitor.flow-meta.xml): Flow to monitor commits

# See Also

[Lifecycle Platform Events](../Lifecycle.md)  
[PreApproval Validators](../PreApprovalValidators.md)
