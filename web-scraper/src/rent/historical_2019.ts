import { readHtml } from '@/readHtml'
import ObjectsToCsv from 'objects-to-csv'
import { LogTimeUtil } from '@/util/logTimeUtil'
import { writeFile } from 'fs/promises'
import { resolve } from 'path'
import { getDataByYearRent } from '@/util/historical-urls'
import { formatDate } from '@/util/dateUtil'

/**
 * This function extracts data from a webpage and returns an array of objects containing property details.
 * It uses the Document object model of the webpage to select and extract the required data.
 * The function maps over each property container on the webpage, extracting details such as link, date, title, address, area, rooms, suite, bathrooms, garage, price, condo, and additional internal data.
 * The function also records the time of data extraction.
 *
 * @param {Document} document - The Document object model of the webpage.
 * @param {string} pageUrl - The URL of the webpage.
 * @returns {Promise<Array<Object>>} - A promise that resolves to an array of objects, each containing details of a property.
 */
async function extractData(document: Document, pageUrl: string) {
  const containers = Array.from(document.querySelectorAll('.property-card__container'))
  const createAt = new Date()
  return await Promise.all(containers.map(async (el) => {
    const details = Array.from(el.querySelectorAll('ul.property-card__details .property-card__detail-item')).map(item => item?.textContent?.trim().replace(/[\n\r\s\t]+/g, ' '))
    return {
      link: pageUrl,
      date: formatDate(pageUrl.replace(/\D/g, '')),
      title: el.querySelector('.property-card__carousel .carousel__item-wrapper:first-child img')?.getAttribute('alt'),
      address: el.querySelector('.property-card__address')?.textContent?.trim(),
      area: details.filter(item => item?.includes('Área'))[0]?.replace(/[^0-9-]/g, ''),
      rooms: details.filter(item => item?.includes('Quartos') || item?.includes('Quarto'))[0]?.replace(/[^0-9-]/g, ''),
      suite: details.filter(item => item?.includes('Suítes') || item?.includes('Suíte'))[0]?.replace(/[^0-9-]/g, ''),
      bathrooms: details.filter(item => item?.includes('Banheiros') || item?.includes('Banheiro'))[0]?.replace(/[^0-9-]/g, ''),
      garage: details.filter(item => item?.includes('Vagas') || item?.includes('Vaga'))[0]?.replace(/[^0-9-]/g, ''),
      price: el.querySelector('.property-card__price')?.textContent?.trim().replace(/\D/g, ''),
      condo: el.querySelector('.property-card__price-details--condo')?.textContent?.replace(/\D/g, '').trim(),
      ...await extractInternalData('https://web.archive.org' + el.querySelector('a.property-card__main-link')?.getAttribute('href')),
      createdAt: createAt.toISOString().split('.')[0].replace('T', '-'),
    }
  }))
}

/**
 * This function extracts internal data from a property listing webpage and returns an object containing the details.
 * It uses the Document object model of the webpage to select and extract the required data.
 * The function extracts details such as zone, district, and characteristics of the property.
 * If there is an error while extracting the data, the function will return an object with undefined values.
 *
 * @param {string} url - The URL of the property listing webpage.
 * @returns {Promise<Object>} - A promise that resolves to an object containing the internal details of a property.
 * @throws {Error} - Throws an error if there is an issue with reading the HTML of the webpage.
 */
async function extractInternalData(url: string) {
  try {
    const document = await readHtml(url)
    const path = Array.from(document.querySelectorAll('div > ol > li')).map(item => item.textContent?.trim())
    return {
      // condo: document.querySelector('span.price__list-value.condominium')?.textContent?.replace(/R\$|\s/g, '').trim(),
      // suite: document.querySelector('small')?.textContent?.trim(),
      zone: path.filter(item => item?.includes('Zona'))[0],
      district: path[path.findIndex(item => item?.includes('Zona')) + 1],
      characteristics: Array.from(document.querySelectorAll('ul.qt > li')).map(item => item.textContent?.trim()),
    }
  } catch (e) {
    // console.log(`error extracting data for ${url}`)
  }

  return {
    condo: undefined,
    suite: undefined,
    zone: undefined,
    district: undefined,
    characteristics: undefined,
  }
}

async function getData(url: string) {
  const dom = await readHtml(url)
  return await extractData(dom, url)
}


async function getAllData() {
  const urls = getDataByYearRent(2019)
  const data: any[] = []
  const errorPages: number[] = []
  for (const [index, url] of urls.entries()) {
    for (let i = 1; i < 8; i++) {
      const append = i > 1 ? `?pagina=${i}` : ''
      try {
        const logTimeUtil = new LogTimeUtil()
        data.push(...await getData(url + append))
        console.info(`Finished page ${index} - ${i} after ${logTimeUtil.getElapsedTime()} seconds`)
      } catch (e: any) {
        console.error('error processing data', e)
        errorPages.push(i)
      }
    }
  }

  await writeFile(resolve('./error_pages_rent.txt'), errorPages.toString(), { encoding: 'utf-8' })
  await new ObjectsToCsv(data).toDisk('./final_rent_2019.csv')
}

async function run() {
  const data = await extractInternalData('https://web.archive.org/web/20200101112349/https://www.vivareal.com.br/imovel/apartamento-2-quartos-santana-zona-norte-sao-paulo-com-garagem-90m2-venda-RS699753-id-2456657010/')
  console.log(data)
}

getAllData()
