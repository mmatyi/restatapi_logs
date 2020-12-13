library(shiny)
library(rCharts)
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
                       value = (Sys.Date()-30)
                       )
            ),
      column(3,
             dateInput('edatum',
                       label = 'End date: yyyy-mm-dd',
                       value = (Sys.Date())
             )
      ),
      
      column(2,style='padding:25px;',actionButton("update","Update page",icon("refresh")) 
      ),
      column(4, style='padding:25px;', verbatimTextOutput("sumText"))
      
      ),
    fluidRow(
      column(6,showOutput("versiongraph",'nvd3'))
      ,column(1,showOutput("myChart3",'highcharts'))
      ,column(5,htmlOutput("plot2"))
       
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
