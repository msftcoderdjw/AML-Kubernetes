In CMAKS, we will provide the same AML experiences as other compute target. For the data scientists, the workflow to submit a AML training job can be summarize as below:

1. get the workspace 

```python
from azureml.contrib.core.compute.cmakscompute import CmAksCompute
from azureml.core.compute import ComputeTarget
from azureml.core import Workspace
ws = Workspace.from_config()
```

2. attach CMAKS compute

```python
from azureml.contrib.core.compute.cmakscompute import CmAksCompute
from azureml.core import Workspace
attach_config = CmAksCompute.attach_configuration(cluster_name =<cluster_name>
                                                    , resource_group =<resource group>
                                                    , node_pool=<node pool>
                                                 )

cmaks_target = CmAksCompute.attach(ws, <compute name>, attach_config)                                                 
```

3. define experiment

```python
from azureml.core import Experiment
experiment_name = <experiment name>
experiment = Experiment(workspace = ws, name = experiment_name)
```

4. submit run
```python

project_folder = '.'
script = 'sklearn.py'

from azureml.train.estimator import Estimator

sk_est = Estimator(source_directory=project_folder,
                   compute_target=cmaks_compute,
                   entry_script=script,
                   conda_packages=['scikit-learn'])

run = experiment.submit(sk_est)
run
```

You can find sample notebooks under: https://github.com/Azure/CMK8s-Sample/tree/master/sample_notebooks

After submmit runs you can [View metrics in Compute level and runs level](https://github.com/Azure/CMK8s-Samples/blob/master/docs/4.%20View%20metrics%20in%20Compute%20level%20and%20runs%20level.markdown)