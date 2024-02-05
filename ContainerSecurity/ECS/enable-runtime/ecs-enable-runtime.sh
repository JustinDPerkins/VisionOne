while getopts ":apiKey:" opt; do
  case $opt in
    apiKey)
      apiKey="$OPTARG"
      ;;
    \?)
      echo "Usage: $0 -apiKey apiKey"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Check if the API key is provided
if [ -z "$apiKey" ]; then
  echo "Please provide the API key using the -apiKey parameter."
  exit 1
fi

headers="Authorization: Bearer $apiKey
Content-Type: application/json"

response=$(curl -s -H "$headers" 'https://api.xdr.trendmicro.com/beta/containerSecurity/amazonEcsClusters')
ids=$(echo "$response" | jq -r '.items[].id')

for id in $ids; do
  # Collect Current Cluster Settings to determine whether to Enable V1 CS Runtime Features
  check_current_setting=$(curl -s -H "$headers" "https://api.xdr.trendmicro.com/beta/containerSecurity/amazonEcsClusters/$id")

  # Check if runtimeSecurityEnabled and vulnerabilityScanEnabled are set to True
  if [ "$(echo "$check_current_setting" | jq -r '.runtimeSecurityEnabled')" == "true" ] && [ "$(echo "$check_current_setting" | jq -r '.vulnerabilityScanEnabled')" == "true" ]; then
    echo "Runtime Security and Vulnerability Scan are already enabled for Cluster ID: $id"
    # Perform additional actions if needed
  else
    echo "Enabling Runtime Security and/or Vulnerability Scan for Cluster ID: $id"
    # Perform additional actions for clusters with disabled settings
    body='{"vulnerabilityScanEnabled": true, "runtimeSecurityEnabled": true}'
    
    curl -s -H "$headers" -X PATCH --data "$body" "https://api.xdr.trendmicro.com/beta/containerSecurity/amazonEcsClusters/$id"
    echo "Enabled Successfully: $id"
  fi
done
