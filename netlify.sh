#!/bin/bash
# This script is used by netlify and cloudflare pages
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d
./bin/task build
