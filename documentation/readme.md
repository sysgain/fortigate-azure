# Lab:Fortinet FortiGate - Fabric Connectors for Azure

## Table of Contents
	
1.	Introduction	
2.	Architecture Diagram	
2.1 Network Flow Diagram	
3.	Deploying the Demo Solution ARM Template	
3.1 Pre-Deployment Step: Collecting the Details from Azure	
3.1.1.	Create Service Principal for Azure AD Using Azure Portal (GUI)
3.1.2.	Create Service Principal for Azure AD Using Azure Cloud Shell (CLI)
3.1.3.	Role Assignment to Service Principal Using Azure Portal (GUI)	
3.1.4.	Role Assignment to Service Principal Using Azure CLI	
3.2.	Deploying the ARM Template	
3.2.1.	ARM Template Input Parameters	
3.2.2.	ARM Template Output Parameters
4.	Configuring FortiGate	
5	Blocking a URL Using IPv4 Policy and Fabric Connector Address	
Changing the policy precedence	
6.	Intrusion prevention	
6.1.	Create an IPS senor	
6.2.	Add the IPS sensor to the security policy allowing Internet access	
6.3.	Test the IPS sensor	
7.	Botnet C&C IP blocking	
7.1.	Test the Botnet C&C IP Blocking	
8.	Cleaning Up the Demo VNET Resources	
9.	Clean Up All Resources
9.1.	Deleting Service Principal	
9.1.1.	Deleting Service Principal Using the Azure Portal UI	
9.1.2.	Deleting Service Principal Using the Azure Cloud Shell	
10.	Connecting to the Existing Spoke VNet Resources
10.1.	Associating Subnets to the Route Table Using Azure Portal (GUI)	
10.2.	Associating Subnets to the Route Table Using Azure Cloud Shell (CLI)	


## 1. Introduction

This solution is comprised of an automated deployment template for a FortiGate solution on Azure, with a demo environment and use case baked in. Once the demo is completed, this solution allows the user to clean up the demo environment and optionally connect and protect their existing environment without the need to redeploy the FortiGate solution. This way, users get a guaranteed hands-on demo, and they also have the opportunity to keep the solution if they like it. 

In this solution, the core capabilities of Fortinet’s FortiGate firewall, along with Fabric Connectors, are demonstrated. Fabric Connectors are software-defined network (SDN) connectors that provide integration and orchestration of Fortinet products with key SDN solutions. 

The Fortinet Security Fabric provides visibility into your security posture across multiple cloud networks, spanning private, public, and Software as a Service (SaaS) clouds. 

By using the Fabric Connector with Microsoft Azure Infrastructure as a Service (IaaS), changes to attributes in the Azure environment can be automatically updated in the Fortinet Security Fabric.

The complete solution is deployed using an Azure Resource Manager (ARM) template that contains the user input parameters. This solution is developed using a reference architecture of hub-spoke topology in Azure. The hub is a virtual network (VNet) in Azure that acts as a central point of connectivity to spoke VNets, and it also can be extended to your personal cloud environment. 

The spokes are VNets that peer with the hub and can be used to isolate workloads.

**Fortinet FortiGate**
Fortinet FortiGate-VM firewall technology delivers complete content and network protection by combining stateful inspection with a comprehensive suite of powerful security features. This includes application control, antivirus, IPS, web filtering, and VPN – along with advanced features such as an extreme threat database, vulnerability management, and flow-based inspection work in concert to identify and mitigate the latest complex security threats. The security-hardened FortiOS operating system is purpose-built for inspection and identification of malware. With its new Docker application control signatures, your container environments are protected from newly emerged security threats.

**Hub VNets** - Azure VNet is used as the hub in the hub-spoke topology. The hub is the central point of connectivity to different workloads hosted in the spoke VNets. 

**Spoke VNets** - One or more Azure VNets that are used as spokes in the hub-spoke topology. Spokes can be used to isolate workloads in their own VNets. Each spoke VNet can include multiple subnets or single subnet with workloads (Web server or other) deployed. 

**VNet peering** – Two V-Nets are connected using a peering connection. Peering connections are non-transitive, low latency connections between VNets. In a hub-spoke network topology, you use VNet peering to connect the hub to each spoke. This solution supports peer virtual networks in the same region.

**Resource groups** – This solution supports hub VNet & spoke VNets in the same resource group.

**User defined routes (UDRs)** – used to force traffic destined to a spoke to be sent to an FortiGate acting as a router at the hub VNet. This will allow the spokes to connect to each other.

## 2. Architecture Diagram

![alt text](https://github.com/sysgain/fortigate-azure/raw/master/documentation/images/1.png)
 
### 2.1 Network Flow Diagram

![alt text](https://github.com/sysgain/fortigate-azure/raw/master/documentation/images/2.png)

You will get the same network flow if you deploy the template with default values. If you change any network related parameters, you will get a different network flow based on the given values.

*	All the inbound traffic is from Port1 to Port 2                      
*	All the outbound traffic is from Port2 to Port 1
*	A static route from FortiGate to workload (172.1.0.0/16 to 10.0.1.1(Gateway))

## 3. Deploying the Demo Solution ARM Template

### 3.1 Pre-Deployment Step: Collecting the Details from Azure

Before you deploy the template, you need to have the following information:

- **Azure Tenant ID**
A tenant is a representation of an organization. An Azure tenant ID is the Azure AD GUID associated with an Azure subscription.

- **Azure Client ID** (also called ‘Application ID’)
The unique identifier Azure AD issues to an application registration that identifies a specific application and the associated configurations. This application id (client id) is used while performing authentication requests.

- **Azure Client Secret**
Password for API Access in Registered App settings.

- **Azure Subscription ID**
The subscription ID is a unique alphanumeric string that identifies your Azure subscription. 

#### 3.1.1.	Create Service Principal for Azure AD Using Azure Portal (GUI)

An Azure AD application must be created to generate the Azure client ID and the corresponding Azure client secret, or Key as it is referred to in Azure. This application must be a service principal. Otherwise, the Azure SDN connector cannot read the inventory.
Note: Before creating the service principal, you need to verify that you have the required permissions on the subscription. Make sure your subscription has the following permissions:

*  Application Administrator
*  A User with app registrations setting is set to ‘Yes’

In your Azure subscription, your account must have the **Owner** role or **User Access Administrator** role.

For more information on the required permissions refer this link. For more information on the available roles and permissions refer this link.
1.	Sign in to your Azure account through the Azure portal and select Azure Active Directory > App registrations > New registration.
 
2.	Provide a name and select the Supported account types. Add a Redirect URI for the application. Select Web for the type of application you want to create. After setting the values, click on Register.
 
3.	Once you register the App, the following screen appears. You need to grab the Application/Client ID as shown below:
 
4.	To create the password, you will need to click on the Certificates & secrets then click on + New client secret. Provide the needed description, select the expiry duration and click on Add.
 
5.	Once you click on Add, the client secret/password will be created and shown under the VALUE column as shown below. Copy the value and keep it for future use.
 
3.1.2.	Create Service Principal for Azure AD Using Azure Cloud Shell (CLI)

1.	Run the command az ad sp create-for-rbac -n sdntest-ap --skip-assignment
 to get the App ID (Azure Client ID), tenant Id and password (Azure client secret).

Note: If you do not have the required permissions, contact your Azure portal admin to create a service principal with Network Contributor and Virtual Machine Contributor Roles.
 
 
Grab all the details from the output and save them to use in the ARM template input parameters while deploying the template.
3.1.3.	Role Assignment to Service Principal Using Azure Portal (GUI)

Dynamic address objects (IP addresses) in Azure can be resolved by FortiGate Azure SDN connector/Fabric Connector, provided that the service principal is granted Network Contributor and Virtual Machine Contributor roles for the target Subscription.
1.	Go to Azure Portal, search for “Subscriptions” and click on Subscriptions as shown below:
 
2.	It will open the subscriptions page, click on the target subscription where you are going to deploy the template as shown below:
 
3.	In your subscription page click on the Access Control (IAM),  +Add  Add role assignment as shown below:
 
4.	In Add role assignment page, select Role as “Network Contributor” and then select the service principal by typing the service principal name under Select, then click on Save.
 
5.	Repeat the above steps (3, 4) to assign “Virtual Machine Contributor” to the service principal as shown below:
 



3.1.4.	Role Assignment to Service Principal Using Azure CLI 

You can also run the following commands in the Azure CLI to assign roles to the App on the Subscription level:
Ex: az role assignment create --assignee <App ID> --role <Role Name> --subscription <subscription name/ID>
az role assignment create --assignee "fbc3c19f-0ce7-4XX9-aXXd-4e75f29330a3" --role "Network Contributor" --subscription "demoSubcription"
az role assignment create --assignee "fbc3c19f-0ce7-4XX9-aXXd-4e75f29330a3" --role "Virtual Machine Contributor" --subscription "demoSubcription"
 
 
3.2.	Deploying the ARM Template

1. Click on the Deploy to Azure button from this link. 
 
2.	It will open a Microsoft Azure Sign In page. Enter your Azure portal credentials then a Custom deployment page appears. Fill in all the details, accept the terms and conditions and click on the Purchase button.
   
 
 
After clicking on the Purchase button, the deployment starts. It will take around 8-12 mins to deploy the template. 
3.2.1.	 ARM Template Input Parameters

Parameter Name	Description	Allowed Values	Default Values
hubFotigateVNetCIDR	CIDR address for FortiGate vnet (Hub vnet)		10.0.0.0/16
FortiGatePublicFacingSubnetCIDR
	CIDR address for FortiGate public facing subnet		10.0.0.0/24
FortiGateInsideSubnetCIDR
	CIDR address for FortiGate internal (private facing) subnet		10.0.1.0/24
FortiGatePublicFacingSubnetAddress
	static address of public facing subnet		10.0.0.4
FortiGateInsideSubnetAddress
	static address of internal (private facing) subnet		10.0.1.4
fortigateVMSize	Size of the FortiGate Virtual Machine	"Standard_F1",
"Standard_F16s",
"Standard_F1s",
"Standard_F2",
"Standard_F2s",
"Standard_F4",
"Standard_F4s",
"Standard_F8",
"Standard_F8s"	Standard_F1
adminUsername	Username for FortiGate Virtual Machine 		
adminPassword	Password for FortiGate Virtual Machine		
ClientID	Application ID of AD Application		
clientSecret	Password for AD Application		
fabricConnectorWorkloadAddressName
	Name of the fabric connector address for workload VM with tag as “web”		
fabricConnectorFirewallAddressName
	Name of the fabric connector address for FortiGate VM with tag as “firewall”		
ExistingspokeVnet
	This parameter will allow user to choose existing VNet or Create new VNet based on the values YES/NO
Note: You need to select the existing resource group while deploying the template if you choose Yes for Existing Vnet	Yes
No	
existingVnetName	If you choose ExistingspokeVNet as Yes, then you need to provide the name of the existing VNet. Otherwise keep the default value as it is.
		
existingVnetPrefix	If you choose ExistingspokeVNet as Yes, then provide the Address prefix of the existing Vnet. Otherwise keep the default value as it is		
spokeDemoVnetCIDR	CIDR address for Demo vnet(spoke)		172.1.0.0/16
spokeDemoSubnetCIDR1	CIDR address for Demo subnet1(spoke)		172.1.0.0/24
spokeDemoSubnetCIDR2
	CIDR address for Demo subnet2(spoke)		172.1.1.0/24


3.2.2.	 ARM Template Output Parameters

To view the output parameters of the deployed template, you need to navigate to Resource Group, then you need click on Deployments, then click on Microsoft.Template and after that you need to click on Outputs, as shown below:

4.	Configuring FortiGate
1.	After a successful deployment, login to the FortiGate UI using the fortigateWebURL provided in the Outputs of the deployments as discussed in 3.2.2. section 
 

 

 
2.	Provide the username and password to login into the FortiGate web Interface. You can get these values from fortiGateVMUserName and fortiGateVMPassword output parameters as discussed in section 3.2.2.
 


3.	After login, you can see the dashboard as shown below:
 

The ARM template automates the creation of Fabric Connector for Microsoft Azure. If you use the fabric connector, the changes made to the Azure environment are automatically reflected to the fabric connector address objects without any manual changes. 
The template also creates two Fabric Connector addresses with filter values tags.displayName=web and tags.displayName=firewall.
To demonstrate how to use a dynamic address, the template creates virtual machines with tag names displayName with values “web” and “firewall”. The Address Objects contain IP address(es) within the Azure instance that are running.
When changes occur to addresses in the Azure environment, the Fabric Connector populates and updates the changes automatically based on the specified filtering condition. So, Administrators do not need to reconfigure the Address Objects content manually.
The following screenshot shows the Fabric Connector for Microsoft Azure and the addresses.
You can view the same by navigating to the path Security Fabric  Fabric Connectors 
 
For Fabric Connector Addresses Click on Policy & Objects  Addresses 
 
Note: It will take some time to resolve the fabric connector address. If it does not resolve within the time and you see any error, then double click on the address to change any of the values like Name or Color to a different value and click Ok. After a while, mouse-hover on the name of the fabric connector address you will be able to see resolved IP addresses as shown below:
 
In this document you will be presented with a use case which demonstrates how can you protect a workload using FortiGate and the use of fabric connector addresses.
The ARM template automates the creation of required Virtual IPs and IPv4 policies required for the use case.
You will need two Virtual IPs, one for SSH and one to access the sample web application from the workload VM. 
Let us understand what Virtual IP (VIP) is – The mapping of a specific IP address to another specific IP address is usually referred to as Destination NAT. When the Central NAT table is not being used, FortiOS calls this a Virtual IP Address – sometimes referred to as a VIP.
The above mentioned two VIPs allow users on the Internet to connect to your server protected behind a FortiGate firewall, without knowing the server’s internal IP address and only through ports that you choose.
TCP ports 8888 (HTTP) and 22 (SSH) are opened for remote users to communicate with a server behind the firewall. The external IP address used is 10.0.0.4 (FortiGate Public facing IP) and is mapped to 172.1.0.4 (workload IP/spoke VM IP) by the VIP. In the following screenshots you will be selecting the Interface as port 1 which is a public facing interface under the Network section, which allows users on the Internet to connect to your firewall (FortiGate).
You can view the Virtual IPs which were created using the ARM template by navigating to Policy & Objects  Virtual IPs.
 
You need to create the three policies. Let us understand what a policy is – The firewall policy is the axis around which most of the other features of the FortiGate firewall revolve. A large portion of the settings in the firewall at some point will end up relating to or being associated with the firewall policies and the traffic that they govern.
One policy is for SSH connection into the workload VM, the second policy is for accessing the sample web application, and the third is for allowing internet inside the workload VM.
You can see all the policies by navigating to Policy & Objects IPv4 Policy.
 
Note: Here you see a total of four policies: one for Fabric connector – i.e. An IPv4 policy from the FortiGate-VM ‘virtual appliance’ on Port 2 (Internal) to Port 1 (External) – the second one for SSH into the workload VM, the third one for accessing the sample web site and the fourth one is for Blocking the URL.
To view the sample web site, use the link as shown below and open the test website from a web browser on your local machine.
http://<DNS of the FortiGate VM>:8888	
Ex: http:// fortigateijkah.eastus2.cloudapp.azure.com:8888
 
5	Blocking a URL Using IPv4 Policy and Fabric Connector Address
Open PuTTY from your local machine and SSH into the workload VM through the FortiGate VM DNS. You can get the required details from the Outputs of the template deployment. Refer to 3.2.2. section for viewing the output parameters of the template deployment.
You can get the FortiGate VM DNS from the output parameter named “fortiGate-Dns” and the user name from the output parameter “workloadVM-UserName”. The password is from the output parameter “workloadVM-Password”. 
Note: You can download PuTTY here
SSH instructions for Windows
1.	Grab all the required values and SSH into the workload VM as shown below:
 

2.	Click on YES.

 

3.	After connecting to the VM successfully, provide the username and password of the Workload VM. 

 

4.	After a successful login you can view following screen:	
 

SSH instruction for Mac OS
5.	Launch the Terminal application, you can launch it from Spotlight by hitting Command + Spacebar and typing “Terminal”.
 
6.	In the command prompt, enter the following ssh command and hit Enter.
Syntax:  ssh <username>@<DNS(OR)IP Address> -p <port number>
ssh demouser@fortigatepw2x4.westus2.cloudapp.azure.com -p 2222
 
7.	Login to the remote server by entering the password for the user account you are logging into.
 
Note: You can login to the workload VM using the FortiGate DNS with port 2222, as you have created a policy (ssh-wl) in the earlier steps to route the SSH traffic to the workload VM through the FortiGate VM.
8.	Once you login to the workload VM, run the following command to access a specific URL. In this case it is www.facebook.com.
         wget www.facebook.com 
Note: After login to the workload VM the commands are same for the Window OS and Mac OS.
 
You can see that you are able to access facebook.com and download the index.html file (to verify, enter the “ls” command and you can see index.html file, as shown in above screenshot).
You can control web content by blocking access to web pages containing specific words or patterns. This can be done by using the “Web content filter”. The web content filter feature scans the content of every web page that is accepted by a security policy.
9.	Navigate to Security Profile  Web Filter, click on Create New 
 
10.	Provide the name of the Web Filter profile under Name as shown below
 
11.	Scroll down until you find Static URL Filter then enable URL Filter, click on Create. A New URL Filter pop-up will appear. Fill in the URL with *facebook.com. Select Type as Wildcard and Action as Block then click OK and then click Apply as shown below:
 
12.	You will need to update an IPv4 Policy (blocking-url-policy) to block the URL (facebook) in the workload VM. Click on Policy & Objects  IPv4 Policy then double click on blocking-url-policy enable Web Filter, select the Web Filter profile(blocking-url) you have created earlier and select Enable this policy as shown below:
 
13.	Now, try to access the Facebook site from the workload VM again, as shown below. You will now not be able to access the Facebook web URL.
NOTE: Move the ‘Block-Facebook’ policy to top of the list so that it will take the highest precedence if you have any similar policies. You can move the policy as shown below.
Changing the policy precedence
Click on the policy you want to move (ex: ‘Block-Facebook’). Hold the left mouse button and move it to the top of the policy list.
 
 
 
14.	You can view the log details in FortiGate UI by navigating to Log & Reports  Web Filter, then click on the log entry and click on Details for more information.
 
The above use case shows the use of FortiGate Fabric Connector for Azure. By using the FortiGate Fabric Connector for Azure (in this use case testip is the fabric connector address which is created using resource tag “firewall”), the configuration of the FortiGate’s policies is not dependent on the IP addresses of the resources connecting to it. 
The entire environment could be moved to a new Azure location on a different continent with different public IP addresses, even for internal resources. After the move, no reconfiguration needs to take place. Everything works just as it did before the move.

6.	Intrusion prevention
The FortiOS intrusion prevention system (IPS) combines signature detection and prevention with low latency and excellent reliability. 
With intrusion protection, you can create multiple IPS sensors, each containing a complete configuration based on signatures. Then, you can apply any IPS sensor to any security policy.
The following use case explains how to enable IPS on the FortiGate unit by using the EICAR test file.
In this example, you create a new IPS sensor and include a filter that detects the EICAR test file and saves a packet log when it is found.
6.1.	Create an IPS senor
1.	Go to Security Profiles > Intrusion Prevention. Select Create New, provide the name for new IPS sensor under Name as IPS-test 
 
2.	Click on +Add Signatures a pop-up will appear in that click on +Add Filter
For Severity: select all the options (you need repeat this to select all the values 
For Target: select server only.
For OS: select Linux only.
Search for Eicar.Virus.Test.File under the Name column, select it and click on Use Selected Signature as shown below.
 
3.	Under IPS Signatures table right click under Action and select Block as shown below.

 
4.	Under IPS Signatures table right click on Packet Logging, click on Packet Logging and Select Enable as shown below
 
5.	Under IPS Signatures table right click on Packet Logging, click on Status and Select Enable as shown below
 
6.	The IPS Signature is enabled as shown below then click OK. In the next screen click on Apply.
 
 
6.2.	Add the IPS sensor to the security policy allowing Internet access
1.	Go to Policy & Objects > IPv4 Policy then edit the internet-inbound-policy, Under Security Profiles enable IPS select IPS-test and click on OK
 
2.	Make sure that the internet-inbound-policy on the top of the list as shown below. 
Note: Follow the instructions from here to move the policy to top.
 
6.3.	Test the IPS sensor
With the IPS sensor configured and selected in the security policy, the FortiGate unit blocks any attempt to download the EICAR test file.
1.	SSH into the workload VM using the FortiGate-DNS with port 2222 and run the following command.
Note: As discussed in 3.2.2. section you can get login details of the workload VM from Outputs of the template deployments.
wget http://2016.eicar.org/download/eicar.com
 
No file is downloaded, that means the custom signature successfully detected the EICAR test file and blocked the download.
You can view the log details by navigating to Log & Reports Intrusion Prevention as shown below
 
7.	Botnet C&C IP blocking
FortiGuard Service continually updates the Botnet C&C domain list (Domain DB). The botnet C&C domain blocking feature can block the botnet website access at the DNS name resolving stage. This provides additional protection for your network.
1.	Go to Security Profiles > Intrusion Prevention and click on + Create New, provide a Name and enable Botnet C&C by setting Scan Outgoing Connections to Botnet Sites to Block. Click on OK then click on Apply.
 
2.	Go to Policy & Objects > IPv4 Policy then edit the internet-inbound-policy, Under Security Profiles enable IPS select botnet-cnc-ips and click on OK.
 
7.1.	Test the Botnet C&C IP Blocking
1.	Go to the FortiGate CLI (click on    icon in the FortiGate UI) and type the below command to see the botnet C&C IP address database.
diag sys botnet list 0 10 (if you want more IPs you can enter 0 100)

 

2.	SSH into the Workload VM and type the following command (curl -v 46.166.135.177 -m 5).
(take any IP with port 80 from the list and run the command)
 
3.	We can view the logs by navigating Log & Reports  Intrusion Prevention as shown below.
 
8.	Cleaning Up the Demo VNET Resources 
Once you are done, you can delete all the demo resources to connect to your existing spoke VNet. Follow the below steps to clean up the demo VNet resources.
1.	Copy the URL present in the output parameter named demoVnetCleanupUrl from the deployment Outputs section and paste it in the browser, then hit Enter to clean up the demo VNet resources.
 
 
 
Clean up activity will take approximately 3 to 5 minutes depending on the resources you have deployed. To make sure that the resources has been deleted, go back to the Resource Group and you can see all the demo VNET resources are deleted. 
Note: You can also delete the end-user VNET and End-user VM if you don’t require them for further testing.
This can be done by going to the Resource Group and delete the resources related to end user (resource names are prefixed with end-user).
9.	Clean Up All Resources
Once you are done testing the use-case and wanted to remove all the resources you've created through an ARM template, delete the Resource Group. This action deletes all resources contained within the Resource Group.
Note: This is applicable only for the Demo environment (this step is applicable if you select existingSpokeVnet as “NO” while deploying the ARM template). 
Go to the Azure portal, click on the Resource Group you have created through the template and delete the Resource Group, as shown below:
 
9.1.	Deleting Service Principal

You can delete the service principal which you have created as part of the demo environment. This can be done using the Azure portal UI or through a CLI command.
Note: Please make sure you have the required permissions to do this operation.
9.1.1.	Deleting Service Principal Using the Azure Portal UI
Go to the Azure portal and Navigate to Azure Active Directory  App registrations and search for the App (service principal) you want to delete, as shown below:
 
Click on the App  Overview  Delete and Yes. 
 
You will be able to see a notification which says, “Successfully deleted application…”	 
9.1.2.	Deleting Service Principal Using the Azure Cloud Shell
Run the following command in Azure Cloud Shell to delete the service principal:
az ad sp delete –id < App ID/object ID of the service principal >
Note: You should have proper permissions (Global Admin) on the subscriptions to delete service principal.
10.	Connecting to the Existing Spoke VNet Resources 

If you want to connect the Hub VNet to the existing spoke VNet resources, you need to choose “Yes” in the input parameter “Existing Spoke Vnet” while deploying the ARM template. You need to deploy the template in the same Resource Group as your existing spoke VNet. The ARM template automates the VNet peering between the Hub VNet and your spoke VNet.
Note: 
1.	The ARM template for connecting to the existing spoke VNet assumes that the existing Vnet contains only one subnet.
2.	You need to update the static route in the FortiGate with your existing spoke vnet CIDR by navigating to the Network Static Routes in the FortiGate UI.
3.	You need update the Mapped IP address with your private IP of the workload VM in both Virtual IPs (ssh-wl and web-ip) by navigating to Policy & Objects Virtual IPs. 
10.1.	Associating Subnets to the Route Table Using Azure Portal (GUI)
Note: you need to perform the following steps if you choose Yes for the input parameter “Existing Spoke Vnet”.
1.	Go to the Resource Group where your existing VNet is present then click on Spoke Route (Workload Route table in the resources list) as shown below:
 
2.	Click on Subnets, then click on +Associate
 
3.	In the Associate subnet page choose the existing VNet and subnet as shown below:
 
4.	Click on OK:
 
10.2.	Associating Subnets to the Route Table Using Azure Cloud Shell (CLI)
1.	You can run the following command to associate the existing subnet to the Workload Route table as shown below:
az network vnet subnet update -g <Resource group name> -n <subnet name> --vnet-name <VNet name to connect> --route-table <spoke route table name>
Ex: az network vnet subnet update -g existing-vnet-demo -n default --vnet-name existingvnet --route-table WorkloadRoutedzzqn
