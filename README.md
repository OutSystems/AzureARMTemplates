# Outsystems Azure ARM templates
This is collection of quick start templates to deploy the Outsystems platform to Microsoft Azure.

## Existing VNET and Database Server

For this set of templates you need a VNET already deployed and a database server reachable from the VMs.

### 1. Controller ( Standalone Environment )

This template deploys and configures a VM as an Outsystems controller/frontend. The template will ask you for a database server to connect ( needs to be reachable to the VM ) and for a virtual network where the VM will be placed.

You have an optional parameter for the environment private key. Usefull if you want to join the VM to an existing Outsystems database.

Example:

<img src="https://raw.githubusercontent.com/pintonunes/Outsystems-AzureARMTemplates/master/Docs/Controller.PNG"/>

Time to deploy: 20-30 minutes

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FController.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### 2. Lifetime Environment

This is the same as the previous template but installs Lifetime. The private key option is not available in this template.

Time to deploy: 30-40 minutes

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FLifetime.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### 3. Frontend server ( Single )

This template deploys and configures a VM as an Outsystems frontend server. A working environment is needed to connect this frontend. You will need to specify the same parameters as for the controller template plus the controller host.

Time to deploy: 10 minutes

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FFrontend.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### 4. Frontend server ( Virtual Machine Scale Set cluster )

Same as the previous one but the frontends will be deployed in a Virtual Machine Scale Set behind an Application Gateway. The trial license included in this templates only allow two frontend servers. To scale to two you need to remove the controller as a frontend server in Service Center.

Time to deploy: 30-40 minutes

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FFrontendVMSS.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## On Azure SQL in existing VNET

This set of templates are exactly like the ones in the previous section but an Azure SQL Server is deployed for the Controller and Lifetime templates. The Azure SQL Server admin username and password will be asked and cannot be the equal to the VM admin username or the deployment will fail.

### 5. Controller ( Standalone Environment )

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FAzSQLController.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### 6. Lifetime Environment

This is the same as the previous template but installs Lifetime. The private key option is not available in this template.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FAzSQLLifetime.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### 7. Production Environment with Controller and a Frontend in a VMSS cluster

Same as the number 5 plus a frontend in a VMSS cluster load balanced by an Application Gateway. The trial license included in all this templates only allows two frontend servers. To scale to two frontends you need to remove the controller as a frontend server in Service Center.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FAzSQLProdVMSS.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

## Full stack on Azure SQL

Full stack environments with Dev, Test, Prod and Lifetime deployed on a new VNET with Azure SQL as the database engine.

### 8. Full stack with AzureSQL, single frontend on the Prod environment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FAzSQLFullStack.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### 9. Full stack with AzureSQL, Frontends of the Prod environment in a VMSS cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FAzSQLFullStackVMSS.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>