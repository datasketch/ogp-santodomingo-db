require('dotenv').config()

const path = require('path')
const fs = require('fs/promises')
const Airtable = require('airtable')

Airtable.configure({
  endpointUrl: 'https://api.airtable.com',
  apiKey: process.env.AIRTABLE_API_KEY
})

const dataFolder = path.resolve(__dirname, '..', 'data')
const base = Airtable.base(process.env.AIRTABLE_BASE_ID)

async function run () {
  const plantsRecords = await base('tbl6RnEeYIndxlcjn').select({ view: 'Plantas' }).all()

  const plants = plantsRecords.reduce((result, record, index) => {
    const { fields, id } = record
    return {
      // This map id to a number
      ids: { ...result.ids, [id]: index + 1 },
      data: [
        ...result.data,
        {
          id,
          Planta: fields['ID Plantas'],
          Tipo: fields.Tipo,
          Contenedor: fields['Tipo contenedor (funda o tubete)']
        }
      ]
    }
  }, { ids: {}, data: [] })

  const developingPlantsRecords = await base('tblrIJTtweCz5X41Y').select({
    view: 'Ordenes de compra'
  }).all()

  const developingPlants = developingPlantsRecords.map(record => {
    const { fields } = record
    const plantMatched = plants.data.find(plant => plant.id === fields.Planta[0])
    const plantId = plants.ids[plantMatched.id]
    return {
      Orden: fields['# Orden'],
      'Estado vivero': fields['Estado Vivero'],
      Cantidad: fields.Cantidad,
      'Fecha transplante': fields['Fecha Trasplante'],
      'Fecha de entrega': fields['Fecha de entrega'],
      Planta: plantId
    }
  })

  const plantsNormalized = plants.data.map(plant => ({
    ...plant,
    id: plants.ids[plant.id]
  }))

  await fs.writeFile(path.join(dataFolder, 'plantas.json'), JSON.stringify(plantsNormalized))
  await fs.writeFile(path.join(dataFolder, 'plantas_en_desarrollo.json'), JSON.stringify(developingPlants))
}

run().catch(err => {
  console.error(err)
  process.exit(1)
})
