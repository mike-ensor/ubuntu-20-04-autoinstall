#!/bin/bash


function show_help() {
    echo ""
    echo "Usage:"
    echo "  ./create-isos.sh [options]"
    echo "  Options:"
    echo "    -h [-?]                   Show this help text"
    echo "    -c [#]                    Count of hosts to create"
    echo "    -l [<path>]               Path to write the ISOs into (defaults to '.')"
    echo "    -d                        Dry-run, print out what commands would be"
    echo ""
}

HOST_COUNT=6
DRY_RUN=0
OUTPUT_PATH="."

while getopts "h?dc:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  HOST_COUNT="$OPTARG";;
    d)  DRY_RUN="1";;
    l)  OUTPUT_PATH="$OPTARG";;
    esac
done
shift $(($OPTIND-1))

for (( host=1; host<=$HOST_COUNT; host++ ))
do
    echo "Creating 'nuc-$host' ISO image..."
    if [[ ${DRY_RUN} > 0 ]]; then
        echo -e "dry-run->\t./build_iso.sh -u abm-admin -H nuc-${host} -F ${OUTPUT_PATH}/nuc-${host}.iso\n"
    else
        ./build_iso.sh -u abm-admin -H nuc-${host} -F ${OUTPUT_PATH}/nuc-${host}.iso
    fi
done

echo -e "\n-----------"
echo "Access/credentials for each ISO:"
echo -e "\tUsername: abm-admin"
echo -e "\tPassword: troubled-marble-150"
echo ""