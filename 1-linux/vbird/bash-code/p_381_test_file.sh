#!/bin/bash

echo -e "Please input the file name, I will check the file type \
and permission.\n\n"
read -p "Input a file name : " filename

test -z $filename && echo "you MUST input a file name." && exit 0
test ! -e $filename && echo "the file '$filename' not exist!" && exit 0

test -f $filename && filetype="regular file"
test -d $filename && filetype="directory"

test -r $filename && perm="readable"
test -w $filename && perm="$perm writable"
test -x $filename && perm="$perm executable"

echo "the filename: $filename is $filetype,"
echo "and the permission is $perm."
