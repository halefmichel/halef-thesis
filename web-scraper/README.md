# Web Scraper

Project that contains a web scraper that extracts data from a website and saves it in a CSV file.
The code is extracting data from the [viva real](https://www.vivareal.com.br) website.

### Folder Structure

1. [resources](./resources) - This folder contains real estate listing data for apartments and houses from 2018 to 2021 in São Paulo districts. The [clean-data](./resources/clean-data) subfolder contains the final version used for regression analysis, while the [raw-data](./resources/raw-data) subfolder includes the original files extracted from listing websites using TypeScript code.

2. [src](./src) - Folder containing the main functions used to extract the data from the website.
<br><br>2.1. [rent](./src/rent) - are the entities that represent the data that will be extracted from the website
   for all the rent between 2018 and 2023.
<br><br>2.2. [sale](./src/sale) - are the entities that represent the data that will be extracted from the website
   for all the sales between 2018 and 2023.
<br><br>2.3. [utils](./src/util) - are the functions that are used to extract the data from the website.
