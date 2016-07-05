## Your working directory must be the root of the 
## data files used in the below script.

library(dplyr)
library(plyr)

## URLs
activity_labels_url <- "activity_labels.txt"
features_url <- "features.txt"

x_train_url <- "train/X_train.txt"
y_train_url <- "train/y_train.txt"
subject_train_url <- "train/subject_train.txt"

x_test_url <- "test/X_test.txt"
y_test_url <- "test/y_test.txt"
subject_test_url <- "test/subject_test.txt"


## Load
activity_labels <- read.table(activity_labels_url)
features <- read.table(features_url)
x_train <- read.table(x_train_url)
y_train <- read.table(y_train_url)
subject_train <- read.table(subject_train_url)
x_test <- read.table(x_test_url)
y_test <- read.table(y_test_url)
subject_test <- read.table(subject_test_url)

## Bind
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

## Names
names(x_data) <- as.character(features$V2)
names(subject_data) <- c("subject")

## Bind Activity Codes
x_data <- cbind(x_data, y_data)

## Bind subject codes
x_data <- cbind(x_data, subject_data)

## x_data and activity_labels should both have a 'V1' variable. Use this to join
x_data <- left_join(x_data, activity_labels)

## Remove 'V1' column as it's no longer needed
x_data$V1 <- NULL

## Rename column 'V2'
v2_ind <- which(names(x_data) == "V2")
names(x_data)[v2_ind] <- "activity"

## convert to tbl_df
x_data <- tbl_df(x_data)

## Find columns with mean() or std() and add 'activity' and 'subject' to beginning.
x_names <- names(x_data)
mean_std_cols <- grep("mean[()]|std[()]", x_names)
col_nums <- c(which(x_names == "subject"), which(x_names == "activity"), mean_std_cols)
x_subset <- x_data[,col_nums]

## Clean names. Remove brackets and caps.
names(x_subset) <- tolower(gsub("[()]","",names(x_subset)))

## Group & summarize
x_grouped <- group_by(x_subset, subject, activity)
x_final <- summarise_each(x_grouped, funs(mean))

## Write
write.table(x_final, row.names = FALSE, file = "subjecActivityMean.txt")

