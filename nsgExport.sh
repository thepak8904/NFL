#!/bin/bash

# Output file
output_file="all_nsg_rules.csv"

# Write CSV header
echo "subscriptionName,nsgName,resourceGroup,ruleName,priority,direction,access,protocol,sourcePortRange,destinationPortRange,sourceAddressPrefix,destinationAddressPrefix" > "$output_file"

# Get all subscriptions (enabled only)
subscriptions=$(az account list --query "[?state=='Enabled'].{id:id, name:name}" -o tsv)

# Loop over each subscription
while read -r sub_id sub_name; do
    echo "🔄 Switching to subscription: $sub_name ($sub_id)"
    az account set --subscription "$sub_id"

    # Get all NSGs in the current subscription
    nsg_list=$(az network nsg list --query "[].{name:name, rg:resourceGroup}" -o tsv)

    while read -r nsg_name nsg_rg; do
        az network nsg rule list \
            --nsg-name "$nsg_name" \
            --resource-group "$nsg_rg" \
            --query "[].{
                subscriptionName: \"$sub_name\",
                nsgName: '$nsg_name',
                resourceGroup: '$nsg_rg',
                ruleName: name,
                priority: priority,
                direction: direction,
                access: access,
                protocol: protocol,
                sourcePortRange: sourcePortRange,
                destinationPortRange: destinationPortRange,
                sourceAddressPrefix: sourceAddressPrefix,
                destinationAddressPrefix: destinationAddressPrefix
            }" -o json | \
        jq -r '.[] | [
            .subscriptionName, .nsgName, .resourceGroup, .ruleName, .priority, .direction, .access, .protocol,
            .sourcePortRange, .destinationPortRange, .sourceAddressPrefix, .destinationAddressPrefix
        ] | @csv' >> "$output_file"
    done <<< "$nsg_list"

done <<< "$subscriptions"

echo "✅ Export complete: $output_file"
