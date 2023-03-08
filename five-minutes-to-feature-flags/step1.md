Here's the service we'll be working on:js

```
cat ~/app/01_vanilla.js
```{{exec}}

Pretty much the most basic express server you can imagine - a single endpoint at `/`{{}} that returns a plaintext `"Hello, world!"`{{}} response.

Start the server:
```
node ~/app/01_vanilla.js
```{{exec}}

[Open the page in a browser]({{TRAFFIC_HOST1_3333}}) and / or open a new terminal Tab (click `+`{{}} next to `Tab 1`{{}}).

We can test that is works:

```
curl http://localhost:3333
```{{exec}}

## With cows, please
Let's imagine that we're adding a new, experimental feature to this hello world service. We're going to upgrade the format of the server's response, using cowsay!

However, we're not 100% sure that this cowsay formatting is going to work out, so for now we'll protect it behind a conditional:

```
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

See the entire code:

```
cat ~/app/02_basic_flags.js
```{{exec interrupt}}

Flick back to tab 1 and try out the new code:

```
node ~/app/02_basic_flags.js
```{{exec interrupt}}

Back to tab 2 to re-curl the server:

```
curl http://localhost:3333
```{{exec}}

No difference? Good. By default, our service continues to work exactly as it did before, but if we change `withCow`{{}} to `true`{{}} then our response comes in an exciting new format:

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

Open the editor and inside the `app`{{}} folder, open `02_basic_flags.js`{{}}.

Change `false`{{}} on line `12`{{}} to `true`

Flick over again to tab 1 and restart the server:

```
node ~/app/02_basic_flags.js
```{{exec interrupt}}

Flick back to tab 2 and curl the endpoint. You should see the new `cowsay`{{}} output:
```
curl http://localhost:3333
```{{exec}}

# The Crudest Flag
That `withCow`{{}} boolean and its accompanying conditional check are a very basic feature flag - they let us hide an experimental or unfinished feature, but also easily switch the feature on while we're building and testing it.