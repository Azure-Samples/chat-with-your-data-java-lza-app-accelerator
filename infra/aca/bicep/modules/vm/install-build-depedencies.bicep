targetScope = 'resourceGroup'

@description('Name of the virtual machine where to install build and deploy dependencies for the java solution')
param vmName string
param location string = resourceGroup().location

resource windowsVmJumpBox 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: vmName
}



resource installDependencies 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
  parent: windowsVmJumpBox
  name: 'installJavaDependencies'
  location: location
  properties: {
    runAsUser:'azureuser'
    source: {
      scriptUri: 'https://raw.githubusercontent.com/dantelmomsft/chat-with-your-data-java-lza-app-accelerator/aca-lza/infra/aca/bicep/modules/vm/jumpbox-tools-setup.sh'
    }
  }
}

