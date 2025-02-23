#!/bin/bash

# This is placeholder for the send-notification script
# Set up the script to send notifications to the slack, mattermost, email, etc.

touch /tmp/send-notification.log
chmod 777 /tmp/send-notification.log
echo $@ >> /tmp/send-notification.log