#!/bin/bash


while true; do
    python3 random_data.py
    sleep $(( RANDOM % 20 ))
done
