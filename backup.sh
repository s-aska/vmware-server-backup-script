#!/bin/sh

# Example.
# /root/backup.sh --host dns1.7kai.org --vmname dns1 --vmxname "Red Hat Enterprise Linux 4.vmx"
# 
# HOST="dns1.7kai.org"
# VMNAME="dns1"
# VMXNAME="Red Hat Enterprise Linux 4.vmx"
VMBASEDIR="/var/lib/vmware/Virtual Machines"
BACKUPDIR="/backup/var/lib/vmware/Virtual Machines"

while [ -- != "$1" ] && [ "" != "$1" ]; do
    case $1 in
    --help)
        echo "usage: backup.sh --host dns1 --vmname dns1 --vmxname rhel4.vmx"
        exit 0
        ;;
    --host)
        HOST=$2; shift
        ;;
    --vmname)
        VMNAME=$2; shift
        ;;
    --vmxname)
        VMXNAME=$2; shift
        ;;
    esac
    shift 
done

VMDIR="$VMBASEDIR/$VMNAME"
VMXPATH="$VMDIR/$VMXNAME"

echo "host      : $HOST"
echo "vmname    : $VMNAME"
echo "vmxname   : $VMXNAME"
echo "vmdir     : $VMDIR"
echo "backupdir : $BACKUPDIR"
echo "vmxpath   : $VMXPATH"

echo -n "shutdown "

ssh root@$HOST shutdown -h now

for i in `seq 1 100`;do
sleep 5
STATE=`vmware-cmd "$VMXPATH" getstate`
if [ "$STATE" == "getstate() = on" ];then
echo -n "."
elif [ "$STATE" == "getstate() = off" ];then
echo " ok"
break
else    
echo -n "?"
fi
done

rsync -avz --delete "$VMDIR" "$BACKUPDIR"

vmware-cmd "$VMXPATH" start

echo "startup."

exit 0