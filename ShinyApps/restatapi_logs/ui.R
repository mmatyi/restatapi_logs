library(shiny)
library(rCharts)
library(plotly)
# library(rMaps)

shinyUI(
 
  
  fluidPage(
    # tags$head(            
    #   tags$script(src="http://code.highcharts.com/highcharts.js"),
    #   tags$script(src="http://code.highcharts.com/modules/exporting.js")
    # ),
    title='restatapi downloads stats from CRAN ',
    fluidRow(
      
      column(3,
             dateInput('sdatum',
                       label = 'Starting from: yyyy-mm-dd',
                       weekstart = 1,
                       value = (Sys.Date()-30)
                       )
            ),
      column(3,
             dateInput('edatum',
                       label = 'End date: yyyy-mm-dd',
                       weekstart = 1,
                       value = (Sys.Date())
             )
      ),
      
      column(2,style='padding:25px;',actionButton("update","Update page",icon("refresh")) 
      ),
      column(4, style='padding:25px;', verbatimTextOutput("sumText"))
      
      ),
    fluidRow(
      column(6,plotlyOutput("versiongraph"))
      ,column(1,showOutput("myChart3",'highcharts'))
      ,column(5,htmlOutput("plot2"))
       
     ),
    
    fluidRow(
      verbatimTextOutput("paramText")
    ),
    
    
    fluidRow(
     plotlyOutput("dsgraph")
      
    ),
    # fluidRow(
    #   column(8,htmlOutput("plot2"))
    # ),
    # 
        hr(),
     fluidRow(
      column(12,DT::dataTableOutput("adattabla"))
    )
  )
)
