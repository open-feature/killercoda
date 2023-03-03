[flagd](https://github.com/open-feature/flagd) is a tool created by OpenFeature to demonstrate feature flag usage. flagd is OpenFeature compliant and can read flag configurations from many sources including `files`{{}}, `http(s)`{{}} endpoints and `kubernetes`{{}}.

flagd reads a source of feature flags, interprets them and presents an OpenFeature compliant API endpoint that can be queried.

flagd is compatible with `gRPC`{{}} and `HTTP`{{}} and has native support for metrics using Prometheus. In this demo we will read flags directly from a Git repo using `HTTPS`{{}}.

## Start flagd

Start flagd and ask it to read files from a JSON source hosted online:

```
flagd start \
  --port 8013 \
  --uri {{TRAFFIC_HOST1_3000}}/openfeature/flags/raw/branch/main/flags.json
```{{exec}}
