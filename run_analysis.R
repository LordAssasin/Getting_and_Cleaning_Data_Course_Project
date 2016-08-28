library(reshape2)

thefilename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(thefilename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, thefilename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(thefilename) 
}

# Load activity labels + features

ActivityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
ActivityLabels[,2] <- as.character(ActivitytLabels[,2])
Features <- read.table("UCI HAR Dataset/features.txt")
Features[,2] <- as.character(Features[,2])

# Extracts only the measurements on the mean and standard deviation for each measurement.
FeaturesWanted <- grep(".*mean.*|.*std.*", Features[,2])
FeaturesWanted.names <- Features[FeaturesWanted,2]
FeaturesWanted.names = gsub('-mean', 'Mean', FeaturesWanted.names)
FeaturesWanted.names = gsub('-std', 'Std', FeaturesWanted.names)
FeaturesWanted.names <- gsub('[-()]', '', FeaturesWanted.names)


# Load the datasets and appropriately labels the data set with descriptive variable names. 
Train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesWanted]
TrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
Train <- cbind(TrainSubjects, TrainActivities, Train)

Test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesWanted]
TestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
TestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
Test <- cbind(TestSubjects, TestActivities, Test)

# Merges the training and the test sets to create one data set.
AllData <- rbind(Train, Test)
colnames(AllData) <- c("Subject", "Activity", FeaturesWanted.names)

# turn activities & subjects into factors
AllData$Activity <- factor(AllData$Activity, levels = ActivityLabels[,1], labels = ActivityLabels[,2])
AllData$Subject <- as.factor(AllData$Subject)

AllData.melted <- melt(AllData, id = c("Subject", "Activity"))
AllData.mean <- dcast(AllData.melted, Subject + Activity ~ variable, mean)

write.table(AllData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
