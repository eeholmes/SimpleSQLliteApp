#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(gridExtra)
library(grid)
library(stringr)
library(sqldf)
library(stargazer)

# Create a database from a csv file
# library(sqldf)
# db <- dbConnect(SQLite(), dbname="database.db")
# #if you have a csv file
# # dbWriteTable(conn=db, name="data", value="mtcars.csv", row.names=FALSE, header=TRUE,overwrite=TRUE)
# dbWriteTable(conn=db, name="data", value=mtcars, row.names=TRUE, header=TRUE,overwrite=TRUE)
# dbDisconnect(db)

# Define a function to get some data from the database

# Define UI for application to plot slices from your data
ui <- fluidPage(
  tags$style(type='text/css', ".selectize-input { font-size: 12px; line-height: 12px;} .selectize-dropdown { font-size: 12px; line-height: 12px; }"),
  
   # Application title
   titlePanel("Simple Data Viewer"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput('cyl', 'cylinders', sort(unique(sqldf("select cyl from data", dbname="database.db")$cyl)), selectize=TRUE,selected=c(4,6,8),multiple=TRUE),
         selectInput('carb', 'carburators', sort(unique(sqldf("select carb from data", dbname="database.db")$carb)), selectize=TRUE, selected=4)
   ),
   
      # Show a plot of the generated distribution
   mainPanel(
     tabsetPanel(
     tabPanel("Plot", plotOutput("distPlot", width="4in")),
     tabPanel("Summary", htmlOutput("summary")),
     tabPanel("Table", tableOutput("table"))
   )
   )
   )
)

server <- function(input, output, session) {
  
  getXY <- function(cyl=6, carb=4){
    query <- paste0("select mpg, wt from data ",
                    "where cyl in ( ",  paste(cyl, collapse=", ")," )",
                    " and carb=",carb)
    sqldf(query, dbname="database.db")
  }
  getCyl <- function(carb=1){
    query <- paste0("select cyl from data where carb=",carb)
    sqldf(query, dbname="database.db")
  }
  getCarb <- function(cyl=1){
    query <- paste0("select carb from data ",
                    "where cyl in ( ",  paste(cyl, collapse=",")," )")
    sqldf(query, dbname="database.db")
  }

  observe({
    carb <- input$carb
    cyl <- isolate(input$cyl)
    s_val <- sort(unique(getCyl(carb=carb)$cyl))

    # Text =====================================================
    # Change both the label and the text
    updateSelectInput(session, "cyl", 
                      label = "Select cylinders (click on box)",
                      choices = s_val, selected = cyl)
  }, priority=20)
  
  observe({
    cyl <- input$cyl
    carb <- isolate(input$carb)
    s_val <- sort(unique(getCarb(cyl=cyl)$carb))
    
    # Text =====================================================
    # Change both the label and the text
    updateSelectInput(session, "carb", 
                      label = "Select carburators (click on box)",
                      choices = s_val, selected = carb)
  }, priority=20)
  
  
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
     dat = getXY(cyl=input$cyl, carb=input$carb)
     if(nrow(dat)!=0){
       g1 = ggplot(dat, aes(x=wt, y=mpg, color=1)) +
       geom_point() + 
      xlab("wt") + ylab("mpg")
     g1
     }
   })
   
   output$table <- renderTable({
     query <- paste0("select name, mpg, wt, cyl, carb from data ",
                     "where cyl in ( ",  paste(input$cyl, collapse=", ")," )",
                     " and carb=",input$carb)
     sqldf(query, dbname="database.db")
   })
   
   output$summary <- renderPrint({
     dat = getXY(cyl=input$cyl, carb=input$carb)
     fit = lm(mpg ~ wt, data=dat)
     a=summary(fit)
     stargazer(fit, type="html", align=TRUE)
     })
}

# Run the application 
shinyApp(ui = ui, server = server)

