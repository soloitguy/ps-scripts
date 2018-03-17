#Release Scripts
Store for all build and release scripts and dependencies.



##AddWebApptoOMS.ps1
**Use Case**

Utitlized to add all Azure WebApps in a Resource Group to a OMS LA Workspace.


**Required Parameters**
	
- `omsResourceGroup` - Azure Resource Group of OMS Log Analytics Workspace
- `omsWorkSpace` - OMS Log Analytics Workspace Name
- `appResourceGroup` - Azure Resource Group of the WebApp

--	

##ApimAssociateProducts.ps1
**Use Case**

Utilized to associate a list of products with the API being deployed.

**Required Parameters**
	
- `ApiServiceName` - The name of the API Management Instance
- `ApiID` - Name/ID of the API for creating and updating
- `Products` - Array of Product names that need to be associated with the API

--
	
##ApimDeploySwagger.ps1
**Use Case**

Deploy a swagger file from a remote URL, then commit this to the API Management
 git repository that is centrally located in the API Management service. When running in VSTS, a subscription should be assigned which will provide Azure context for locating the API Management service.
	
**Required Parameters**

- `ApiServiceName` - The name of the API Management Instance
- `ApiName` - Name of the API Deployed
- `SwaggerURL` - Location of the swagger.json

--
 	
##ApimSetProperties.ps1

**Use Case**

Set a property in API Management by either creating a new property or overwriting one that currently exists

**Required Parameters**

- `ApiServiceName` - Name of the API Management Instance
- `Properties` - A hash array of properties that will be set in APIM as key/value pairs

--
	
##ApimUpdateRepo.ps1

**Use Case**

Updates the APIM Repository

**Required Parameters**

- `ApiServiceName` -  Name of the API Management instance

--

##ArmSetVariables.ps1

**Use Case**

Loop through all outputs from ARM templates and set as VSO variables.

**Required Parameters** 

- `ResourceGroupName` - Name of the resource group being deployed
- `ParameterNamespace` - Namespace to be set in VSO variables. "Azure" is default.

--

##ContainerPermissions.ps1

**Use Case**

Sets the permission level of an Azure Blob container to "Blob", allowing public access.

**Required Parameters**

- `StorageAccountName` - Name of Azure storage account the container resides in
-  `ResourceGroupName` - Name of the Azure resource group the container resides in
-  `ContainerName` -  Name of the container that will change permissions

--

##DocDbCreateCollection.ps1

**Use Case**

Deploys a database and collection from a parameter file

**Required Parameters**

- `accountEndpoint` - The full endpoint without the port
- `connectionKey` - The master connection key for authorization
- `paramFile`	- Param file that includes database information, collection information and throughput for collection. 

--	

##DocDbHelpers.ps1

**Use Case**

DocumentDB functions using REST API. *Consumed by DocDbCreateCollection.ps1*

##SetResourceGroupTag.ps1

**Use Case**

Sets the deployed Resource Group Tags

**Required Parameters**

- `ResourceGroupName` - Name of the resource group deployed
- `Tags` - Hashtable of key/value pairs assigned to the group

--
