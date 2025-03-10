# pivoting from bootstrap to MC

Deploy MC fully up to (but not including) the kustomization (in the MC) which manages CAPI resources (Cluster etc). All bootstrap cluster kustomizations should be fully reconciled.

Pause reconciliation of CAPI resources and main flux kustomization in bootstrap cluster

Get owner ref of a CAPI-created secret (e.g. `room101-a7d-mc-kubeconfig`) & apply ownerRef to Talos cert bundle secret to ensure it is pivoted correctly (`room101-a7d-mc-talos`):

```
OWNER_REFERENCE=$(kubectl get secret room101-a7d-mc-kubesconfig -n cluster-room101-a7d-mc -o jsonpath='{.metadata.ownerReferences}')
kubectl patch secret room101-a7d-mc-talos -n cluster-room101-a7d-mc --type=json -p="[{'op': 'add', 'path': '/metadata/ownerReferences', 'value': $OWNER_REFERENCE}]"
```

Check state of CAPI resources in the bootstrap cluster and ensure Talos secret is owned by the Cluster:

```
➜  k tree cl room101-a7d-mc -n cluster-room101-a7d-mc
NAMESPACE               NAME                                                                   READY  REASON  AGE
cluster-room101-a7d-mc  Cluster/room101-a7d-mc                                                 True           2d1h
cluster-room101-a7d-mc  ├─MachineDeployment/room101-a7d-mc-workers                             True           2d1h
cluster-room101-a7d-mc  │ └─MachineSet/room101-a7d-mc-workers-q4mhc                            True           2d1h
cluster-room101-a7d-mc  │   ├─Machine/room101-a7d-mc-workers-q4mhc-d44rd                       True           2d1h
cluster-room101-a7d-mc  │   │ ├─ProxmoxMachine/room101-a7d-mc-workers-q4mhc-d44rd              True           2d1h
cluster-room101-a7d-mc  │   │ │ └─IPAddressClaim/room101-a7d-mc-workers-q4mhc-d44rd-net0-inet  -              2d1h
cluster-room101-a7d-mc  │   │ │   └─IPAddress/room101-a7d-mc-workers-q4mhc-d44rd-net0-inet     -              2d1h
cluster-room101-a7d-mc  │   │ └─TalosConfig/room101-a7d-mc-workers-q4mhc-d44rd                 True           2d1h
cluster-room101-a7d-mc  │   │   └─Secret/room101-a7d-mc-workers-q4mhc-d44rd-bootstrap-data     -              2d1h
cluster-room101-a7d-mc  │   └─Machine/room101-a7d-mc-workers-q4mhc-hnq9d                       True           2d1h
cluster-room101-a7d-mc  │     ├─ProxmoxMachine/room101-a7d-mc-workers-q4mhc-hnq9d              True           2d1h
cluster-room101-a7d-mc  │     │ └─IPAddressClaim/room101-a7d-mc-workers-q4mhc-hnq9d-net0-inet  -              2d1h
cluster-room101-a7d-mc  │     │   └─IPAddress/room101-a7d-mc-workers-q4mhc-hnq9d-net0-inet     -              2d1h
cluster-room101-a7d-mc  │     └─TalosConfig/room101-a7d-mc-workers-q4mhc-hnq9d                 True           2d1h
cluster-room101-a7d-mc  │       └─Secret/room101-a7d-mc-workers-q4mhc-hnq9d-bootstrap-data     -              2d1h
cluster-room101-a7d-mc  ├─ProxmoxCluster/room101-a7d-mc                                        True           2d1h
cluster-room101-a7d-mc  │ └─InClusterIPPool/room101-a7d-mc-v4-icip                             -              2d1h
cluster-room101-a7d-mc  │   ├─IPAddress/room101-a7d-mc-cp-7dc85922f0-fxtpj-net0-inet           -              2d1h
cluster-room101-a7d-mc  │   ├─IPAddress/room101-a7d-mc-cp-7dc85922f0-l9zl2-net0-inet           -              2d1h
cluster-room101-a7d-mc  │   ├─IPAddress/room101-a7d-mc-cp-7dc85922f0-mw4hm-net0-inet           -              2d1h
cluster-room101-a7d-mc  │   ├─IPAddress/room101-a7d-mc-workers-q4mhc-d44rd-net0-inet           -              2d1h
cluster-room101-a7d-mc  │   └─IPAddress/room101-a7d-mc-workers-q4mhc-hnq9d-net0-inet           -              2d1h
cluster-room101-a7d-mc  ├─ProxmoxMachineTemplate/room101-a7d-mc-cp-7dc85922f0                  -              2d1h
cluster-room101-a7d-mc  ├─ProxmoxMachineTemplate/room101-a7d-mc-workers-ed155637ea             -              2d1h
cluster-room101-a7d-mc  ├─Secret/room101-a7d-mc-ca                                             -              2d1h
cluster-room101-a7d-mc  ├─Secret/room101-a7d-mc-talos                                          -              2d1h
cluster-room101-a7d-mc  ├─Secret/room101-a7d-mc-talosconfig                                    -              2d1h
cluster-room101-a7d-mc  ├─TalosConfigTemplate/room101-a7d-mc-workers-ed155637ea                -              2d1h
cluster-room101-a7d-mc  └─TalosControlPlane/room101-a7d-mc-cp                                  True           2d1h
cluster-room101-a7d-mc    ├─Machine/room101-a7d-mc-cp-5wtzt                                    True           2d1h
cluster-room101-a7d-mc    │ ├─ProxmoxMachine/room101-a7d-mc-cp-7dc85922f0-fxtpj                True           2d1h
cluster-room101-a7d-mc    │ │ └─IPAddressClaim/room101-a7d-mc-cp-7dc85922f0-fxtpj-net0-inet    -              2d1h
cluster-room101-a7d-mc    │ │   └─IPAddress/room101-a7d-mc-cp-7dc85922f0-fxtpj-net0-inet       -              2d1h
cluster-room101-a7d-mc    │ └─TalosConfig/room101-a7d-mc-cp-sfnmt                              True           2d1h
cluster-room101-a7d-mc    │   └─Secret/room101-a7d-mc-cp-5wtzt-bootstrap-data                  -              2d1h
cluster-room101-a7d-mc    ├─Machine/room101-a7d-mc-cp-ds5m5                                    True           2d1h
cluster-room101-a7d-mc    │ ├─ProxmoxMachine/room101-a7d-mc-cp-7dc85922f0-mw4hm                True           2d1h
cluster-room101-a7d-mc    │ │ └─IPAddressClaim/room101-a7d-mc-cp-7dc85922f0-mw4hm-net0-inet    -              2d1h
cluster-room101-a7d-mc    │ │   └─IPAddress/room101-a7d-mc-cp-7dc85922f0-mw4hm-net0-inet       -              2d1h
cluster-room101-a7d-mc    │ └─TalosConfig/room101-a7d-mc-cp-5695n                              True           2d1h
cluster-room101-a7d-mc    │   └─Secret/room101-a7d-mc-cp-ds5m5-bootstrap-data                  -              2d1h
cluster-room101-a7d-mc    └─Machine/room101-a7d-mc-cp-tqc2n                                    True           2d1h
cluster-room101-a7d-mc      ├─ProxmoxMachine/room101-a7d-mc-cp-7dc85922f0-l9zl2                True           2d1h
cluster-room101-a7d-mc      │ └─IPAddressClaim/room101-a7d-mc-cp-7dc85922f0-l9zl2-net0-inet    -              2d1h
cluster-room101-a7d-mc      │   └─IPAddress/room101-a7d-mc-cp-7dc85922f0-l9zl2-net0-inet       -              2d1h
cluster-room101-a7d-mc      └─TalosConfig/room101-a7d-mc-cp-v8xpt                              True           2d1h
cluster-room101-a7d-mc        └─Secret/room101-a7d-mc-cp-tqc2n-bootstrap-data                  -              2d1h

➜  clusterctl describe cluster room101-a7d-mc -n cluster-room101-a7d-mc --show-conditions all
NAME                                                     READY  SEVERITY  REASON  SINCE  MESSAGE
Cluster/room101-a7d-mc                                   True                     2d1h
│           ├─ControlPlaneInitialized                    True                     2d1h
│           ├─ControlPlaneReady                          True                     2d1h
│           └─InfrastructureReady                        True                     2d1h
├─ClusterInfrastructure - ProxmoxCluster/room101-a7d-mc  True                     2d1h
│             └─ClusterReady                             True                     2d1h
├─ControlPlane - TalosControlPlane/room101-a7d-mc-cp     True                     2d1h
│ │           ├─Available                                True                     2d1h
│ │           ├─ControlPlaneComponentsHealthy            True                     2d1h
│ │           ├─EtcdClusterHealthyCondition              True                     2d1h
│ │           ├─MachinesBootstrapped                     True                     2d1h
│ │           ├─MachinesCreated                          True                     2d1h
│ │           ├─MachinesReady                            True                     2d1h
│ │           └─Resized                                  True                     2d1h
│ └─3 Machines...                                        True                     2d1h   See room101-a7d-mc-cp-5wtzt, room101-a7d-mc-cp-ds5m5, ...
└─Workers
  └─MachineDeployment/room101-a7d-mc-workers             True                     2d1h
    │           ├─Available                              True                     2d1h
    │           └─MachineSetReady                        True                     2d1h
    └─2 Machines...                                      True                     2d1h   See room101-a7d-mc-workers-q4mhc-d44rd, room101-a7d-mc-workers-q4mhc-hnq9d
```

Dry run:

```
clusterctl move --dry-run --kubeconfig tmp/bootstrap.kubeconfig --to-kubeconfig tmp/room101-a7d-mc.kubeconfig -n cluster-room101-a7d-mc -v 10
```

Actually pivot:

```
clusterctl move --kubeconfig tmp/bootstrap.kubeconfig --to-kubeconfig tmp/room101-a7d-mc.kubeconfig -n cluster-room101-a7d-mc -v 10
```

Resume reconciliation of CAPI resources in MC