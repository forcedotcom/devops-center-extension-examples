/**
 * An example of how the pre promote validator can be used to control the promote options dialog.
 */
global with sharing class PrePromoteOptionsProvider extends sf_devops.PrePromoteProvider {
  private final sf_devops.DefaultedPromoteOptions options = new PrePromoteOptions();

  global override sf_devops.DefaultedPromoteOptions getPromoteOptions() {
    return this.options;
  }

  global with sharing class PrePromoteOptions extends sf_devops.DefaultedPromoteOptions {
    global override void setDefaults(
      sf_devops.SpiPrePromoteContext context,
      sf_devops.SpiDefaultPromoteOptionsBuilder builder
    ) {
      //Load the target stage from the context
      sf_devops__Pipeline_Stage__c target = [
        SELECT
          Id,
          Name,
          sf_devops__Next_Stage__c,
          Required_Tests__c,
          (
            SELECT Id, sf_devops__Prerelease__c
            FROM sf_devops__Pipeline_Stages__r
          )
        FROM sf_devops__Pipeline_Stage__c
        WHERE Id = :context.getTargetStageId()
      ][0];

      Boolean bundlingPromotion = false;
      if (target.sf_devops__Pipeline_Stages__r.isEmpty()) {
        //This is the first stage and we require a full deploy into the first stage
        builder.setDeploymentType(sf_devops.SpiDeploymentType.FULL, false);
      } else {
        //See if the source stage is the bundling stage
        bundlingPromotion =
          target.sf_devops__Pipeline_Stages__r[0].sf_devops__Prerelease__c ==
          true;
      }

      //If this is the bundling stage, then we want to default the version number
      if (bundlingPromotion == true) {
        this.defaultVersionNumber(builder, target);
      }

      //Lastly set the promotion type and test levels
      if (target.sf_devops__Next_Stage__c == null) {
        //This is a promotion into the terminal stage, require a check deploy and all tests
        builder.setTestOptions(
          sf_devops.SpiTestLevel.RUN_ALL_TESTS_IN_ORG,
          null,
          false
        );
        builder.setPromotionType(
          sf_devops.SpiPromotionType.CHECK_DEPLOY,
          false
        );
      } else {
        //Look for specified tests
        if (String.isNotBlank(target.Required_Tests__c)) {
          builder.setTestOptions(
            sf_devops.SpiTestLevel.RUN_SPECIFIED_TESTS,
            target.Required_Tests__c,
            false
          );
        }
      }
    }

    /**
     * Helper to look for existing change bundles and auto increment the version number
     */
    private void defaultVersionNumber(
      sf_devops.SpiDefaultPromoteOptionsBuilder builder,
      sf_devops__Pipeline_Stage__c target
    ) {
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
        builder.setVersionName('v' + (lastVersionNumber.intValue() + 1) + '.0');
      }
    }
  }
}
