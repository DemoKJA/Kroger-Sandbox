terraform {
	  required_version = "~> 0.13.0"
	
	  required_providers {
	    azurerm = {
	      source  = "hashicorp/azurerm"
	      version = "~> 2.33.0"
	    }
	  }
	}
	
	provider azurerm {
	  features {}
	  skip_provider_registration = true
	}
