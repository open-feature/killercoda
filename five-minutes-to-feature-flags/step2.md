Managing these flags by changing hardcoded constants gets old fast though. A team that uses feature flags in any significant way soon reaches for a feature flagging framework. Let's move in that direction by setting up the [OpenFeature](https://openfeature.dev) SDK:

The code looks like this:

```
import { OpenFeature } from '@openfeature/js-sdk'

const featureFlags = OpenFeature.getClient()

routes.get('/', async (req, res) => {
  const withCows = await featureFlags.getBooleanValue('with-cows', false)
  if(withCows){
    res.send(cowsay.say({text:'Hello, world!'}))
  }else{
    res.send("Hello, world!")
  }
})
```

Or show the entire server:

```
cat ~/app/03_openfeature.js
```{{exec}}

We've installed and imported the `@openfeature/js-sdk`{{}} npm module, and used it to create an OpenFeature client called `featureFlags`{{}}. We then call `getBooleanValue`{{}} on that client to find out if the `with-cows` feature flag is `true` or `false`. Depending on what we get back we either show the new cow-based output, or the traditional plaintext format.

Head back to Tab 1 and run the new server:

```
node ~/app/03_openfeature.js
```{{exec interrupt}}

Note that when we call `getBooleanValue`{{}} we also provide a default value of `false`{{}}. Since we haven't configured the OpenFeature SDK with a feature flag provider yet, it will always return that default value:

```
$> curl http://localhost:3333
Hello, world!
```{{}}

Flick over to tab 2 and try it:

```
curl http://localhost:3333
```{{exec}}

## Configuring OpenFeature

Without a feature flagging provider, [OpenFeature](https://openfeature.dev) is pretty pointless - it'll just return default values. Instead we want to connect our OpenFeature SDK to a full-fledged feature flagging system - a commercial product such as LaunchDarkly or Split, an open-source system like [FlagD](https://github.com/open-feature/flagd), or perhaps a custom internal system - so that it can provide flagging decisions from that system.

Connecting OpenFeature to one of these backends is very straightforward, but it does require that we have an actual flagging framework set up. For now, just to get started, let's just configure a really, really simple provider that doesn't need a backend. It looks like this:

```
import { MinimalistProvider } from '@moredip/openfeature-minimalist-provider'

const FLAG_CONFIGURATION = {
  'with-cows': true
}

const featureFlagProvider = new MinimalistProvider(FLAG_CONFIGURATION)

OpenFeature.setProvider(featureFlagProvider)
const featureFlags = OpenFeature.getClient()
```{{}}

This minimalist provider is exactly that - you give it a hard-coded set of feature flag values, and it provides those values via the OpenFeature SDK.

In our `FLAG_CONFIGURATION`{{}} above we've hard-coded that `with-cows`{{}} feature flag to `true`{{}}, which means that conditional predicate in our express app will now evaluate to true, which means that our service will now start providing bovine output:

```
$> curl http://localhost:3333
 _______________
< Hello, world! >
 ---------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```{{}}

In Tab 1, run this latest app version:
```
node ~/app/04_openfeature_with_provider.js
```{{exec interrupt}}

Try it (in tab 2):

```
curl http://localhost:3333
```{{exec}}

Open the editor again and edit `~/app/04_openfeature_with_provider.js`{{}}. On line `13`{{}}, change `true`{{}} to `false`.

Restart the server and you'll see the more boring response:

```
$> curl http://localhost:3333
Hello, world!
```{{}}

Try it now. In Tab 1, relaunch `04_openfeature_with_provider.js`{{}}:
```
node ~/app/04_openfeature_with_provider.js
```{{exec interrupt}}

Then `curl`{{}} once again on tab 2:
```
curl http://localhost:3333
```{{exec}}