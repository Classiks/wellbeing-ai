library(tidyverse)

wellbeing <- read_csv("./data/ngram_dependencies_wellbeing.csv")

wellbeing <- wellbeing %>%
    mutate(
        noun = str_extract(ngram, "\\w+(?=_noun=>)"),
        adjective = str_extract(ngram, "\\w+(?=_adj)")
    ) %>%
    select(ngram, noun, adjective, year, count)

write_csv(wellbeing, "./data/ngram_dependencies_wellbeing_separated.csv")


