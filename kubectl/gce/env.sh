INSTANCE_PREFIX="sch"
PROJECT="coastal-sunspot-206412" 
#ZONE="europe-west1-b"
NODE_FIRST_ID=1
NODE_LAST_ID=8

ZONE="europe-north1-a"
NODE_FIRST_ID=9
NODE_LAST_ID=16

#ZONE="europe-westr2-a"
NODE_FIRST_ID=17
NODE_LAST_ID=24


MACHINE_TYPE="n1-standard-2"


# Used for ssh access
NODES=$(seq --format "${INSTANCE_PREFIX}-%g" \
        --separator=" " "$NODE_FIRST_ID" "$NODE_LAST_ID")
