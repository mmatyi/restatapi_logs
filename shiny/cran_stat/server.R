library(shiny)
library(rCharts)
library(reshape2)
library(cranlogs)
library(data.table)


shinyServer(function(input, output) {
  
  adat<-reactive({
    input$update
    isolate({
      withProgress({
        setProgress(message = "Downloading data...")
        if (nchar(input$pkg_name)>0){
          if (input$pkg_name=="Package name...") {
            pkg_name<-input$selection
          } else {
            pkg_name<-input$pkg_name
          }
        } else {
          pkg_name<-input$selection
        }
         df<-cran_downloads(from=as.character(input$datum), packages = pkg_name)
          df$cumsum<-cumsum(df$count)
          df$date<-as.character(df$date)
          df[df$cumsum!=0,]  
        as.data.table(df)
      })
    })
    
 })   
  output$sumText  <- renderText({
     if (nrow(adat())==0) {
      paste0("No downloads for the package '",input$pkg_name,"' starting from ",as.character(input$datum),".")
   } else {
      paste("The total download in the period:", as.character(max(adat()$cumsum)))
    }
  })


  output$adattabla <- DT::renderDataTable(DT::datatable({
    adat()[order(-date)]
  },rownames=FALSE,options = list(paging = FALSE,column.searchable = T,info=FALSE)))



  output$sumgraph <- renderChart2({
    plot <- mPlot(x = "date", y = "cumsum",
                  data = adat(), type = "Line")
    #    plot$set(pointSize = 3)
    plot$set(hideHover = "auto")
    plot$set(labels=list("Cummulative download"))
    plot$set(dom="graph")
    #    plot$set(color=c('brown', 'blue', '#594c26', 'green'))
    plot$addParams(width = 800, dom = 'graph', title = "Daily downloads")
    return(plot)
    
  })

  
  output$dailygraph <- renderChart2({
    plot <- mPlot(x = "date", y = "count",
                  data = adat(), type = "Line")
#    plot$set(pointSize = 3)
    plot$set(hideHover = "auto")
    plot$set(labels=list("Daily download"))
    plot$set(dom="graph2")
#    plot$set(color=c('brown', 'blue', '#594c26', 'green'))
    plot$addParams(width = 800, dom = 'graph2', title = "Cummulative downloads")
    return(plot)
      
  })
})
