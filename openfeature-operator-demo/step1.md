# Expose the application

```
kubectl -n open-feature-demo port-forward --address 0.0.0.0 service/open-feature-demo-service 30000
```{{exec}}

# Visit Application

[View the OpenFeature Demo Application]({{TRAFFIC_HOST1_30000}})

# View the Feature Flag Configuration

The demo application pod is reading feature flag configurations from a CRD called `FeatureFlagConfiguration`{{}}.

Leave the port-forward running. Open new terminal window and display the `featureflagconfigurations`:

```
kubectl -n open-feature-demo get featureflagconfigurations
```{{exec}}

# Update Application Color Flag

Change the application color by updating the feature flag.

The flag definition is already available as a YAML file.

Modify line `28`{{}} of `~/end-to-end.yaml` file and re-apply it.

You can use the built-in editor or a text editor like nano:
```
nano ~/end-to-end.yaml
```{{exec}}

Change `defaultVariant: blue` to `defaultVariant: green`.

Apply those changes:

```
kubectl apply -f ~/end-to-end.yaml
```{{exec}}

# View Changes

View the application again and within a few seconds the app should turn green.