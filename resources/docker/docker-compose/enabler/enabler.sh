#!/bin/bash

debugging=0

debug() {
        if [ $debugging -eq 1 ]; then
                echo $1
        fi
}

check() {
    if [ -z "$1" ]; then
        echo "Can not chack without platform Interworking Services URL!"
        exit 1
    fi

    nginxUrl=$1

    checkUrl $nginxUrl 404 "Nginx"
    checkLog "enablerconfig" "Enabler Config Service"
    checkLog "eureka" "Eureka"
    checkUrl "$nginxUrl/paam/get_available_aams" 200 "AAM - Authentication Authorization Manager"
    checkUrl "http://localhost:8001/resources" 200 "RH - Resource Manager"
    checkUrl "$nginxUrl/rap/Sensors('x')" 404 "RAP - Resource Access Proxy"
    checkLog "monitoring" "Monitoring"
    checkLog "erm" "ERM - Enabler Resource Manager"
    checkLog "epp" "EPP - Enabler Platform Proxy"
    checkLog "enablerlogicexample" "ELE - Enabler Logic Example"
}

checkLog() {
    debug "checkLog: $1 $2"
    unset result
    containerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep $1 | awk '{print $1}')
    debug "checkLog: containerID=$containerID"
    if [ -n "$containerID" ]; then
        result=$(docker logs $containerID 2>&1 | grep "seconds (JVM running for")
    fi
    debug "checkLog: result=$result"

    if [ -n "$result" ]; then
        echo "OK - $2"
    else
        echo "NOT RUNNING - $2"
    fi
}

checkUrl() {
    result=$(curl -o /dev/null --silent --write-out '%{http_code}' $1)
    if [ "$2" == "$result" ]; then
        echo "OK - $3"
    elif [ "000" == "$result" ]; then
        echo "NOT RUNNING - $3"
    elif [ "502" == "$result" ]; then
        echo "NOT RUNNING - $3"
    else
        echo "ERROR - $3"
        echo "  Response code:"
        echo "    expecting: $2"
        echo "    actual: $result"
    fi
}

wait() {
    if [ -z "$1" ]; then
        echo "Can not chack without platform Interworking Services URL!"
        exit 1
    fi

    nginxUrl=$1
    waitForUrl $nginxUrl 404 "Nginx"
    waitForLog "enablerconfig" "Enabler Config Service"
    waitForLog "eureka" "Eureka"
    waitForUrl "$nginxUrl/paam/get_available_aams" 200 "AAM - Authentication Authorization Manager"
    waitForUrl "http://localhost:8001/resources" 200 "RH - Resource Manager"
    waitForUrl "$nginxUrl/rap/Sensors('x')" 404 "RAP - Resource Access Proxy"
    waitForLog "monitoring" "Monitoring"
    waitForLog "erm" "ERM - Enabler Resource Manager"
    waitForLog "epp" "EPP - Enabler Platform Proxy"
    waitForLog "enablerlogicexample" "ELE - Enabler Logic Example"
}

waitForUrl() {
    echo "Waiting for $3"
    until [ $(curl -o /dev/null --silent --write-out '%{http_code}' $1) == "$2" ]; do
        printf '.'
        sleep 2
    done
    echo " STARTED"
}

waitForLog() {
    debug "waitForLog: $1 $2"
    unset result
    echo "Waiting for $2"
    containerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep $1 | awk '{print $1}')
    debug "waitForLog: containerID=$containerID"
    if [ -n "$containerID" ]; then
        result=$(docker logs $containerID 2>&1 | grep "seconds (JVM running for")
    fi
    debug "waitForLog: result=$result"

    until [ -n "$result" ]; do
        printf '.'
        sleep 2
        containerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep $1 | awk '{print $1}')
        if [ -n "$containerID" ]; then
            result=$(docker logs $containerID 2>&1 | grep "seconds (JVM running for")
        fi
        debug "waitForLog: result=$result"
    done
    echo " STARTED"
}

log() {
    debug "log: $1"
    echo "Log for $1"
    containerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep $1 | awk '{print $1}')
    debug "log: containerID=$containerID"
    if [ -n "$containerID" ]; then
        docker logs $containerID -f
    else
        echo "Can not find containerID for '$1'"
    fi
    debug "waitForLog: result=$result"
}

callSsh() {
    debug "callSsh: $1"
    echo "SSH in $1"
    containerID=$(docker ps --format "{{.ID}} {{.Image}}" | grep $1 | awk '{print $1}')
    debug "log: containerID=$containerID"
    if [ -n "$containerID" ]; then
        docker exec -it $containerID /bin/bash
    else
        echo "Can not find containerID for '$1'"
    fi
}

case "$1" in
  check)
    check $2
    ;;
  checklog)
    case "$2" in
            enablerconfig)
                checkLog $2 "Enabler Config Service"
                ;;
            eureka)
                checkLog $2 "Eureka"
                ;;
            aam)
                checkLog $2 "AAM - Authentication Authorization Manager"
                ;;
            rh)
                checkLog $2 "RH - Resource Manager"
                ;;
            rap)
                checkLog $2 "RAP - Resource Access Proxy"
                ;;
            monitoring)
                checkLog $2 "Monitoring"
                ;;
            erm)
                checkLog $2 "ERM - Enabler Resource Manager"
                ;;
            epp)
                checkLog $2 "EPP - Enabler Platform Proxy"
                ;;
            enablerlogicexample)
                checkLog $2 "ELE - Enabler Logic Example"
                ;;
    esac
    ;;
  log)
    log $2
    ;;
  ssh)
    callSsh $2
    ;;
  wait)
    wait $2
    ;;
  *)
    echo "Usage: $0 {command}"
    echo "COMMANDS:"
    echo "  check {Interworking Service URL} - Checks if all components are running"
    echo "  checklog {enablerconfig|eureka|aam|rh|rap|monitoring|erm|epp|enablerlogicexample} - Check if specified component is running by checking log"
    echo "  log {enablerconfig|eureka|aam|rh|rap|monitoring|erm|epp|enablerlogicexample} - Print log of specified component"
    echo "  ssh {enablerconfig|eureka|aam|rh|rap|monitoring|erm|epp|enablerlogicexample} - SSH to specified component"
    echo "  wait {Interworking Service URL} - Wait until all components are running"
esac
