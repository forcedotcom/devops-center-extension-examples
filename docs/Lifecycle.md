# DevOps Center Platform Events


The main focus of the DevOps Center is to move metadata from lower environments, through a pipeline and eventually into the production org. These metadata changes are encapusalted in a construct we call the work item. As this is such a crucial aspect of the application, the lifecycle of a work item is where we choose to implement our initial platform events.

These are just standard platform events. For information on how to subscribe to them, see [Platform Events Docs](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_intro.htm).  


# Development Lifecycle

In the development phases, DevOps Center generates platform events every time a work item changes state (New, In Progress, and so on). We also generate a platform event for every commit on the work item's feature branch and when the change request is open.

## State Change

When a work item changes state, we publish a [Work_Item_State_Change__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_state_change__e.htm) event. This is published on all state changes, even when a work item is reverted to a previous development state. For example, if a work item was In Review and the pull request is closed, the work item reverts to In Progress and a Work_Item_State_Change__c event is published.  

We also publish an event when a work item is created. In this case the `Previous_State__c` is empty and the `New_State__c` is NEW.

## Commits

Once development begins on a work item and it has a feature branch, we generate a [Work_Item_Commit__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_commit__e.htm) platform event everytime there's a commit on the work item's feature branch.  These are generated whether the commit was initiated from DevOps Center (via the commit button) or was externally applied to the feature branch (pro-code model). After a work item has been promoted once, then we stop generating Work_Item_Commit__e events for the work item.

## Open Change Request

When a change request is opened for the work item, we generate a [Work_Item_Open_Change_Request__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_open_change_request__e.htm). Note, just like state changes, if the change request is closed (work item reverted to In Progress), then reopened, we generate a second event.

# Promotion Lifecycle

After a work item enters the pipeline, fewer events are generated, and they only deal with the promotion of the work item (either by itself, as a group, or as a bundle) through the stages of the pipeline.

## Merged Change Request

One aspect of a promotion is merging the metadata into the branch of the next pipeline stage. This is done by merging the change request(s) that are part of the promotion.  Also, DevOps Center supports progromatic development and is monitring the source control repository for change requests that are merged outside of DevOps Center (externally merged). In either case, when DevOps Center detects a work item's change request has been merged into the next stage, a [Work_Item_Merged_Change_Request__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_merged_change_request__e.htm) event is published. One event is published for each work item that was merged, even if they are part of the same promotion.

## Open Change Request for Next Promotion

After a promotion is completed DevOps Center creates a change request for the next promotion. When this occurs the DevOps Center publishes a [Work_Item_Open_Change_Request__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_open_change_request__e.htm) event for each work item that has a change request created.

## Deployment

The second aspect of a promotion is the deployment of the metadata to the target stage. After this is completed, DevOps Center publishes a [Deployment__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__deployment__e.htm) event. This event contains the work item deployed as well as the deployment ID from the target org.

# Examples

The [Development Time](./examples/DevelopmentTime.md) example uses an Apex trigger to subscribe to the [Work_Item_State_Change__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_state_change__e.htm) event.  
The [Test Status](./exanples/TestStatus.md) example uses platform event triggered flows to subscribe to the [Work_Item_Open_Change_Request__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_open_change_request__e.htm) and [Work_Item_Commit__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__work_item_commit__e.htm) events.  
The [Promote Tasks](./examples/PromoteTasks.md) example uses platform event triggered flows to subscribe to the [Deployment__e](https://developer.salesforce.com/docs/atlas.en-us.devops_center_dev.meta/devops_center_dev/sforce_api_objects_sf_devops__deployment__e.htm) event.  
