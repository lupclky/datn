# Configuration Variables - CHANGE THESE
$ErrorActionPreference = "Stop"
$RandomSuffix = Get-Random
$RESOURCE_GROUP = "rg-lockerkorea"
$LOCATION = "southeastasia" # or eastus, westeurope, etc.
$FRONTEND_APP_NAME = "lockerkorea-frontend-$RandomSuffix"
$BACKEND_APP_NAME = "lockerkorea-backend-$RandomSuffix"
$MYSQL_SERVER_NAME = "lockerkorea-db-$RandomSuffix"
$STORAGE_ACCOUNT_NAME = "lockerkoreastore$RandomSuffix" # Must be lowercase and unique
$MYSQL_ADMIN_USER = "adminuser"
$MYSQL_ADMIN_PASSWORD = "tql28102003superhero" # Change this!

# Wait for deletion if it's still happening
Write-Host "Checking if Resource Group $RESOURCE_GROUP exists..."
if (az group exists --name $RESOURCE_GROUP | ConvertFrom-Json) {
    Write-Host "Resource Group $RESOURCE_GROUP still exists. Waiting for deletion to complete..."
    while (az group exists --name $RESOURCE_GROUP | ConvertFrom-Json) {
        Start-Sleep -Seconds 10
        Write-Host -NoNewline "."
    }
    Write-Host "`nResource Group deleted."
}

Write-Host "Creating Resource Group: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

Write-Host "Creating App Service Plan (Linux - B1 for Students)..."
# B1 is recommended for Spring Boot. F1 (Free) often runs out of memory for Java apps.
az appservice plan create --name "plan-lockerkorea" --resource-group $RESOURCE_GROUP --sku B1 --is-linux

Write-Host "Creating Frontend Web App (Node.js)..."
az webapp create --name $FRONTEND_APP_NAME --resource-group $RESOURCE_GROUP --plan "plan-lockerkorea" --runtime 'NODE|18-lts'
if ($LASTEXITCODE -ne 0) { Write-Error "Frontend creation failed"; exit 1 }

Write-Host "Creating Backend Web App (Java)..."
az webapp create --name $BACKEND_APP_NAME --resource-group $RESOURCE_GROUP --plan "plan-lockerkorea" --runtime 'JAVA|17-java17'
if ($LASTEXITCODE -ne 0) { Write-Error "Backend creation failed"; exit 1 }

Write-Host "Creating MySQL Flexible Server (B1ms - Free Tier Eligible)..."
az mysql flexible-server create --name $MYSQL_SERVER_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --admin-user $MYSQL_ADMIN_USER `
    --admin-password $MYSQL_ADMIN_PASSWORD `
    --sku-name Standard_B1ms `
    --tier Burstable `
    --version 8.0.21 `
    --storage-size 32 `
    --yes

Write-Host "Configuring MySQL Firewall (Allow Azure Services)..."
az mysql flexible-server firewall-rule create --resource-group $RESOURCE_GROUP --name $MYSQL_SERVER_NAME --rule-name AllowAzureIPs --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

Write-Host "Creating Azure Storage Account..."
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS

Write-Host "Creating Storage Container..."
az storage container create --name "lockerkorea-images" --account-name $STORAGE_ACCOUNT_NAME

Write-Host "Retrieving Storage Key..."
$STORAGE_KEY = az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv

Write-Host "========================================================"
Write-Host "SETUP COMPLETE!"
Write-Host "========================================================"
Write-Host "Resource Group: $RESOURCE_GROUP"
Write-Host "Frontend App Name: $FRONTEND_APP_NAME"
Write-Host "Backend App Name: $BACKEND_APP_NAME"
Write-Host "MySQL Server: $MYSQL_SERVER_NAME.mysql.database.azure.com"
Write-Host "MySQL User: $MYSQL_ADMIN_USER"
Write-Host "MySQL Password: $MYSQL_ADMIN_PASSWORD"
Write-Host "Storage Account: $STORAGE_ACCOUNT_NAME"
Write-Host "Storage Key: $STORAGE_KEY"
Write-Host "========================================================"
Write-Host "NEXT STEPS:"
$subscriptionId = az account show --query id -o tsv
Write-Host "1. Run this command to get your AZURE_CREDENTIALS for GitHub Secrets:"
Write-Host "   az ad sp create-for-rbac --name ""lockerkorea-cicd"" --role contributor --scopes /subscriptions/$subscriptionId/resourceGroups/$RESOURCE_GROUP --json-auth"
Write-Host "2. Add the output as a secret named 'AZURE_CREDENTIALS' in your GitHub Repo."
Write-Host "3. Add other secrets: AZURE_RESOURCE_GROUP, AZURE_WEBAPP_FRONTEND_NAME, AZURE_WEBAPP_BACKEND_NAME"
Write-Host "4. Configure Environment Variables in the Backend Web App using the info above."
