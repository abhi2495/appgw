#! /usr/bin/env bash
# This script assumes azure cli is installed and logged into appropriate subscription.
# Usage: (Note- When running locally in MAC, you need to uncomment some of the lines mentioned below and comment some.)
#   ./scripts/create-rg-if-not-exists.sh --resource-group XYZ --location ABC
# All fields are mandatory
# This script checks if given storage account and container exists. If not, then it creates the same.

LONG=resource-group:,location:

# read the options
OPTS=$(getopt -o '' --long $LONG --name "$0" -- "$@")
#OPTS=$(getopt --long $LONG --name "$0" -- "$@") -> For running locally in MAC, uncomment this line, and comment the previous one
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
eval set -- "$OPTS"


#shift 5 -> This line is required when running the script in local Mac Machine as the $OPTS value is set differently


# extract options and their arguments into variables.
while true ; do
  case "$1" in
    --resource-group )
      RESOURCE_GROUP="$2"
      shift 2
      ;;
    --location )
      LOCATION="$2"
      shift 2
      ;;
    -- )
    #'' ) -> For running locally in MAC, uncomment this line, and comment the previous one
      shift
      break
      ;;
    *)
      echo "Internal error!"
      exit 1
      ;;
  esac
done

if [[ $RESOURCE_GROUP == '' ]]; then
  echo "Name of the resource group must be specified"
  exit 1
fi
if [[ $LOCATION == '' ]]; then
  echo "Location of the resource group must be specified"
  exit 1
fi

resourceGrpExists=$(az group exists -n $RESOURCE_GROUP 2>&1)
if [[ $resourceGrpExists == "false" ]]; then
  echo "Resource Group $RESOURCE_GROUP does not exist. Creating.."
  az group create -l $LOCATION -n $RESOURCE_GROUP
else
  echo "Resource Group $RESOURCE_GROUP exists"
fi

