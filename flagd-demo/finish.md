
## Congratulations! 🎉
In this tutorial you have built an OpenFeature compliant feature flag backend using flagd.

You now have a pure GitOps feature flagging system. You can change only a JSON file and your application will automatically leverage the changes.

This is just the beginning. flagd is capable of a lot more, such as providing multiple flag sources, local file usage or retrieval over HTTPS or gRPC.

## What's Next?

In this tutorial, interaction with the flagd API was via `curl`{{}}. In reality, you wouldn't want your application becoming reliant on flagd - that's the entire premise of OpenFeature. Your application should be able to say "getAFlag" without caring about the backend system (flagd in this case).

To achieve this, OpenFeature offers [language specific flagd providers](https://github.com/open-feature/flagd/blob/main/docs/usage/flagd_providers.md) which interact and "translate" to flagd code for you. If you are using Kubernetes - use the OpenFeature Operator which handles all of this complexity for you. Follow the [OpenFeature Operator hands-on tutorial](https://killercoda.com/open-feature/scenario/openfeature-operator-demo) or read the [OFO docs](https://github.com/open-feature/open-feature-operator/tree/main/docs).

For example, in Golang, your application code would look like this:

```
package main

import (
	"github.com/open-feature/go-sdk-contrib/providers/flagd/pkg"
   	"github.com/open-feature/go-sdk/pkg/openfeature"
)

func main() {
    openfeature.SetProvider(flagd.NewProvider(
        flagd.WithHost("flagDHost"),
        flagd.WithPort(8013),
    ))

    // Get an openFeature client
    client := openfeature.NewClient("myApp")

    // Get flag values
    value, err := client.BooleanValue(
		context.Background(), "myFlagValue", false, openfeature.EvaluationContext{},
	)
}
```

- [Get started with flagd](https://github.com/open-feature/flagd)
- Questions? [Join the community](https://docs.openfeature.dev/community/)
