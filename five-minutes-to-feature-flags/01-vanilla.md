We're starting off with a "Hello, World" server, stored in `01_vanilla.js`. You can use the Editor tab (up at the top left of the terminal on the right) to view that file, or just click on the command below
to print the file out to the terminal:

```
cat ~/app/01_vanilla.js
```{{exec}}

*(yes, you can literally click that command above to have it run live in the terminal on the right!)*

This is pretty much the most basic express server you can imagine - a single endpoint at `/`{{}} that returns a plaintext `"Hello, world!"`{{}} response.

Start the server by clicking the command below:
```
node ~/app/01_vanilla.js
```{{exec}}

You should be informed of a `Server running at http://localhost:3333`.

Now you can [visit this actual running server in a browser]({{TRAFFIC_HOST1_3333}}) to see its output.

Alternatively you can be old-school and test its responses from the command line. Open a new terminal Tab (click `+`{{}} next to `Tab 1`{{}}) then click the following command:

```
curl http://localhost:3333
```{{exec}}

Either way, you should see a very vanilla `Hello, World!` response.

Let's see if we can make that response a bit more exciting...
