INSTANCE_PREFIX="sch"
PROJECT="coastal-sunspot-206412" 
ZONE="europe-north1-a"
#ZONE="europe-west1-b"

MACHINE_TYPE="n1-standard-2"

NODE_FIRST_ID=1
NODE_LAST_ID=8

# Used for ssh access
NODES=$(seq --format "${INSTANCE_PREFIX}-%g" \
        --separator=" " "$NODE_FIRST_ID" "$NODE_LAST_ID")
