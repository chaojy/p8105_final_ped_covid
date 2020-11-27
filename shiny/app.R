# Import libraries
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(randomForest)
library(tidyverse)
library(data.table)

# Read data 
datacomplete = read_csv("./data/datacomplete.csv") %>%
  mutate_at(c("admitted", "ethnicity_race", "asthma", "diabetes", "gender"), as.factor) %>%
  select(admitted, age, gender, bmi_value, systolic_bp_value, ethnicity_race, asthma, diabetes)

# Build model
model = randomForest(admitted ~ ., data = datacomplete, ntree = 500, mtry = 6, importance = TRUE)

ui = fluidPage(theme = shinytheme("united"),
                
                # Page header
                headerPanel('COVID-19 Pediatric Hospitalization Risk Predictor'),
                
                # Input values
                sidebarPanel(
                  HTML("<h3>Select patient parameters</h3>"),
                  
                  sliderInput("age", "Age:",
                              min = 0, max = 22,
                              value = 15),
                  
                  selectInput("gender", label = "Gender:", 
                              choices = list("Female" = "F", "Male" = "M"), 
                              selected = "Female"),
                  
                  sliderInput("bmi_value", "Body Mass Index:",
                              min = 10, max = 85,
                              value = 22),
                  
                  sliderInput("systolic_bp_value", "Systolic blood pressure:",
                              min = 60, max = 190,
                              value = 120),
                  
                  selectInput("ethnicity_race", label = "Ethnicity:", 
                              choices = list("African American" = "black", "Asian" = "asian", "Caucasian" = "caucasian",
                                             "Hispanic" = "latino", "Native American" = "american indian",
                                             "Multiple" = "multiple"), 
                              selected = "African American"),
                  
                  selectInput("asthma", label = "Asthma:", 
                              choices = list("Yes" = "1", "No" = "0"), 
                              selected = "1"),
                  
                  selectInput("diabetes", label = "Diabetes:", 
                              choices = list("Yes" = "1", "No" = "0"), 
                              selected = "1"),
                  
                  actionButton("submitbutton", "Predict", class = "btn btn-primary")
                ),
                
                mainPanel(
                  tags$label(h3('Prediction')), # Status/Output Text Box
                  verbatimTextOutput('contents'),
                  tableOutput('tabledata') # Prediction results table
                  
                )
)

####################################
# Server                           #
####################################

server <- function(input, output, session) {
  
  # Input Data
  datasetInput = reactive({  
  
    df = data.frame(
      Name = c("age",
               "gender",
               "bmi_value",
               "systolic_bp_value",
               "ethnicity_race",
               "asthma",
               "diabetes"),
      Value = as.character(c(input$age,
                             input$gender,
                             input$bmi_value,
                             input$systolic_bp_value,
                             input$ethnicity_race,
                             input$asthma,
                             input$diabetes)),
      stringsAsFactors = FALSE)
    
    admitted = "admitted"
    df = rbind(admitted, df)
    input = transpose(df)
    write.table(input, "input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test = read_csv("input.csv") %>%
      mutate(admitted = factor(admitted, levels = c("yes", "no")),
             gender = factor(gender, levels = c("F", "M")),
             ethnicity_race = factor(ethnicity_race, levels = c("american indian", "asian", "caucasian", "black",
                                                                "latino", "multiple")),
             asthma = factor(asthma, levels = c("0", "1")),
             diabetes = factor(diabetes, levels = c("0", "1"))
      )
    
    Output = data.frame(Prediction = predict(model, test, type="prob"))
    print(Output)
    
  })
  
# Status/Output Text Box
  output$contents <- renderPrint({
    if (input$submitbutton>0) { 
      isolate("Calculation complete.") 
    } else {
      return("Server is ready for calculation.")
    }
  })
  
# Prediction results table
  output$tabledata <- renderTable({
    if (input$submitbutton>0) { 
      isolate(datasetInput()) 
    } 
  })
  
}

####################################
# Create the shiny app             #
####################################
shinyApp(ui = ui, server = server)