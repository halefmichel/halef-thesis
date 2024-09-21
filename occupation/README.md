# Occupation

A project containing data on socio-demographic indicators.

### Folder structure

1. [pnadc-cod](./occupation/pnadc-cod) - This folder contains information on the PNAD Contínua (a Brazilian survey that continuously gathers socio-economic and demographic data), divided into two subfolders: one for codes, labeled `pnad-cod-code`, which originated the files located in the other subfolder, `pnad-cod-data`. The acronym COD refers to the _Classificação de Ocupações para Pesquisas Domiciliares_, a classification used in the PNAD.
<br><br>1.1 [R-code](./occupation/pnadc-cod/pnadc-cod-code/R-code) - This folder contains the R script, `pnad_continua.R`, which extracts microdata from the government's repository on the PNAD Contínua.
<br><br>1.2 [sql-code](./occupation/pnadc-cod/pnadc-cod-code/sql-code) - This folder contains the SQL code detailing the logic for calculating the adjusted teleworkability indicator for districts in São Paulo from 2018 to 2021, following the Barbosa Filho methodology.

2. [rais-cbo](./occupation/rais-cbo) - This folder contains information from the RAIS (Annual Social Information Report), including data from Brazil's Ministry of Labor on employment, wages, and working conditions for the years 2018 to 2021. The RAIS uses the CBO (Brazilian Classification of Occupations) as the basis for its data.
<br><br>2.1 [rais-cbo-code/sql-code](./occupation/rais-cbo/rais-cbo-code/sql-code) - This folder contains the SQL code that details the logic for calculating the teleworkability indicator for districts in São Paulo from 2018 to 2021, based on Dingel and Neiman methodology.
<br><br>2.2 [rais-cbo-data](./occupation/rais-cbo/rais-cbo-data) - This folder contains files generated from SQL code, featuring various groupings of districts and dates related to occupations.

3. Files
-  [final_translator](./occupation/rais-cbo/final_translator.csv) - 
- [commute_matrix](./occupation/rais-cbo/final_translator.csv) - 