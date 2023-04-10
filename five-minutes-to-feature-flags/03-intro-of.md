[OpenFeature](https://openfeature.dev/) is an open standard that lets us add feature flagging capabilities to our service in a vendor-neutral way. You can read more about the benefits of this approach [here](https://docs.openfeature.dev/blog/openfeature-a-standard-for-feature-flagging), but for now let's get our Hello, World service set up with OpenFeature - it shouldn't take more than a minute or two.

We'll create a new version of our server (`app/03_openfeature.js`) which looks something like this:

```javascript{6}
import { OpenFeature } from '@openfeature/js-sdk'
// ...
const featureFlags = OpenFeature.getClient()
// ...
routes.get('/', async (req, res) => {
  const withCows = await featureFlags.getBooleanValue('with-cows', false)
  if(withCows){
    res.send(cowsay.say({text:'Hello, world!'}))
  }else{
    res.send("Hello, world!")
  }
})
```

We're importing the `@openfeature/js-sdk`{{}} npm module, and using it to create an OpenFeature client called `featureFlags`{{}}. We then call `getBooleanValue`{{}} to find out if the `with-cows` feature flag is `true` or `false`. Finally, we show either the new cow-based output or the traditional plaintext format depending on whether `withCows` is true or false, just as we did before.

The big difference is that rather than using a hard-coded conditional we're now asking for the state of the flag dynamically, at runtime, using `getBooleanValue()`.

Let's try this new server out. Head back to Tab 1 and run it:

```
node ~/app/03_openfeature.js
```{{exec interrupt}}

Over in tab 2 we can re-curl the server (or [load it in the browser]({{TRAFFIC_HOST1_3333}})):

```
curl http://localhost:3333
```{{exec}}

and we should be back to getting a vanilla `Hello, World!` response. Why is that?

Well, the OpenFeature SDK doesn't provide feature flagging capabilities by itself. We have to configure it with a "[provider](https://docs.openfeature.dev/docs/specification/glossary/#provider)" which connects the SDK to a feature flagging implementation which can actually make the flagging decisions we need. (You can read more about OpenFeature's architecture [here](https://docs.openfeature.dev/docs/reference/intro#what-is-openfeature).)

Since we haven't configured the SDK with a provider it has no way of making feature flagging decisions and will just return default values. In this case, `with-cows` is defaulting to `false`, so now we don't see any cows in our output.

Let's fix that by configuring the SDK with a feature flag provider!

## Configuring OpenFeature

If this was a fancy production-grade system we'd probably want to connect the OpenFeature SDK to a full-fledged feature flagging system - a commercial product such as [LaunchDarkly](https://launchdarkly.com/) or [Split](https://www.split.io/), an open-source system like [flagd](https://github.com/open-feature/flagd), or perhaps a custom internal system - so that it can provide flagging decisions from that system.

Connecting OpenFeature to one of these backends is very straightforward, but it does require us to get a backend set up and ready to go. Instead, just to get us started, we'll use a super-simple flag provider that doesn't need a backend.
