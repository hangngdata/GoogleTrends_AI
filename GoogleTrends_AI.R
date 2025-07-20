rm(list=ls())

if (!require('pacman')) install.packages('pacman'); require('pacman',character.only=TRUE,quietly=TRUE)
p_load(ggbump, ggplot2,ggrepel, glue, gtrendsR, shadowtext, tidyverse)

keywords <- c("GenAI", "LLM", "Agentic AI")

#================ Interest over time ===================
trends <- gtrends(keyword = keywords,
               time = "2021-01-01 2025-07-18")

trend_df <- trends$interest_over_time %>%
  filter(!is.na(hits)) %>%
  mutate(
    hits = ifelse(hits == "<1", "0.5", hits),
    hits = as.numeric(hits),
    date = as.Date(date)
  )

label_data <- trend_df %>%
  group_by(keyword) %>%
  filter(date == max(date)) %>%
  ungroup()

trend_plot <- ggplot(trend_df, aes(x = date, y = hits, color = keyword)) +
  geom_line(linewidth = 1.1) +
  
  annotate("segment", 
           x = as.Date("2023-01-01"), xend = as.Date("2023-01-01"), 
           y = 0, yend = 100,
           color = "white", linetype = "dashed", linewidth = 0.6) +
  
  annotate("text", x = as.Date("2023-02-01"), y = 95, 
           label = "LLM takes off", 
           color = "white", hjust = 0, vjust = -0.5, 
           fontface = "italic", size = 4) +
  
  geom_text_repel(
    data = label_data,
    aes(label = keyword),
    nudge_x = 25,
    direction = "y",
    hjust = 0,
    segment.color = NA,
    size = 5,
    fontface = "bold"
  ) +
  
  scale_color_manual(values = c("Agentic AI" = "#E41A1C", 
                                "GenAI" = "#4DAF4A", 
                                "LLM" = "#377EB8")) +
  
  scale_x_date(expand = expansion(mult = c(0.01, 0.25))) +

  labs(
    title = "Rising Interest in AI Concepts (2021–2025)",
    subtitle = "LLMs dominate since 2023, GenAI and Agentic AI show recent growth",
    x = NULL, y = "Search hits (normalized)",
    caption = "Source: Google Trends"
  ) +

  theme_minimal(base_size = 13) +
  theme(
    plot.background = element_rect(fill = 'grey20', color = NA),
    panel.grid.major.y = element_line(color = "grey35", size = 0.2),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none",
    axis.text = element_text(color = "white"),
    axis.title.y = element_text(color = "white"),
    plot.title = element_text(face = "bold", size = 18, color = "white"),
    plot.subtitle = element_text(size = 14, color = "white"),
    plot.caption = element_text(size = 10, color = "grey80", face = "italic"),
    plot.margin = margin(t = 40, r = 40, b = 40, l = 40, unit = "pt")
  )

write.csv(trend_df,"./data/interest_over_time.csv", row.names = FALSE)
ggsave("./plots/trend_plot.png", plot = trend_plot,
       width = 14, height = 8, dpi = 300, units = "in", bg = "grey10")

#================ Interest by Country ===================
years <- c("2021-01-01 2021-12-31", 
           "2022-01-01 2022-12-31",
           "2023-01-01 2023-12-31",
           "2024-01-01 2024-12-31",
           "2025-01-01 2025-07-18")

all_years_data <- list()

for (year in years) {
  message("Fetching year: ", year)
  
  gt <- tryCatch({
    gtrends(keywords, time = year)
  }, error = function(e) {
    message("Error for year ", year, ": ", e$message)
    NULL
  })
  
  if (!is.null(gt)) {
    region_data <- gt$interest_by_country
    region_data$year <- substr(year, 1, 4)
    
    all_years_data[[year]] <- region_data
  }
}

combined <- bind_rows(all_years_data)

final_df <- combined %>%
  filter(!is.na(hits)) %>%
  mutate(hits_num = as.numeric(gsub("<1", "0.5", hits))) %>%
  group_by(keyword, year) %>%
  slice_max(order_by = hits_num, n = 5, with_ties = FALSE) %>%
  ungroup() %>%
  select(location, hits, keyword, year)

View(final_df)


ranked_df <- final_df %>%
  mutate(hits_num = as.numeric(gsub("<1", "1", hits))) %>%
  group_by(year, keyword) %>%
  mutate(rank = dense_rank(-hits_num)) %>%  # or min_rank()
  ungroup()

ranked_df$year <- as.integer(ranked_df$year)
ranked_df$location <- factor(ranked_df$location)

write.csv(ranked_df,"./data/interest_by_country_ranked.csv", row.names = FALSE)

plot_top_countries_per_keyword <- function(ranked_df, keyword) {
  
  title <- glue("Top 5 Countries for '{keyword}' Google Searches (2021–2025)")
  
  df_plot <- filter(ranked_df, keyword == !!keyword)
  
  df_plot <- df_plot %>%
    mutate(
      year = as.integer(year),
      location_factor = as.numeric(as.factor(location))
    )
  
  label_df <- df_plot %>%
    group_by(year, rank) %>%
    mutate(
      n_ranked = n(),
      tie_order = row_number(),
      offset = (tie_order - (n_ranked + 1)/2) * 0.3 
    ) %>%
    ungroup() %>%
    mutate(
      y_jitter = rank + offset,
      vjust_pos = ifelse(rank == 1, 1.5, -1.2)
    )
  
  ggplot(df_plot, aes(x = year, y = rank, group = location, color = location)) +
    geom_bump(size = 18, smooth = 8) +
    geom_point(size = 18, color = "white") +
    geom_point(size = 16) +
    
    geom_shadowtext(
      data = label_df,
      aes(x = year, y = y_jitter, label = location),
      inherit.aes = FALSE,
      size = 7,
      bg.color = "black",
      color = "white",
      fontface = "bold"
    ) +
    
    scale_y_reverse(breaks = 1:5, expand = expansion(mult = c(0.12, 0.25))) +
    scale_x_continuous(breaks = unique(df_plot$year),
                       expand = expansion(mult = c(0.12, 0.25))) +
    labs(
      title = title,
      x = NULL,
      y = NULL,
      caption = "Source: Google Trends"
    ) +
    theme_minimal(base_size = 16) +
    theme(
      plot.background = element_rect(fill = "grey10", color = NA),
      panel.grid = element_blank(),
      axis.text = element_text(color = "white", size = 18),
      axis.text.y = element_blank(),
      axis.title.y = element_text(color = "white", face = "bold", size = 25),
      plot.title = element_text(color = "white", face = "bold", size = 25),
      plot.caption = element_text(color = "grey80"),
      legend.position = "none",
      plot.margin = margin(t = 40, r = 40, b = 40, l = 40, unit = "pt")
    )
}

llm_plot <- plot_top_countries_per_keyword(ranked_df, "LLM")
genai_plot <- plot_top_countries_per_keyword(ranked_df, "GenAI")

ggsave("./plots/llm_top_countries.png", plot = llm_plot,
       width = 14, height = 8, dpi = 300, units = "in", bg = "grey10")
ggsave("./plots/genai_top_countries.png", plot = genai_plot,
       width = 14, height = 8, dpi = 300, units = "in", bg = "grey10")
