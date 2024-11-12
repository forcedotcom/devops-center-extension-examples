#!/bin/sh

USERNAME="User User"

USERID=$(sf data query -q "SELECT Id, Name from User WHERE Name = '$USERNAME'" --json | jq -r '.result.records[0].Id')

sf data query -q "SELECT Id, Name from Apextrigger WHERE NAMESPACEPREFIX = NULL"  --json | jq -c '.result.records[]' | while read trigger; do
    CONFIG_NAME=$(echo $trigger | jq -r '.Name')_Config
    TRIGGER_ID=$(echo $trigger | jq -r '.Id')
    sf data record create -t -s PlatformEventSubscriberConfig -v "BatchSize=500 UserId=$USERID MasterLabel=$CONFIG_NAME DeveloperName=$CONFIG_NAME PlatformEventConsumerId=$TRIGGER_ID"
done

echo "Now you need to go into your setup, disable the subscriber and reenable it"


