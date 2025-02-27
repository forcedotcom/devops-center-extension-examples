# Pre-Approval Validators

DevOps Center has the concept of approving the development of a work item. This is a gate between a work item that is in development and a work item that is in the pipeline and ready for it's journey to the production environment.

Previously, DevOps Center had some pretty basic rules on when a work item can be approved for promotions, basically if the change request for that work item was mergeable. It was assumed that the rest of the approval process was handled externally (in a code review, or design review, and so on).

Now, with the global Pre-Appoval Validator interface, customers can start to add their own business logic to DevOps Center to help gate when a work item is ready for promotion.

## Overview

When a work item is in the In Review state, DevOps Center looks for all Pre-Approval validators installed in the system. It asks all of them, in parrellel, if the given work item is allowed to be Approved. If all of the validators return "yes", then DevOps Center shows the Approval toggle. If any one of the validators returns a "no", then we show it's error message instead of the Approval toggle.

Internally, DevOps Center still checks if the change request for the work item is mergeable; however, now we do this check as just one more implementation of the Pre-Approval Validator.

## Details

### Implementation

The method to implement for the validation is fairly straight forward.

```
global abstract sf_devop.SpiPreApprovalValidationResponse validate(
     sf_devop.SpiPreApprovalContext context
);

```

The context that you are provided gives you information about the work item that we are asking to be validated. The implementation can be whatever your business processes are. There are a few examples of Pre-Approval in this repository for further help.

After your validation logic is completed, you return an instance of `SpiPreApprovalValidationResponse`. To create one of them, there are two static factory methods on that class.

```
global static sf_devop.SpiPreApprovalValidationResponse pass();

global static sf_devop.SpiPreApprovalValidationResponse fail(
   String title,
   String message
);

```

As the names imply, if the context work item passes the validation, it returns the results of calling `pass()`; otherwise, it returns the results of calling `fail()`. If your validation fails the work item, you can return Rich Text Format in the message body and it is displayed when DevOps Center user shows the popover.

### Custom Metadata

DevOps Center lives in the `sf_devops` namespace and your implementation of the Pre-Approval validator does not. It might live in no namespace, or in a different namesspace. Because of this, DevOps Center can't easily tell that there is an implementation of PreApprovalValidator that we need to consider when determining if a work item can be Approved.

To assist in this, we have defined a custom metadata type called `Service_Provider`. This is used as a declarative way for you to say "Hey, I have a Pre-Approval Validator and it lives in this Apex class". DevOps Center can query these CMT records, find all of the PreApprovalValidators and then use them to determine if a work item can be Approved.

```
<?xml version="1.0" encoding="UTF-8" ?>
<CustomMetadata
  xmlns="http://soap.sforce.com/2006/04/metadata"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
>
    <label>A really cool name goes here</label>
    <protected>true</protected>
    <values>
        <field>sf_devops__Apex_Class__c</field>
        <value xsi:type="xsd:string">YourApexClassNameGoesHere</value>
    </values>
    <values>
        <field>sf_devops__Service_Type__c</field>
        <value xsi:type="xsd:string">PreApproval</value>
    </values>
</CustomMetadata>

```

This also provides a very convient way to turn on/off the Pre-Approval validators. Because DevOps Center is looking for Service_Providers with a `Service_Type__c` of `PreApproval`, you can just change the type to something else and it will get ignored. This is what we have done in this repository. We have prefixed all of the types with `demo-` so that they all start off, and customers can individually turn them on if they would like to sample them.

# See Also

[Test Status Example](./examples/TestStatus.md)  
[Pre-Approval Validator Developer's Guide](LinkMePlease)
