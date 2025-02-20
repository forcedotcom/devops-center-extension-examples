# DevOps Center Platform Events


The main focus of the DevOps Center is to move Metadata from lower environments, through a pipeline and eventually into the production organization.  These metadata changes are encapusalted in a construct we call the Work Item.  As this is such a crucial aspect of the application, the lifecycle of a work item is where we choose to implement our initial platform events.

These are just standard platform events.  For information on how to subscribe to them please see [Platform Events Docs](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_intro.htm).  


# Development Lifecycle

In the development phases, The DevOps Center will generate a platform events every time a work item changes state (New, In Progress, etc).  We will also generate a platform event for every commit on the work items’ feature branch and when the change request is open.

## State Change

When a Work Item changes state we will publish a [Work_Item_State_Change__e](LinkMePlease) event.  This will be published on all state changes, even when a work item is reverted to a previous development state (ie, if a Work Item was InReview and the pull request is closed, the Work Item will revert to InProgress and a Work_Item_State_Change__c event will be published).  

We will also publish an event when a work item is created.  In this case the `Previous_State__c` will be empty and the `New_State__c` will be NEW.

## Commits

Once development begins on a Work Item and it has a feature branch, we will generate a [Work_Item_Commit__e](LinkMePlease) platform event everytime there is a commit on the work item's feature branch.  These will be generated whether the commit was initiated from the DevOps Center (via the commit button) or was externally applied to the feature branch (pro-code model).  After a work item has been promoted once, then we will stop generating Work_Item_Commit__e events for the Work Item.

## Open Change Request

When a change request is opened for the Work Item, we will generate a [Work_Item_Open_Change_Request__e](LinkMePlease).  Note, just like state changes, if the change request is closed (Work Item reverted to In Progress), then reopened, we will generate a second event.

# Promotion Lifecycle

Once a work item enters the pipeline, fewer events are generated, and they only deal with the promotion of the work item (either by its self, as a group, or as a bundle)
 through the stages of the pipeline

## Merged Change Request

One aspect of a promotion is merging the metadata into the branch of the next pipeline stage, this is done by merging the change request(s) that are part of the promotion.  Also, the DevOps Center supports progromatic development and is monitring the VCS for change requests that are merged outside of the DevOps Center (externally merged).  In either case, when the DevOps Center detects a work item's change request has been merged into the next stage, a [Work_Item_Merged_Change_Request__e](LinkMePlease) event will be published.  One event will be published for each work item that was merged, even if they are part of the same promotion.

## Open Change Request

After a promotion is completed the DevOps Center may create a change request for the next promotion.  When this occurs the DevOps Center will publish a [Work_Item_Open_Change_Request__e](LinkMePlease) event for each work item that has a change request created.

## Deployment

The second aspect of a promotion is the deployment of the metadata to the target stage.  Once this is completed the DevOps Center will publish a [Deployment__e](LinkMePlease) event.  This event will contain the work item deployed as well as the deployment ID from the target organization.

# Examples

The [Development Time](./examples/DevelopmentTime.md) example uses an Apex trigger to subscribe to the [Work_Item_State_Change__e](LinkMePlease) event.  
The [Test Status](./exanples/TestStatus.md) example uses platform event triggered flows to subscribe to the [Work_Item_Open_Change_Request__e](LinkMePlease) and [Work_Item_Commit__e](LinkMePlease) events.  
The [Promote Tasks](./examples/PromoteTasks.md) example uses platform event triggered flows to subscribe to the [Deployment__e](LinkMePlease) event.  
