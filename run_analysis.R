if (!"reshape2" %in% installed.packages()) {
  install.packages("reshape2")
}
if (!"dplyr" %in% installed.packages()) {
  install.packages("dplyr")
}
if (!"tidyr" %in% installed.packages()) {
  install.packages("tidyr")
}


library(reshape2)
library(dplyr)
library(tidyr)

if(!dir.exists("./datafile")){
  dir.create("datafile")
}
setwd("datafile")
#I'm using MacOs so method = "curl", might subject to change due to operating system.
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "Dataset.zip",method="curl")
unzip("Dataset.zip")
setwd("UCI HAR Dataset")



train_subject <- read.table("./train/subject_train.txt",sep="\t")
train_set <- read.table("./train/X_train.txt",header = FALSE)
train_label <- read.table("./train/y_train.txt",header = FALSE)

train <- data.frame(train_subject,train_label,train_set)

test_subject <- read.table("./test/subject_test.txt",sep="\t")
test_set <- read.table("./test/X_test.txt",header = FALSE)
test_label <- read.table("./test/y_test.txt",header = FALSE)

test <- data.frame(test_subject,test_label,test_set)

all <- rbind(test,train)
colnames(all)[1:2] <- c("subject","label")

all2 <- gather(all,activity,value,-c(subject,label))

all2 <- all2[,c(1,2,4)]

summary <- all2 %>%
  group_by(subject,label) %>%
  summarise(average = mean(value),standard_deviation = sd(value))


label_text <- read.table("activity_labels.txt")

for (i in c(1,2,3,4,5,6)){
  summary$label[which(summary$label==i)] <- as.character(label_text$V2[which(label_text$V1 == i)])
}

tidyset <- select(summary,subject,label,average)

summary
tidyset

