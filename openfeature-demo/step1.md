## What's in the demo?

The demo consists of three different scenarios where feature flags are used. They help the fictional company Fib3r safely test and release new features.

### Rebranding

As we all know, naming is hard! In this scenario, the team at Fib3r is in the process of rebranding from `FaaS` to `Fib3r`. This may seem like a situation where a feature flag is unnecessary. However, may times a rebranding needs to correspond with a press release or blog post. Of course, you could time a deployment moments before the announcement but that's potentially risky and may require coordination across multiple teams. Using a feature flag would allow you to deploy when it's convent, tests in production by enabled the feature for a subset of users, and then enable the feature instantly for everyone.

For the rebranding effort, we're only interested in being able to toggle the new welcome message on and off. A boolean value is exactly what we need! That can be accomplished in OpenFeature like [this](https://github.com/open-feature/playground/blob/main/packages/app/src/app/message/message.service.ts).

### Experimenting with color

The team at Fib3r has a hypothesis. They feel that the reason Fib3r hasn't achieved unicorn status is because the current color of the landing page is responsible for high bounce rates. This is a great opportunity to use feature flags for experimentation. With feature flags, it's possible to measure the impact a change has on the metrics that are important to your business.

[Diving into the code](https://github.com/open-feature/playground/blob/main/packages/app/src/app/hex-color/hex-color.service.ts), you may notice that an `after` hook has been defined. [Hooks](https://docs.openfeature.dev/docs/reference/concepts/hooks) are a powerful feature that can be used to extend OpenFeature capabilities. In this case, the code is expecting a valid css hex color value. However, _the person configuring the feature flag in a remote feature flag management tool may not be aware of this requirement_. That's where a validation hook could be used to ensure only valid CSS values are returned. In this hook, the evaluated value is tested against a regular expression. If it doesn't match, a warning messaged is logged and the hook throws an error. OpenFeature will catch the error and return the default value.

### Test in production

Fib3r is on a mission to help the world calculate the nth digit a Fibonacci more efficiently. According to a Stack Overflow article the team recently found, it's possible to use the Binet's Formula to calculate Fibonacci more efficiently. While the initial tests look promising, changing the underlying algorithm Fib3r has used for years is risky. The team decided that it would be safer put the new feature behind a context-dependant feature flag so that only employees could use it, initially. If the test goes well, the feature could be slowly rolled out to everyone or quickly revert if an issue is discovered.

Let's see how this could be done using OpenFeature. [Here](https://github.com/open-feature/playground/blob/main/packages/fibonacci/src/lib/fibonacci.ts) is where the Fib3r team add a feature flag that returns the name of the algorithm to run. Looking closely at the `getStringValue` method, you'll notice [evaluation context](https://docs.openfeature.dev/docs/reference/concepts/evaluation-context) is not being defined. Evaluation context is commonly used in feature flagging to dynamically determine the flag value. For example, the Fib3r team may want to test the `binet` algorithm on employees only. This can be done by setting the user's email address as evaluation context and defining a rule that returns `binet` only when the email address ends with `@faas.com`. Simple enough, but remember that evaluation context wasn't explicitly set during the flag evaluation linked above. That's because OpenFeature allows developers to set evaluation context at various points in their application. In this case, evaluation context is set [on each transaction](https://github.com/open-feature/playground/blob/main/packages/app/src/app/transaction-context.middleware.ts) and automatically used during flag evaluation.

## Available providers

The following [providers](https://docs.openfeature.dev/docs/reference/concepts/provider) can be used in the demo. Locate the provider you're interested in using to learn more.

- FlagD
- Go Feature Flag
- Environment Variable

For more information on each of these, review the [readme](https://github.com/open-feature/playground/blob/main/README.md).

## Enough Reading! Get Started!

[Click here to open the OpenFeature Demo]({{TRAFFIC_HOST1_30000}})

[OpenTelemetry Tracing is stored in Jaeger and available here]({{TRAFFIC_HOST1_16686}})