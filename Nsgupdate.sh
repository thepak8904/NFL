#!/bin/bash

read -p "Enter Resource Group: " RG
read -p "Enter NSG Name: " NSG

# File paths
ZSCALER_FILE="zscaler_ips.txt"
AZURE_PUBLIC_FILE="azure_public_ips.txt"
REMOTE_VNET_FILE="remote_vnet_cidrs.txt"

# Function to get next available priority
get_next_priority() {
  local BASE=$1
  local USED_PRIORITIES=($(az network nsg rule list \
    --resource-group "$RG" \
    --nsg-name "$NSG" \
    --query "[].priority" \
    --output tsv))

  while [[ " ${USED_PRIORITIES[@]} " =~ " $BASE " ]]; do
    BASE=$((BASE + 10))
  done
  echo $BASE
}

echo "Targeting NSG: $NSG in Resource Group: $RG"

# ========== ZSCALER ==========
if [ -f "$ZSCALER_FILE" ]; then
  ZSCALER_IPS=$(tr '\n' ' ' < "$ZSCALER_FILE")
  PRIORITY=$(get_next_priority 500)
  echo "→ Adding Zscaler rule at priority $PRIORITY..."
  az network nsg rule create \
    --resource-group "$RG" \
    --nsg-name "$NSG" \
    --name "Allow-Zscaler" \
    --priority $PRIORITY \
    --direction Inbound \
    --access Allow \
    --protocol "*" \
    --source-address-prefixes $ZSCALER_IPS \
    --destination-port-ranges "*" \
    --description "Allow Zscaler IPs" \
    --output none
fi

# ========== AZURE PUBLIC ==========
if [ -f "$AZURE_PUBLIC_FILE" ]; then
  AZURE_IPS=$(tr '\n' ' ' < "$AZURE_PUBLIC_FILE")
  PRIORITY=$(get_next_priority 600)
  echo "→ Adding Azure Public IP rule at priority $PRIORITY..."
  az network nsg rule create \
    --resource-group "$RG" \
    --nsg-name "$NSG" \
    --name "Allow-AzurePublic" \
    --priority $PRIORITY \
    --direction Inbound \
    --access Allow \
    --protocol "*" \
    --source-address-prefixes $AZURE_IPS \
    --destination-port-ranges "*" \
    --description "Allow Azure public IPs" \
    --output none
fi

# ========== REMOTE VNET CIDRs ==========
if [ -f "$REMOTE_VNET_FILE" ]; then
  REMOTE_VNET_CIDRS=$(tr '\n' ' ' < "$REMOTE_VNET_FILE")
  PRIORITY=$(get_next_priority 700)
  echo "→ Adding Remote VNet rule at priority $PRIORITY..."
  az network nsg rule create \
    --resource-group "$RG" \
    --nsg-name "$NSG" \
    --name "Allow-Remote-VNet" \
    --priority $PRIORITY \
    --direction Inbound \
    --access Allow \
    --protocol "*" \
    --source-address-prefixes $REMOTE_VNET_CIDRS \
    --destination-address-prefixes VirtualNetwork \
    --destination-port-ranges "*" \
    --description "Allow traffic from remote VNets" \
    --output none
fi

echo "✅ All applicable rules added to NSG: $NSG"
