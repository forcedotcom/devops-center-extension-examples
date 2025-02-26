# Defaulting Promote Options

**Use Case**: As a developer, I would like to always deploy all metadata that is in our source control system (VCS) when I promote into the first stage of the pipeline.  
**Use Case**: As a release manager, I would like a consistant naming convention to our change bundles.  
**Use Case**: As a release manager, I would like to require all deployments into our production org are check deploys and that all tests are run as part of the deployment.  
**Use Case**: As a quality manager, I would like to assign certain tests to be run on certain pipeline stages.

## Overview

The PrePromoteProvider interface allows customers to control the default selection and state of each of the options in the promote options dialog box. These options are:

- **Deployment Type**: Deploy only what is changed, or all metadata on the branch.
- **Test Options**: Which tests options are passed into the metadata deployment payload.
- **Promotion Type**: Deploy now, or do a check deploy?
- **Version Name**: Default value for a newly created version.

For each of the options sets, a developer can control the default selection and/or if the selection is modifiable.

## Details

In this example we load the target pipeline stage from the context, and based on the stage, the custom object correctly configures the SpiDefaultPromoteOptionsBuilder that is provided.

### First Stage Use Case

In this use case we want to control the deployment type of the first stage. We can determine the first stage if the target doesn't have a previous stage. If so, we can set the deployment type.

```
if (target.sf_devops__Pipeline_Stages__r.isEmpty()) {
    /**
    This is the first stage and we require a full deploy into the first stage.
    **/
    builder.setDeploymentType(sf_devops.SpiDeploymentType.FULL, false);
}
```

### Version Name Use Case

In this use case, we look at the source stage of the promotion to see if it is the bundling stage. If it is, we load the latest change bundle to determine what the defaulted version number should be. If there are no previous bundles, then we start at v1.0. If not, we pull apart the previous version number and increment. I know, this needs some error handling.

```
//Load the most recent bundle
List<sf_devops__Change_Bundle__c> bundles = [
  SELECT Id, sf_devops__Version_Name__c
  FROM sf_devops__Change_Bundle__c
  ORDER BY CreatedDate DESC
  LIMIT 1
];
if (bundles.isEmpty()) {
  //First version!
  builder.setVersionName('v1.0');
} else {
  String lastVersion = bundles[0].sf_devops__Version_Name__c;
  Decimal lastVersionNumber = Decimal.valueOf(
    lastVersion.subStringAfter('v')
  );
  builder.setVersionName('v' +
    (lastVersionNumber.intValue() + 1) +
    '.0');
}

```

### Terminal Stage Use Case

To determine if our target stage is the last stage in the pipeline (presumably production) we just need to verify it does not have a `sf_devops__Next_Stage__c` reference. If not, then we can set the promotion type and the test level.

```
if (target.sf_devops__Next_Stage__c == null) {
  /**
  This is a promotion into the terminal stage, require a check deploy and all tests.
  **/
  builder.setTestOptions(
    sf_devops.SpiTestLevel.RUN_ALL_TESTS_IN_ORG,
    null,
    false
  );
  builder.setPromotionType(
    sf_devops.SpiPromotionType.CHECK_DEPLOY,
    false
  );
}

```

### Specified Tests Use Case

And lastly, we can look to see if the stage has any specific tests defined. If so, we can change the test options to run these specified tests.

```
if (String.isNotBlank(target.Required_Tests__c)) {
  builder.setTestOptions(
    sf_devops.SpiTestLevel.RUN_SPECIFIED_TESTS,
    target.Required_Tests__c,
    false
  );
}
```

## Relevant Files

- [PrePromoteOptionsProvider.cls](../../force-app/main/default/classes/prePromote/PrePromoteOptionsProvider.cls): Implementation of the Pre-Promote Provider for the options

- [sf_devops\_\_Service_Provider.Options_PrePromote_Validator.md-meta.xml](../../force-app/main/default/customMetadata/sf_devops__Service_Provider.Options_PrePromote_Validator.md-meta.xml): Custom Metadata Type to enable the Pre-Promote Provider

- [Required_Tests\_\_c.field-meta.xml](../../force-app/main/default/objects/sf_devops__Pipeline_Stage__c/fields/Required_Tests__c.field-meta.xml): Custom field for specific tests on a stage.

# See Also

[PrePromote Validators](../PrePromoteValidators.md)
