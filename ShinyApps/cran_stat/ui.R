library(shiny)
library(rCharts)

pckgs<<-c("restatapi")

shinyUI(
  fluidPage(
    title='Number of downloads for various packages',
    fluidRow(
      column(2,selectInput("selection", "Choose a package:",
                  choices = pckgs)),
      column(2,textInput("pkg_name", label = "or provide package name", value = "Package name...")
             ),
     
      column(2,
             dateInput('datum',
                       label = 'Starting from: yyyy-mm-dd',
                       value = (Sys.Date()-7)
                       )
            ),
      column(2,style='padding:25px;',actionButton("update","Update page",icon("refresh")) 
      ),
      column(4, style='padding:25px;', verbatimTextOutput("sumText"))
      
      ),
    hr(),
    fluidRow(
      column(6,showOutput("dailygraph",'morris')),
      column(6,showOutput("sumgraph",'morris'))
    ),
    hr(),


     fluidRow(
      column(12,DT::dataTableOutput("adattabla"))
    )
  )
)
