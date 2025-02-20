# Promotion Tasks

**Use Case**:  As a developer, I would like to track a set of tasks that need to be done before a work item is promoted into a pipeline stage.  
**Use Case**: As a developer, I would like to track a set of tasks that need to be done after a work item has been promoted to a pipeline stage.


## Overview

We need to add a place where we can store the tasks on a work item.  In a real world situation this would probably be modeled as a new Custom Object that is a child of Work Item, allowing a single Work Item to have multiple tasks associated with it.  To keep things simply (and to focus more on the extending the DevOps Center) we will just model this as 2 new fields on the Work Item, Pre_Promote_Task__c and Post_Promote_Task__c.

To implement the first use case, we will add a PrePromote Validator that will query all Work Items that are involved in the promotion.  If one or more of the Work Items has `Pre_Promote_Task__c` defined, then we will organize all of them into a simple ordered list that is displayed in the promotion dialog.

For the second use case, we will create a Flow that is triggered on the `sf_devops__Deployment__e` platform event.  This flow will look at the deployed Work Item, if the Work Item defines a `Post_Promote_Task__c`, then we will fire a custom notification to remind the user of the task to be done.

## Details

### Pre Promote Tasks

Please see [PrePromote Validators](../PrePromoteValidators.md) for the complete instructions on how to implement a PrePromote Validator.

In this example, we want to also showcase the ability to have a PrePromote Validator conditionaly excluded from the prepromotion process.  This is accimplished by implementing the `include` method on the validator.

```
      global override Boolean include(sf_devops.SpiPrePromoteContext context) {
        return !this.loadWorkItems(context).isEmpty();
      }
```
 In this case, we would like our validator included in the pre-promotion validation **if** any of the included Work Items have `Pre_Promote_Task__c` defined.  This is not strictly required, however it does improve the overall performance of the promotion process, so it is recommended to implement this method if it is easy to determine inclusion.

 The main logic of the validator is iimplemented in the `validate` method.
 ```
       global override sf_devops.SpiPrePromoteValidationResponse validate(
        sf_devops.SpiPrePromoteContext context
      ) {
        List<sf_devops__Work_Item__c> workItems = 
            this.loadWorkItems(context);
        if (workItems.isEmpty()) {
            return sf_devops.SpiPrePromoteValidationResponse.pass();
        }
        /**
        More UI could be done here including
        links to the work item and/or links to 
        the target stage.
        **/
        String message = '<ol>';
        for (sf_devops__Work_Item__c wi: workItems) {
            message += '<li><b>' + wi.Name + '</b>: ' + wi.Pre_Promote_Task__c + '</li>';
        }
        message += '</ol>';
        /**
        I choose to only offer the "continue" button
        in this example, but you can also offer the 
        "cancel" button if this is call changed 
        from info() to warning().
        **/
        return sf_devops.SpiPrePromoteValidationResponse.info()
          .simple()
          .withTitle('Promotion Reminders')
          .withMessage(message)
          .build();
      }
 ```
The above logic is fairly straight forward.  We first load the Work Items with `Pre_Promote_Task__c` defined.  We then create a simple HTML list of these work items and create a informational response to show to the user.

### Post Promote Tasks

This logic is completely contained in the `Post_Promote` flow.

![image](../files/Post%20Promote%20Flow.png)

This flow is triggered by the `sf_devops__Deployment__e` platform event.  This event is fired whenever a work item has completed a deployment to a pipeline stage.  The event contains the ID of the Work Item that was promoted.  We use this ID to load the Work Item in the first step of the Flow.

We then make a decision, does the Work Item have `Post_Promote_Task__c` defined.  If not, the flow terminates.

If it does, we perform the following steps.  
 1. We load the pipeline stage (so we can use the name in the messaging)
 2. We load the ID of our custom notification type (needed to trigger the notification)
 3. We build a list of recipients for the notification.  In this case, just the user that performed the promotion, but we could notify the entire team.
 4. We push the Custom Notification to the recipients.

 ## Relevant Files

 * [PrePromoteTaskProvider.cls](../../force-app/main/default/classes/prePromote/PrePromoteTaskProvider.cls): Implementation of the PrePromote Validator
 * [sf_devops__Service_Provider.Task_PrePromote_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Task_PrePromote_Validator.md-meta.xml): Custom Metadata Type to enable the PrePromoteValidator
 * [Post_Promote.flow-meta.xml](../../force-app/main/default/flows/Post_Promote.flow-meta.xml): Flow to generate the custom notification
 * [Post_Promote.notiftype-meta.xml](../../force-app/main/default/notificationtypes/Post_Promote.notiftype-meta.xml): Post Promotion custom notification type
* [Pre_Promote_Task__c.field-meta.xml](../../force-app/main/default/objects/sf_devops__Work_Item__c/fields/Pre_Promote_Task__c.field-meta.xml): Custom field for pre promote task
* [Post_Promote_Task__c.field-meta.xml](../../force-app/main/default/objects/sf_devops__Work_Item__c/fields/Post_Promote_Task__c.field-meta.xml): Custom field for post promote task

# See Also

[PrePromote Validators](../PrePromoteValidators.md)  
[Lifecycle Platform Events](../Lifecycle.md)


