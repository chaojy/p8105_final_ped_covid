library(broom)
library(caret)
library(plotly)
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(tidyverse)

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
  select(admitted, age, gender, ses, zip, eventdatetime, bmi_value, icu, icu_date_time, 
         systolic_bp_value, ethnicity_race, asthma, diabetes, zip, service, ed, admission_dx) %>%
  mutate_at(c("admitted", "gender", "icu", "ethnicity_race", "asthma", "diabetes",
              "ed"), as.factor)

# Merge zipcode data with latitude and longitude.
zipcode_df = 
  usa::zipcodes

ped_covid = 
  left_join(ped_covid, zipcode_df, by = "zip")

# Define UI
ui = fluidPage(theme = shinytheme("cerulean"),
               titlePanel("Pediatric COVID Hospitalization Prediction Tool"),
               sidebarLayout(
                 sidebarPanel(
                   helpText("Select predictors for hospitalization in pediatric patients with 
                            COVID-19. Examine coefficients and their odds ratios."),
                   pickerInput(
                     inputId = "demographics",
                     label = "Patient demographics",
                     choices = demographics,
                     options = list(
                       'actions-box' = TRUE,
                       size = 12,
                       'selected-text-format' = "count > 3"
                     ), 
                     multiple = TRUE),
                   pickerInput(
                     inputId = "comorbidities",
                     label = "Patient comorbidities",
                     choices = comorbidities,
                     options = list(
                       'actions-box' = TRUE,
                       size = 12, 
                       'selected-text-format' = "count > 3"
                     ),
                     multiple = TRUE
                   ),
                   actionBttn("submit", "Enter"),
                   mainPanel(
                     tabsetPanel(
                       tabPanel("Coefficient Magnitudes", plotlyOutput("coeff_graph")),
                       tabPanel("Odds Ratios", plotlyOutput("or_graph"))
                     )
                   )
                 )
               )
)

# Compile all the covariates into a formula for the regression
fmla = reactive({
  as.formula(
    paste("admitted ~ ", paste(c(input$demographics
                                input$comorbidities), collapse = "+"))
  )
})

# Create a model from the formula
log.model = reactive({
  glm(fmla(), data = ped_covid, family = binomial())
})

# Act upon a user pressing the Regress button
observeEvent(input$submit, {
  
  output$coeff_graph = renderPlotly({
    tidy(log.model()) %>%
      plot_ly(
        x = ~term,
        y = ~estimate, 
        type = "bar",
        text = mapCoeffsToText(.$estimate),
        marker = list(
          color = mapCoeffsToColor(.$estimate)
        ) 
      ) %>% 
      layout(xaxis = list(title = "Coefficient Term", tickangle = -45),
             yaxis = list(title = "Coefficient Magnitude"),
             margin = list(b = 100))
  })
  
  output$or_graph = renderPlotly({
    tidy(log.model()) %>% 
      mutate(OR = exp(estimate),
             low.bound = exp(estimate - 1.96 * std.error),
             high.bound = exp(estimate + 1.96 * std.error)) %>% 
      plot_ly(
        x = ~term,
        y = ~OR,
        type = "scatter",
        mode = "markers",
        color = ~term,
        error_y = ~list(array = c(.$low.bound, .$high.bound))
      ) %>% 
      layout(xaxis = list(title = "Coefficient Term", tickangle = -45),
             yaxis = list(title = "Adjusted Odds Ratio"),
             margin = list(b = 100))
  })
  
})
}

# Run the application 
shinyApp(ui = ui, server = server)


