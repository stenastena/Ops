#!/bin/bash 
### For debugging #!/bin/bash -x

# Register the Azure Policy Insights resource provider. Registering the resource provider makes sure that your subscription works with it.
az provider register --namespace 'Microsoft.PolicyInsights'

# Variables for policy definition and assinment
policy_name_definition="Deny-SKU-VMs"
policy_display_name='Deny SKU of VMs'
policy_description='A policy assure that some SKUs of VMs are denied.'
policy_rules="./azurepolicy.rules.json"
policy_param="./azurepolicy.parameters.json"
policy_asignmnet_name="Deny-SKU-VMs-to-Resource-Group"

policypar='{ "listOfNotAllowedSKUs": { "value": [ "Standard_B1s",	"Standard_B1ms", "Standard_B2ms" ] } }' 

## define a scope
## A name of resource group
rgname="rgMSP-Vms-Windows"
## jq - It is a command line lightweight and flexible command-line JSON processor  
## Extract a scope and a location from the Resource Grope object from JSON format  
scope=$(az group show --name $rgname | jq .id -r)

# Create a policy definition
policy_definition=$(az policy definition create --name $policy_name_definition --display-name "$policy_display_name" --description "$policy_description" --rules $policy_rules --params $policy_param --mode All)
#policy_definition_id=$(echo $policy_definition | jq .id -r )

# Create a policy assignment for particular resource group and parametrs
az policy assignment create --name $policy_asignmnet_name --scope $scope --policy $policy_name_definition --params "$policypar"
