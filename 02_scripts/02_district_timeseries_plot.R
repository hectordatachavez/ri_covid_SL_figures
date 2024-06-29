# set-up ----------
library(ggtext)
library(readxl)
library(dplyr)
library(tidyr)
library(patchwork)
library(ggplot2)
library(ggnewscale)
library(purrr)
library(stringr)

# load data ----------
# annual coverage rates - national level
data_districts <- read_excel("./01_data/data.xlsx", sheet = 2)

# Load functions ----------
source("./03_functions/functions.R")

# Pre-processing ------------
districts_levels <- stringr::str_sort(unique(data_districts$district), decreasing = F)

# Creating a vector of letters "(a)" to "(p)"
letters_vector <- sprintf("(%s)", letters[1:length(districts_levels)])

# Gluing district names with corresponding letters
result_vector <- as.character(glue::glue("{letters_vector} {districts_levels}"))

# data formatting
data_districts_long <- data_districts %>%
  mutate(district = stringr::str_squish(district),
         change_cov = `2022` - `2019`,
         key = case_when(change_cov > 0 ~ "'#0571b0'",
                         change_cov < 0 ~ "'#ca0020'",
                         change_cov == 0 ~ "'#000000'"
         )) %>%
  pivot_longer(contains("20")) %>%
  mutate(name = factor(name,
                       levels = (c("2019", "2020",
                                   "2021", "2022")),
                       ordered = T),
         district = factor(district,
                           levels = (districts_levels),
                           ordered = T))


## plot matrix of time series:

## BCG plot  ---------
plot_list_bcg <- map(districts_levels, ~plot_district(antigen_name = "BCG", district_name = .x))

plots_matrix_bcg <- reduce(plot_list_bcg, `+`)

plots_matrix_bcg <- wrap_plots(plots_matrix_bcg)

plots_matrix_bcg +
  patchwork::plot_layout(axes = "collect") +
  plot_annotation(
    title = "BCG Annual Coverage Rate in Sierra Leone Districts",
    subtitle = "Trends colored by <span style = 'color:#436685;'>**increase**</span> or <span style = 'color:#BF2F24;'>**decrease**</span> over 2019 coverage rate<br>",
    theme = theme(plot.title = element_markdown(size = 15, face = "bold"),
                  plot.subtitle = element_markdown(size = 12))
  )

# export
ggsave(filename = paste("./04_output/bcg_districts_combined_print_170x170mm_panels.jpeg", sep = ""),
       width = 170, #8*3 inches
       height = 200, # 14
       units = "mm",
       dpi = 300,
       device = 'jpeg')




## MR1 plot  ---------
plot_list_mr1 <- map(districts_levels, ~plot_district(antigen_name = "Measles-rubella 1",
                                                      district_name = .x))
plots_matrix_mr1 <- reduce(plot_list_mr1, `+`)

plots_matrix_mr1 <- wrap_plots(plots_matrix_mr1)

plots_matrix_mr1 +
  patchwork::plot_layout(axes = "collect") +
  plot_annotation(
    title = "Measles-rubella 1 Annual Coverage Rate in Sierra Leone Districts",
    subtitle = "Trends colored by <span style = 'color:#436685;'>**increase**</span> or <span style = 'color:#BF2F24;'>**decrease**</span> over 2019 coverage rate<br>",
    theme = theme(plot.title = element_markdown(size = 15, face = "bold"),
                  plot.subtitle = element_markdown(size = 12))
  )

# export it as png
ggsave(filename = paste("./04_output/mr1_districts_combined_print_170x170mm_panels.jpeg", sep = ""),
       width = 170, #8*3 inches
       height = 200, # 14
       units = "mm",
       dpi = 300,
       device = 'jpeg')


## Penta 1 plot  ---------
plot_list_p1 <- map(districts_levels, ~plot_district(antigen_name = "Penta 1",
                                                     district_name = .x))
plots_matrix_p1 <- reduce(plot_list_p1, `+`)

plots_matrix_p1 <- wrap_plots(plots_matrix_p1)

plots_matrix_p1 +
  patchwork::plot_layout(axes = "collect") +
  plot_annotation(
    title = "Pentavalent 1 Annual Coverage Rate in Sierra Leone Districts",
    subtitle = "Trends colored by <span style = 'color:#436685;'>**increase**</span> or <span style = 'color:#BF2F24;'>**decrease**</span> over 2019 coverage rate<br>",
    theme = theme(plot.title = element_markdown(size = 15, face = "bold"),
                  plot.subtitle = element_markdown(size = 12))
  )

# export it as png
ggsave(filename = paste("./04_output/penta1_districts_combined_print_170x170mm_panels.jpeg", sep = ""),
       width = 170, #8*3 inches
       height = 200, # 14
       units = "mm",
       dpi = 300,
       device = 'jpeg')
