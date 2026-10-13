#!/bin/bash

# Generated from official installation evidence:
# - https://usemagpie.ai/docs/docker

# Adjust host-mounted data directory permissions for the container runtime user.
if [ -d config ]; then
    chown -R 65532:65532 config
fi
