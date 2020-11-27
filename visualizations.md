visualizations
================

``` r
library(tidyverse)
library(usa)
library(mice)

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
# Load and tidy data
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
    ed = ed_yes_no_0_365_before,
    admission_dx = admission_apr_drg,
    icu = icu_yes_no
  ) %>%
  mutate(obesity = case_when(
    bmi_value >= 30 ~ "1",
    bmi_value < 30 ~"0"
  ))
```

``` r
# Merge zipcode data with latitude and longitude.
zipcode_df = 
  usa::zipcodes

ped_covid = 
  left_join(ped_covid, zipcode_df, by = "zip") %>%
  select(admitted, age, gender, ses, zip, eventdatetime, bmi_value, icu, icu_date_time, 
         systolic_bp_value, ethnicity_race, asthma, diabetes, zip, service, ed, admission_dx,
         city.y, obesity, lat, long) %>%
  mutate_at(c("admitted", "icu", "ethnicity_race", "asthma", "diabetes",
              "ed", "city.y", "obesity"), as.factor) %>%
  mutate(gender = factor(gender, levels = c("M", "F"))) %>%
  rename(city = city.y) 
```

``` r
# Impute missing data
impute = mice(ped_covid, m=3, seed=111)
```

``` 

 iter imp variable
  1   1  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  1   2  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  1   3  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  2   1  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  2   2  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  2   3  gender  ses*  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  3   1  gender  ses  bmi_value  systolic_bp_value*  ethnicity_race  city  obesity  lat  long
  3   2  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  3   3  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  4   1  gender  ses  bmi_value  systolic_bp_value*  ethnicity_race  city  obesity  lat  long
  4   2  gender  ses  bmi_value  systolic_bp_value*  ethnicity_race  city  obesity  lat  long
  4   3  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  5   1  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  5   2  gender  ses  bmi_value  systolic_bp_value  ethnicity_race  city  obesity  lat  long
  5   3  gender  ses  bmi_value  systolic_bp_value*  ethnicity_race  city  obesity  lat  long
 * Please inspect the loggedEvents 
```

``` r
datacomplete = complete(impute,2)
```

``` r
# Export csv
write_csv(datacomplete, "datacomplete.csv")
```
