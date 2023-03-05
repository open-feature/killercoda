So far you've seen a very basic feature flag. But often you need more flexibility *within* a given flag rule.

For this, OpenFeature provides a concept of targeting rules. Targeting rules allow you to be more specific in *who* receives a given flag value.

<!--
## TODO
This section needs to be updated based on the outcome of https://github.com/open-feature/flagd/pull/467.

This should probably reference `targetedFlag` not `headerColor`.

For example, look at [headerColor]({{TRAFFIC_HOST1_3000}}/openfeature/flags/src/branch/main/example_flags.flagd.json#L88-L133). 

The rules can be read like this:

- When an `email` key is present containing `@faas.com`, the returned flag is `second` with a value of `BBB`.
- When an `userAgent` key is present containing `Chrome`, the returned flag is `third` with a value of `CCC`.

Try this out now:

This command should return the `first` variant with a value of `AAA`.
```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "targetedFlag", "context": {} }'
```{{exec}}

This command should return the `second` variant with a value of `BBB`.
```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "targetedFlag", "context": { "email": "me@faas.com" } }'
```{{exec}}

This command should return the `third` variant with a value of `CCC`.
```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "targetedFlag", "context": { "userAgent": "Chrome 1.2.3" } }'
```{{exec}}
-->