#!/bin/bash

# test for
userlist=$(cut -d ":" -f1 /etc/passwd)
for user in $userlist
do
  echo ====$user====
  id $user
  finger $user
done
