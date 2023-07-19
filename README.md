# OutSystems Azure ARM templates

This is a collection of quick start templates for deploying OutSystems on Microsoft Azure.

The goal is to enable our customers to deploy OutSystems on Microsoft Azure with extended customization options not available in the Azure Marketplace ofer.

**Features:**

- Support for OutSystems 11.
- Catalogs configuration. You can configure the session catalog and the log catalog. For performance reasons its highly recommended to create separate session and log catalogs.
- Frontends in a Virtual Machine Scale Set for manual and auto-scale.
- Deploy OutSystems on your own Virtual Network.
- A 30 days trial license to test OutSystems on Azure. Make sure you upload your own license before starting to develop real apps.

**Notes:**

- Only Microsoft SQL Server and Azure SQL with database authentication is supported.
- You must chose the same major version for the Platform Server and Service Studio.
- On OutSystems 11, the RabbitMQ user and password is the virtual machine admin user and password.

**Warnings:**

- **This templates are updated frequently and we don't ensure backward compatibility.**
- **If you find an error or want to request a new feature, please use the GitHub Issue reporting, not the official OutSystems Support channel. These templates are maintained by OutSystems staff but are not supported by OutSystems itself.**
- If you want to use them on production environments you should clone/fork this repo to your own GitHub account, change the "Deploy to Azure" button links to your repository and start the deployment from there.
- This warning is especially important when using scale-sets. The scale-set is dependent of the repository where it was created from for scale-up operations. The newly created instances NEED ACCESS to the GitHub repository to perform the OutSystems configuration!!! So, or avoid using scale-sets or clone/fork this repository to your own!!!

## Deploy OutSystems on top of existing Database Server

Use this group of templates to deploy OutSystems on top of an existing database server.

**Notes:**

- You should check if the virtual network has network connectivity to the database server before starting the deployment.
- Always validate if you already have your own Virtual Network to deploy on or if you need to use one of the auxiliary templates (bottom of this read.me)

### 1. Single Environment (You can choose if it's a Development/Production or LifeTime Environment)

This template deploys a single OutSystems environment on a virtual machine.

[![SingleEnv](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2Fenvironment.json)

**Notes:**

- **If you don't have your own Virtual Network, use this auxiliary template to deploy it before deploying this template**: [Virtual Network Ready for Single Environment](https://github.com/OutSystems/AzureARMTemplates/tree/master#virtual-network-for-single-environments)
- You have an optional parameter for the OutSystems environment private key. Usefull if you want to connect the VM to an existing OutSystems environment database (environment clone).

### 2. Frontend Server

Deploys a single OutSystems frontend server for an existing environment.

[![Frontend](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2Ffrontend.json)

**Notes:**

- For this template, you will need an existing OutSystems environment and a virtual network with network connectivity to the environment and to the database.
- The template requires the same parameters as the single environment template plus the controller hostname/IP and the environment private key.

### 3. Frontend Server in a Virtual Machine Scale Set

Same as the previous template but this time, the frontend server will be deployed in a Virtual Machine Scale Set. This enables scaling/auto-scaling of the frontends (ideal for production environments)..

[![FrontendVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2FfrontendVmss.json)

![AzSQLVMSS](https://raw.githubusercontent.com/OutSystems/AzureARMTemplates/master/media/AzSQLVMSS1.PNG)

**Notes:**

- **If you don't have your own Virtual Network, use this auxiliary template to deploy it before deploying this template**: [Virtual Network Ready for ScaleSet](https://github.com/OutSystems/AzureARMTemplates#virtual-network-for-virtual-machine-scale-sets)
- If you already have your own Virtual Network for this deployment, it must contain at least two subnets: One for the VMs and another for the Azure Application Gateway. The subnet for the Application Gateway must not contain any other resources.
- The trial license included in the templates only allows two frontend servers including the deployment controller. To scale to two frontends using the Virtual Machine Scale Set you need to go to Service Center -> Frontends, and disable the frontend role of the deployment controller server.
- To scale to more than two frontends you need to install your own OutSystems license.
- **Since we are always adding new features to this templates and we don't guarantee backward compatibility the safest way is to:**
  - **Fork this repository.**
  - Copy the script to a location that you control. Example: Azure Storage Account or your own github repository.
  - Edit the outsystemsFrontendVMSS.json template and specify the new file http location by editing the "fileUris" parameter "value".

## Deploy OutSystems with a set of new AzureSQL databases

Use this group of templates to deploy OutSystems on Azure SQL.

**Notes:**

- The Azure SQL Server admin username MUST BE different from the VM admin username.
- Always validate if you already have your own Virtual Network to deploy on or if you need to use one of the auxiliary templates (bottom of this read.me)

### 4. Full Environment (You can choose if it's a Development/Production or LifeTime Environment)

This template deploys an OutSystems Deployment Controller on a virtual machine and an AzureSQL server with OutSystems databases. Also deploys an Application Gateway for accessing the Environment. Use this template to deploy a complete, standalone environment.
Fill the form with your own naming convention, replacing the default values placed as examples.

[![AzSQLController](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2FenvironmentAzSQL.json)

**Notes:**

- **To Add this Environment to an existing Marketplace Deployment, first use the following template to add a new network the Resource Group of your OutSystems installation and take note of the names you give to the Virtual Network and Subnetworks.**: [Virtual Network Ready for Complete Environment](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2Fresources%2FvirtualNetworkVMSS.json)
Alternatively you can create a new subnet inside your existing VNet, create an Microsoft.Sql Endpoint on it and use it to deploy this template #6. If opting for this, use the existing gateway-subnet to deploy the new Application Gateway.

## Full stack on Azure SQL

For a full stack with Dev, Test, Prod and Lifetime environments deployed on a new VNET with Azure SQL as the database engine, use our [Azure Marketplace template](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/outsystems.outsystems_platform?tab=Overview).

To deploy a full stack on an existing VNET you can also use this templates but you will need to deploy each environment one at the time.

Use template number four to deploy each environment separately. If you want to have a Prod environment with scalling and HA capabilities, use the template number three after deploying the prod environment.

## Auxiliary Templates

This is a group of templates to help you creating the OutSystems infrastructure in Azure.

### Virtual Network for Single Environments

This will deploy a Virtual Network with a single subnet for OutSystems VMs.
Use this template to deploy a Virtual Network for all templates that DONT uses a Virtual Machine Scale Set.

[![VNETSingle](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2Fresources%2FvirtualNetworkSingle.json)

### Virtual Network for Environments with Application Gateways and/or Virtual Machine Scale Sets

This will deploy a Virtual Network with two subnet. One for VMs and another for Application Gateways.
Use this template to deploy a Virtual Network for all templates uses a Virtual Machine Scale Set.

[![VNETVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2Fresources%2FvirtualNetworkVMSS.json)

### Virtual Network for Full Stacks

This will deploy a Virtual Network for a full OutSystems stack with Dev, Test, Prd and Lifetime.
The virtual network will contain five subnets. One for Dev, another for Test, two for Prd (VM and Application Gateway) and another for Lifetime.

[![VNETVMSS](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOutSystems%2FAzureARMTemplates%2Fmaster%2Fresources%2FvirtualNetworkFullStack.json)

## Base Image Versioning

To have a different version of OutSystems deployed, fork this repo, refer to the table below and change the code accordingly in the corresponding template. Here's an example:

![BaseImageUpdate](https://raw.githubusercontent.com/OutSystems/AzureARMTemplates/master/media/image_update.png)


In the SKU field you can type _platformserver_ if you're deploying a VM that will run one of the development or production environments. Type _lifetime_ if your VM will run the Lifetime environment only.

The version to use and the software installed on each one are described in the following table:

| Image Version  | Platform Server | Lifetime |
|---|---|---|
| 1.5.0 | 11.0.211.0 | 11.0.304.0 |
| 1.6.0 | 11.0.424.0 | 11.0.308.0 |
| 1.8.0 | 11.0.607.0 | 11.0.322.0 |
| 2.0.0 | 11.7.3.7036 | not available |
| 2.1.0 | 11.8.1 | 11.5.3 |
| 2.2.0 | 11.8.2 | 11.6.0 |
| 2.3.0 | 11.9.0 | 11.6.1 |
| 2.5.0 | 11.9.1 | 11.7.1 |
| 2.6.0 | 11.10.0 | 11.7.5 |
| 2.7.0 | 11.10.2 | 11.8.2 |
| 2.13.0 | 11.17.0 | 11.14.1 |
| 2.14.0 | 11.17.0 | 11.14.2 |
| 2.15.0 | 11.20.0 | 11.17.0 |
| 2.16.0 | 11.21.0 | 11.17.1 |
| 2.17.0 | 11.22.0 | 11.17.2 |

You can also use the versioning here to update your scalesets. Please follow Microsoft's reference documentation on the subject here:

[Update the OS image for your scale set](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-upgrade-scale-set#update-the-os-image-for-your-scale-set)

Or here, directly from OutSystems Public documentation:
[Update the OutSystems Version in your scale set](https://success.outsystems.com/Documentation/11/Setting_Up_OutSystems/OutSystems_on_Microsoft_Azure/Additional_Configurations_for_OutSystems_on_Microsoft_Azure#Update_Azure_Scale_Sets_to_a_Newer_Platform_Version)
