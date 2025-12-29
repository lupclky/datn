#!/bin/bash

# Configuration Variables - CHANGE THESE
RESOURCE_GROUP="rg-lockerkorea"
LOCATION="southeastasia" # or eastus, westeurope, etc.
FRONTEND_APP_NAME="lockerkorea-frontend-$RANDOM"
BACKEND_APP_NAME="lockerkorea-backend-$RANDOM"
MYSQL_SERVER_NAME="lockerkorea-db-$RANDOM"
STORAGE_ACCOUNT_NAME="lockerkoreastore$RANDOM" # Must be lowercase and unique
MYSQL_ADMIN_USER="adminuser"
MYSQL_ADMIN_PASSWORD="tql28102003superhero" # Change this!

echo "Creating Resource Group: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Creating App Service Plan (Linux)..."
az appservice plan create --name "plan-lockerkorea" --resource-group $RESOURCE_GROUP --sku B1 --is-linux

echo "Creating Frontend Web App (Node.js)..."
az webapp create --name $FRONTEND_APP_NAME --resource-group $RESOURCE_GROUP --plan "plan-lockerkorea" --runtime "NODE:18-lts"

echo "Creating Backend Web App (Java)..."
az webapp create --name $BACKEND_APP_NAME --resource-group $RESOURCE_GROUP --plan "plan-lockerkorea" --runtime "JAVA:17-java17"

echo "Creating MySQL Flexible Server..."
az mysql flexible-server create --name $MYSQL_SERVER_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --admin-user $MYSQL_ADMIN_USER \
    --admin-password $MYSQL_ADMIN_PASSWORD \
    --sku-name Standard_B1ms \
    --tier Burstable \
    --version 8.0.21 \
    --storage-size 32 \
    --yes

echo "Configuring MySQL Firewall (Allow Azure Services)..."
az mysql flexible-server firewall-rule create --resource-group $RESOURCE_GROUP --name $MYSQL_SERVER_NAME --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

echo "Creating Azure Storage Account..."
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS

echo "Creating Storage Container..."
az storage container create --name "lockerkorea-images" --account-name $STORAGE_ACCOUNT_NAME

echo "Retrieving Storage Key..."
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)

echo "========================================================"
echo "SETUP COMPLETE!"
echo "========================================================"
echo "Resource Group: $RESOURCE_GROUP"
echo "Frontend App Name: $FRONTEND_APP_NAME"
echo "Backend App Name: $BACKEND_APP_NAME"
echo "MySQL Server: $MYSQL_SERVER_NAME.mysql.database.azure.com"
echo "MySQL User: $MYSQL_ADMIN_USER"
echo "MySQL Password: $MYSQL_ADMIN_PASSWORD"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Storage Key: $STORAGE_KEY"
echo "========================================================"
echo "NEXT STEPS:"
echo "1. Run this command to get your AZURE_CREDENTIALS for GitHub Secrets:"
echo "   az ad sp create-for-rbac --name \"lockerkorea-cicd\" --role contributor --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP --json-auth"
echo "2. Add the output as a secret named 'AZURE_CREDENTIALS' in your GitHub Repo."
echo "3. Add other secrets: AZURE_RESOURCE_GROUP, AZURE_WEBAPP_FRONTEND_NAME, AZURE_WEBAPP_BACKEND_NAME"
echo "4. Configure Environment Variables in the Backend Web App using the info above."
