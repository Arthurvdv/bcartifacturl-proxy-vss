# bcartifacturl-proxy
Get artifact URLs for Microsoft Dynamics 365 Business Central

This extension utilizes the [bcartifacturl-proxy](https://github.com/tfenster/bcartifacturl-proxy) to retrieve artifact URLs for Microsoft Dynamics 365 Business Central. In some specific scenarios it could be interesting to use this proxy instead of directly calling the `Get-BCArtifactUrl` method from the [BcContainerHelper](https://www.powershellgallery.com/packages/BcContainerHelper).

Benefits could be
* Reduce the duration of pipelines with the caching results of [bcartifacturl-proxy](https://github.com/tfenster/bcartifacturl-proxy)
* Azure DevOps agent without BcContainerHelper installed

Read more on this on [Get your BC artifact URLs without PowerShell](https://tobiasfenster.io/get-your-bc-artifact-urls-without-powers)

## Example

```yaml
- task: bcartifacturlproxy@1
  inputs:
    type: 'Sandbox'
    country: 'W1'
    select: 'Daily'
```

The task will set the pipeline variable $(BCARTIFACTURL_PROXY) with the result retrieved from the [bcartifacturl-proxy](https://github.com/tfenster/bcartifacturl-proxy) instance.

```
Starting: Get-BCArtifactUrl
==============================================================================
Task         : bcartifacturl-proxy
Description  : Proxy for artifact URLs read by BcContainerHelper.
Version      : 1.0.9
Author       : Arthur van de Vondervoort
Help         : https://marketplace.visualstudio.com/items?itemName=Arthurvdv.bcartifacturl-proxy
==============================================================================
*** Task Inputs:

name                           value
-----                          -----
instanceUri                    
type                           Sandbox
country                        W1
version                        
select                         Daily
storageAccount                 
sasToken                       
accept_insiderEula             false


Invoke-WebRequest https://bca-url-proxy.azurewebsites.net/bca-url/sandbox/w1?DoNotRedirect=true&select=daily -UseBasicParsing
Response OK
*** Set Pipeline variable $(BCARTIFACTURL_PROXY) = 'https://bcartifacts.azureedge.net/sandbox/23.5.16502.17828/w1'
Finishing: Get-BCArtifactUrl
```

### Pipeline variable
After having the pipeline variable $(BCARTIFACTURL_PROXY) set, this can then be easily passed to other tasks.

```yaml
- task: PowerShell@2
  displayName: "Create BcContainer"
  env:
    ARTIFACTURL: $(BCARTIFACTURL_PROXY)
  inputs:
    targetType: "inline"
    script: |
      New-BcContainer -artifactUrl $env:ARTIFACTURL
```

```yaml
- task: ALOpsAppCompiler@2
  displayName: "Compile Extension"
  inputs:
    alternativeartifacturl: "$(BCARTIFACTURL_PROXY)"
```


# FAQ
### What is the benefit of the bcartifacturl-proxy caching mechanism?
With the increasing amount of artifact URLs available, it can take up to 20-30 seconds for the `Get-BCArtifactUrl` to retrieve the result.

_When a call comes in, it first checks a cache to find out if that artifact URLs has previously been requested. Those cache entries stay valid for one hour (sandbox artifacts) or one day (onprem artifacts). If a valid entry is found, the URL from the cache is returned._  
https://tobiasfenster.io/get-your-bc-artifact-urls-without-powershell

When handeling translations files within the pipeline, which requires compiling the App to generate the translation (XLIFF) file and recompile again to include additional created translations files, this can reduce the duration of the pipeline [up to 60 seconds](https://twitter.com/arthrvdv/status/1771049108087689659).

### Can I run my own instance of bcartifacturl-proxy?
Yes! Head over to https://github.com/tfenster/bcartifacturl-proxy and provide your `instanceUri` as a parameter to the task.  
Leaving the parameter empty will default to 'https://bca-url-proxy.azurewebsites.net/bca-url/', a link shared for the community by [Tobias Fenster](https://tobiasfenster.io/).

### Is an Azure DevOps agent running on Linux supported?
Currently only agents running on Windows are supported.

### What will happen if the WebRequest fails?
In case the call to the instanceUri fails, the task will fallback to the `Get-BCArtifactUrl` method from the [BcContainerHelper](https://www.powershellgallery.com/packages/BcContainerHelper).
