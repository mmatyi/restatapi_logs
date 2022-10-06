if (!("data.table" %in% rownames(installed.packages()))){install.packages("data.table")}
library(data.table)
old_rlogs<-readRDS("./restatapi_logs/log_summary.RDS")

# tbc<-verbose<-TRUE
# date<-"2019-02-06"
start_date<-as.Date(max(old_rlogs$date))+1  
# start_date<-as.Date("2019-05-28")
# dates<-seq(start_date,as.Date("2020-12-15"),by="day")
dates<-seq(start_date,Sys.Date(),by="day")


dlog<-function(date){
  fname<-paste0("./restatapi_logs/",date,".tab")
  # cat(date,"\n")
  if (file.exists(fname)) {
    system(paste("echo",paste(date,format(Sys.time()),sep="#"),paste0(">> debug.txt")))
    dt<-fread(fname,sep="",header=F,stringsAsFactors=F,)
    setorder(dt[,coln:=nchar(gregexec("\t",V1))],-coln)
    dt<-dt[!grepl("^E",V1,perl=T)]
    fwrite(dt[,coln:=NULL],file.path(tempdir(),"tmp.tab"),col.names=F,quote=F)
    # dt$coln=lapply(dt$coln,length())
    # order(readLines(file(fname)),unlist(lapply(gregexec("\t",readLines(file(fname))),length)))
    logs<-read.table(file.path(tempdir(),"tmp.tab"),sep='\t',header=F,stringsAsFactors=F,fill=T,quote="") #nrows=length(readLines(file(fname))),colClasses="character",verbose=T
    if (nrow(logs)>1 & ncol(logs)>3){
      dsum<-data.table(date=date,version=logs$V1,dataset=tolower(gsub("id=","",logs$V2)),params=gsub("\\|*$","",apply(apply(logs[,3:ncol(logs)],2,function(x) gsub("=.*","",x)),1,paste,collapse="|")))
    } else if (nrow(logs)>1 & ncol(logs)==3) {
      dsum<-data.table(date=date,version=logs$V1,dataset=tolower(gsub("id=","",logs$V2)),params=gsub("=.*","",logs[,3:ncol(logs)]))
    } else if (ncol(logs)==2) {
      dsum<-data.table(date=date,version=logs$V1,dataset=tolower(gsub("id=","",logs$V2)),params="")
    } else {
      dsum<-data.table(date=date,version=logs$V1,dataset=tolower(gsub("id=","",logs$V2)),params=gsub("\\|*$","",paste(gsub("=.*","",logs[,3:ncol(logs)]),collapse="|")))
    }
     # nparam=rowSums(apply(logs[,3:ncol(logs)],2,nchar)>0)
  }
}
# dlog(date)

rlogs_new<-rbindlist(lapply(dates,dlog))
rlogs<-rbind(old_rlogs,rlogs_new)
saveRDS(rlogs,"./restatapi_logs/log_summary.RDS")
fwrite(rlogs,"./restatapi_logs/log_summary.tsv",sep="\t")
system("git config --global --add safe.directory /__w/restatapi_logs/restatapi_logs")            
