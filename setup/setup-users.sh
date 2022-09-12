#! /bin/bash

cd $REPO_HOME/setup
oc delete secret htpasswd-secret -n openshift-config
oc create secret generic htpasswd-secret --from-file=htpasswd=pre-bakedusers.httpasswd -n openshift-config

oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config

oc apply -f htpasswd-oauth.yaml

# the application of the oauth object will trigger the bounce of the auth pods in openshift-auth ns
#oc scale deployment/oauth-deployment --replicas=0 -n openshift-authentication
#oc scale deployment/oauth-deployment --replicas=3 -n openshift-authentication
oc rollout status deployment/oauth-openshift --watch=true -n openshift-authentication


for i in {1..30}
#for i in {30..30}
do
    oc new-project a-predictive-maint-user$i
    oc delete limits a-predictive-maint-user$i-core-resource-limits
    oc adm policy add-role-to-user admin user$i -n a-predictive-maint-user$i

    oc new-project a-train-model-user$i
    oc delete limits a-train-model-user$i-core-resource-limits
    oc adm policy add-role-to-user admin user$i -n a-train-model-user$i
done



oc adm policy add-cluster-role-to-user cluster-admin user29

