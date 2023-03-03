We will now simulate what your application would do to retrieve a flag value.

Open a new tab (click the `+`{{}} icon near the top of the right hand panel) and run this command:

```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "headerColor", "context": {} }'
```{{exec}}

This should return `red` because the `defaultVariant` is set to `red` in Git ([see here]({{TRAFFIC_HOST1_3000}}/openfeature/flags/src/branch/main/flags.json#L91)).

## Change Flag Color

Using GitOps, change the `defaultVariant` from `red` to `yellow`:

Edit `~/template/flags.json`{{}} (or do it via the UI) then `git commit and git push`{{}}. Remember that the username and password is `openfeature` for both.

```
cd ~/template
sed -i 's/"defaultVariant": "red"/"defaultVariant": "yellow"/g' ~/template/flags.json
git add flags.json && git commit -m "update header color" && git push
```{{exec}}

[Line 91]({{TRAFFIC_HOST1_3000}}/openfeature/flags/src/branch/main/flags.json#L91) should now be `"defaultVariant": "yellow",`

## Retrieve the Flag Value Again

This time you should receive `yellow`.

```
curl -X POST {{TRAFFIC_HOST1_8013}}/schema.v1.Service/ResolveString \
  -H "Content-Type: application/json" \
  -d '{"flagKey": "headerColor", "context": {} }'
```{{exec}}