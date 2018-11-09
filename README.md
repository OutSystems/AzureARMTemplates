# OutSystems Azure ARM templates

This is a collection of quick start templates for deploying OutSystems on Microsoft Azure.

The goal is to enable our customers to deploy OutSystems on Microsoft Azure with extended customization options not available in the Azure Marketplace ofer.

**Features:**

- Supports both OutSystems 10 and 11. You can select witch version to install.

- Optional databases. You can chose if you want to create a session database (OutSystems 10 and 11) and/or a log database (OutSystems 11).

- Frontends auto-scalling when using a Virtual Machine Scale Set.

**Notes:**

- All templates assume that you already have a VNET created. Before using this templates, create a Virtual Network first.

- Only Microsoft SQL Server and Azure SQL with database authentication is available.

- For performance reasons its highly recommended that you create a separate session database and a log database (OutSystems 11 only).

- All templates will install OutSystems with a 30 days trial license. Please make sure you upload your own license before starting the real development of your apps.

## Existing Database Server

Use this group of templates if you want to deploy OutSystems on an existing virtual network (VNET) and existing database server.

Please make sure that the virtual network has network connectivity to the database server before starting the deployment.

### 1. Single Environment

This template deploys an OutSystems environment on a single virtual machine.

Template settings:

![SingleEnv](https://raw.githubusercontent.com/OutSystems/AzureARMTemplates/dev/media/Controller.PNG)

[![SingleEnv](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FController.json)

**Notes:**

- You have an optional parameter for the OutSystems environment private key. This can be usefull if you want to connect the VM to an existing OutSystems environment database (environment clone).

### 2. Lifetime Environment

Same as the previous template but this time for the Lifetime environment.

[![Lifetime](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FLifetime.json)

### 3. Frontend Server

Deploys a single OutSystems frontend server for an existing environment.

[![Frontend](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FFrontend.json)

**Notes:**

- To use this template, you will need a working OutSystems environment already deployed and a virtual network with network connectivity to the existing environment and to the database.
- The template requires the same parameters as the single environment template plus the controller hostname/IP and the environment private key.

### 4. Frontend Server in a Virtual Machine Scale Set

Same as the previous template but this time, the frontend server will be deployed in a Virtual Machine Scale Set. This enables scaling/auto-scaling of the frontends.

[![FrontendVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FFrontendVMSS.json)

**Notes:**

- The trial license included in all templates only allow two frontend servers.
- To be able to scale to two frontends using the trial license, you need to go to Service Center -> Frontends, and disable the frontend role in the deployment controller server.
- To scale to more than two frontends, you need to install your own OutSystems license.

## On Azure SQL

Use this group of templates if you want to deploy OutSystems on an existing virtual network (VNET) and use Azure SQL as the database server.

**Notes:**

- The Azure SQL Server admin username MUST BE different from the VM admin username or the deployment will fail.

- When installing OutSystems 10 leave the Database Log parameter empty.

### 5. Single Environment

This template deploys an OutSystems environment on a single virtual machine and two Azure SQL databases for the platform database and session database.

[![AzSQLController](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FAzSQLController.json)

### 6. Lifetime Environment

Same as the previous template but this time for the Lifetime environment.

[![AzSQLLifetime](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FAzSQLLifetime.json)

### 7. Single Environment + Frontend Server in a Virtual Machine Scale Set

Same as template number five plus a frontend server deployed in a VMSS cluster. This enables scaling/auto-scaling of the frontends (ideal for production environments).

[![AzSQLFrontendVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fdev%2FAzSQLFrontendVMSS.json)

**Notes:**

- The trial license included in all templates only allow two frontend servers.
- To be able to scale to two frontends using the trial license, you need to go to Service Center -> Frontends, and disable the frontend role in the deployment controller server.
- To scale to more than two frontends, you need to install your own OutSystems license.

## Full stack on Azure SQL

For a full stack with Dev, Test, Prod and Lifetime environments deployed on a new VNET with Azure SQL as the database engine, use our [Azure Marketplace template](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/outsystems.outsystems_platform?tab=Overview).

To deploy a full stack on an existing VNET you can also use this templates but you will need to deploy each environment one at the time.

Use template number five for the Dev, Test and Prod environments and the number six for Lifetime. If you want to have a Prod environment with scalling and HA capabilities, use the template number seven.
