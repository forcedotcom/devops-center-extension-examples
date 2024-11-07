# Pre Promote Validators

Pre Promote Validators run every time a promotions is attempted and act as gates to allow or not the promotion to initiate.

DevOps Center Team has provided some examples on how to create custom ones.

In order to create a custom one please check this doc: https://docs.google.com/document/d/1zrIQchr8OdYG7N2HUqzorxSaeiS-ohRQgDBiP_A0jzM/edit?tab=t.0

## Info Pre Promote Provider

This Validator has no real logic, it always shows an INFO dialog to the user. The user can decide to continue with promotion or to cancel it by clicking close.

![image](files/info.png)

## Warning Pre Promote Provider

This Validator has no real logic, it always shows a WARNING dialog to the user. This dialog uses WhatHappened shape and shows a warning banner. It allows the user to continue or cancel the promotion.

![image](files/warningWhatHappened.png)

## Warning Pre Promote Provider Override Action

This Validator showcases how to add some logic to the 'continue' button.

In this example, the team wants to add a check for each pipeline stage that will receive a promotion. They want to flag the pipeline stage as ready to receive a promotion or not.

For this they need a new field, so using the object model extensibility features, they create a new checkbox field on `sf_devops__Pipeline_Stage__c` object. (`Is_Available__c `)

Then they implement a Validator that verifies if this field is true on the target stage to allow promotion.

In case it is not true, it returns a warning dialog (also what happened structure) but with the caveat that they want to override the 'continue' button behavior to instead of continuing with the promotion, to update the `Is_Available__c` field on `sf_devops__Pipeline_Stage__c` to true.

Then the next time any promotion is attempted into the same stage, it will allow the promotion to complete.
