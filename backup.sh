#!/bin/bash

### 
# Authors:  Luigi Fratini   lfratini@sogei.it 
#           Valerio Coretti vcoretti@sogei.it
###

# LOGIN
USER="<USER>"
PASS="<PASSWORD>"
#ENV="$(oc whoami --show-server)"

#oc login -u $user -p $PASS $ENV
oc login -u $USER -p $PASS

# SKIPPATI: servicemnoitor, pvc

#List projects and save objects
for i in $( oc get projects | grep -vE '(openshift|kube|default|datagrid|prometheus|NAME)' |  awk {'print $1'} ); do # Edit based on projects you have to exclude    
    
    WORK_DIR_PROJECT=/path/to/workdir/$i
    echo "Verifico se esiste la work directory"
    if [ ! -d $WORK_DIR_PROJECT ]; then
        mkdir -p $WORK_DIR_PROJECT
    fi

    cd $WORK_DIR_PROJECT

    # Enter the project
    oc project $i

    # Get project template
    oc get project $i -o yaml | yq 'del(.metadata.managedFields)' > $i.yaml

    # Get configmaps. Skip custom configmaps.
    oc get cm -n $i -o yaml | yq e 'del(.items[] | select(.metadata.name == "openshift-service-ca.crt" or .metadata.name == "kube-root-ca.crt"))' | yq 'del(.items[].metadata.managedFields)' > $i-cm.yaml

    # Get rolebindings. Skip custom rolebindings.
    oc get rolebindings -n $i -o yaml | yq e 'del(.items[] | select(.metadata.name == "system:deployers" or .metadata.name == "system:image-builders" or .metadata.name == "system:image-pullers"))' | yq 'del(.items[].metadata.managedFields)' > $i-rolebindings.yaml

    # Get serviceaccounts. Skip customs serviceaccounts.
    oc get sa -n $i -o yaml | yq e 'del(.items[] | select(.metadata.name == "deployer" or .metadata.name == "builder" or .metadata.name == "default"))' | yq 'del(.items[].metadata.managedFields)' > $i-sa.yaml

    # Get other objects.
    oc get dc,replicaset,imagestream,routes,svc,rc,deployment,secrets,quota,limitrange,cronjobs,networkpolicies -n $i -o yaml | yq 'del(.items[].metadata.managedFields)' > $i-objects.yaml
done;

oc logout