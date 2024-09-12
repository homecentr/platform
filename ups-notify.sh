#!/usr/bin/env bash

set -e

# NOTIFYTYPE is supplied by NUT
PAGERDUTY_ROUTING_KEY="TBA"
UPS_NAME=$(cat /etc/ups)

case $NOTIFYTYPE in
  ONBATT | LOWBATT)
    EVENT_ACTION="trigger"
    EVENT_SEVERITY="critical"
    EVENT_DEDUP_KEY="STATE_$UPS_NAME"
    ;;

  ONLINE)
    EVENT_ACTION="resolve"
    EVENT_SEVERITY="critical"
    EVENT_DEDUP_KEY="STATE_$UPS_NAME"
    ;;

  SHUTDOWN | FSD)
    EVENT_ACTION="trigger"
    EVENT_SEVERITY="error"
    EVENT_DEDUP_KEY="STATE_$UPS_NAME"
    ;;


  COMMBAD | NOCOMM)
    EVENT_ACTION="trigger"
    EVENT_SEVERITY="warn"
    EVENT_DEDUP_KEY="COMM_$UPS_NAME"
    ;;

  COMMOK)
    EVENT_ACTION="resolve"
    EVENT_SEVERITY="warn"
    EVENT_DEDUP_KEY="COMM_$UPS_NAME"
    ;;

  *)
    EVENT_SEVERITY="critical"
    EVENT_ACTION="trigger"
    EVENT_DEDUP_KEY="STATE_$UPS_NAME"
    ;;
esac

EVENT_TIME=$(date --utc '+%Y-%m-%dT%H:%M:%S.%3N+0000')
EVENT_SOURCE=$(hostname)

UPS_STATUS_ALL=$(upsc "$UPS_NAME" 2>/dev/null)
UPS_STATUS=$(echo "$UPS_STATUS_ALL" | grep ups.status | cut -d':' -f 2 | xargs)
UPS_BATTERY_CHARGE=$(echo "$UPS_STATUS_ALL" | grep battery.charge | cut -d':' -f 2 | xargs)
UPS_BATTERY_RUNTIME=$(echo "$UPS_STATUS_ALL" | grep battery.runtime | cut -d':' -f 2 | xargs)

PAYLOAD=$(cat <<-EOF
  {
    "payload": {
        "summary": "UPS $UPS_NAME status changed to $NOTIFYTYPE",
        "timestamp": "$EVENT_TIME",
        "severity": "$EVENT_SEVERITY",
        "source": "$EVENT_SOURCE",
        "component": "Network UPS tools",
        "custom_details": {
            "notifytype": "$NOTIFYTYPE",
            "ups.status": "$UPS_STATUS",
            "battery.charge": "$UPS_BATTERY_CHARGE",
            "battery.runtime": "$UPS_BATTERY_RUNTIME"
        }
    },
    "routing_key": "$PAGERDUTY_ROUTING_KEY",
    "dedup_key": "$EVENT_DEDUP_KEY",
    "event_action": "$EVENT_ACTION",
    "client": "Network UPS tools"
  }
EOF
)

echo "$PAYLOAD"

curl --request POST -v \
     --url https://events.pagerduty.com/v2/enqueue \
     --header 'Accept: application/json' \
     --header 'Content-Type: application/json' \
     --data "$PAYLOAD"