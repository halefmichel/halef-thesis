import { existsSync, mkdirSync } from 'fs'
import { readFile, writeFile } from 'fs/promises'
import { resolve } from 'path'
import { fetchPage } from '@/fetchPage'

/**
 * This function fetches HTML content from a webpage or from a cache.
 * If the cache folder doesn't exist, it creates it.
 * It then generates a path for the cache file based on the URL of the webpage.
 * If the cache file exists and the ignoreCache parameter is false, it reads the HTML content from the cache file.
 * If the cache file doesn't exist or the ignoreCache parameter is true, it fetches the HTML content from the webpage.
 * If the ignoreCache parameter is false and the HTML content was fetched from the webpage, it writes the HTML content to the cache file.
 * The function returns a promise that resolves to the HTML content of the webpage or undefined if the HTML content couldn't be fetched.
 *
 * @param {string} url - The URL of the webpage to fetch HTML content from.
 * @param {boolean} [ignoreCache=false] - A boolean indicating whether to ignore the cache and fetch the HTML content from the webpage.
 * @returns {Promise<string | undefined>} - A promise that resolves to the HTML content of the webpage or undefined if the HTML content couldn't be fetched.
 */
export async function fetchFromWebOrCache(url: string, ignoreCache = false): Promise<string | undefined> {
  // If the cache folder doesn't exist, create it
  if (!existsSync(resolve('./.cache'))) {
    mkdirSync('.cache')
  }

  const path = `./.cache/${Buffer.from(url, 'binary').toString('base64').replace(/[/+=]/gm, '')}.html`
  if (!ignoreCache && existsSync(resolve(path))) {
    return await readFile(resolve(path), { encoding: 'utf8' })
  }

  const htmlData = await fetchPage(url)
  if (!ignoreCache && htmlData) {
    await writeFile(resolve(path), htmlData, { encoding: 'utf8' })
  }

  return htmlData
}
