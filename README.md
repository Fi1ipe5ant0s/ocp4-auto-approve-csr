# Auto-approve Openshift 4 CSRs

This repo is to be used with caution and mainly will help ensuring certificiates request within Openshift are no lomnger in Pending state and are approved.  

## Additional information  
The manifest **[ocp4-auto-approve-csr](./ocp4-auto-approve-csr.yml)**, will create the following:  
- 1 Project called: *openshift-csr-approve*  
- 1 Service Account called: *csr-sa*  
- 1 RoleBinding called: openshift-csr-approve  
- 1 ConfigMap called: *ocp4-aprove-csr*  
- 1 CronJob called: *ocp4-aprove-csr*  

## Deploy the cron-job onto Openshift 4.x

#### Update the CronJob schedule
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

`oc get CronJob -n openshift-csr-approve` 

*The output should be similar to the following:*  

```sh
NAME                    SCHEDULE   SUSPEND   ACTIVE   LAST SCHEDULE   AGE
ocp4-auto-approve-csr   @hourly    False     0        <none>          93s
```

#### Review the CronJob output

*You may review the output of every CronJob within the namespace to confirm if any CSR were approved*

```sh
oc get pods -n openshift-csr-approve
```

Output similar to this:  

```sh
NAME                                     READY   STATUS      RESTARTS   AGE
ocp4-auto-approve-csr-1617897600-mftxq   0/1     Completed   0          125m
ocp4-auto-approve-csr-1617901200-f9hbp   0/1     Completed   0          65m
ocp4-auto-approve-csr-1617904800-jklwh   0/1     Completed   0          5m40s
```

*Review the Logs*  
`oc logs < Pod name > -n openshift-csr-approve`  