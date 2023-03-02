#!/bin/bash


while true; do
    python3 random_data.py
    if [ $? != 0 ]; then echo "Failed.."; exit 1; fi 
    sleep $(( RANDOM % 20 ))
done
