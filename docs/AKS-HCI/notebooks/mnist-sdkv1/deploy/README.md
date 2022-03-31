# Prepare inference python env - python 3.7.6
```python
python -m virtualenv sklearn-env 

pip install azureml-dataset-runtime[pandas,fuse]~=1.24.0.0
pip install scikit-learn==0.22.1
pip install azureml-defaults~=1.24.0.0
pip install Flask==1.1.4 # might conflict with azureml-defaults==1.24.0.0, but this won't affect inference
pip install markupsafe==2.0.1      
```
# Start inference server
```powershell
$env:AZUREML_MODEL_DIR = "F:\Vienna\AML-Kubernetes\docs\AKS-HCI\notebooks\mnist-sdkv1\model" #<model root path>

# activate python virtual env
python F:\Vienna\AML-Kubernetes\docs\AKS-HCI\notebooks\mnist-sdkv1\deploy\api.py
```

# Test
e.g.
```python
import json
score_uri = "http://localhost:12345/predict"

import requests
# example post payload: docs\AKS-HCI\cli\mnist\sample-request.json
# second number should be 7,2
test = json.dumps({"data": X_test.tolist()[:2]})
headers = {'Content-Type': 'application/json'}
r = requests.post(score_uri, data=test, headers=headers)
print(f"predictions: {r.json()}")
```