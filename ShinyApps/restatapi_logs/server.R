library(shiny)
library(rCharts)
library(plotly)
# library(rMaps)
# library(reshape2)
# library(cranlogs)
library(data.table)

tmp<-tempfile()
download.file("https://github.com/mmatyi/restatapi_logs/raw/main/restatapi_logs/log_summary.RDS",tmp)
dt<-readRDS(tmp)

shinyServer(function(input, output) {
  
  adat<-reactive({
    input$update
    isolate({
      withProgress({
        setProgress(message = "Filtering data...")
        d<-dt[date>=input$sdatum & date<=input$edatum]
        return(d)
      })
    })
    
 })   
  output$sumText  <- renderText({
     if (nrow(adat())==0) {
      paste0("No logfile between ",as.character(input$sdatum)," and ",as.character(input$edatum),".")
   } else {
      paste("The total query in the period:", as.character(nrow(adat())))
    }
  })

  output$paramText  <- renderText({
    if (nrow(adat())==0) {
      paste0("No logfile between ",as.character(input$sdatum)," and ",as.character(input$edatum),".")
    } else {
      all_params<-unlist(strsplit(adat()$params,"|",fixed=T))
      unique_params<-unique(all_params)
      param_freq<-sort(sapply(unique_params,function(x) sum(grepl(x,all_params))),decreasing = T)
      
      paste("Parameter frequency in the period:", paste(paste0(names(param_freq),"(",param_freq,")"),collapse = ", "))
    }
  })
  
  
  
  
  output$adattabla <- DT::renderDataTable(DT::datatable({
    adat()[order(-date)]
  },rownames=FALSE,options = list(paging = FALSE,column.searchable = T,info=FALSE)))



  
  dd1<-reactive({
  dd1<-adat()[,c("version","date")]
  dd1<-dd1[,.(dd=.N),by=c("version","date")]
  dd1$date<-as.Date(dd1$date)
  dd1
  })
  
  
  # output$versiongraph <- renderChart({
  #   n1 <- nPlot(dd ~ date, group = "version", data = dd1(), type = "multiBarChart")
  #   n1$addParams(dom = 'versiongraph')
  #   n1$addParams(reduceXTicks=FALSE)
  #   n1$xAxis(type = "datetime", labels=list(format= "{value:%Y-%m-%d}",rotation=45,align="left"))
  #   return(n1)
  # 
  # })

  output$versiongraph <- renderPlotly({
    versiongraph<-plot_ly(data=dd1(), x = ~date, y = ~dd, color=~version, type = 'bar')
    versiongraph<- versiongraph %>% layout(yaxis = list(title = 'Nr of queries'), barmode = 'stack')
    versiongraph<- versiongraph %>% config(modeBarButtonsToRemove=c("pan2d","select2d","autoscale2d","lasso2d"))
  
  }
  )

  
  dd2<-reactive({
    dd2<-adat()[,c("dataset","version")]
    dd2<-dd2[!(grepl("[\\.\\,\\[\\=\\(\\s\\$]",dataset))&!(grepl("[\\,\\[\\=\\(\\s\\$]",version))]
    dd2<-dd2[,.(dd=.N),by=c("dataset","version")]
    ddp<-dd2[,.(dd=sum(dd)),by=dataset]
    setnames(ddp,1,"version")
    ddp$dataset<-"Datasets total"
    dd2<-rbind(dd2,ddp)
    dd2<-rbind(dd2,data.table(dataset="",version="Datasets total",dd=sum(ddp$dd)))
    
    dd2
  })  
    
  output$dsgraph <- renderPlotly({
    dsgraph<-plot_ly(data=dd2(), type = 'sunburst', values=dd2()$dd,labels=dd2()$version, parents=dd2()$dataset)
   }
  )
  
  
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
    h1$yAxis(list(list(title = list(text = 'Daily logged query'), min=0, opposite = FALSE), 
                  list(title = list(text = 'Cummulative number of logged query'), min=0, opposite = TRUE)))
    h1$series(name = 'Daily logged query', type = 'spline', color = '#000099',
              data = gsub('"', "", substring(s1.json, 4, nchar(s1.json)-3)))
    h1$series(name = 'Cummulative number of logged query', type = 'spline', color = '#FF0000',
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

