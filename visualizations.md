visualizations
================

``` r
library(tidyverse)
library(usa)

knitr::opts_chunk$set(
  fig.width = 6,
  fig.asp = .6,
  out.width = "90%")

theme_set(theme_minimal() + theme(legend.position = "bottom"))

options(
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis")

scale_colour_discrete = scale_color_viridis_d
scale_fill_discrete = scale_fill_viridis_d

knitr::opts_chunk$set(comment = NA, message = FALSE, warning = FALSE, echo = TRUE)
```

Read in and tidy the data.

``` r
ped_covid =
  read_csv("./data/p8105_final_ped_covid.csv") %>%
  mutate(
    ethnicity_race = case_when(
      race == "R3 Black or African-American"        ~ "black",
      race == "R2 Asian"                            ~ "asian",
      race == "R5 White"                            ~ "caucasian",
      race == "R1 American Indian or Alaska Native" ~ "american indian",
      race == "Multiple Selected"                   ~ "multiple",
      ethnicity == "E1 Spanish/Hispanic/Latino"     ~ "latino"
    )
  ) %>%
  mutate(
    asthma = replace_na(asthma_dx, 0),
    asthma = str_replace(asthma, ".*J.*", "1"),
    diabetes = replace_na(diabetes_dx, 0),
    diabetes = str_replace(diabetes, ".*E.*", "1"),
    zip = as.character(zip_code_set),
    service = outcomeadmission_admission_1inpatient_admit_service, 
    obesity = bmi_yes_or_no,
    ed = ed_yes_no_0_365_before,
    admission_dx = admission_apr_drg,
    icu = icu_yes_no
  ) %>%
  select(admitted, age, gender, ses, zip, eventdatetime, obesity, bmi_value, icu, icu_date_time, 
         systolic_bp_value, ethnicity_race, asthma, diabetes, zip, service, ed, admission_dx)
```

Merge zipcode data with latitude and longitude.

``` r
zipcode_df = 
  usa::zipcodes

ped_covid = 
  left_join(ped_covid, zipcode_df, by = "zip")
```
