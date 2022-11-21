library(tidyverse)

clustered <- read_csv("./data/clustered.csv")
clustered <- clustered %>%
    mutate(
        axis1_lg = log(axis1),
        axis2_lg = log(axis2)
    ) %>%
    rename(
        adjective = dependency,
        year = calendar_year
    )

occurences <- read_csv("./data/ngram_dependencies_wellbeing_separated.csv")
occurences <- occurences %>%
    select(adjective, year, count)

full_data <- full_join(occurences, clustered) %>%
    replace_na(list(count = 0))

write_csv(full_data, "./data/clustered_with_count.csv")
