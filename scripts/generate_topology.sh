#!/bin/bash

CLIENTS=0
CDNS=0

# parse args
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --cdns)
            CDNS="$2"
            shift 2
            ;;
        --clients)
            CLIENTS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--clients N] [--cdns N]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Generating topology with:"
echo "- $CLIENTS Client node(s)"
echo "- $CDNS CDN node(s)"

# create directory structure in accordance with specified params:



exit 1