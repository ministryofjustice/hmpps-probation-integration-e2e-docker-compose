#!/usr/bin/env bash

# Given dependencies have started
while ! curl -sf http://community-api:8080/health \
   || ! curl -sf http://delius-api:8080/health \
   || ! curl -sf http://prison-to-probation-update:8080/health/ping; do sleep 1; done;

# When I send a prisoner released notification
aws --endpoint-url=http://localstack:4566 sns publish \
    --topic-arn arn:aws:sns:eu-west-2:000000000000:hmpps-events-topic \
    --message-attributes '{
      "eventType": { "DataType": "String", "StringValue": "prison-offender-events.prisoner.released" }
    }' \
    --message '{
      "version":"1.0",
      "occurredAt":"2020-02-12T15:14:24.125533Z",
      "publishedAt":"2020-02-12T15:15:09.902048716Z",
      "description":"A prisoner has been released from prison",
      "additionalInformation": {
        "nomsNumber":"A0289IR",
        "prisonId":"BZIHMP",
        "reason":"RELEASED",
        "details":"Release date 2021-05-12"
      }
    }'
sleep 30 # and wait for message to be processed

# Then there should be a single new release record
count=$(sqlplus -S delius_app_schema/NDelius1@oracledb:1521/XEPDB1 <<EOF
  select count(*) from release
  where offender_id = (select offender_id from offender where noms_number = 'A0289IR')
  and last_updated_datetime > sysdate - interval '5' minute;
EOF
)
echo "$count" | grep 1