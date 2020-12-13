library(shiny)
library(rCharts)
# library(rMaps)
# library(reshape2)
# library(cranlogs)
library(data.table)


shinyServer(function(input, output) {
  
  adat<-reactive({
    input$update
    isolate({
      withProgress({
        setProgress(message = "Filtering data...")
        d<-readRDS("../../cran_logs/rlogs.RDS")
        d<-d[date>=input$sdatum & date<=input$edatum]
        return(d)
      })
    })
    
 })   
  output$sumText  <- renderText({
     if (nrow(adat())==0) {
      paste0("No downloads between ",as.character(input$sdatum)," and ",as.character(input$edatum),".")
   } else {
      paste("The total download in the period:", as.character(nrow(adat())))
    }
  })

 
  
  
  output$adattabla <- DT::renderDataTable(DT::datatable({
    adat()[order(-date)]
  },rownames=FALSE,options = list(paging = FALSE,column.searchable = T,info=FALSE)))



  
  dd1<-reactive({
  dd1<-adat()[,c("version","r_os")]
  dd1[grepl("linux",r_os),os:="linux"]
  dd1[grepl("darwin",r_os),os:="mac"]
  dd1[grepl("mingw",r_os),os:="windows"]
  dd1<-dd1[,.(dd=.N),by=c("version","os")]
  dd1<-dd1[!is.na(os)]
  dd1
  })
  
  
  output$versiongraph <- renderChart({
    n1 <- nPlot(dd ~ version, group = "os", data = dd1(), type = "multiBarChart")
    n1$addParams(dom = 'versiongraph')
    n1$addParams(reduceXTicks=FALSE)
    return(n1)

  })

  
  
  dd<-reactive({
    dd<-adat()[,c("date")]
    dd<-dd[,.(dd=.N),by=date]
    dd$cumsum<-cumsum(dd$dd)
    dd$date<-as.Date(dd$date)
    
    dd$y<- format(dd$date, "%Y")
    dd$m<- as.numeric(format(dd$date, "%m"))-1
    dd$d<- format(dd$date, "%d")
    dd$date2<-paste0("Date.UTC(",dd$y,",",dd$m,",",dd$d,")")
    dd
  })
  
  
  
  output$myChart3 <- renderChart({
    h <- Highcharts$new()
    h$addParams(dom = 'myChart3')
    return(h)
    
  })
  
    output$plot2 <- renderText({  
    dd()[order(date)]
    
    s1.json <- toJSONArray2(cbind(dd()$date2, dd()$dd), json = T, names = F)
    s2.json <- toJSONArray2(cbind(dd()$date2, dd()$cumsum), json = T, names = F)
  
      h1 <- Highcharts$new()
    h1$chart(type = "scatter")
    h1$chart(zoomType = "xy")
    h1$xAxis(type = "datetime", labels=list(format= "{value:%Y-%m-%d}",rotation=45,align="left"))
    h1$yAxis(list(list(title = list(text = 'Daily download'), min=0, opposite = FALSE), 
                  list(title = list(text = 'Cummulative download'), min=0, opposite = TRUE)))
    h1$series(name = 'Daily download', type = 'spline', color = '#000099',
              data = gsub('"', "", substring(s1.json, 4, nchar(s1.json)-3)))
    h1$series(name = 'Cummulative download', type = 'spline', color = '#FF0000',
              data = gsub('"', "", substring(s2.json, 4, nchar(s2.json)-3)), yAxis=1)
    a <- paste0(capture.output(h1$print()), collapse="")
    a <- gsub(']" ]', '] ]', a)
    a <- gsub('\\[ \"\\[', '[ [', a)
    a  
  }) 
  
    # dd2<-d[,.(dd=.N),by=country]
    # dd2$ctry<-countrycode::countrycode(dd2$country,"iso2c","country.name")
    # crosslet(x="country",y="dd",data=dd2)$html()
    
})

