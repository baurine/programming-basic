#!/bin/bash

# test while
while [ "$yn" != "yes" -a "$yn" != "YES" ] 
do
  read -p "input yes/YES to stop the program : " yn
done
