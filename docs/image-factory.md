# Talos image factory

In order to install extensions in the Talos nodes, we need to use a specific installer image which is customised with our requirements.

The installer schematic ID is retrieved by POSTing the schematic definition yaml to the factory API:

```bash
curl --data-binary "@cluster/$CLUSTER/factory.talos.dev/schematic.yaml" https://factory.talos.dev/schematics
```

The returned ID is then used along with the Talos version to craft the installer image path which is applied to machines using the Serverclass resource.
