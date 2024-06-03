# Instalar e carregar os pacotes necessários
install.packages("COVIDIBGE")
install.packages("rstudioapi")
library(COVIDIBGE)
library(dplyr)
library(rstudioapi)

# Carregar dados
dados <- get_covid(year = 2020, month = 5)
dados_tabela_completa <- dados$variables

# Filtrar dados
tabela_reduzida <- dados_tabela_completa %>% select(Ano, V1013, UF, CAPITAL, C013, C007, C007A, C007B, C007C, C007D)
pnad_covid_2020M5 <- tabela_reduzida %>% filter(UF == "São Paulo", CAPITAL == "Município de São Paulo (SP)")

# Abrir caixa de diálogo para selecionar a pasta Downloads
save_dir <- selectDirectory()

# Definir o nome do arquivo
file_name <- "pnad_covid_2020M5.csv"

# Combinar o caminho da pasta e o nome do arquivo
save_path <- file.path(save_dir, file_name)

# Exportar a tabela para o local escolhido
write.csv(pnad_continua_2020M5, save_path, row.names = FALSE)
