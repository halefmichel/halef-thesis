import axios, {AxiosError} from 'axios'
import {setTimeout} from 'timers/promises'

/**
 * This function fetches a webpage and returns its HTML content as a string.
 * If the server responds with a 429 status (Too Many Requests), the function will wait for 15 seconds and then retry the request.
 * The function will retry up to 3 times before throwing an error.
 *
 * @param {string} url - The URL of the webpage to fetch.
 * @param {number} [retry=3] - The number of times to retry the request if a 429 status is received.
 * @returns {Promise<string | undefined>} - A promise that resolves to the HTML content of the webpage as a string, or undefined if the request fails.
 * @throws {Error} - Throws an error if the request fails after the specified number of retries.
 */
export async function fetchPage(url: string, retry: number = 3): Promise<string | undefined> {
    try {
        const html = await axios.get(url)
        return html.data
    } catch (e: any) {
        const error = e as AxiosError
        // console.error(`There was an error with ${error.config?.url}.`)
        if (error.response?.status === 429 && retry) {
            console.log('Waiting 15s to continue...')
            await setTimeout(15000)

            return await fetchPage(url, retry - 1)
        }
        // console.log(`Failed to extract the data for url ${url} after ${retry} retries`)
        throw new Error(error.message)
    }
}
