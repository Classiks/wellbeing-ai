library(tidyverse)

clustered <- read_csv("./data/clustered_with_count.csv")
clustered <- clustered %>%
    mutate(
        axis1_lg = log(axis1),
        axis2_lg = log(axis2)
    )

clusters <- list(
    social = c("psychological", "emotional", "social"),
    categorical = c("individual", "national", "public"),
    economical = c("financial", "political", "economic"),
    personal = c("mental", "physical", "personal"),
    spiritual = c("spiritual", "religious", "intellectual"),
    environmental = c("ecological", "environmental", "physiological")
)
clusters_reversed <- list()
for (n in names(clusters)) {
    for (adj in clusters[[n]]) {
        clusters_reversed[[adj]] <- n
    }
}

clustered <- mutate(clustered, cluster = map_chr(adjective, function(x) {
    if (x %in% names(clusters_reversed)) return(clusters_reversed[[x]])
    return(NA)
}))

p1 <- ggplot(clustered, aes(axis1_lg, axis2_lg)) +
    geom_point()
# ggplotly(p1)

clustered_grouped <- clustered %>%
    group_by(adjective, cluster) %>%
    summarise(
        axis1 = mean(axis1),
        axis2 = mean(axis2),
        count = sum(count, rm.na = TRUE),
        .groups = "drop"
    ) %>%
    mutate(
        axis1_lg = log(axis1),
        axis2_lg = log(axis2),
        count_lg = log(count)
    )



clustered_grouped_filtered <- filter(clustered_grouped, count > 1100)
# clustered_grouped_filtered <- filter(clustered, year > 2018 & count > 100) %>% mutate(count_lg = log(count))
# clustered_grouped_filtered <- clustered_grouped

p2 <- ggplot(clustered_grouped_filtered, aes(
        axis1_lg, axis2_lg,
        color = cluster,
        size = count_lg
    )) +
    geom_point(size = 2) +
    ggrepel::geom_label_repel(
        data = filter(clustered_grouped_filtered, is.na(cluster)),
        aes(label = adjective), color = "grey", max.overlaps = 20
    ) +
    ggforce::geom_mark_ellipse(
        data = filter(clustered_grouped_filtered, !is.na(cluster)),
        size = 1,
        con.type = "none"
    ) +
    ggrepel::geom_label_repel(
        data = filter(clustered_grouped_filtered, !is.na(cluster)),
        aes(label = adjective), max.overlaps = 20
    ) +
    labs(x = "Dimension 1", y = "Dimension 2") +
    theme_bw()

p2 +
    theme(legend.position = "none")
ggsave("./images/cluster_light.png", type = "cairo-png", width = 10, height = 10)

p2 +
    ggdark::dark_mode() +
    theme(legend.position = "none")
ggsave("./images/cluster_dark.png", type = "cairo-png", width = 10, height = 10)

