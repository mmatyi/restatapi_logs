if (!("data.table" %in% rownames(installed.packages()))){install.packages(data.table)}
library(data.table)
cat(getwd())
old_rlogs<-readRDS(".cran_logs/rlogs.RDS")
rlogs_new<-data.table(date=Sys.Date(),time=format(Sys.time()),v=round(runif(1,0,100)))
rlogs<-rbind(old_rlogs,rlogs_new)
saveRDS(rlogs,"rlogs.RDS")
fwrite(rlogs,"rlogs.tsv",sep="\t")
