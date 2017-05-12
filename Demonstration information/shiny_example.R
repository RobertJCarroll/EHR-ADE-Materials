library(shiny)
library(ggplot2)
library(dplyr)
library(DatabaseConnector)
conn <- connect(connectionDetails)
conditions=dbGetQuery(conn, "SELECT distinct condition_concept_id, concept_name 
                      FROM condition_occurrence join concept on (condition_concept_id=concept_id)")
dbDisconnect(conn)

cond_list=as.list(conditions$condition_concept_id)
names(cond_list)=conditions$concept_name

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Age at first diagnosis"),
  
  # Sidebar with a dropdown of SNOMED CT
  sidebarLayout(
    sidebarPanel(
      selectInput("cond", label = h3("Select SNOMED CT concept"), 
                  choices = cond_list, 
                  selected = 319835)
    ),
    # Show a plot 
    mainPanel(
      plotOutput("age_hist")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  #Get first ages for specified condition
  
  output$age_hist <- renderPlot({
    conn <- connect(connectionDetails)
    ages=dbGetQuery(conn, paste0("SELECT min(extract(year from condition_start_date)-year_of_birth) as age
                      FROM condition_occurrence join person using (person_id) 
                      WHERE condition_concept_id=",input$cond,"
                                     group by person_id"))
    dbDisconnect(conn)
    # draw the histogram with the specified number of bins
    ggplot(ages,aes(age))+geom_histogram()
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
