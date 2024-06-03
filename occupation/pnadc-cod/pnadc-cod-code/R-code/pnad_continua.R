# Instalar e carregar os pacotes necessários
install.packages("PNADcIBGE")
install.packages("rstudioapi")
library(PNADcIBGE)
library(dplyr)
library(rstudioapi)

# Carregar dados
dados <- get_pnadc(year = 2022, interview = 1)
dados_tabela_completa <- dados$variables

# Filtrar dados
tabela_reduzida <- dados_tabela_completa %>% select(Ano, Trimestre, UF, Capital, S01015, S01028, S01029, V4010)
pnad_continua_2022I1 <- tabela_reduzida %>% filter(UF == "São Paulo", Capital == "Município de São Paulo (SP)")

# Abrir caixa de diálogo para selecionar a pasta Downloads
save_dir <- selectDirectory()

# Definir o nome do arquivo
file_name <- "pnad_continua_2022I1.csv"

# Combinar o caminho da pasta e o nome do arquivo
save_path <- file.path(save_dir, file_name)

# Exportar a tabela para o local escolhido
write.csv(pnad_continua_2022I1, save_path, row.names = FALSE)
