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

  const plantsNormalized = plants.data.map(plant => ({
    ...plant,
    id: plants.ids[plant.id]
  }))

  console.log('Plantas ✅')

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

  console.log('Plantas en desarrollo ✅')

  const ordersManagementRecords = await base('tblgryeiOTYelYT6E').select({ view: 'Archivo de pedidos' }).all()

  const ordersManagement = ordersManagementRecords.reduce((result, record, index) => {
    const { fields, id } = record
    return {
      // This map id to a number
      ids: { ...result.ids, [id]: index + 1 },
      data: [
        ...result.data,
        {
          id,
          Orden: fields.Orden,
          Estado: fields.Estado,
          Fecha: fields.Fecha,
          Año: fields['Año'],
          'Nombre beneficiario': fields['Nombre Beneficiario'],
          Parroquia: fields.Parroquia,
          Cantón: fields['Cantón'],
          Teléfono: fields['Teléfono'],
          'Dirección / Sector': fields['Dirección/Sector'],
          Cédula: fields['Cédula'],
          'Subsidio o venta': fields['Subsidio o venta'],
          Ubicación: fields['Ubicación'],
          Colaboradores: fields.Colaboradores,
          'Supervivencia individuos': fields['Supervivencia individuos'],
          'Fecha medición': fields['Fecha medición'],
          Actor: fields.Actor
        }
      ]
    }
  }, { ids: {}, data: [] })

  const ordersNormalized = ordersManagement.data.map(order => ({
    ...order,
    id: ordersManagement.ids[order.id]
  }))

  console.log('Pedidos ✅')

  const ordersDetailsRecords = await base('tbl3CzcZuCBWE7utX').select({ view: 'Detalle Pedidos' }).all()

  const ordersDetails = ordersDetailsRecords.map(record => {
    const { fields } = record
    const orderMatched = ordersManagement.data.find(order => order.id === fields.Orden[0])
    const plantMatched = plants.data.find(plant => plant.id === fields.Plantas[0])

    const orderId = ordersManagement.ids[orderMatched.id]
    const plantId = plants.ids[plantMatched.id]

    return {
      Cantidad: fields.Cantidad || 0,
      Pedido: orderId,
      Planta: plantId
    }
  })

  console.log('Detalle pedidos ✅')

  await fs.writeFile(path.join(dataFolder, 'plantas.json'), JSON.stringify(plantsNormalized))
  await fs.writeFile(path.join(dataFolder, 'plantas_en_desarrollo.json'), JSON.stringify(developingPlants))
  await fs.writeFile(path.join(dataFolder, 'gestion_pedidos.json'), JSON.stringify(ordersNormalized))
  await fs.writeFile(path.join(dataFolder, 'detalle_pedidos.json'), JSON.stringify(ordersDetails))
}

run().catch(err => {
  console.error(err)
  process.exit(1)
})
