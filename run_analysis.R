# file: run_analysis.R
#
# Code to read mean and std raw data from the 
# Human Activity Recognition Using Smartphones Dataset
#
# Outputs a dataset comprising of:
#   1.  A combined dataset of train and test data, transformed according to 
#       tidy data principles
#   2.  A summarised dataset of #1 show mean of the aggregate values by
#       activity, subject ID, measurement type & direction component
#   3.  A fixed width file containing the dataset produced in #2
#       titled directional_summarised_Samsung_Galaxy_S_accelerometers.txt
#       to be found in the same folder as this script
#
# There are two commented lines produce a csv containing the combined dataset
# (not required for this project)
#
# Assumptions:
#   The Human Activity Recognition Using Smartphones Dataset has been unzipped
#   to ./data/raw, its original file structure preserved.
#   The file dataset.R containing functions for the processing of the dataset
#   is found in ./src
#   The following libraries have been installed on the machine running this script:
#     dplyr, tidyr, readr, stringr
#       
# Addresses project requirements in the following order:
# 2.	Extract only the measurements on the mean and standard deviation for each measurement. 
# 4.	Appropriately label the data set with descriptive variable names. 
# 3.	Use descriptive activity names to name the activities in the data set
# 1.	Merge the training and the test sets to create one data set.
# 5.	From the data set in step 4, create a second, independent tidy data set with 
#       the average of each variable for each activity and each subject.
#
source(file.path('.', 'src', 'dataset.R'))

## File Path Definitions

##  Common Files
features_list <- file.path('.', 'data', 'raw', 'features.txt')
activity_label_list <- file.path('.', 'data', 'raw', 'activity_labels.txt')

##  Test Files
X_test <- file.path('.', 'data', 'raw', 'test', 'X_test.txt')
Y_test <- file.path('.', 'data', 'raw', 'test', 'y_test.txt')
subject_test <- file.path('.', 'data', 'raw', 'test', 'subject_test.txt')
##  Train Files
X_train <- file.path('.', 'data', 'raw', 'train', 'X_train.txt')
Y_train <- file.path('.', 'data', 'raw', 'train', 'y_train.txt')
subject_train <- file.path('.', 'data', 'raw', 'train', 'subject_train.txt')

## Get common data
colMeanStd <- get_mean_std_cols(features_list)
activities <- get_activity_labels(activity_label_list)

## Create & tidy training data set
dfTrain <- create_data_set(
  dataFile = X_train,
  activityFile = Y_train,
  subjectFile = subject_train,
  dfFeatures = colMeanStd,
  dfActivityLabels = activities
)
dfTidyTrain <- tidy_dataset(dfTrain, 'Train')
rm(dfTrain) # remove large dataset

## Create & tidy test data set
dfTest <- create_data_set(
  dataFile = X_test,
  activityFile = Y_test,
  subjectFile = subject_test,
  dfFeatures = colMeanStd,
  dfActivityLabels = activities
)
dfTidyTest <- tidy_dataset(dfTest, 'Test')
rm(dfTest) # remove large dataset

## Increment dfTrain measurement ID's to maintain unique ID's in combined datasets
dfTidyTest$measurementID <- dfTidyTest$measurementID + max(dfTidyTrain$measurementID)

## Combine the tidied datasets
final <- bind_rows(dfTidyTrain, dfTidyTest) 
rm(dfTidyTest) # remove large dataset
rm(dfTidyTrain) # remove large dataset

## free up memory
gc()

# Write final dataset to file
# outFile <- file.path('.', 'data', 'processed', 'tidy_Samsung_Galaxy_S_accelerometers.csv')
# write.csv(final, outFile)

# Create summaries - average mean, meanFreq and standard deviation for each
# measurement type, for each subject ID, for each activity
# Create second summary as above but split by directional property where it exists

# To skip recreating the combined tidy dataset and read prepaired data, uncomment the following two lines:
# dataFile <- file.path('.', 'data', 'processed', 'tidy_Samsung_Galaxy_S_accelerometers.csv')
# final <- read.csv(dataFile)

# Create summary - average mean and standard deviation for each
# measurement type (including direction), for each subject ID, for each activity
final_directional_summary <- final %>% 
  group_by(activity, subjectID, measurement_type, direction) %>%
  summarise(
    avg_time_mean = mean(time_mean, na.rm = T), 
    avg_time_std = mean(time_std, na.rm = T),
    avg_frequency_mean = mean(frequency_mean, na.rm = T), 
    avg_frequency_std = mean(frequency_std, na.rm = T)
  ) %>% 
  mutate_at(vars(-group_cols()),~ifelse(is.nan(.), NA,.))

## Write directional summarised final dataset to file
outFile <- 'directional_summarised_Samsung_Galaxy_S_accelerometers.txt'
write.table(final_directional_summary, outFile, row.names = F)


