## Multiple Flag Sources

What if another team has their set of flags defined elsewhere? What if you are experimenting and have some flag values saved in a local file?

In both cases, you need flagd to read **both** sources, evaluate and return the value to you. You shouldn't need to care *where* the flag is stored.

## Create New Flags

In tab 2 (leave flagd running), click the following to create a new file containing a single flag called `brandNewFlag`
```
cat <<EOF > /tmp/localFlags.json
{
  "flags": {
     "brandNewFlag": {
      "state": "ENABLED",
      "variants": {
        "A": "this",
        "B": "that"
      },
      "defaultVariant": "A"
    }
  }
}
EOF
```{{exec}}

## Attempt to retrieve brandNewFlag
In tab 2, attempt to retrieve `brandNewFlag`. It should fail because flagd isn't yet aware of our new flag source (the JSON file):

```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "brandNewFlag", "context": {} }'
```{{exec}}

Expect the following output: `{"code":"not_found","message":"FlagdError:, FLAG_NOT_FOUND"}`{{}}

## flagd Monitors New Flags

Switch to Tab 1 and restart flagd, this time providing both flag sources:

```
flagd start \
--port 8013 \
--uri {{TRAFFIC_HOST1_3000}}/openfeature/flags/raw/branch/main/example_flags.flagd.json \
--uri file:/tmp/localFlags.json
```{{exec interrupt}}

## Retrieve Flag

Change back to tab 2 and again try to retrieve the flag value.

```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "brandNewFlag", "context": {} }'
```{{exec}}

This time you should see: `{"value":"this", "reason":"STATIC", "variant":"A"}`{{}}