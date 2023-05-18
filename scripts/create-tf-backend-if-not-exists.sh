#! /usr/bin/env bash
# This script assumes azure cli is installed and logged into appropriate subscription.
# Usage: (Note- When running locally in MAC, you need to uncomment some of the lines mentioned below and comment some.)
#   ./scripts/create-tf-backend-if-not-exists.sh --resource-group XYZ --location ABC --storage-account-name XYZ --container-name ABC
# All fields are mandatory
# This script checks if given storage account and container exists. If not, then it creates the same.

LONG=resource-group:,location:,storage-account-name:,container-name:

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
    --storage-account-name )
      STORAGE_ACC_NAME="$2"
      shift 2
      ;;
    --container-name )
      CONTAINER_NAME="$2"
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
  echo "Resource Group must be specified"
  exit 1
fi
if [[ $LOCATION == '' ]]; then
  echo "Location of the storage account must be specified"
  exit 1
fi
if [[ $STORAGE_ACC_NAME == '' ]]; then
  echo "Name of the storage account must be specified"
  exit 1
fi
if [[ $CONTAINER_NAME == '' ]]; then
  echo "Name of the container holding the terraform state files must be specified"
  exit 1
fi


storageAccResp=$(az storage account show -g $RESOURCE_GROUP -n $STORAGE_ACC_NAME 2>&1)

if [[ $storageAccResp == *"was not found."* ]]; then
  echo "Storage account does not exist. Creating..."
  az storage account create --name $STORAGE_ACC_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --access-tier Hot --allow-blob-public-access false --kind StorageV2 --min-tls-version TLS1_2 --sku Standard_RAGRS
  echo "Creating container..."
  az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACC_NAME --auth-mode login
else
  echo "Storage account exists"
  storageContainerExists=$(az storage container exists --account-name $STORAGE_ACC_NAME --name $CONTAINER_NAME --auth-mode login | jq '.exists')
  if $storageContainerExists ; then
    echo "Container exists"
  else
    echo "Container does not exist. Creating..."
    az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACC_NAME --auth-mode login
  fi
fi


