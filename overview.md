# bcartifacturl-proxy

Get artifact URLs for Microsoft Dynamics 365 Business Central trough [bcartifacturl-proxy](https://github.com/tfenster/bcartifacturl-proxy).

The [bcartifacturl-proxy](https://github.com/tfenster/bcartifacturl-proxy) utilizes the Get-BCArtifactUrl from the [BcContainerHelper](https://www.powershellgallery.com/packages/BcContainerHelper) and caches this one hour (Sandbox artifacts) or one day (OnPrem artifacts). When a call comes in, it first checks a cache to find out if that artifact URLs has previously been requested. This can reduce the executing time of the pipelines.

Read more on [Get your BC artifact URLs without PowerShell](https://tobiasfenster.io/get-your-bc-artifact-urls-without-powers)

### Example

```yaml
- task: bcartifacturlproxy@1
  inputs:
    type: 'Sandbox'
    country: 'BE'
    select: 'Weekly'
```