/**
 * Watch for work item state changes and update our tracking fields for how long a work item was in a given state.
 * @author molson
 */
trigger Work_Item_Lifecycle on sf_devops__Work_Item_State_Change__e (after insert) {
    //See: https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/platform_events_subscribe_apex.htm
    //Really, we would want to watch for errors and limits as we process these work items in bulk
    //But as this is just an example, we will pretend life is just unicorns and rainbows
    new LifecycleService().handleStageChanges(Trigger.New);
}