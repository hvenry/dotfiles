#!/bin/bash

# Display user@hostname information
# Returns format: "user@hostname"

echo "$(whoami)@$(hostnamectl hostname)"
