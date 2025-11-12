#!/bin/bash
while [ $# -ne 0 ]
do
    case "$1" in
        --home) shift ; home="$1" ;;
        --uid) shift ; uid="$1" ;;
        --user) shift ; user="$1" ;;
        --shell) shift ; shell="$1" ;;
        *) echo "Unknown argument given" ;;
    esac
    shift
done

useradd ${user:?error} \
        --uid ${uid:?error} \
        --home-dir ${home:?error} \
        --shell ${shell:-/bin/bash}

su $user -c vnc.bash

