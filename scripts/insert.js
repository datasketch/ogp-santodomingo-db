require('dotenv').config()

const knex = require('knex')({
  client: 'pg',
  connection: {
    host: process.env.POSTGRES_HOST,
    port: 5432,
    user: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: 'sd_plantas'
  }
})

const plantsJSON = require('../data/plantas.json')
const developingPlantsJSON = require('../data/plantas_en_desarrollo.json')
const ordersManagementJSON = require('../data/gestion_pedidos.json')
const orderDetailsJSON = require('../data/detalle_pedidos.json')

async function run () {
  await knex.insert(plantsJSON).into('plantas')
  await knex.insert(developingPlantsJSON).into('plantas_en_desarrollo')
  await knex.insert(ordersManagementJSON).into('pedidos')
  await knex.insert(orderDetailsJSON).into('detalle_pedidos')
}

run()
  .then(() => {
    process.exit(0)
  })
  .catch(err => {
    console.error(err)
    process.exit(1)
  })
