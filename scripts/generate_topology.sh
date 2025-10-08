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

ip_idx=0

if [[ $CDNS -gt 0 ]]; then 

    echo "# CDN Mesh (M):" > "$CONF_FILE"    
    echo >> "$CONF_FILE"

    for i in $(seq 1 "$CDNS"); do 
        echo "cdn$i[0]=M" >> "$CONF_FILE"
        echo "cdn$i[exec]=cdn" >> "$CONF_FILE"
        echo "cdn$i[num_terms]=0" >> "$CONF_FILE"
        # echo "cdn$i[image]=
        if [[ $i -lt $CDNS ]]; then 
            echo >> "$CONF_FILE"
        fi

        touch "$LAB_DIR/cdn$i.startup"
        echo "ip addr add 10.0.0.$((ip_idx + 1))/24 dev eth0" >> "$LAB_DIR/cdn$i.startup"
        ip_idx=$((ip_idx + 1))
    done
fi

if [[ $CLIENTS -gt 0 ]]; then 

    echo >> "$CONF_FILE"

    echo "# Clients:" >> "$CONF_FILE"
    echo >> "$CONF_FILE"

    for i in $(seq 1 "$CLIENTS"); do 
        echo "client$i[0]=C$i" >> "$CONF_FILE"
        echo "client$i[exec]=client" >> "$CONF_FILE"
        echo "client$i[num_terms]=0" >> "$CONF_FILE"
        # echo "client$i[image]=
        if [[ $CDNS -gt 0 ]]; then
            rand_idx=$((RANDOM % CDNS + 1))
            if_idx=1  
            while grep -q "cdn$rand_idx\[$if_idx\]" "$CONF_FILE"; do
                ((if_idx++))
            done
            echo "cdn$rand_idx[$if_idx]=C$i" >> "$CONF_FILE" # connect each client to random CDN 
            echo "ip addr add 10.0.0.$((ip_idx + 1))/24 dev eth$if_idx" >> "$LAB_DIR/cdn$rand_idx.startup"
            ip_idx=$((ip_idx + 1))
        fi

        if [[ $i -lt $CLIENTS ]]; then 
            echo >> "$CONF_FILE"
        fi

        touch "$LAB_DIR/client$i.startup"

        echo "ip addr add 10.0.0.$((ip_idx + 1))/24 dev eth0" >> "$LAB_DIR/client$i.startup"    
        ip_idx=$((ip_idx + 1))
    done
fi

if [[ $CLIENTS -eq 0 && $CDNS -eq 0 ]]; then 
    echo "You generated an empty topology. If this was not intended, please run \"$0 --help\"."
fi
