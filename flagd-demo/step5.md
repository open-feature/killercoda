So far, you've seen a very basic feature flag. But often, you need more flexibility *within* a given flag rule.

For this, OpenFeature provides a concept of targeting rules. Targeting rules allow you to be more specific in *who* receives a given flag value.

For example, look at [fibAlgo]({{TRAFFIC_HOST1_3000}}/openfeature/flags/src/branch/main/example_flags.flagd.json#L70-88). 

The rules can be read like this:

- By default, everyone receives `recursive` **except**...
- When an `email` key ends with `@faas.com,` the returned variant is `binet` is returned.

Try this out now:

This command should return the `recursive` variant with a value of `recursive`.
```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "fibAlgo", "context": {} }'
```{{exec}}

This command should return the `binet` variant with a value of `binet`.
```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "fibAlgo", "context": { "email": "me@faas.com" } }'
```{{exec}}
