#!/bin/bash

read -p "Enter Resource Group: " RG
read -p "Enter NSG Name: " NSG

# Location is fixed
LOCATION="japaneast"

# Rule priorities
ZSCALER_PRIORITY=500
AZURE_PUBLIC_PRIORITY=600
VNET_CIDR_PRIORITY=700

# --- ZSCALER ---
ZSCALER_FILE="zscaler_ips.txt"
if [ ! -f "$ZSCALER_FILE" ]; then
  echo "Zscaler IP file ($ZSCALER_FILE) not found!"
  exit 1
fi

ZSCALER_IPS=$(tr '\n' ' ' < "$ZSCALER_FILE")
echo "Adding Zscaler IP rule..."
az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG" \
  --name "Allow-Zscaler" \
  --priority $ZSCALER_PRIORITY \
  --direction Inbound \
  --access Allow \
  --protocol "*" \
  --source-address-prefixes $ZSCALER_IPS \
  --destination-port-ranges "*" \
  --description "Allow Zscaler IPs on any port/protocol" \
  --output none
echo "Zscaler rule added."

# --- AZURE PUBLIC IPs ---
AZURE_PUBLIC_FILE="azure_public_ips.txt"
if [ ! -f "$AZURE_PUBLIC_FILE" ]; then
  echo "Azure Public IP file ($AZURE_PUBLIC_FILE) not found!"
  exit 1
fi

AZURE_PUBLIC_IPS=$(tr '\n' ' ' < "$AZURE_PUBLIC_FILE")
echo "Adding Azure Public IP rule..."
az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG" \
  --name "Allow-AzurePublic" \
  --priority $AZURE_PUBLIC_PRIORITY \
  --direction Inbound \
  --access Allow \
  --protocol "*" \
  --source-address-prefixes $AZURE_PUBLIC_IPS \
  --destination-port-ranges "*" \
  --description "Allow Azure Public IPs" \
  --output none
echo "Azure Public IP rule added."

# --- REMOTE VNET CIDRs (Cross-subscription) ---
REMOTE_VNET_FILE="remote_vnet_cidrs.txt"

if [ ! -f "$REMOTE_VNET_FILE" ]; then
  echo "Remote VNet CIDR file ($REMOTE_VNET_FILE) not found. Skipping cross-sub VNet rule."
else
  REMOTE_VNET_CIDRS=$(tr '\n' ' ' < "$REMOTE_VNET_FILE")

  echo "Adding Cross-subscription VNet rule..."
  az network nsg rule create \
    --resource-group "$RG" \
    --nsg-name "$NSG" \
    --name "Allow-Remote-VNet" \
    --priority 750 \
    --direction Inbound \
    --access Allow \
    --protocol "*" \
    --source-address-prefixes $REMOTE_VNET_CIDRS \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges "*" \
    --description "Allow traffic from external VNets (no peering)" \
    --output none
  echo "Remote VNet rule added."
fi
