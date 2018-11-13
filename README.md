# OutSystems Azure ARM templates

This is a collection of quick start templates for deploying OutSystems on Microsoft Azure.

The goal is to enable our customers to deploy OutSystems on Microsoft Azure with extended customization options not available in the Azure Marketplace ofer.

**Features:**

- Support for OutSystems 10 and 11.
- Catalogs configuration. You can configure the session catalog (OutSystems 10 and 11) and the log catalog (OutSystems 11 only). For performance reasons its highly recommended to create separate session and log catalogs.
- Frontends in a Virtual Machine Scale Set for manual and auto-scale.
- Deploy OutSystems on your own Virtual Network.
- A 30 days trial license to test OutSystems on Azure. Make sure you upload your own license before starting to develop real apps.

**Notes:**

- Only Microsoft SQL Server and Azure SQL with database authentication is supported.
- You must chose the same major version for the Platform Server and Service Studio.
- On OutSystems 11, the RabbitMQ user and password is the virtual machine admin user and password.

## Existing Database Server

Use this group of templates to deploy OutSystems in an existing database server.

You should check if the virtual network has network connectivity to the database server before starting the deployment.

### 1. Single Environment

This template deploys a single OutSystems environment on a virtual machine.

Template settings:

![SingleEnv](https://raw.githubusercontent.com/OutSystems/AzureARMTemplates/dev/media/Controller.PNG)

[![SingleEnv](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FController.json)

**Notes:**

- You have an optional parameter for the OutSystems environment private key. Usefull if you want to connect the VM to an existing OutSystems environment database (environment clone).

### 2. Lifetime Environment

Same as the previous template but for a Lifetime environment.

[![Lifetime](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FLifetime.json)

### 3. Frontend Server

Deploys a single OutSystems frontend server for an existing environment.

[![Frontend](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FFrontend.json)

**Notes:**

- For this template, you will need an existing OutSystems environment and a virtual network with network connectivity to the environment and to the database.
- The template requires the same parameters as the single environment template plus the controller hostname/IP and the environment private key.

### 4. Frontend Server in a Virtual Machine Scale Set

Same as the previous template but this time, the frontend server will be deployed in a Virtual Machine Scale Set. This enables scaling/auto-scaling of the frontends.

[![FrontendVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FFrontendVMSS.json)

**Notes:**

- The virtual network for this deployment must contain at least two subnets. One for the VMs and another for the Azure Application Gateway. The subnet for the Application Gateway must not contain any other resources.
- The trial license included in the templates only allows two frontend servers including the deployment controller. To scale to two frontends using the Virtual Machine Scale Set you need to go to Service Center -> Frontends, and disable the frontend role of the deployment controller server.
- To scale to more than two frontends you need to install your own OutSystems license.
- IMPORTANT: When the Virtual Machine Scale Set is scalling up, it needs access to the "outsystemsSetup\OutSystemsSetupScript.ps1" file in this repository. So you should not block internet access to the VMSS.
- Since we are always adding new features to this templates and we don't guarantee backward compatibility the safest way is to:
  - Fork this repository.
  - Copy the script to a location that you control. Example: Azure Storage Account, your own github repository, etc etc ...
  - Edit the outsystemsFrontendVMSS.json template and specify the new file http location by editing the "fileUris" parameter "value".

## Azure SQL

Use this group of templates to deploy OutSystems on Azure SQL.

**Notes:**

- The Azure SQL Server admin username MUST BE different from the VM admin username.
- When installing OutSystems 10 leave the Database Log parameter empty.

### 5. Single Environment

This template deploys an OutSystems environment on a virtual machine on Azure SQL.

[![AzSQLController](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FAzSQLController.json)

### 6. Lifetime Environment

Same as the previous template but for the Lifetime environment.

[![AzSQLLifetime](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FAzSQLLifetime.json)

### 7. Single Environment + Frontend Server in a Virtual Machine Scale Set

Single environment with a frontend server deployed in a VMSS cluster. This enables scaling/auto-scaling of the frontends (ideal for production environments).

![AzSQLVMSS](https://raw.githubusercontent.com/OutSystems/AzureARMTemplates/dev/media/AzSQLVMSS1.PNG)
[![AzSQLFrontendVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FAzSQLFrontendVMSS.json)

**Notes:**

- The virtual network for this deployment must contain at least two subnets. One for the VMs and another for the Azure Application Gateway. The subnet for the Application Gateway must not contain any other resources.
- The trial license included in the templates only allows two frontend servers including the deployment controller. To scale to two frontends using the Virtual Machine Scale Set you need to go to Service Center -> Frontends, and disable the frontend role of the deployment controller server.
- To scale to more than two frontends you need to install your own OutSystems license.
- IMPORTANT: When the Virtual Machine Scale Set is scalling up, it needs access to the "outsystemsSetup\OutSystemsSetupScript.ps1" file in this repository. So you should not block internet access to the VMSS.
- Since we are always adding new features to this templates and we don't guarantee backward compatibility the safest way is to:
  - Fork this repository.
  - Copy the script to a location that you control. Example: Azure Storage Account, your own github repository, etc etc ...
  - Edit the outsystemsFrontendVMSS.json template and specify the new file http location by editing the "fileUris" parameter "value".

## Azure SQL + Containers

For environments with OutSystems 11 on Azure Container Service (ACS) with Kubernetes checkout [our github](https://github.com/OutSystems/Containers-ACS-AzDevOps) repo.

![ACS](https://raw.githubusercontent.com/OutSystems/AzureARMTemplates/dev/media/ACS.PNG)

## Full stack on Azure SQL

For a full stack with Dev, Test, Prod and Lifetime environments deployed on a new VNET with Azure SQL as the database engine, use our [Azure Marketplace template](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/outsystems.outsystems_platform?tab=Overview).

To deploy a full stack on an existing VNET you can also use this templates but you will need to deploy each environment one at the time.

Use template number five for the Dev, Test and Prod environments and the number six for Lifetime. If you want to have a Prod environment with scalling and HA capabilities, use the template number seven.
