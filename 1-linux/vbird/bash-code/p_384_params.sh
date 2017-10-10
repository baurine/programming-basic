#!/bin/bash

# test parameters
echo "The script name is ==> $0"
echo "Total parameters number is ==> $1"
[ "$#" -lt 2 ] && echo "parameters are less than 2, stop here." \
&& exit 0
echo "Whole parameters is ==> '$@'"
echo "The first parameter is ==> '$1'"
echo "The second parameters is ==> '$2'"

echo "---"
echo "parameter number is ==> '$#'"
echo "whole parameters is ==> '$@;"
shift
echo "parameter number is ==> '$#'"
echo "whole parameters is ==> '$@;"
echo "The first parameter is ==> '$1'"
