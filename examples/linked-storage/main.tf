module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["law", "storage"]
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

module "storage1" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = "stdemodev1"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "storage2" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = "stdemodev2"
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

    linked_storage = {
      customlogs = {
        data_source_type    = "CustomLogs"
        storage_account_ids = [module.storage1.account.id]
      },
      alerts = {
        data_source_type    = "Alerts"
        storage_account_ids = [module.storage2.account.id]
      }
    }
  }
}
