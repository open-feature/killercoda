import express from 'express'
import Router from 'express-promise-router'

const app = express()
const routes = Router();
app.use(routes);

routes.get('/', async (req, res) => {
  res.send("Hello, world!")
})

app.listen(3333)

console.log("Server running on port 3333")