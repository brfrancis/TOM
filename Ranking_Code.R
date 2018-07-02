install.packages("rvest")#
install.packages("selectorgadget")
require(rvest)
require(XML)
require(googlesheets)
require(chron)


get_pos <- function(html){
  html %>% 
    # The relevant tag
    html_nodes('.tbody') %>%
    html_text
}

pg<-1
url<-paste('https://www.resultsbase.net/event/4509/results?page=',pg,sep="")
population <- url %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mainBody"]/div[2]/div[1]/div/div/table') %>%
  html_table(fill=TRUE)
bib<-as.numeric(population[[1]]$`Bibno.`[seq(1, 250, 5)])
name<-population[[1]]$`Participant`[seq(1, 250, 5)]
chip<-population[[1]]$`Chip time`[seq(1, 250, 5)]
gun<-population[[1]]$`Finish time`[seq(1, 250, 5)]


for(pg in seq(2,32)){
  url<-paste('https://www.resultsbase.net/event/4509/results?page=',pg,sep="")
  population <- url %>%
    read_html() %>%
    html_nodes(xpath='//*[@id="mainBody"]/div[2]/div[1]/div/div/table') %>%
    html_table(fill=TRUE)
  bib<-c(bib,as.numeric(population[[1]]$`Bibno.`[seq(1, 250, 5)]))
  name<-c(name,population[[1]]$`Participant`[seq(1, 250, 5)])
  chip<-c(chip,population[[1]]$`Chip time`[seq(1, 250, 5)])
  gun<-c(gun,population[[1]]$`Finish time`[seq(1, 250, 5)])
  
}

res<-cbind(as.numeric(bib),name,gun,chip)
tom_res1<-res[as.numeric(res[,1])>6000&!is.na(res[,1]),]
tom_res=cbind(order(60*24*times(tom_res1[,3])),order(60*24*times(tom_res1[,4])),tom_res1)
colnames(tom_res)<-c("Tour Position (Gun)","Position (Chip)", "Bib", "Name", "Chip Time", "Gun Time")
tom_res %>%
write.csv("TOM_Southport.csv", row.names = FALSE)
TOM_Southport <- gs_upload("TOM_Southport.csv",overwrite = TRUE) 

