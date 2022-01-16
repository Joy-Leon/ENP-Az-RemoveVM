#-------------------------------------------------------------------------------------------------------------------------------------------------#
#          _             _                _            _            _   _         _                 _          _          _             _         #
#         / /\          /\_\             /\ \         /\ \         /\_\/\_\ _    / /\              /\ \       /\ \       /\ \     _    /\ \       #
#        / /  \        / / /         _   \_\ \       /  \ \       / / / / //\_\ / /  \             \_\ \      \ \ \     /  \ \   /\_\ /  \ \      #
#       / / /\ \       \ \ \__      /\_\ /\__ \     / /\ \ \     /\ \/ \ \/ / // / /\ \            /\__ \     /\ \_\   / /\ \ \_/ / // /\ \_\     #
#      / / /\ \ \       \ \___\    / / // /_ \ \   / / /\ \ \   /  \____\__/ // / /\ \ \          / /_ \ \   / /\/_/  / / /\ \___/ // / /\/_/     #
#     / / /  \ \ \       \__  /   / / // / /\ \ \ / / /  \ \_\ / /\/________// / /  \ \ \        / / /\ \ \ / / /    / / /  \/____// / / ______   #
#    / / /___/ /\ \      / / /   / / // / /  \/_// / /   / / // / /\/_// / // / /___/ /\ \      / / /  \/_// / /    / / /    / / // / / /\_____\  #
#   / / /_____/ /\ \    / / /   / / // / /      / / /   / / // / /    / / // / /_____/ /\ \    / / /      / / /    / / /    / / // / /  \/____ /  #
#  / /_________/\ \ \  / / /___/ / // / /      / / /___/ / // / /    / / // /_________/\ \ \  / / /   ___/ / /__  / / /    / / // / /_____/ / /   #
# / / /_       __\ \_\/ / /____\/ //_/ /      / / /____\/ / \/_/    / / // / /_       __\ \_\/_/ /   /\__\/_/___\/ / /    / / // / /______\/ /    #
# \_\___\     /____/_/\/_________/ \_\/       \/_________/          \/_/ \_\___\     /____/_/\_\/    \/_________/\/_/     \/_/ \/___________/     #
#                            _              _        _            _       _                _        _    _        _                               #
#                           / /\      _    /\ \     /\ \         / /\    / /\             /\ \     /\ \ /\ \     /\_\                             #
#                          / / /    / /\   \ \ \    \_\ \       / / /   / / /             \ \ \   /  \ \\ \ \   / / /                             #
#                         / / /    / / /   /\ \_\   /\__ \     / /_/   / / /              /\ \_\ / /\ \ \\ \ \_/ / /                              #
#                        / / /_   / / /   / /\/_/  / /_ \ \   / /\ \__/ / /              / /\/_// / /\ \ \\ \___/ /                               #
#                       / /_//_/\/ / /   / / /    / / /\ \ \ / /\ \___\/ /      _       / / /  / / /  \ \_\\ \ \_/                                #
#                      / _______/\/ /   / / /    / / /  \/_// / /\/___/ /      /\ \    / / /  / / /   / / / \ \ \                                 #
#                     / /  \____\  /   / / /    / / /      / / /   / / /       \ \_\  / / /  / / /   / / /   \ \ \                                #
#                    /_/ /\ \ /\ \/___/ / /__  / / /      / / /   / / /        / / /_/ / /  / / /___/ / /     \ \ \                               #
#                    \_\//_/ /_/ //\__\/_/___\/_/ /      / / /   / / /        / / /__\/ /  / / /____\/ /       \ \_\                              #
#                        \_\/\_\/ \/_________/\_\/       \/_/    \/_/         \/_______/   \/_________/         \/_/                              #
#                                                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------------------#
# Disclaimer:                                                                                                                                     #
#                                                                                                                                                 #
# This script comes with no guarantees. The cmdlets in this script functioned as is on the moment of creating the script.                         #
# It is possible that during the lifecycle of the product this script is intended for, updates were performed to the systems and the script       #
# might not, or might to some extent, no longer function.                                                                                         #
#                                                                                                                                                 #
# Therefor, I would suggest running the script in a test environment first, cmdlet per cmdlet, before effectively running it in production        #
# environments.                                                                                                                                   #
#                                                                                                                                                 #
# Created by Leon Moris                                                                                                                           #
# Website: www.switchtojoy.be                                                                                                                     #
# Github: https://github.com/Joy-Leon                                                                                                             #
#-------------------------------------------------------------------------------------------------------------------------------------------------#

# Declared functions.
function func_logging {   
    param ($String) 
    func_writeok $string
    return "[{0:dd/MM/yy} {0:HH:mm:ss}] $String" -f (Get-Date)  | Out-File $logfile -append
}
function func_writeok {
    param ($string)
    write-host ""
    write-host $string -f green
}
function func_writenok {
    param ($string)
    write-host ""
    write-host $string -f red
}

# Declared variables.
$logfile = Get-Location
$logfile = "$logfile\logfile.txt"
if (Test-Path $logfile) {
    if (Test-Path "$logfile.old") {
        Remove-Item "$logfile.old"
    }
    move-item $logfile -destination "$logfile.old"
}

# Make sure you have the AZ Powershell Module installed.
$Subscription = "00000000-0000-0000-0000-000000000000"

# Make sure to either enter your Resource Group or edit the name and location to your specific needs.
$AzResourceGroup = $null
$AzResourceGroupName = "AutomatingWithJoy"
$AzResourceGroupLocation = "West Europe"

# Make sure to edit the VM variables to your own needs.
$AzVMName = "JoyVM-WeEur-01"

# Connect to your Azure Tenant Account.
Connect-AzAccount

# Change to the subscription of your choice on where to create the new VM.
Set-AZContext -Subscription $Subscription | Out-File $logfile -append
func_logging "The subscription has been set to $Subscription"

# Load the Az VM into a separate variable.
try {
    $AzVM = (Get-AzVM -Name $AzVMName -ResourceGroupName $AzResourceGroupName)
    func_logging "The Az VM has been loaded in succesfully in the AzVM variable."
} catch {
    throw "The Az VM was not able to be loaded into the variable AzVM. Please check the logfiles for added troubleshooting." 
}

# Stop the Az VM from running.
try {
    Stop-AzVM -Name $AzVM.name -ResourceGroup $AzVM.ResourceGroupName | Out-File $logfile -append
    func_logging "The AzVM has been stopped succesfully."
} catch {
    throw "The AzVM was not able to be stopped. Please check the logfiles for added troubleshooting." 
}

# Remove the Az VM.
try {
    Remove-AzVM -Name $AzVM.name -ResourceGroup $AzVM.ResourceGroupName | Out-File $logfile -append
    func_logging "The AzVM has been removed succesfully."
} catch {
    throw "The AzVM was not able to be removed. Please check the logfiles for added troubleshooting." 
}

# Get the remaining Az VM resources.
$AzVMResources = (Get-AzResource -ResourceGroupName $AzVm.ResourceGroupName | Out-File $logfile -append)

# Remove the AzNetworkInterface.
try {
    $AzVM | Remove-AzNetworkInterface –Force | Out-File $logfile -append
    func_logging "The AzVM network interface has been removed succesfully."
} catch {
    throw "The AzVM network interface was not able to be removed. Please check the logfiles for added troubleshooting." 
}

# Remove the AzDisk.
try {
    Get-AzDisk -ResourceGroupName $AzVM.ResourceGroupName -DiskName $AzVM.StorageProfile.OSDisk.Name | Remove-AzDisk -Force | Out-File $logfile -append
    func_logging "The AzVM disk has been removed succesfully."
} catch {
    throw "The AzVM disk was not able to be removed. Please check the logfiles for added troubleshooting." 
}

# Remove the Az Virtual Network.
try {
    Get-AzVirtualNetwork -ResourceGroup $AzVM.ResourceGroupName | Remove-AzVirtualNetwork -Force | Out-File $logfile -append
    func_logging "The AzVM virtual network has been removed succesfully."
} catch {
    throw "The AzVM virtual network was not able to be removed. Please check the logfiles for added troubleshooting." 
}

# Remove the Az NSG.
try {
    Get-AzNetworkSecurityGroup -ResourceGroup $AzVM.ResourceGroupName | Remove-AzNetworkSecurityGroup -Force | Out-File $logfile -append
    func_logging "The AzVM NSG has been removed succesfully."
} catch {
    throw "The AzVM NSG was not able to be removed. Please check the logfiles for added troubleshooting." 
}

# Perform a last check to see if there are any other remaining Az VM resources.
$AzVMResources = (Get-AzResource -ResourceGroupName $AzVm.ResourceGroupName)
func_logging $AzVMResources
