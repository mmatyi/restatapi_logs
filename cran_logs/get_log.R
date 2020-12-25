if (!("data.table" %in% rownames(installed.packages()))){install.packages("data.table")}
library(data.table)
old_rlogs<-readRDS("./cran_logs/rlogs.RDS")

tbc<-verbose<-TRUE
# date<-"2019-04-26"
start_date<-as.Date(max(old_rlogs$date))+1   #"2019-04-26"
# dates<-seq(start_date,as.Date("2020-01-01"),by="day")
dates<-seq(start_date,Sys.Date(),by="day")

dlog<-function(date){
  cat(format(Sys.time()),"---",format(date),"\n")
  url<-paste0("http://cran-logs.rstudio.com/",gsub("-.*","",date),"/",date,".csv.gz")
  temp<-tempfile()
  tryCatch({utils::download.file(url,temp)},
           error = function(e) {
             if (verbose){message("Error by the download the log file:",'\n',paste(unlist(e),collapse="\n"))}
             tbc<-FALSE
           },
           warning = function(w) {
             if (verbose){message("Warning by the download the log file:",'\n',paste(unlist(w),collapse="\n"))}
           })
  if (tbc & (file.info(temp)$size>0)){
    tryCatch({gz<-gzfile(temp,open="rt")},
             error = function(e) {
               if (verbose){message("Error by the opening the downloaded gz file:",'\n',paste(unlist(e),collapse="\n"))}
               tbc<-FALSE
             },
             warning = function(w) {
               if (verbose){message("Warning by the opening the downloaded gz file:",'\n',paste(unlist(w),collapse="\n"))}
             })
    if(max(utils::sessionInfo()$otherPkgs$data.table$Version,utils::sessionInfo()$loadedOnly$data.table$Version)>"1.11.7"){
      logs<-data.table::fread(text=readLines(gz),sep=',',colClasses='character',header=TRUE,stringsAsFactors=F)
    } else{
      logs<-data.table::fread(paste(readLines(gz),collapse="\n"),sep=',',colClasses='character',header=TRUE,stringsAsFactors=F)
    }
    close(gz)
    unlink(temp)
    logs[package=="restatapi"]
  }  
}
# rlogs<-dlog(date)
rlogs_new<-rbindlist(lapply(dates,dlog))
rlogs<-rbind(old_rlogs,rlogs_new)
saveRDS(rlogs,"./cran_logs/rlogs.RDS")
fwrite(rlogs,"./cran_logs/rlogs.tsv",sep="\t")
<<<<<<< HEAD
alog<-rlogs[!is.na(country),.(fday=gsub("-","",min(date)),days=length(unique(date)),versions=length(unique(version)),downloads=.N),by=country]
fwrite(alog,"./cran_logs/logs_map.tsv",sep="\t")  
=======
alog<-rlogs[!is.na(country),.(fday=min(date),days=length(unique(date)),versions=length(unique(version)),downloads=.N),by=country]
fwrite(alog,"./docs/logs_map.tsv",sep="\t")  
>>>>>>> ab6df85e4877bc19ae9f451a69e218d58b7cf07f
                              
