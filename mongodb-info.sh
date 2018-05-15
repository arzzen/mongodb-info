#!/bin/bash

set -o errexit

white=$(tput bold)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
gray=$(tput setaf 11)
blue=$(tput setaf 6)
normal=$(tput sgr0)
readonly format="%-18s %-10s %-30s\n"

function usage() 
{
    cmd=$(basename $0)    
    cat <<EOF

${white}MongoDB Stats ${normal}

Usage:
  $white$cmd [ -s | -c | -k | -G | -M | -h ]$normal

Connection options:
  $white-s$normal <connection_string>    MongoDB connection string. 
  $white-c$normal <collection_name>      [optional] MongoDB collection string name.

Stat options:
  $white-k$normal                        [optional] This command returns all data in kilo bytes.
  $white-M|m$normal                      [optional] This command returns all data in mega bytes.
  $white-G|g$normal                      [optional] This command returns all data in giga bytes.
  $white-r$normal                        [optional] Disable interpret ANSI color and style sequences.
  $white-h$normal                        Prints this help.

Example:
  ${normal}$cmd -s "<hostname|ip>:<port>/<dbname> -u <username> -p <password>" -c "<collection_name>" -G ${normal}
  ${normal}$cmd -s "--host=<hostname|ip> --port=<port> --username=<user> --password=<pass> --authenticationDatabase=<dbname>" ${normal}


EOF
    exit $1
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

OPTERR=0
CONNECT_STRING=""
COLOR=1
SCALE="1"
SCALE_LABEL="B"
COLLECTION=""
while getopts ":c:s:r:hkmMgG" options
do
    case $options in
        s) 
            CONNECT_STRING=$OPTARG
            ;;
        k) 
            SCALE="1024"
            SCALE_LABEL="kB"
            ;;
        m|M)
            SCALE="1024*1024"
            SCALE_LABEL="MB"
            ;;
        g|G)
            SCALE="1024*1024*1024"
            SCALE_LABEL="GB"
            ;;
        c)
            COLLECTION=$OPTARG"."
            ;;
        r)
            COLOR=0
            ;;
        h|*) 
            usage 0
            ;;
    esac
done
shift $(($OPTIND - 1))

mongoStats=$(mktemp)
mongo --eval="JSON.stringify(db."$COLLECTION"stats($SCALE))" --quiet "$CONNECT_STRING" > $mongoStats

mongoServerStats=$(mktemp)
mongo --eval="JSON.stringify(db.serverStatus())" --quiet "$CONNECT_STRING" > $mongoServerStats

mongoProcesses=$(mktemp)
mongo --eval="db.currentOP().inprog.forEach(function(query){ if(query.op != 'none') { print(JSON.stringify(query)) } })" --quiet "$CONNECT_STRING" > $mongoProcesses

mongoDbs=$(mktemp)
mongo --eval="JSON.stringify(db.adminCommand( { listDatabases: 1 } ) )" --quiet "$CONNECT_STRING" > $mongoDbs

mongoColls=$(mktemp)
mongo --eval="JSON.stringify(db.getCollectionInfos())" --quiet "$CONNECT_STRING" > $mongoColls

function _echo
{
    printf '%s\n' "$1" 
}

function _echoB
{
    _echo ""

    if [[ $COLOR == 1 ]]; then
        _echo "${white}$1${normal}"
    else 
        _echo "$1"
    fi

    _echo ""
}

function row() 
{
    printf '    %-20s %s\n' "$1" "$2"
}

function rowCol3() 
{
    printf '    %-20s %-20s %s\n' "$1" "$2" "$3"
}

function rowCol4() 
{
    printf '    %-20s %-20s %-20s %s\n' "$1" "$2" "$3" "$4"
}

function rowCol6() 
{
    printf '    %-20s %-20s %-20s %-20s %-20s %s\n' "$1" "$2" "$3" "$4" "$5" "$6"
}

function rowLong() 
{
    printf '    %-110s %s\n' "$1" "$2"
}

function humanSize() 
{
    bytes=$1
    printf '%02d %s\n' $bytes $SCALE_LABEL
}

function humanTime() 
{
    secs=$1
    printf '%02dd %02dh %02dm %02ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60))
}

function round() 
{
    echo "$1" | awk '{ printf("%.2f", $1); }'
}

function cmd()
{
    cat $mongoStats | jq "$1"
}

function cmdSrv()
{
    cat $mongoServerStats | jq -r "$1" | tr -d '"'
}

function cmdSrvItter()
{
    echo $(cmdSrv ".$1 | to_entries[] | map(tostring) | join(\";\")")
}

function main()
{
    _echoB "Server"
    row "host" $(cmdSrv .host)
    row "version" $(cmdSrv .version)
    row "uptime" "$(humanTime $(cmdSrv .uptime))"
    row "local time" $(cmdSrv .localTime)

    if [ -n "$COLLECTION" ]; then
        _echoB "Collection" 

        row "name" $(echo $COLLECTION | tr -d '.')
        row "indexes" "$(cmd '.nindexes')"
        row "index size" "$(humanSize $(cmd .totalIndexSize))"
        row "objects" $(cmd .count)
        row "average object size" $(round $(cmd .avgObjSize))
        row "storage size" "$(humanSize $(cmd .storageSize))"
        row "data size" "$(humanSize $(cmd .size))"

        _echoB "Indexes"
        rowLong "Name" "Size"
        indexes=$(cat $mongoStats | jq -r '.indexSizes | to_entries[] | map(tostring) | join(";")')
        for value in $indexes; do
            indexName=$(echo $value | awk -F";" '{print $1}')
            indexSize=$(echo $value | awk -F";" '{print $2}')
            rowLong "$indexName" "$(humanSize $indexSize)"
        done

        if [ $(cmd .sharded) == "true" ]; then
            _echoB "Shards"
            rowCol3 "Name" "Objects" "Storage size"
            shards=$(cat $mongoStats | jq -r '.shards | keys | join("\n")')
            for value in $shards; do
                size=$(cmd ".shards.$value.storageSize")
                count=$(cmd ".shards.$value.count")
                rowCol3 "$value" "$count" "$(humanSize $size)"
            done
        fi
    else 
        _echoB "Database stats"
        row "indexes" $(cmd .indexes) 
        row "index size" "$(humanSize $(cmd .indexSize))"
        row "objects" $(cmd .objects)
        row "average object size" $(round "$(cmd .avgObjSize)")
        row "storage size" "$(humanSize $(cmd .storageSize))"
        row "data size" "$(humanSize $(cmd .dataSize))"

        _echoB "Databases"
        dbs=$(cat $mongoDbs | jq -r '.databases | .[].name')
        for db in $dbs; do
            row $db
        done
        
        _echoB "Collections"
        colls=$(cat $mongoColls | jq -r '.[].name')
        for coll in $colls; do
            row $coll
        done

        _echoB "Memory allocation"
        cat "$mongoServerStats" | jq -r ".tcmalloc.tcmalloc.formattedString" | tail -n +2 | head -n -4 | while read line; do
            rowLong "$(echo $line | sed -e 's/^MALLOC:[ ]*//')"
        done

        _echoB "Counters"
        opcounters=$(cmdSrvItter "opcounters")
        for data in $opcounters; do
            key=$(echo $data | awk -F";" '{print $1}')
            value=$(echo $data | awk -F";" '{print $2}')
            row "$key" "$value"
        done
    fi


    _echoB "Connections"
    connections=$(cmdSrvItter "connections")
    for data in $connections; do
        key=$(echo $data | awk -F";" '{print $1}')
        value=$(echo $data | awk -F";" '{print $2}')
        row "$key" "$value"
    done

    _echoB "Current processes"
    processes=$(cat $mongoProcesses | tr -d ' ' | tr -d '$')
    rowCol4 "Namespace" "Operation" "Running time" "Op Id"
    for process in $processes; do
        rowCol4 $(echo "$process" | jq -r '.ns') $(echo "$process" | jq -r '.op') "$(humanTime $(echo $process | jq -r '.microsecs_running.numberLong'))" $(echo "$process" | jq -r '.opid')
    done

    _echo ""
}

_echoB "MongoDB Stats"
main

exit 0
