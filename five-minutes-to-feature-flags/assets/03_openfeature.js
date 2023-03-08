import express from 'express'
import Router from 'express-promise-router'
import cowsay from 'cowsay'
import { OpenFeature } from '@openfeature/js-sdk'

const app = express()
const routes = Router();
app.use(routes);

const featureFlags = OpenFeature.getClient()

routes.get('/', async (req, res) => {
  const withCows = await featureFlags.getBooleanValue('with-cows', false)
  if(withCows){
    res.send(cowsay.say({text:'Hello, world!'}))
  }else{
    res.send("Hello, world!")
  }
})

app.listen(3333)

console.log("Server running on port 3333")