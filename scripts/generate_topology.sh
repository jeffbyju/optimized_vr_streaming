#!/bin/bash

CLIENTS=0
CDNS=0
LAB_NAME=test

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
        --labname)
            LAB_NAME="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--clients N] [--cdns N] [--labname name]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1. If you're confused, run $0 --help."
            exit 1
            ;;
    esac
done

echo "Generating topology for lab \"$LAB_NAME\" with:"
echo "- $CLIENTS Client node(s)"
echo "- $CDNS CDN node(s)"

# create directory structure in accordance with specified params:

LAB_DIR="$HOME/$LAB_NAME"
CONF_FILE="$LAB_DIR/lab.conf"

mkdir -p "$LAB_DIR"
touch "$CONF_FILE"

if [[ $CDNS -gt 0 ]]; then 
    mkdir -p "$LAB_DIR/cdn"

    echo "# CDN Mesh (M):" > "$CONF_FILE"    
    echo >> "$CONF_FILE"

    for i in $(seq 1 "$CDNS"); do 
        echo "cdn$i[0]=M" >> "$CONF_FILE"
        echo "cdn$i[exec]=cdn" >> "$CONF_FILE"
        # echo "cdn$i[image]=
        if [[ $i -lt $CDNS ]]; then 
            echo >> "$CONF_FILE"
        fi
    done
fi

if [[ $CLIENTS -gt 0 ]]; then 

    echo >> "$CONF_FILE"

	mkdir -p "$LAB_DIR/client"

    echo "# Clients:" >> "$CONF_FILE"
    echo >> "$CONF_FILE"

    for i in $(seq 1 "$CLIENTS"); do 
        echo "client$i[0]=C$i" >> "$CONF_FILE"
        echo "client$i[exec]=client" >> "$CONF_FILE"
        # echo "client$i[image]=
        if [[ $CDNS -gt 0 ]]; then 
            echo "cdn$(( RANDOM % CDNS + 1 ))[1]=C$i" >> "$CONF_FILE" # connect each client to random CDN 
        fi
        if [[ $i -lt $CLIENTS ]]; then 
            echo >> "$CONF_FILE"
        fi
    done
fi

if [[ $CLIENTS -eq 0 && $CDNS -eq 0 ]]; then 
    echo "You generated an empty topology. If this was not intended, please run \"$0 --help\"."
fi
