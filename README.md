# Auto-approve Openshift 4.x UPI CSRs

This repo is to be used with caution and mainly will help any UPI of Openshift 4.x where the [CSRs](https://docs.openshift.com/container-platform/4.1/installing/installing_bare_metal/installing-bare-metal.html#installation-approve-csrs_installing-bare-metal) need to be approved manually. When this is not in place you will see some odd behavior of Openshift and may not realize that the approvals of some CSRs is pending

>For the next steps below, checkout this repo and change-directory into it.

## Create the container image that performs the auto-approval

Within the [Dockerfile](./Dockerfile) the environment variable for the OPENSHIFT_VERSION is set to 4.7.5, we will be aligning our tag to reference the same.  

#### Build the container image

*Change the < quay-username > to your quay.io username*

```sh 
podman build -t quay.io/<quay-username>/ocp4-auto-approve-csr:4.7.5 .
```

#### Push the container image

*Change the < quay-username > to your quay.io username*

```sh
podman push quay.io/<quay-username>/ocp4-auto-approve-csr:4.7.5
```

## Deploy the cron-job onto Openshift 4.x

#### Create a new openshift project

```sh 
oc adm new-project openshift-cron-jobs
```

#### Update the ServiceAccount role

*Provide the default service account of openshift-cron-jobs the role of cluster-admin*  

```sh
oc adm policy add-cluster-role-to-user cluster-admin -z default -n openshift-cron-jobs
```

#### Update the CronJob values

*You will need to update the [ocp4-auto-approve-csr.yml](./ocp4-auto-approve-csr.yml) file and replace the line 16 with the information of your repository and TAG.*  

`              image: 'quay.io/<quay-username>/ocp4-auto-approve-csr:4.7.5'`  

*You may also replace the cron schedule, to better suit your needs or requirements. The default values are set to CSRs getting approved every hour.*  

```sh
spec:
  schedule: '@hourly'
```
#### Create the CronJob entry

*You may create the resource within your cluster*  

```sh
oc create -f ocp4-auto-approve-csr.yml
```

## Review and confirm

#### Confirm it's all set

*You may confirm that there is a CronJob created within the new project by running the following command*  

`oc get CronJob -n openshift-cron-jobs` 

*The output should be similar to the following:*  

```sh
NAME                    SCHEDULE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
ocp4-auto-approve-csr   @hourly    False     0        <none>          93s
```

#### Review the CronJob ouput

*You may review the output of every CronJob within the namespace to confirm if any CSR were approved*

```sh
oc get pods -n openshift-cron-jobs
```

Output similar to this:
> NAME                                     READY   STATUS      RESTARTS   AGE
> ocp4-auto-approve-csr-1617897600-mftxq   0/1     Completed   0          125m
> ocp4-auto-approve-csr-1617901200-f9hbp   0/1     Completed   0          65m
> ocp4-auto-approve-csr-1617904800-jklwh   0/1     Completed   0          5m40s

oc logs < Pod name > -n openshift-cron-jobs

Output similar to this:
> Logged into "https://172.30.0.1:443" as "system:serviceaccount:openshift-cron-jobs:default" using the token provided.
> ...
> No CSRs found, nothing to do!