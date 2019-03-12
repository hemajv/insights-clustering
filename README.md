## Insights Clustering with MLflow

This is an application which demonstrates how to run the clustering model using MLflow on Openshift.

## Running on OpenShift
This is a two stage process:

* The first stage is to get your code on openshift
* The second stage is to run the experiment.

Once you have your code on openshift, you can have multiple instances of your experiment running with different parameters.

### First Stage: getting your code on OpenShift
To run this application on openshift, we need to create a container image for it. In other words, this means that we need to download the code that we want to run on openshift. To do this a [image build template](https://github.com/AICoE/experiment-tracking-template/blob/master/openshift/mlflow-experiment-image-buildconfig.yaml) should already be available in your openshift namespace.


<!-- This template will take a base image, and install all the dependencies listed in the Pipfile of your source repository and store this new image to the image registry. -->

<!-- To initiate a new image build, run the following command from the root of this repository: -->
To download the source code for your experiment to openshift, use the following command:

```
oc process mlflow-experiment-bc --param APPLICATION_NAME=my-mlflow-experiment --param GIT_URI=https://github.com/AICoE/experiment-tracking-template.git --param APP_FILE=app.py | oc create -f -
```
* Here, the `APPLICATION_NAME` parameter is the name of the container image that will be built and is where your code will be downloaded, this is the image name that you will use to run your experiments.
* You can set `GIT_URI` to the link for your repository to create a container image for your application.
* You can also change the `APP_FILE` env variable to your app file name.

Building the container image can take a couple of minutes or more depending on the number of packages that need to be installed from the dependencies list.

If the image build process has started you should see some output like this:
```
imagestream.image.openshift.io "my-mlflow-experiment" created
buildconfig.build.openshift.io "my-mlflow-experiment" created
```
To see if the build process has finished, run the following command:
```
oc logs bc/my-mlflow-experiment
```
If you see something like:
```
Pushed 5/10 layers, 50% complete
Pushed 6/10 layers, 60% complete
Pushed 7/10 layers, 70% complete
Pushed 8/10 layers, 80% complete
Pushed 9/10 layers, 90% complete
Pushed 10/10 layers, 100% complete
Push successful
```
at the end of the logs, the first stage is completed.
### Second Stage: Running an experiment
After the image is built, we can use it to run an experiment on OpenShift.

To run the experiment, use the following command:
```
oc new-app mlflow-experiment-job --param APP_IMAGE_URI=my-mlflow-experiment --env PARAM_ALPHA=0.4 --env PARAM_L1_RATIO=1.2
```
In the above command, `PARAM_ALPHA` and `PARAM_L1_RATIO` are the parameters for training the demo model. ([Here](https://github.com/AICoE/experiment-tracking-template/blob/23efac85099ca40b1bc2ead402008a8febf69608/app.py#L90-L91))<br/>
Make sure that the `APP_IMAGE_URI` that you specified in the above command is the same as the `APPLICATION_NAME` that you specified in the first stage.

This should run the experiment on OpenShift with the specified values of parameters.

If you want to use a different mlflow tracking server, you can use the `MLFLOW_TRACKING_URI` parameter to specify its address in the above command.<br/>
(Example: `--param MLFLOW_TRACKING_URI=http://mlflow-server-url:5000/`)

If you know your mlflow experiment id, you can set it with `MLFLOW_EXPERIMENT_ID` environment variable.<br/>
(Example: `--env MLFLOW_EXPERIMENT_ID=3`)

### Re-run the experiment with different parameters
You can create a new run by using the command from stage two with a different `APPLICATION_NAME`.<br/>
For example, if you want to run the same experiment with different model training parameters, you could run a command like:
```
oc new-app mlflow-experiment-job --param APP_IMAGE_URI=my-mlflow-experiment --env PARAM_ALPHA=0.7 --env PARAM_L1_RATIO=0.8
```
This will run the same experiment with different values for `PARAM_ALPHA` and `PARAM_L1_RATIO` than previously used.

### Updating your experiment code
If you want to make any changes to your experiment code on openshift, first push all your changes to your repository and then run the following command:

<!-- To update the image after you have made some changes to the source repository, use the following command: -->

```
oc start-build my-mlflow-experiment
```
* Here, `my-mlflow-experiment` is the `APPLICATION_NAME` parameter you provided during the first stage.

This command will pull the new code from your repository and create a new image with it. Once this new image is built, you can run a new experiment (just like stage two), which will use the new version of the code automatically.
