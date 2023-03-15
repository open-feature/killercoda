A new version of our server, `04_openfeature_with_provider.js`, shows how to plug the OpenFeature SDK into a really simple flag provider.  Here's the relevant part of that file:

```
import { InMemoryProvider } from '@openfeature/in-memory-provider'


const FLAG_CONFIGURATION = {
  'with-cows': true
}

const featureFlagProvider = new InMemoryProvider(FLAG_CONFIGURATION)

OpenFeature.setProvider(featureFlagProvider)
const featureFlags = OpenFeature.getClient()
```{{}}

This [in-memory provider](https://www.npmjs.com/package/@openfeature/in-memory-provider) is the most basic feature flagging provider you could imagine. You configure it with hard-coded set of feature flag values, and it provides those values via the OpenFeature SDK.

In our `FLAG_CONFIGURATION`{{}} above we've hard-coded that `with-cows`{{}} feature flag to `true`{{}}, causing that conditional predicate in our express app to now evaluate to true, which in turn means that our service should now start providing bovine output. Let's check!

First, we'll start up this version of the server. Head back to Tab 1 and launch it:

```
node ~/app/04_openfeature_with_provider.js
```{{exec interrupt}}

Now in tab 2 we can re-curl the server (or [load it in the browser]({{TRAFFIC_HOST1_3333}})):

```
curl http://localhost:3333
```{{exec}}

The output should look like this:

```
 _______________
< Hello, world! >
 ---------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```{{}}

Our feature flagging system is working! Our server asks OpenFeature for the state of the `with-cows` flag. The OpenFeature SDK passes this request on to the configured provider which returns a value of `true`, enabling the flag in the server and producing the new and improved formatting.

# Flipping a Flag

We can double-check that our feature flag is having an effect by updating the provider's flag configuration. Open up `04_openfeature_with_provider.js` in the Editor tab, and update the configuration to turn off the `with-cows` feature:

```javascript{3}
const featureFlags = OpenFeature.getClient()
const FLAG_CONFIGURATION = {
  'with-cows': false
}

const featureFlagProvider = new InMemoryProvider(FLAG_CONFIGURATION)
```

Now hop over to tab 1 and re-start the server:

```
node ~/app/04_openfeature_with_provider.js
```{{exec interrupt}}

and over in tab 2 reload the response (or [load it in the browser]({{TRAFFIC_HOST1_3333}})):

```
curl http://localhost:3333
```{{exec}}

You should see that we're back to the cow-less, vanilla `Hello, World!` response. Feature flags in action!

This is all very exciting, but we're still having to make changes in source code to control that feature flag, due to the limitation of
this extremely basic in-memory provider. Next we'll look at upgrading to a *real* feature flagging backend...
