## Check/install required packages
if (!require("dplyr")) {install.packages("dplyr")}
require(dplyr)

# download file to the data directory
dataDir <-"."
if (!file.exists(dataDir)) {
        dir.create(path = dataDir)
}
strURL <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
strFile <-"dataset.zip"
strPathFile <-file.path(dataDir, strFile, fsep = "/")
if(!file.exists(strPathFile)) {
        download.file(url = strURL, destfile = strPathFile, method = "auto", mode = "wb")
        # unzip the file to the data directory
        unzip(zipfile = strPathFile, exdir = dataDir)
}

##read tables
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table('./UCI HAR Dataset/features.txt')[,2]

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# 1. merge datasets - row bind
x <- rbind(x_train, x_test)
names(x) = features
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)

#remove objects that are no longer needed
rm(x_train)
rm(x_test)
rm(y_train)
rm(y_test)
rm(subject_train)
rm(subject_test)

# 2. Get only mean and standard deviation for each measurement status.
extract <- grepl("mean|std", features)
x <- x[,extract]

# 3. Use descriptive activity names to name the activities in the data set
y <- activity_labels[y[,1]]

names(subject) <- "subject"

#merge datasets - column bind
tidydata <- cbind(subject, y, x)
rm(x)
rm(y)
rm(subject)

# 4. Appropriately label the data set with descriptive variable names. 
names(tidydata)[1:2] <- c("subject", "activity")

#create summary dataset
groups <- group_by(tidydata,subject,activity)
rm(tidydata)
means <- summarise_each(groups,funs(mean))
rm(groups)
write.table(means, file = "./means.txt", row.name=FALSE)
#rm(means)
