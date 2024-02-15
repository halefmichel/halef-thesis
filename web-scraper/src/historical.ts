import {readHtml} from '@/readHtml'
import ObjectsToCsv from 'objects-to-csv'
import {LogTimeUtil} from '@/util/logTimeUtil'
import {writeFile} from 'fs/promises'
import {resolve} from 'path'
import {getDataByYear} from '@/util/historical-urls'

/**
 * This function extracts data from a webpage and returns an array of objects containing property details.
 * It uses the Document object model of the webpage to select and extract the required data.
 * The function maps over each property container on the webpage, extracting details such as link, title, address, area, rooms, bathrooms, garage, price, and additional internal data.
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
        const details = Array.from(el.querySelectorAll('ul.property-card__details .property-card__detail-item'))
        return {
            link: pageUrl,
            title: el.querySelector('.property-card__carousel .carousel__item-wrapper:first-child img')?.getAttribute('alt'),
            address: el.querySelector(".property-card__address")?.textContent?.trim(),
            area: details[0]?.querySelector('.js-property-card-value')?.textContent?.trim(),
            rooms: details[1]?.querySelector('.js-property-card-value')?.textContent?.trim(),
            bathrooms: details[2]?.querySelector('.js-property-card-value')?.textContent?.trim(),
            garage: details[3]?.querySelector('.js-property-card-value')?.textContent?.trim(),
            price: el.querySelector('.property-card__price')?.textContent?.trim().replace(/R\$|\s/g, ''),
            ...await extractInternalData('https://web.archive.org' + el.querySelector('a.property-card__main-link')?.getAttribute('href')),
            createdAt: createAt.toISOString().split('.')[0].replace('T', '-'),
        }
    }))
}

/**
 * This function extracts internal data from a property listing webpage and returns an object containing the details.
 * It uses the Document object model of the webpage to select and extract the required data.
 * The function extracts details such as condominium price, suite details, zone, district, and characteristics of the property.
 * If there is an error while extracting the data, the function will return an object with undefined values.
 *
 * @param {string} url - The URL of the property listing webpage.
 * @returns {Promise<Object>} - A promise that resolves to an object containing the internal details of a property.
 * @throws {Error} - Throws an error if there is an issue with reading the HTML of the webpage.
 */
async function extractInternalData(url: string) {
    try {
        const document = await readHtml(url)
        return {
            condo: document.querySelector('span.price__list-value.condominium')?.textContent?.replace(/R\$|\s/g, '').trim(),
            suite: document.querySelector('small')?.textContent?.trim(),
            zone: Array.from(document.querySelectorAll('.breadcrumb__item-name')).map(item => item.textContent?.trim())[4],
            district: Array.from(document.querySelectorAll('.breadcrumb__item-name')).map(item => item.textContent?.trim())[5],
            characteristics: Array.from(document.querySelectorAll('ul.amenities__list li')).map(item => item.textContent?.trim()),
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
 * This function extracts internal data from a property listing webpage and returns an object containing the details.
 * It uses the Document object model of the webpage to select and extract the required data.
 * The function extracts details such as condominium price, suite details, zone, district, and characteristics of the property.
 * If there is an error while extracting the data, the function will return an object with undefined values.
 *
 * @param {string} url - The URL of the property listing webpage.
 * @returns {Promise<Object>} - A promise that resolves to an object containing the internal details of a property.
 * @throws {Error} - Throws an error if there is an issue with reading the HTML of the webpage.
 */
async function getData(url: string) {
    const dom = await readHtml(url)
    return await extractData(dom, url)
}


/**
 * This function fetches all data from a list of URLs for a given year.
 * It uses the getData function to fetch and extract data from each URL.
 * The function iterates over each URL and fetches data from up to seven pages of listings.
 * If there is an error while fetching data from a page, the page number is added to an array of error pages.
 * After all data has been fetched,
 * the function writes the array of error pages to a text file and the array of data to a CSV file.
 *
 * @async
 * @function
 * @returns {Promise<void>} - A promise that resolves when all data has been fetched and written to files.
 * @throws {Error} - Throws an error if there is an issue with writing to the files.
 */
async function getAllData() {
    const urls = getDataByYear(2019)
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

    await writeFile(resolve('./error_pages.txt'), errorPages.toString(), {encoding: 'utf-8'})
    await new ObjectsToCsv(data).toDisk('./final.csv')
}

async function run() {
    const data = await extractInternalData('https://web.archive.org/web/20200101112349/https://www.vivareal.com.br/imovel/apartamento-2-quartos-santana-zona-norte-sao-paulo-com-garagem-90m2-venda-RS699753-id-2456657010/')
    console.log(data)
}

getAllData()
