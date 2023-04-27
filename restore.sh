#!/bin/bash

### 
# Authors:  Luigi Fratini   lfratini@sogei.it 
#           Valerio Coretti vcoretti@sogei.it
###

#Put project from cli
read -p "inserisci il nome del project da ricreare :" PROJECT
echo ""

#Check working dir
WORK_DIR_PROJECT=/path/to/workdir/$PROJECT

echo "Verifico se esiste la work directory"
if [ ! -d $WORK_DIR_PROJECT ]; then
    echo "La directory del project da ricreare non esiste"
    exit
fi

# LOGIN
USER="<USER>"
PASS="<PASSWORD>"
#ENV="$(oc whoami --show-server)"

#oc login -u $user -p $PASS $ENV
oc login -u $USER -p $PASS

# SKIPPATI: servicemnoitor, pvc

cd $WORK_DIR_PROJECT

# Create project from template
oc create -f $PROJECT.yaml

# Enter the project
oc project $PROJECT

# Get configmaps. Skip custom configmaps.
oc create -f $PROJECT-cm.yaml -n $PROJECT

# Get rolebindings. Skip custom rolebindings.
oc create -f  $PROJECT-rolebindings.yaml -n $PROJECT

# Get serviceaccounts. Skip customs serviceaccounts.
oc create -f $PROJECT-sa.yaml -n $PROJECT

# Get other objects.
oc create -f $PROJECT-objects.yaml -n $PROJECT

oc logout