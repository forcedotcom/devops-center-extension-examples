# Test Status

**Use Case**: As a development manager, I would like to ensure certain quality gates are passed before a Work Item is allowed to enter the pipeline.

## Overview

In this example we will be implementing a simple quality gating mechanism on Work Items. We will enforce that the gates have passed before we allow the work item to be approved for promotion.

To accomplish this, we introduce a new Custom Object called `Test_Status__c`. In the real world, this custom object would probablyhave more fields to track the status of some external quality gate as it is run against the work items feature branch. Envision a Github action (or something simliar) that is run on the work item feature branch to verify code quality and/or other metrics. After it has run, it will change the `Status__c` field on the `Test_Status__c` to singal it passed ot failed.

We then add a PreApproval validator for a Work Item, this will look at the Work Item that is requesting approval and look at the latest `Test_Status__c` related to the `Work_Item__c`. If the `Status__c` is not `Passed`, then we will not allow the work item to be approved.

Lastly, we need a mechanisim to insert a `Test_Status__c` on a Work Item. To accomplish this we will use 2 flows that are triggered by platform events. One of the flows will create a `Test_Status__c` child on a work item when a review is created. Another will watch for commits on the Work Item, and if the Work Item is in review, it will reset the `Test_Status__c`.

## Details

### PreApproval Validator

The logic to gate the approval is fairly straight forward. First we query the latest test status on the work item from the context. If there is no `Test_Status__c` or the latest is not in the `Passed` state, we will return a message blocking the approval. Otherwise we will pass the approval. In this example we provide a bit of markup in the message that provides a link to the `Test_Status__c` that is not passing.

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

This flow is the first that will insert a `Test_Status__c` on a Work Item. When the Open Change Request event is dispatched we first load the Work Item. We then look at the work item to decide if we need a `Test_Status__c`. Remember, we will also get this event when the Work Item is promoted through the pipeline. If this is a promoted Work Item, then we do not want to insert a `Test_Status__c`, however, if this is a `Work_Item__c` that is in development, then we will insert a `Test_Status__c` in the state of `Needed`.

### Commit Monitor Flow

![image](../files/Commit%20Monitor%20Flow.png)

To handle the case where additional commits are made to the feature branch after a review has been created, we have the Commit Monitor flow. This is triggered when the `Work_Item_Commit__e` event is dispatched. As with the other flow, the first thing we do is load the Work Item. We then make a decision, we only want to update Test_Status records if the Work Item is In Review. If it is not, then we terminate the Flow. If it is in review, the first thing we do is transition all old `Test_Status__c` records to canceled. This means if the Work Item was in a `Passed` state, it can no longer be approved until the quality gate is run with the new commit.

After we transition the previous `Test_Status__c` we insert a new `Test_Status__c` in the state of `Needed`

## Relevant Files

- [TestStatusApprovalValidator.cls](../../force-app/main/default/classes/preApproval/TestStatusApprovalValidator.cls): PreApproval Validator
- [sf_devops\_\_Service_Provider.Test_Status_PreApproval_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Test_Status_PreApproval_Validator.md-meta.xml): Custom Metadata to enable the validator
- [Change_Request_Monitor.flow-meta.xml](../../force-app/main/default/flows/Change_Request_Monitor.flow-meta.xml): Flow to monitor change requests
- [Commit_Monitor.flow-meta.xml](../../force-app/main/default/flows/Commit_Monitor.flow-meta.xml): Flow to monitor commits

# See Also

[Lifecycle Platform Events](../Lifecycle.md)  
[PreApproval Validators](../PreApprovalValidators.md)
