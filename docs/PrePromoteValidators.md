# Pre Promote Validators

Pre Promote Validators run every time a promotions is attempted and act as gates to allow or not the promotion to initiate.

DevOps Center Team has provided some examples on how to create custom ones.

In order to create a custom one please check this doc: https://docs.google.com/document/d/1zrIQchr8OdYG7N2HUqzorxSaeiS-ohRQgDBiP_A0jzM/edit?tab=t.0

## Info Pre Promote Provider

This Validator has no real logic, it always shows an INFO dialog to the user. The user can decide to continue with promotion or to cancel it by clicking close.

![image](files/info.png)

## Warning Pre Promote Provider

This Validator has no real logic, it always shows a WARNING dialog to the user. This dialog uses WhatHappened shape and allows the user to continue or cancel the promotion.

![image](files/warningWhatHappened.png)
