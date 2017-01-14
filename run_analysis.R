# Getting and Cleaning Data Course Project

library(dplyr)

datadir <- 'UCI HAR Dataset'

# Create directory if it not exists
if (!dir.exists(datadir)) {
  dir.create(datadir)
}

# Download and unzip data set archive
fileUrl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
download.file(fileUrl, destfile=paste(datadir, 'dataset.zip', sep = '/'))
unzip(zipfile=paste(datadir, 'dataset.zip', sep = '/'), exdir='.')

# Load metadata for features
featurelabel <- read.table(paste(datadir, 'features.txt', sep = '/'))
featurelabel[,2] <- as.character(featurelabel[,2])
# Extracts only the measurements on the mean and standard deviation for each measurement
featurefiltered <- grep("-mean|-std", featurelabel[,2])
featurelabel[,2] <- gsub('-mean', 'Mean', featurelabel[,2])
featurelabel[,2] <- gsub('-std', 'Std', featurelabel[,2])

# Load metadata for activities
activitylabel <- read.table(paste(datadir, 'activity_labels.txt', sep = '/'))
activitylabel[,2] <- as.character(activitylabel[,2])

# Load test sets
testx <- read.table(paste(datadir, 'test', 'X_test.txt', sep = '/'))[featurefiltered]
testy <- read.table(paste(datadir, 'test', 'y_test.txt', sep = '/'))
testsubj <- read.table(paste(datadir, 'test', 'subject_test.txt', sep = '/'))
test <- cbind(testsubj, testy, testx)

# Load train sets
trainx <- read.table(paste(datadir, 'train', 'X_train.txt', sep = '/'))[featurefiltered]
trainy <- read.table(paste(datadir, 'train', 'y_train.txt', sep = '/'))
trainsubj <- read.table(paste(datadir, 'train', 'subject_train.txt', sep = '/'))
train <- cbind(trainsubj, trainy, trainx)

# Merges the training and the test sets to create one data set
combinedset <- rbind(test, train)
colnames(combinedset) <- c('subject', 'activity', as.character(gsub('-|\\(\\)', '', featurelabel[featurefiltered,]$V2)))

# Uses descriptive activity names to name the activities in the data set
combinedset$activity <- factor(combinedset$activity, levels = activitylabel[,1], labels = activitylabel[,2])

# Create tidy data set with the average of each variable for each activity and each subject
meandataset <- combinedset %>% 
  group_by(subject, activity) %>% 
  summarise_each(funs(mean))

# Persist tidy data
write.table(meandataset, paste(datadir, 'tidy_dataset.txt', sep = '/'), row.names = FALSE, quote = FALSE)
