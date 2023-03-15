Let's imagine that we're adding a new, experimental feature to this hello world service. We're going to upgrade the format of the server's response, using [cowsay](https://www.npmjs.com/package/cowsay)!

However, we're not 100% sure that this cowsay formatting is going to work out, so for now we'll protect it behind a conditional. We've made this change in a new copy of the server, `app/02_basic_flags.js`:

```javascript
import 'cowsay'
...
routes.get('/', async (req, res) => {
  // set this to true to test our new
  // cow-based greeting system
  const withCow = false
  if(withCow){
    res.send(cowsay.say({text:'Hello, world!'}))
  }else{
    res.send("Hello, world!")
  }
})
```{{}}

By default our service continues to work exactly as it did before, but if we change `withCow` to `true`, our new formatting will come to life.

Let's run this new version of the server.  Flick back to tab 1 and try out the new code:

```
node ~/app/02_basic_flags.js
```{{exec interrupt}}

Back to tab 2 to re-curl the server (or [load it in the browser]({{TRAFFIC_HOST1_3333}})):

```
curl http://localhost:3333
```{{exec}}

Don't be surprised if the output looks the same as before - `withCow` is still set to `false` in that file, so it should be returning the same response as before.
However, if we now update it to `true` then the format should change. 

Give it a try! Open the server code (`app/02_basic_flags.js`) in the IDE (that `Editor` tab at the top left of the terminal to the right) and set `withCow` to true:

```javascript{4}
routes.get('/', async (req, res) => {
  // set this to true to test our new
  // cow-based greeting system
  const withCow = true
  if(withCow){
    res.send(cowsay.say({text:'Hello, world!'}))
  }else{
    res.send("Hello, world!")
  }
})
```

Now flip back to `Tab 1` and restart the server:
```
node ~/app/02_basic_flags.js
```{{exec interrupt}}


Finally, check [our server's response]({{TRAFFIC_HOST1_3333}})

```
curl http://localhost:3333
```{{exec}}

it should look a bit more exciting:

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

Beautiful.

# The Crudest Flag
That `withCow`{{}} boolean and its accompanying conditional check is a very basic implementation of a *Feature Flag*. It lets us hide an experimental or unfinished feature, but also easily switch the feature on while we're building and testing it. 

But managing these flags by changing hardcoded constants gets old pretty fast. Teams that uses feature flags in any significant way soon reach for a feature flagging framework. We'll take a confident step in that direction next, by setting up the [OpenFeature](https://openfeature.dev) SDK...
