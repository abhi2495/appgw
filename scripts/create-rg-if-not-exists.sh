#! /usr/bin/env bash
# This script assumes azure cli is installed and logged into appropriate subscription.
# Usage: (Note- When running locally in MAC, you need to uncomment some of the lines mentioned below and comment some.)
#   ./scripts/create-rg-if-not-exists.sh --resource-group XYZ --location eastus --cost-center-id 474000 --customer Internal --environment-type Dev --product-group \"Luminate Platform\"
# All fields are mandatory
# This script checks if given resource group exists. If not, then it creates the same.

LONG=resource-group:,location:,cost-center-id:,customer:,environment-type:,product-group:

# read the options
OPTS=$(getopt -o '' --long $LONG --name "$0" -- "$@")
# OPTS=$(getopt --long $LONG --name "$0" -- "$@") #-> For running locally in MAC, uncomment this line, and comment the previous one
if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi
eval set -- "$OPTS"


# shift 5 #-> This line is required when running the script in local Mac Machine as the $OPTS value is set differently


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
    --cost-center-id )
      COST_CENTER_ID="$2"
      shift 2
      ;;
    --customer )
      CUSTOMER="$2"
      shift 2
      ;;
    --environment-type )
      ENV_TYPE="$2"
      shift 2
      ;;
    --product-group )
      PRD_GRP="$2"
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
if [[ $COST_CENTER_ID == '' ]]; then
  echo "Const center id tag of the resource group must be specified"
  exit 1
fi
if [[ $CUSTOMER == '' ]]; then
  echo "Customer tag of the resource group must be specified"
  exit 1
fi
if [[ $ENV_TYPE == '' ]]; then
  echo "Environment type tag of the resource group must be specified"
  exit 1
fi
if [[ $PRD_GRP == '' ]]; then
  echo "Product group tag of the resource group must be specified"
  exit 1
fi

resourceGrpExists=$(az group exists -n $RESOURCE_GROUP 2>&1)
if [[ $resourceGrpExists == "false" ]]; then
  echo "Resource Group $RESOURCE_GROUP does not exist. Creating.."
  az group create -l $LOCATION -n $RESOURCE_GROUP --tags "Cost_Center_ID=$COST_CENTER_ID" "Customer=$CUSTOMER" "Environment_Type=$ENV_TYPE" "Product_Group=$PRD_GRP"
else
  echo "Resource Group $RESOURCE_GROUP exists"
fi

