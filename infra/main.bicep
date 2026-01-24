// main.bicep
// Updated and optimized Bicep file for Azure infrastructure deployment
resource appServicePlan 'Microsoft.Web/serverfarms@2022-07-01' = {
  name: 'myAppServicePlan'
  location: resourceGroup().location
  sku: {
    name: 'S1' // Changed from Basic (B1) to Standard (S1)
    tier: 'Standard'
    capacity: 1
  }
}

resource postgresServer 'Microsoft.DBforPostgreSQL/servers@2022-11-01' = {
  name: 'myPostgresServer'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'GP_Gen5_2' // Changed from Burstable to GeneralPurpose
      tier: 'GeneralPurpose'
      capacity: 2
    }
    storageProfile: {
      storageMb: 128000 // Increased from 32 GB to 128 GB
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-08-01' = {
  name: 'myKeyVault'
  location: resourceGroup().location
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: 'user-object-id'  // Update with actual object ID
        permissions: {
          keys: ['get','list']
          secrets: ['get','list','set']
          certificates: ['get','list']
        }
      }
    ]
  }
}

resource webApp 'Microsoft.Web/sites@2022-07-01' = {
  name: 'myWebApp'
  location: resourceGroup().location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings:
      [
        {'name':'APPLICATION_INSIGHTS_CONNECTION_STRING', 'value': 'YOUR_CONNECTION_STRING'}
        {'name':'WEBSITE_NODE_DEFAULT_VERSION', 'value': '14.x'}
        // Enable logging
        {'name':'APPINSIGHTS_INSTRUMENTATION_KEY', 'value': 'YOUR_APPINSIGHTS_KEY'}
        // Add custom domains
        {'name':'CUSTOM_DOMAIN', 'value': 'example.com'}
      ]
      linuxFxVersion: 'NODE|14-lts'
    }
  }
}

// Ensure PostgreSQL server version is aligned with other app-related files
// Setting version to PostgreSQL 15 for consistency
resource sqlDatabase 'Microsoft.DBforPostgreSQL/servers/databases@2022-11-01' = {
  name: 'myDatabase'
  parent: postgresServer
  properties: {
    charset: 'UTF8'
    collation: 'English_United States.1252'
    // Consistent SQL database version
    // Updating to PostgreSQL 15
    version: '15'
  }
}