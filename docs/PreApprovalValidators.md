# Pre Approval Validators

The DevOps Center has the concept of approving the development of a Work Item. This is a gate between a Work Item that is in development and a Work Item that is in the pipeline and ready for it's journey to the production environment.

Previously, the DevOps Center had some pretty basic rules on when a Work Item can be approved for promotions, basically if the change request for that work item was mergeable. It was assumed that the rest of the approval process was handled externally (ie in a code review, or design review, etc.).

Now, with the global PreAppovalValidator interface, customers can start to add their own business logic to the DevOps Center to help gate when a Work Item is ready for promotion.

## Overview

When a Work Item is in the In Review state, the DevOps Center will look for all PreApproval validators installed in the system. It will ask all of them, in parrellel, if the given Work Item is allowed to be Approved. If all of the validators return "yes", then the DevOps Center will show the Approval toggle. If any one of the validators returns a "no", then we will show it's error message instead of the Approcal toggle.

Internally, the DevOps Center still checks if the change request for the work item is mergeable, however now we do this check as just one more implementation of the PreApproval Validator.

## Details

### Implementation

The method to implement for the validation is fairly straight forward.

```
global abstract sf_devop.SpiPreApprovalValidationResponse validate(
     sf_devop.SpiPreApprovalContext context
);

```

The context that you are provided will give you information about the Work Item that we are asking to be validated. The implementation can be whatever your business processes maybe. There are a few examples of PreApproval in this repository for further help.

Once your validation logic is completed, you will need to return an instance of `SpiPreApprovalValidationResponse`. To create one of them there are 2 static factory methods on that class.

```
global static sf_devop.SpiPreApprovalValidationResponse pass();

global static sf_devop.SpiPreApprovalValidationResponse fail(
   String title,
   String message
);

```

As the names imply, if the context Work Item passes the validation, return the results of calling `pass()`, otherwise return the results of calling `fail()`. If your validation fails the work item, you may return Rich Text Format in the message body and it will be displayed when the DevOps Center user shows the popover.

### Custom Metadata

The DevOps Center lives in the sf_devops namespace and your implementation of the PreApproval validator does not. It might live in no namespace, or in a different namesspace. Because of this, the DevOps Center cannot easily tell that there is an implementation of PreApprovalValidator that we need to consider when determining if a Work Item can be Approved.

To assist in this, we have defined a Custom Metadata Type called `Service_Provider`. This is used as a declarative way for you to say "Hey, I have a PreApproval Validator and it lives in this Apex class". The DevOps Center can query these CMT records, find all of the PreApprovalValidators and then use them to determine if a Work Item can be Approved.

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

This also provides a very convient way to turn on/off the PreApproval validators. Since the DevOps Center is looking for Service_Providers with a `Service_Type__c` of `PreApproval`, you can just change the type to something else and it will get ignored. This is what we have done in this repository, we have prefixed all of the types with `demo-` so that they all start off, and customers can individually turn them on if they would like to samepl them.

# See Also

[Test Status Example](./examples/TestStatus.md)  
[PreApproval Validator Developer's Guide](LinkMePlease)
