# Setup virtual env - Python 3.7.6

```python
python -m virtualenv myenv3

pip install azure-identity
pip install azureml-core
pip install opencensus
pip install opencensus-ext-azure
pip install azureml-dataset-runtime
pip install azureml-pipeline
pip install azure-cli-core==2.34.1
```

## Modify python lib for on-prem testing
```python
# C:\Users\azureuser\Desktop\myenv2\Lib\site-packages\azureml\_vendor\azure_cli_core\cloud.py

def get_known_clouds(refresh=False):
    if 'ARM_CLOUD_METADATA_URL' in os.environ:
        from azureml._vendor.azure_cli_core._session import CLOUD_ENDPOINTS
        endpoints_file = os.path.join(GLOBAL_CONFIG_DIR, 'cloudEndpoints.json')
        CLOUD_ENDPOINTS.load(endpoints_file)
        if refresh:
            CLOUD_ENDPOINTS['clouds'] = {}
        clouds = []
        if CLOUD_ENDPOINTS['clouds']:
            try:
                clouds = [Cloud.from_json(c) for c in CLOUD_ENDPOINTS['clouds']]
                logger.info("Cloud endpoints loaded from local file: %s", endpoints_file)
                # add below three lines
                for c in clouds:
                    if c.name == 'AzureStack-Admin-cae20689-f5ee-4377-93ba-18a68ebb55d4':
                        c.endpoints.resource_manager = 'https://adminmanagement.shanghai.int.azurestack.corp.microsoft.com'
            except Exception as ex:  # pylint: disable=broad-except
                logger.info("Failed to parse cloud endpoints from local file. CLI will clean it and reload from ARM_CLOUD_METADATA_URL. %s", str(ex))
                CLOUD_ENDPOINTS['clouds'] = {}
        if not CLOUD_ENDPOINTS['clouds']:
            try:
                arm_cloud_dict = json.loads(urlretrieve(os.getenv('ARM_CLOUD_METADATA_URL')))
                cli_cloud_dict = _convert_arm_to_cli(arm_cloud_dict)
                if 'AzureCloud' in cli_cloud_dict:
                    cli_cloud_dict['AzureCloud'].endpoints.active_directory = 'https://login.microsoftonline.com'  # change once active_directory is fixed in ARM for the public cloud
                # add below two lines
                if 'AzureStack-Admin-cae20689-f5ee-4377-93ba-18a68ebb55d4' in cli_cloud_dict:
                    cli_cloud_dict['AzureStack-Admin-cae20689-f5ee-4377-93ba-18a68ebb55d4'].endpoints.resource_manager = 'https://adminmanagement.shanghai.int.azurestack.corp.microsoft.com'
                clouds = list(cli_cloud_dict.values())
                CLOUD_ENDPOINTS['clouds'] = [c.to_json() for c in clouds]
                logger.info("Cloud endpoints loaded from ARM_CLOUD_METADATA_URL: %s", os.getenv('ARM_CLOUD_METADATA_URL'))
            except Exception as ex:  # pylint: disable=broad-except
                logger.warning('Failed to load cloud metadata from the url specified by ARM_CLOUD_METADATA_URL')
                raise ex
        if not clouds:
            raise AzureMLException("No clouds available. Please ensure ARM_CLOUD_METADATA_URL is valid.")
        return clouds
    return HARD_CODED_CLOUD_LIST
```

Client needs to use AZ CLI auth for workspace (with AZUREML_CURRENT_CLOUD, ARM_CLOUD_METADATA_URL env var), e.g.
```powershell
$env:AZUREML_CURRENT_CLOUD="AzureStack-Admin-cae20689-f5ee-4377-93ba-18a68ebb55d4"
$env:ARM_CLOUD_METADATA_URL="https://aml.dbadapter.shanghai.int.azurestack.corp.microsoft.com/CloudEndpoints" # expose by openresty, return both Azure and AzureStack cloud endpoints
#$env:HTTPS_PROXY="http://127.0.0.1:8888"
#$env:HTTP_PROXY="http://127.0.0.1:8888"
#$env:NO_PROXY="kubernetes.docker.internal:6443"
```
```python
from azureml.core.authentication import AzureCliAuthentication
cli_auth = AzureCliAuthentication()
Onebox_Workspace = Workspace(subscription_id='ec8a03cd-95c8-4e27-8298-baafeac190cd',
                resource_group='jiadu-amltestrg',
                workspace_name='jd-mlcws-220302a',
                auth=cli_auth)
```


## Test inference
```
pip install azureml-opendatasets==1.39.0  
pip install matplotlib   
```

## Total pip modules
docs\AKS-HCI\notebooks\mnist-sdkv1\notebook-requirements.txt