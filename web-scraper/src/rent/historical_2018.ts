import { readHtml } from '@/readHtml'
import ObjectsToCsv from 'objects-to-csv'
import { LogTimeUtil } from '@/util/logTimeUtil'
import { writeFile } from 'fs/promises'
import { resolve } from 'path'
import { formatDate } from '@/util/dateUtil'
import { getDataByYearRent } from '@/util/historical-urls'


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
  const containers = Array.from(document.querySelectorAll('div.kG > div'))
  const createAt = new Date()
  return await Promise.all(containers.map(async (el) => {
    const details = Array.from(el.querySelectorAll('ul.cO > li')).map(item => item.textContent)
    return {
      link: pageUrl,
      date: formatDate(pageUrl.replace(/\D/g, '')),
      title: el.querySelector('.cK > a')?.textContent?.trim(),
      address: el.querySelector('.cM')?.textContent?.trim(),
      area: details.filter(item => item?.includes('Área'))[0]?.replace(/[^0-9-]/g, ''),
      rooms: details.filter(item => item?.includes('Quartos') || item?.includes('Quarto'))[0]?.replace(/[^0-9-]/g, ''),
      suite: details.filter(item => item?.includes('Suítes') || item?.includes('Suíte'))[0]?.replace(/[^0-9-]/g, ''),
      bathrooms: details.filter(item => item?.includes('Banheiros') || item?.includes('Banheiro'))[0]?.replace(/[^0-9-]/g, ''),
      garage: details.filter(item => item?.includes('Vagas') || item?.includes('Vaga'))[0]?.replace(/[^0-9-]/g, ''),
      price: el.querySelector('.cI')?.textContent?.trim().replace(/\D/g, ''),
      condo: el.querySelector('.js-condo-price')?.textContent?.trim().replace(/\D/g, ''),
      ...await extractInternalData('https://web.archive.org' + el.querySelector('.cK > a')?.getAttribute('href')),
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
    const path = Array.from(document.querySelectorAll('.kU > li')).map(item => item.textContent?.trim())
    return {
      zone: path.filter(item => item?.includes('Zona'))[0],
      district: path[path.findIndex(item => item?.includes('Zona')) + 1],
      characteristics: Array.from(document.querySelectorAll('ul.bS > li')).map(item => item.textContent?.trim()).filter(item => item != ''),
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

/**
 * This function fetches the HTML content of a webpage and extracts data from it.
 * It uses the readHtml function to fetch the HTML content and the extractData function to extract the data.
 * The function returns a promise that resolves to an array of objects, each containing details of a property.
 *
 * @param {string} url - The URL of the webpage to fetch and extract data from.
 * @returns {Promise<Array<Object>>} - A promise that resolves to an array of objects, each containing details of a property.
 */
async function getData(url: string) {
  const dom = await readHtml(url)
  return await extractData(dom, url)
}

/**
 * This function fetches all data from a list of URLs for a given year.
 * It uses the getData function to fetch and extract data from each URL.
 * The function iterates over each URL and fetches data from up to 7 pages of listings.
 * If there is an error while fetching data from a page, the page number is added to an array of error pages.
 * After all data has been fetched, the function writes the array of error pages to a text file and the array of data to a CSV file.
 *
 * @async
 * @function
 * @returns {Promise<void>} - A promise that resolves when all data has been fetched and written to files.
 * @throws {Error} - Throws an error if there is an issue with writing to the files.
 */
async function getAllData() {
  const urls = getDataByYearRent(2018)
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

  await writeFile(resolve('./error_pages_rent_2018.txt'), errorPages.toString(), { encoding: 'utf-8' })
  await new ObjectsToCsv(data).toDisk('./final_rent_2018.csv')
}

getAllData()
