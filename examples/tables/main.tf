module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["law", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "analytics" {
  source  = "codectl/law/azure"
  version = "~> 1.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    tables = {
      InsightsMetrics = {
        plan                    = "Analytics"
        retention_in_days       = 40
        total_retention_in_days = 50
      }
      Alert = {
        plan                    = "Analytics"
        retention_in_days       = 30
        total_retention_in_days = 60
      }
      ContainerLogV2 = {
        plan = "Basic"
      }
    }
  }
}
