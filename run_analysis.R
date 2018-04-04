#getting the packages

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

#download the file
if(!dir.exists("./datafile")){
  dir.create("datafile")
}
setwd("datafile")
#I'm using MacOs so method = "curl", might subject to change due to operating system.
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "Dataset.zip",method="curl")
unzip("Dataset.zip")
setwd("UCI HAR Dataset")


#Merges the training and the test sets to create one data set.

train_subject <- read.table("./train/subject_train.txt",sep="\t")
train_set <- read.table("./train/X_train.txt",header = FALSE)
train_label <- read.table("./train/y_train.txt",header = FALSE)

train <- data.frame(train_subject,train_label,train_set)

test_subject <- read.table("./test/subject_test.txt",sep="\t")
test_set <- read.table("./test/X_test.txt",header = FALSE)
test_label <- read.table("./test/y_test.txt",header = FALSE)

test <- data.frame(test_subject,test_label,test_set)

feature <- read.table("features.txt")

all <- rbind(test,train)

# Uses descriptive activity names to name the activities in the data set
colnames(all)[1:2] <- c("subject","label")
colnames(all)[3:563] <- as.character(feature[,2])

# Extracts only the measurements on the mean and standard deviation for each measurement. 
mean.sd <- grep("-mean\\(\\)|-std\\(\\)", feature[, 2])
all.mean.sd <- all[,mean.sd]

# Uses descriptive activity names to name the activities in the data set
label_text <- read.table("activity_labels.txt")

for (i in c(1,2,3,4,5,6)){
  all.mean.sd$label[which(all.mean.sd$label==i)] <- as.character(label_text$V2[which(label_text$V1 == i)])
}

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
all$label <- factor(all$label, levels = label_text[,1], labels = label_text[,2])
all$subject <- as.factor(all$subject)

all.melted <- melt(all, id = c("subject", "label"))
all.mean <- dcast(all.melted, subject + label ~ variable, mean)

write.table(all.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
