#!/bin/bash

# check network service
testing=$(netstat -tuln | grep ":80 ")
if [ "$testing" != "" ]; then
  echo  "WWW is running in your system."
fi

testing=$(netstat -tuln | grep ":22 ")
if [ "$testing" != "" ]; then
  echo  "ssh is running in your system."
fi

testing=$(netstat -tuln | grep ":21 ")
if [ "$testing" != "" ]; then
  echo  "ftp is running in your system."
fi

testing=$(netstat -tuln | grep ":25 ")
if [ "$testing" != "" ]; then
  echo  "mail is running in your system."
fi
