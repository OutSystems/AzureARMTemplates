# Outsystems Azure ARM templates

### Single environment without database. 
This template deploys a single outsystems environment without database. You need to specify the database server and the VNET where you want the deploy the VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FEnvSingleNoSQL.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### Lifetime environment without database. 
This template deploys the outsytems lifetime environment without database. You need to specify the database server and the VNET where you want the deploy the VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FEnvLifetimeNoSQL.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### Frontend server (single)
This template deploys an outsytems single frontend. A working environment is needed to connect this frontend.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FFrontendOnly.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

### Frontend server (VMSS)
This template deploys an outsytems frontend in a Virtual Machine Scale Set (VMSS). A working environment is needed to connect this frontends.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpintonunes%2FOutsystems-AzureARMTemplates%2Fmaster%2FFrontendVMSS.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>