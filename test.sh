#!/bin/bash

# Run a command and capture its output
output=$(ls -l)

# Display the output in a Zenity dialog
zenity --info --text="$output"