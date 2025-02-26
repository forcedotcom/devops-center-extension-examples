# DevOps Center Extension Showcase

This repository is meant as a showscase of how you can extend the internal business process to more directly meet your internal business processes. See examples for:

_Platform Events_ How you can be notified when work items are moved through the pipeline.
_Pre Approval Validator_ How you can block the approval of a work item until certain business logic is met.
_Pre Promote Validator_ How you can block the promotion process work item(s) until certain business logic is met.

## Overview

For the validators, these extensions are implemented by a set of global interfaces that you can implement, then the DevOps Center will query these as needed to perform the validation. In the simpliest sense, the DevOps Center will ask "Can WI-000123 be approved?" and you can return a yes or no answer. DevOps Center displays the appropriate state, based on your answer, and either allow or disallow the approval.

Besides implementing the correct global interfaces, you also need to declare that the extension exists by inserting a custom metadata record of the type sf_devops\_\_Service_Provider. This declares that there is an extension, what type is is (Pre-Approval or Pre-Promote) and the name of the Apex class that implements the required interface.

_Note_ Because there are many example implementations in this repository, all of them are intially setup as disabled. To accomplish this we added `demo-` to the front of the type, so it is checked in as `demo-PreApproval` or `demo-PrePromote`. To enable an example, just remove the `demo-` from the type property of the custom metadata type and push the source to your test org.

## Creating a Test Org

These examples work in any org with DevOps Center installed. If you want to create a demo org to test these extension and not do it in your production org, you can use `./scripts/unix/create-scratch-org.sh`. This script uses the default Dev Hub to create a new scratch org, and then installs DevOps Center into the scratch org and pushes all of the examples.

`./scripts/unix/create-scratch-org.sh "DevOps Center@9.1"`

## Documentation

### By Extension Type

[Lifecycle Platform Events](./docs/Lifecycle.md)  
[Pre Approval](./docs/PreApprovalValidators.md)  
[Pre Promote](./docs/PrePromoteValidators.md)

### By Example

[Test Status](./docs/examples/TestStatus.md)  
[Development Time](./docs/examples/DevelopmentTime.md)  
[Promote Tasks](./docs/examples/PromoteTasks.md)  
[Promote Options](./docs/examples/PromoteOptions.md)  
[Pre Promote Info](./docs/examples/PrePromoteInfo.md)  
[Pre Promote Warning](./docs/examples/PrePromoteWarning.md)  
[Pre Promote Override](./docs/examples/PrePromoteOverride.md)
