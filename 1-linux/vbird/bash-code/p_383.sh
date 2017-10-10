#!/bin/bash

read -p "Please input (Y/N) : " yn
[ "$yn" == "Y" -o "$yn" == "y" ] && echo "ok, contiune." && exit 0
[ "$yn" == "N" -o "$yn" == "n" ] && echo "game over." && exit 0
echo "I don't know what you choice."
