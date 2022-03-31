# Dependencies
from flask import Flask, request, jsonify, Response
from sklearn.externals import joblib
import traceback
import pandas as pd
import numpy as np
import os
import json

# Your API definition
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    try:
        json_ = request.json
        # print(json_)
        data = np.array(json_['data'])
        # make prediction
        y_hat = model.predict(data)
        result = y_hat.tolist()
        return Response(json.dumps(result),  mimetype='application/json')
    except:
        return jsonify({'trace': traceback.format_exc()})

@app.route("/")
def hello():
    return "Welcome to machine learning model APIs!"

if __name__ == '__main__':
    try:
        port = int(sys.argv[1]) # This is for a command-line input
    except:
        port = 12345 # If you don't provide any port the port will be set to 12345

    # os.environ['AZUREML_MODEL_DIR'] = "F:\\Vienna\\AML-Kubernetes\\docs\\AKS-HCI\\notebooks\\mnist-sdkv1\\model"
    model_path = os.path.join(os.getenv('AZUREML_MODEL_DIR'), 'sklearn_mnist_model.pkl')
    global model
    model = joblib.load(model_path)

    app.run(port=port, debug=True)