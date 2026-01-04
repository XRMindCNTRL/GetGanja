@description('Location for all resources')
param location string = 'eastus'

@description('Name of the App Service plan')
param appServicePlanName string = 'cannabis-appservice-plan'

@description('Backend web app name')
param backendName string = 'cannabis-backend'

@description('Frontend web app name')
param frontendName string = 'cannabis-frontend'

@description('App Service SKU name')
param skuName string = 'P1v2'

@description('Create PostgreSQL Flexible server')
param createPostgres bool = true

@description('Postgres administrator username')
param postgresAdmin string = 'pgadmin'

@secure()
@description('Postgres administrator password (store in GitHub Secret and pass as parameter during deployment)')
param postgresPassword string

@description('Create Azure Cache for Redis')
param createRedis bool = true

@description('Redis SKU')
param redisSkuName string = 'Basic'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: 'PremiumV2'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource backend 'Microsoft.Web/sites@2022-03-01' = {
  name: backendName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}

resource frontend 'Microsoft.Web/sites@2022-03-01' = {
  name: frontendName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|20-lts'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${backendName}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${backendName}-kv'
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableSoftDelete: true
  }
}

var postgresName = '${backendName}-pg'

resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = if (createPostgres) {
  name: postgresName
  location: location
  sku: {
    name: 'Standard_D4s_v3'
    tier: 'GeneralPurpose'
    capacity: 2
  }
  properties: {
    administratorLogin: postgresAdmin
    administratorLoginPassword: postgresPassword
    version: '15'
    storage: {
      storageSizeGB: 32
    }
  }
}

resource redis 'Microsoft.Cache/Redis@2023-04-01' = if (createRedis) {
  name: '${backendName}-redis'
  location: location
  sku: {
    name: redisSkuName
    family: 'C'
    capacity: 0
  }
  properties: {}
}

output backendUrl string = 'https://${backend.properties.defaultHostName}'
output frontendUrl string = 'https://${frontend.properties.defaultHostName}'
