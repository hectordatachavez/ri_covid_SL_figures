# set-up ----------
library(ggtext)
library(readxl)
library(dplyr)
library(tidyr)
library(patchwork)
library(ggplot2)
library(ggnewscale)


# load data ----------
# annual coverage rates - national level
data_national <- read_excel("./01_data/data.xlsx", sheet = 1)

# Load functions ----------
source("./03_functions/functions.R")


# Make plots ---------------

# plot A: 2019-2020
p_A <- process_data(data = data_national,
                    year_1 = "2019",
                    year_2 = "2020") %>%
  plot_coverage_gap(.,
                    title_text = "(a) <span style = 'color:#989898;'>**2019**</span> - <span style = 'color:#000000;'>**2020**</span>",
                    title_just = 0,
                    delta_legend = NA,
                    axis.text.y = element_text(color = "black", size = 10),
                    panel.grid.major.y = element_blank(),
                    plot.title.position = "plot"
                    )
# plot B: 2020-2021
p_B <- process_data(data = data_national,
                    year_1 = "2020",
                    year_2 = "2021") %>%
  plot_coverage_gap(.,
                    title_text = "<br>(b) <span style = 'color:#989898;'>**2020**</span> - <span style = 'color:#000000;'>**2021**</span>",
                    title_just = 0,
                    delta_legend = NA,
                    axis.text.y = element_text(color = "black", size = 10),
                    panel.grid.major.y = element_blank(),
                    plot.title.position = "plot"
                   )
# plot C: 2021-2022
p_C <- process_data(data = data_national,
                    year_1 = "2021",
                    year_2 = "2022") %>%
  plot_coverage_gap(.,
                    title_text = "<br>(c) <span style = 'color:#989898;'>**2021**</span> - <span style = 'color:#000000;'>**2022**</span>",
                    title_just = 0,
                    delta_legend = NA,
                    axis.text.y = element_text(color = "black", size = 10),
                    panel.grid.major.y = element_blank(),
                    plot.title.position = "plot"
                    )

## combine plots into one
p_A / p_B / p_C + plot_annotation(
  title = 'Change in Annual Coverage Rates in Sierra Leone',
  subtitle = ' ',
  theme = theme(plot.title = element_text(size = 15, face = 'bold'))
)


# export
ggsave(filename = paste("./04_output/ci_national_combined_print_160x200mm.jpeg", sep = ""),
       width = 160, #7*3 inches
       height = 200, # 6
       units = "mm",
       dpi = 300,
       device = 'jpeg')
