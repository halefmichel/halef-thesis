# Load necessary libraries
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(cowplot)
library(ggcorrplot)
library(dplyr)
library(car)

# Carregar os dados
data <- read.csv("./resources/clean-data/rent_2018_2023.csv", dec = ",", header = TRUE, sep = ";")

# Converter fatores em variáveis dummy
data$gym <- as.numeric(as.character(data$gym))
data$field_quadra <- as.numeric(as.character(data$field_quadra))
data$elevator <- as.numeric(as.character(data$elevator))
data$furnished <- as.numeric(as.character(data$furnished))
data$swimming_pool <- as.numeric(as.character(data$swimming_pool))

# Convertendo a data para o formato Date
data$date <- as.Date(data$date, format = "%d/%m/%Y")

# Função para aplicar transformações e calcular o modelo de regressão
calculate_best_model <- function(data, dependent_var, independent_vars, transformations) {
  best_r2 <- -Inf
  best_model <- NULL
  best_combination <- NULL
  list_r2 <- NULL

  # Gerar todas as combinações de transformações para todas as variáveis independentes
  trans_combinations <- expand.grid(rep(list(transformations), length(independent_vars)))
  colnames(trans_combinations) <- independent_vars

  for (trans_row in seq_len(nrow(trans_combinations))) {
    transformed_data <- data
    formula_parts <- c(dependent_var, "~")
    for (var in independent_vars) {
      trans <- trans_combinations[trans_row, var]
      transformed_var <- switch(as.character(trans),
                                "X" = data[[var]],
                                "1_X" = 1 / data[[var]],
                                "LnX" = log(data[[var]]),
                                "X__2" = data[[var]]^2,
                                "X__1_2" = sqrt(data[[var]]),
                                "1_X__2" = 1 / (data[[var]]^2),
                                "1_X__1_2" = 1 / sqrt(data[[var]]))
      trans_name <- paste(var, trans, sep = "_")
      transformed_data[[trans_name]] <- transformed_var
      formula_parts <- c(formula_parts, trans_name)
    }

    formula_string <- paste(paste(formula_parts, collapse = " + "), " + garage + condo_real + gym + field_quadra + elevator + furnished + swimming_pool")
    formula_string <- gsub(" \\+ ~ \\+ ", " ~ ", formula_string)  # Corrigir formatação da fórmula
    formula <- as.formula(formula_string)
    model <- lm(formula, data = transformed_data)

    r2 <- summary(model)$r.squared
    list_r2 <- append(list_r2, r2)

    if (r2 > best_r2) {
      best_r2 <- r2
      best_model <- model
      best_combination <- list(variables = independent_vars, transformations = as.list(trans_combinations[trans_row,]))
    }
  }
  return(list(best_model = best_model, best_combination = best_combination, best_r2 = best_r2, list_r2 = list_r2))
}

# Definindo as variáveis e transformações
data$price_m2 <- log(data$price_m2)
dependent_var <- "price_m2"
independent_vars <- c("area_m2", "bedrooms", "metro_dist_km", "delta_cbd_farialima", "idh")
transformations <- c("X", "1_X", "LnX", "X__2", "X__1_2", "1_X__2", "1_X__1_2")

# Calculando o melhor modelo
params <- (price_m2 ~ area_m2 +
  suite +
  bathrooms +
  garage +
  condo_real +
  metro_dist_km +
  delta_cbd_farialima +
  idh +
  gym +
  field_quadra +
  elevator +
  furnished +
  swimming_pool)
outliers <- outlierTest(lm(params, data = data), cutoff = 100, n.max = Inf)
outlier_rows <- as.numeric(names(outliers$rstudent))
data_wo_outliers <- data[-outlier_rows,]
results <- calculate_best_model(data_wo_outliers, dependent_var, independent_vars, transformations)

# Imprimindo o resumo do melhor modelo
if (!is.null(results$best_model)) {
  print(summary(results$best_model))
} else {
  cat("Nenhum modelo válido encontrado.\n")
}
