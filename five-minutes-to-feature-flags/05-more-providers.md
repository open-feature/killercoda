We've gotten started with OpenFeature using a very simple but extremely limited provider.

The beauty of OpenFeature is that we can transition to a real feature-flagging system when we're ready, without any change to how we evaluate flags.

Once you have the flagging system up and runnig, integrating it into this service is as simple as configuring a different provider.

That next step is left as an exercise to you, dear reader. Documentation on the OpenFeature providers available to you is [here](https://docs.openfeature.dev/docs/reference/technologies/server/javascript), but here's a cheat sheet to illustrate how straightforward it is to switch over.

### LaunchDarkly
```
import { init } from 'launchdarkly-node-server-sdk';
import { LaunchDarklyProvider } from '@launchdarkly/openfeature-node-server';

const ldClient = init('[YOUR-SDK-KEY]');
await ldClient.waitForInitialization();
OpenFeature.setProvider(new LaunchDarklyProvider(ldClient));
```

### flagd
```
OpenFeature.setProvider(new FlagdProvider({
    host: '[FLAGD_HOST]',
    port: 8013,
}))
```

### Split
```
import { SplitFactory } from '@splitsoftware/splitio';
import { OpenFeatureSplitProvider } from '@splitsoftware/openfeature-js-split-provider';

const splitClient = SplitFactory({core: {authorizationKey:'[YOUR_AUTH_KEY]'}}).client();
OpenFeature.setProvider(new OpenFeatureSplitProvider({splitClient}));
```

### CloudBees
```
import {CloudbeesProvider} from 'cloudbees-openfeature-provider-node'

const appKey = '[YOUR_APP_KEY]'
OpenFeature.setProvider(await CloudbeesProvider.build(appKey));
```
