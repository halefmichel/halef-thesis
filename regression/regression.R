#install.packages(c("stargazer", "spatialreg", "flextable", "spdep", "corrr", "ggplot2", "ggcorrplot", "car", "HH", "gridExtra", "cowplot", "dplyr"))
library(spatialreg) #for spatial regression analysis
library(sf) #for spatial data manipulation
library(spdep) #for spatial dependence methods
library(corrr) #for exploring correlations
library(ggplot2) #for visualization
library(ggcorrplot) #for correlation plots
library(car) #for regression diagnostics
library(HH) #for additional statistical methods
library(dplyr) #for filter the data by year and remove outliers

# Reading the data frame
#data_rent <- read.csv("/resources/rent_2018_2021.csv", dec = ".", header = TRUE, sep = ",")
data_sell <- read.csv("/resources/sell_2018_2021.csv", dec = ".", header = TRUE, sep = ",")

# Factorizing the categorical variables
data_sell$gym <- as.factor(data_sell$gym)
data_sell$field_quadra <- as.factor(data_sell$field_quadra)
data_sell$elevator <- as.factor(data_sell$elevator)
data_sell$furnished <- as.factor(data_sell$furnished)
data_sell$swimming_pool <- as.factor(data_sell$swimming_pool)

# Formating date 
data_sell$date <- as.Date(data_sell$date, format = "%d/%m/%Y")

# Filtering the data by year to run the regression model for each year studied
data_sell_2018 <- filter(data_sell, year == 2018)
data_sell_2019 <- filter(data_sell, year == 2019)
data_sell_2020 <- filter(data_sell, year == 2020)
data_sell_2021 <- filter(data_sell, year == 2021)

# Set the final data that will be used in the model
data_sell_final <- data_sell_2021
print(nrow(data_sell))
print(nrow(data_sell_final))

# Fuction to remove outliers
remove_outliers <- function(df, column_name) {
  
  # Defining the DataFrame to be cleaned
  df_filtered <- df
  
  # Removing outliers from the DataFrame using the IQR method
  q1_preco_mes <- quantile(df$price_m2, 0.25, na.rm = TRUE)
  q3_preco_mes <- quantile(df$price_m2, 0.75, na.rm = TRUE)
  iqr_preco_mes <- q3_preco_mes - q1_preco_mes
  lower_bound_preco_mes <- q1_preco_mes - 1.5 * iqr_preco_mes
  upper_bound_preco_mes <- q3_preco_mes + 1.5 * iqr_preco_mes
  
  # Using the price per square meter as the reference for the filter
  df_filtered <- df_filtered[df_filtered$price_m2 >= lower_bound_preco_mes & df_filtered$price_m2 <= upper_bound_preco_mes,]
  
  return(df_filtered)
}

df_filtered <- remove_outliers(data_sell_final, "price_m2")
print(paste("Number of removed lines:", nrow(data_sell_final) - nrow(df_filtered)))
print(paste("Number of final rows:", nrow(df_filtered)))


# Import the commute matrix
commute_matrix <- read.csv("/Users/halefboukarim/Documents/halef-thesis/occupation/commute_matrix.csv", dec = ".", header = TRUE, sep = ",") %>% as.matrix()

# Normalize the data by dividing each row by the row sum to get the proportion of commuters
commute_matrix_normalized <- sweep(commute_matrix, 1, rowSums(commute_matrix), "/")


# Import the teleworkability index vector for each year and make it a numeric vector
teleworkability_index_2018 <- read.csv("/Users/halefboukarim/Documents/halef-thesis/occupation/teleworkability_district_SP_2018.csv", dec = ".", header = TRUE, sep = ",") %>%  as.matrix()
teleworkability_vector_2018 <- as.numeric(teleworkability_index_2018 [,6])
teleworkability_index_2019 <- read.csv("/Users/halefboukarim/Documents/halef-thesis/occupation/teleworkability_district_SP_2019.csv", dec = ".", header = TRUE, sep = ",") %>% as.matrix()
teleworkability_vector_2019 <- as.numeric(teleworkability_index_2019 [,6])
teleworkability_index_2020 <- read.csv("/Users/halefboukarim/Documents/halef-thesis/occupation/teleworkability_district_SP_2020.csv", dec = ".", header = TRUE, sep = ",") %>% as.matrix()
teleworkability_vector_2020 <- as.numeric(teleworkability_index_2020 [,6])
teleworkability_index_2021 <- read.csv("/Users/halefboukarim/Documents/halef-thesis/occupation/teleworkability_district_SP_2021.csv", dec = ".", header = TRUE, sep = ",") %>% as.matrix()
teleworkability_vector_2021 <- as.numeric(teleworkability_index_2021 [,6])

spatial_lag_teleworkability_2018 <- commute_matrix_normalized %*% teleworkability_vector_2018
spatial_lag_teleworkability_2019 <- commute_matrix_normalized %*% teleworkability_vector_2019
spatial_lag_teleworkability_2020 <- commute_matrix_normalized %*% teleworkability_vector_2020
spatial_lag_teleworkability_2021 <- commute_matrix_normalized %*% teleworkability_vector_2021

teleworkability_index_2018_first_collunm <- as.data.frame(teleworkability_index_2018 [,c(1,3)])
teleworkability_index_2018_matrix <- cbind(teleworkability_index_2018_first_collunm, spatial_lag_teleworkability_2018)
colnames(teleworkability_index_2018_matrix) <- c("ID", "year", "teleworkability_adj")
teleworkability_index_2019_first_collunm <- as.data.frame(teleworkability_index_2019 [,c(1,3)])
teleworkability_index_2019_matrix <- cbind(teleworkability_index_2019_first_collunm, spatial_lag_teleworkability_2019)
colnames(teleworkability_index_2019_matrix) <- c("ID", "year", "teleworkability_adj")
teleworkability_index_2020_first_collunm <- as.data.frame(teleworkability_index_2020 [,c(1,3)])
teleworkability_index_2020_matrix <- cbind(teleworkability_index_2020_first_collunm, spatial_lag_teleworkability_2020)
colnames(teleworkability_index_2020_matrix) <- c("ID", "year", "teleworkability_adj")
teleworkability_index_2021_first_collunm <- as.data.frame(teleworkability_index_2021 [,c(1,3)])
teleworkability_index_2021_matrix <- cbind(teleworkability_index_2021_first_collunm, spatial_lag_teleworkability_2021)
colnames(teleworkability_index_2021_matrix) <- c("ID", "year", "teleworkability_adj")

teleworkability_adj_matrix <- rbind(teleworkability_index_2018_matrix, teleworkability_index_2019_matrix, teleworkability_index_2020_matrix, teleworkability_index_2021_matrix)
teleworkability_adj_matrix <- as.data.frame(teleworkability_adj_matrix)

df_filtered$ID <- as.integer(df_filtered$ID)
teleworkability_adj_matrix$ID <- as.integer(teleworkability_adj_matrix$ID)
df_filtered$year <- as.integer(df_filtered$year)
teleworkability_adj_matrix$year <- as.integer(teleworkability_adj_matrix$year)
df_filtered <- left_join(df_filtered, teleworkability_adj_matrix, by = c("ID", "year"))

# Select and ensure all columns are numeric
corr_data <- df_filtered[, (names(df_filtered) %in% c("price_m2", "area_m2", "bedrooms", "bathrooms","teleworkability_adj", "metro_dist_km", "delta_cbd_farialima", "inequality_meter", "garage", "avg_salario_medio" ))]

# Convert all columns to numeric
corr_data <- data.frame(lapply(corr_data, function(x) as.numeric(as.character(x))))

# Compute correlation at 2 decimal places
corr_matrix <- round(cor(corr_data, use = "complete.obs"), 2)
ggcorrplot(corr_matrix, hc.order = TRUE, type = "lower", lab = TRUE)

summary(df_filtered)

params <- (log(price_real_month) ~ teleworkability_adj +
             area_m2 +
             bedrooms +
             bathrooms + 
             metro_dist_km +
             delta_cbd_farialima +
             inequality_meter +
             avg_salario_medio)

#data_sell_final_2018 <- filter(data_sell_final, year(date) == 2018)
reg_OLS <- lm(params, data = df_filtered)

summary(reg_OLS)

# Load necessary packages
if (!requireNamespace("nortest", quietly = TRUE)) {
  install.packages("nortest")
}
if (!requireNamespace("lmtest", quietly = TRUE)) {
  install.packages("lmtest")
}
library(nortest)
library(lmtest)

# Perform Shapiro-Wilk test or Anderson-Darling test based on sample size
residuals_best_model <- resid(reg_OLS)
sample_size <- length(residuals_best_model)

if (sample_size >= 3 && sample_size <= 5000) {
  shapiro_test <- shapiro.test(residuals_best_model)
  print(shapiro_test)
  if (shapiro_test$p.value > 0.05) {
    print("Pass: Residuals are normally distributed (fail to reject H0).")
  } else {
    print("Fail: Residuals are not normally distributed (reject H0).")
  }
} else {
  ad_test <- ad.test(residuals_best_model)
  print(ad_test)
  if (ad_test$p.value > 0.05) {
    print("Pass: Residuals are normally distributed (fail to reject H0).")
  } else {
    print("Fail: Residuals are not normally distributed (reject H0).")
  }
}

# Perform Breusch-Pagan test for heteroskedasticity
bp_test <- bptest(reg_OLS)
print(bp_test)
if (bp_test$p.value < 0.05) {
  print("Fail: Heteroskedasticity detected (reject H0).")
} else {
  print("Pass: No heteroskedasticity detected (fail to reject H0).")
}

# Perform Durbin-Watson test for autocorrelation
dw_test <- dwtest(reg_OLS)
print(dw_test)
dw_stat <- dw_test$statistic
if (dw_stat < 1.5) {
  print("Fail: Positive autocorrelation detected.")
} else if (dw_stat > 2.5) {
  print("Fail: Negative autocorrelation detected.")
} else {
  print("Pass: No autocorrelation detected.")
}

# Calcule os resíduos do modelo
residuals <- residuals(reg_OLS)

# Para calcular Moran's I, precisamos de uma matriz de vizinhança (exemplo com vizinhos mais próximos)
coords <- as.matrix(df_filtered[,c("longitude", "latitude")])
nb <- knn2nb(knearneigh(coords, k=3))
listw <- nb2listw(nb, style="W")

# Teste de Moran's I
moran.mc(df_filtered$price_real_month, listw, nsim=999)

lm.morantest(reg_OLS, listw)


caminho_do_arquivo <- "/Users/halefboukarim/Desktop/df_filtered.csv"
write.csv(df_filtered, file = caminho_do_arquivo, row.names = FALSE)


# Testes RS para especificação do modelo espacial
rs_tests <- lm.RStests(reg_OLS, listw, test=c("all"))
print(rs_tests)

# SAR e SE
#reg_error <- errorsarlm(params, data = df_filtered, listw = listw)
#summary(reg_error)

#reg_lag <- lagsarlm(params, data = df_filtered, listw = listw)
#summary(reg_lag)

reg_durbin <- lagsarlm(params, data = df_filtered, listw = listw, type = "Durbin")
summary(reg_durbin)


