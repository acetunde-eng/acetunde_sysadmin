#!/bin/bash

usage () {
        echo "*****GET IP MAC COMMAND*****"
        echo "------------------------------------------------------"

        echo "Usage: $0 <hostname | -f hostfile>"

        echo
        echo "Where hostname is the hostname to generate the command."
        echo "Where hostfile is the file of hostnames, one per line."
}


hostfile=
hostname=

for flag in "$@" ; do
    case $flag in
        -*)
            true
            case $flag in
                -h | --help )
                    usage
                    exit
                    ;;
                -f | --file )
                    shift
                    hostfile=$1
                    ;;
                -C )
                    ;;
                *)
                    echo "ERROR: Unspected option $1"
                    echo
                    usage
                    exit 1
                    ;;
                esac
            ;;
            esac
done

if [ ! $hostfile ]; then
    hostname=${1%%.*}
    ssh cmsdhcpmaster "echo -e \"Main Interface:\"; awk '/$hostname/ {print \$2, \$6, \$8;}' /var/dhcp/cms.misc.dhcp | tr -d ';';awk '/$hostname/ {print \$2, \$6, \$8;}' /var/dhcp/cms.cc8.dhcp | tr -d ';'; echo -e \"\nIPMI Interface:\"; awk '/$hostname/ {print \$2, \$6, \$8;}' /var/dhcp/cms.misc-ipmi.dhcp | tr -d ';';" </dev/null;
elif [ $hostfile ]; then
    if [ ! -f $hostfile ]; then
        echo "ERROR: not a file $hostfile"
        echo
        usage
        exit 1
    else
        echo -e "Main Interfaces:"
        while read -r hn1; do ssh cmsdhcpmaster "awk '/${hn1%%.*}/ {print \$2, \$6, \$8;}' /var/dhcp/cms.misc.dhcp | tr -d ';'; awk '/${hn1%%.*}/ {print \$2, \$6, \$8;}' /var/dhcp/cms.cc8.dhcp | tr -d ';';" </dev/null; done < $hostfile
        echo -e "\nIPMI Interfaces:"
        while read -r hn1; do ssh cmsdhcpmaster "awk '/${hn1%%.*}/ {print \$2, \$6, \$8;}' /var/dhcp/cms.misc-ipmi.dhcp | tr -d ';'" </dev/null; done < $hostfile
    fi
fi

