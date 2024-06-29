# national delta dumbbell plots --------------

## Process data function --------
process_data <-
function(data, year_1, year_2) {

  processed_data <- data %>%
    mutate(change_cov = !!sym(year_2) - !!sym(year_1)) %>%
    group_by(Antigen) %>%
    mutate(max = max(!!sym(year_1), !!sym(year_2))) %>%
    ungroup() %>%
    select(Antigen, !!sym(year_1), !!sym(year_2), max, change_cov) %>%
    mutate(Antigen = factor(Antigen,
                            levels = rev(c("BCG", "Measles-rubella 1",
                                           "Measles-rubella 2", "Penta 1",
                                           "Penta 3")
                                         ),
                            labels = rev(c("BCG", "Measles-rubella 1",
                                           "Measles-rubella 2", "Pentavalent 1",
                                           "Pentavalent 3")
                                          ),
                            ordered = TRUE),
           change_type = ifelse(change_cov < 0 , "negative", "positive"),
           change_type = factor(change_type,
                                levels = c("negative", "positive"),
                                ordered = T)
           ) %>%
    pivot_longer(
      c(!!sym(year_1), !!sym(year_2))
    )

  return(processed_data)
}



## Make dumbbell plot --------
plot_coverage_gap <-
function(processed_data, title_text, title_just, delta_legend, ...) {

# Define the custom nudge value
  nudge_value <- 0.8

# Main dumbbell plot
  p_main <- processed_data %>%
    ggplot(aes(x = value, y = Antigen)) +

    # line: difference between years
    geom_line( aes(group = Antigen, color = change_type,), size = 4.5 , alpha = 0.3) +
    # scale color of the line
    scale_color_manual(values = c("#ca0020", "#0571b0")) +
    # points: year
    geom_point(aes(shape = name), fill = "#989898", size = 4.5) +
    scale_shape_manual(values = c(21, 19)) +
    # geoms below will use another color scale
    new_scale_color() +
    # year value callout
    geom_text( aes(label = value, color = name), size = 4, fontface = "bold",
      nudge_x = if_else(processed_data$value == processed_data$max, nudge_value, -nudge_value),
      hjust = if_else(processed_data$value == processed_data$max, 0, 1) ) +
    # legend
    # geom_text(aes(label = name, color = name), data = . %>% filter(Antigen == "BCG"),
    #   nudge_y = 0.4,fontface = "bold",size = 5.5,
    #   nudge_x = if (all(unique(processed_data$name) %in% c("2019", "2020"))) {
    #               0
    #             } else if (all(unique(processed_data$name) %in% c("2021", "2022"))) {
    #               c(2, -2)
    #             } else if (all(unique(processed_data$name) %in% c("2020", "2021"))) {
    #               c(-1, 1)
    #             } else {
    #               # Default case if none of the specified combinations are met
    #               0
    #             }
    #   ) +
    # color scales
    scale_color_manual(values = c("#989898", "#000000")) +
    # coverage rate scale
    scale_x_continuous(labels = scales::percent_format(accuracy = 1, scale = 1),
                       limits = c(65, 100), breaks = seq(from = 0, to = 100, by = 5)) +
    #labels and title
    labs( title = ifelse(!is.na(title_text), yes = title_text, no = "") ) +
    # theme
    theme_minimal() +
    theme(
      legend.position = 'none',
      plot.title = element_markdown(size = 12, hjust = title_just),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.text.x = element_text(color = "#989898", size = 9),
      axis.title = element_blank(),
      ...
    )

  #### Anotation panel
 p_gap <- processed_data %>%
      ggplot(aes(x = change_cov, y = Antigen)) +
      # Delta for each antigen
      geom_text( aes(x = 0,
                     label = ifelse(change_cov > 0,
                                    paste("+", scales::number(change_cov, accuracy = 0.1), sep = ""),
                                    scales::number(change_cov, accuracy = 0.1))
                     ,
                     color = change_type
            ), fontface = "bold", size = 4 ) +
      # scale colour of text
      scale_color_manual(values = c("#ca0020","#0571b0")) +
      # Legend for the delta values
      geom_text( aes(x = 0, y = 5), label = delta_legend,
                 nudge_y = 0.4, fontface = "bold", size = 3.5 ) +
      # theme
      theme_void() +
      theme(
        plot.margin = margin(l = 0, r = 0, b = 0, t = 0),
        panel.background = element_rect(fill = "#f6f6ef", color = "#f6f6ef"),
        legend.position = "none"
      )

 # patchwork both plots
  p_whole <- p_main + p_gap +
    plot_layout(
      design = c(
        area(l = 0, r = 45, t = 0, b = 1),
        area(l = 46, r = 52, t = 0, b = 1)
      )
    )

  return(p_whole)
}




# district level time series matrices --------------
plot_district <- function(antigen_name, district_name) {
  ## check if input is valid
  if (!antigen_name %in% data_districts_long$antigen) stop("Antigen not found. Check spelling.")
  if (!district_name %in% data_districts_long$district) stop("District not found. Check spelling.")


  y_axes_districts <- c("Bo", "Kailahun","Koinadugu","Pujehun")
  x_axes_districts <- c("Pujehun", "Tonkolili", "Western Area Rural", "Western Area Urban")


  # make plot
  ggplot(data_districts_long, aes(x = name, y = value)) +
    # coverage rate scale
    scale_y_continuous(labels = scales::percent_format(accuracy = 1, scale = 1),
                       breaks = seq(from = 40, to = 100, by = 10)) +
    # all the other districts
    geom_point(data = filter(data_districts_long, antigen %in% antigen_name &
                               !district %in% district_name),
               color = "#989898", size = 0.5, alpha = 0.5
    ) +
    geom_line(data = filter(data_districts_long, antigen %in% antigen_name &
                              !district %in% district_name),
              aes(group = district), stat = "identity",
              color = "#989898", linewidth = 0.5, alpha = 0.5
    ) +
    # Selected district
    geom_point(data = filter(data_districts_long, antigen %in% antigen_name &
                               district %in% district_name),
               color = ifelse(test = data_districts_long$change_cov[data_districts_long$antigen %in% antigen_name &
                                                                      data_districts_long$district %in% district_name] > 0 ,
                              yes = '#436685', no = '#BF2F24'),
               size = 1.5
    ) +
    geom_line(data = filter(data_districts_long, antigen %in% antigen_name &
                              district %in% district_name),
              aes(group = district),
              color = ifelse(test = data_districts_long$change_cov[data_districts_long$antigen %in% antigen_name &
                                                                     data_districts_long$district %in% district_name] > 0 ,
                             yes = '#436685', no = '#BF2F24'),
              stat = "identity",
              linewidth = 1
    ) +
    # labels and titles
    labs(x = element_blank(), y = element_blank(),
         title = ifelse(test = district_name == "Bo",
                        yes = "(a) Bo",
                        no = result_vector[str_which(string = result_vector, pattern = district_name)])

         #title = district_name
    ) +
    # theme
    theme_minimal() +
    #coord_cartesian(ylim = c(40,100)) +
    theme(
      plot.title = element_markdown(size = 10, face = "bold"),
      plot.title.position = "plot",
      legend.position = "none",
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.y = element_blank(),
      #panel.grid.major.y = element_blank(),
      axis.text.y = element_text(color = ifelse(district_name %in% y_axes_districts,
                                                yes = "#989898",
                                                no = NA),
                                 size = ifelse(district_name %in% y_axes_districts,
                                               yes = 7,
                                               no = 0.1)
      ),
      axis.text.x = element_text(size = ifelse(district_name %in% x_axes_districts,
                                               yes = 8,
                                               no = 0.1),
                                 face =  "bold"
      ),
      axis.title = element_blank()
    )
}
