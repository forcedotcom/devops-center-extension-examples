# DevOps Center Extension Showcase

This repository is meant as a showscase of how you can extend the internal business process to more directly meet your internal business processes.  In this showcase we will give examples of

*Platform Events* How you can be notified on the stage changes of work items and when work items are moved through the pipeline.
*Pre Approval Validator*  How you can block the approval of a work item until certain business logic is met.
*Pre Promote Validator* How you can block the promotion process work item(s) until certain business logic is met.



## Overview

For the validators, these extensions are implemented by a set of global interfaces that you can implement, then the DevOps Center will query these as needed to perform the validation.  In the simpliest sense, the DevOps Center will ask "Can WI-000123 be approved?" and you can return a yes or no answer.  The DevOps Center will display the appropriate state, based on your answer, and either allow or disallow the approval.

Besides implementing the correct global interfaces, you also need to declare that the extension exists.  To accomplish this you need to insert of custom metadata record of the type sf_devops__Service_Provider.  This will declare that there is an extension, what type is is (PreApproval or PrePromote) and the name of the Apex class that implements the required interface.

*Note* as there are many example implementations in this repository, all of them are intially setup as disabled.  To accomplish this we added `demo-` to the front of the type, so it is checked in as `demo-PreApproval` or `demo-PrePromote`.  To enable on of the examples, just remove the `demo-` from the type property of the custom metadata type and push the source to your test org.


## Creating a test org

These examples will work in any org that has the DevOps Center installed. If you want to create a demo org to test these extension and not do it in your production org, you can use `./script/unix/create-scratch-org.sh`.  This script will use the default dev hub to create a new scratch org, it will install the DevOps Center into the scratch org and then push all of the examples.

`./script/unix/create-scratch-org.sh "DevOps Center@8.2.0"`

## Documentation

### By Extension Type
[Lifecycle Platform Events](./docs/Lifecycle.md)   
[Pre Approval](./docs/PreApprovalValidators.md)   
[Pre Promote](./docs/PrePromoteValidators.md)   

### By Example
[Test Status](./docs/examples/TestStatus.md)   
[Development Time](./docs/examples/DevelopmentTime.md)   
[Pre Promote Info](./docs/examples/PrePromoteInfo.md)   
[Pre Promote Warning](./docs/examples/PrePromoteWarning.md)   
[Pre Promote Override](./docs/examples/PrePromoteOverride.md)   

