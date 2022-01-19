# dataset.R 
# Functions used to read and tidy the data for run_analysis.R
# Explanation for each function below

library(dplyr)
library(tidyr)
library(readr)

# function: get_mean_std_cols
#
# Read the features_list and return a list of all those ending with mean() or std()
# Used to load a subset of the X data files pertaining to mean and std data
#
# Args:
#   filename: path to the feature_list.txt file
#
# Returns:
#   dataframe containing index and description of column names that correspond to 
#   mean() and std() values for each measurement type
#
get_mean_std_cols <- function(filename){
  # Read the features list
  features <- read_delim(filename, 
                         delim=" ", 
                         col_names = c('index', 'description'),
                         show_col_types = FALSE
  )
  # Subset the features only relating to std() or mean()
  mean_features<-features[grep('mean\\()|std\\()',features$description),]
}

# function: get_activity_labels
#
# Read the activity labels definitions table. Used to swap out the activity
# code in the X file for the actual label for the activity
#
# Args:
#   filename: path to the activity_labels.txt file
#
# Returns:
#   Data frame containing 'index', 'description' columns listing code and label
#   for each recorded activity
#   
get_activity_labels <- function(filename){
  # Read the activity labels
  activity_labels <- read_delim(activity_label_list, 
                                delim=" ", 
                                col_names = c('index', 'description'),
                                show_col_types = FALSE
  )
}

# function: create_data_set
#
# Read the X data table from file, add column names and swap activity codes
# for the corresponding label. 
# Read the Y data table to include the corresponding subject ID for each measurement.
# Create a data table with abritrary measurement ID to allow accessing each measurement 
# even after columns have been collapsed.
# Combine all three tables.
#
# Run once each for test and train datasets
#
# Args:
#   dataFile - path to the 'X' data file containing all measurements
#   activityFile - path to the 'Y' data file containing the activity ID for each measurement
#   subjectFile - path to the 'subject' data file containing the subject ID for each measurement
#   dfFeatures - dataframe containing index and description of column names that correspond to 
#       mean() and std() values for each measurement type
#   dfActivityLabels - data frame containing 'index', 'description' columns listing code and label
#       for each recorded activity
#
# Returns:
#   Data frame containing all relevant columns labelled with Acivity ID's swapped for 
#   relevant labels and an added generated measurement ID (not included in raw data)
#   Returned dataframe has an index on the activity in order of activity code
#   
create_data_set <- function(dataFile, activityFile, subjectFile, dfFeatures, dfActivityLabels){
  # Read the dataset selecting only the subsetted feature list, set all columns to numeric
  x<-read_fwf(dataFile, 
              col_types = rep('n', times = nrow(dfFeatures)),
              col_select = dfFeatures$index,
              show_col_types = FALSE
  )
  
  # Set column names to feature description
  names(x) <- dfFeatures$description
  
  # Read activity list for dataset
  activity <- read_table(activityFile, 
                         col_names = 'activity'
  )
  
  # Apply activity names to activity list
  activity <- lapply(activity, function(x) dfActivityLabels$description[match(x, dfActivityLabels$index)])
  
  # Create factor for activity labels in the order they appear in the activity_labels
  # definition file. Sorting by activity will be by their numeric order rather than alphabetically.
  activity$activity <- factor(factor(activity$activity),levels=dfActivityLabels$description)
  
  # read subject list for dataset
  subjects <- read_table(subjectFile, 
                         col_names = 'subjectID'
  )
  
  # create unique ID for each measurement
  id <- data.frame(measurementID = seq.int(nrow(x)))
  
  # combine dataframes to add measurementID, subjectID and activity to main data set
  bind_cols(id, subjects, activity, x)
}

# function: tidy_dataset
#
# Take a dataset prepared by create_data_set and transformed according to tidy 
# data principles
#
# Args:
#   dataset: dataframe to clean
#   datasource: string to indicate which set this came from (test or train)
#
# Returns:
#   Data frame containing 'index', 'description' columns listing code and label
#     for each recorded activity
#   Measurement columns are collapsed as each base type of measurement is
#     considered an instance of measurement type
#   Direction is considered a variable and can take X, Y, Z or N/A as appropriate
#   Each domain (time or frequency) has it's own mean and std variable
#   For example, the measurement tBodyAcc-mean()-X is considered a mean of a set of
#     time measurements of BodyAcc in the X direction
tidy_dataset <- function(dataset, datasource) {
  
  # gather columns - one row per measurement & aggregate type
  # separate gathered column based on direction vector X, Y, Z or none 
  # swap direction NA's for string N/A
  # separate the aggregate type for each measurement type (mean, std)
  # create a column indicating whether each measurement was for time or frequency
  # strip the t/f prefix of each measurement type
  # use suppressWarnings to avoid long list of NAs warnings on first seperate call
  suppressWarnings({
    dataset<-dataset %>% 
      gather('type', 'value', -c(measurementID, subjectID, activity)) %>% 
      separate(col=type, into=c("what", "direction"), sep = '-(?=[-X]$)|-(?=[-Y]$)|-(?=[-Z]$)') %>% 
      replace_na(list(direction = 'N/A')) %>% 
      separate(col=what, into=c('measurement_type', 'aggregate_type')) %>%  
      mutate(
        domain = substring(measurement_type, 1, 1)
      ) %>%
      mutate(
        domain = stringr::str_replace_all(domain, c('t'='time', 'f'='frequency')),
        measurement_type = stringr::str_replace(measurement_type,"^t|^f","")
      )
  })
  
  # create a factor for the measurement types based on current order (still in original)
  # sorting will be on their column order as they appeared in the original X file
  # rather than alphabetically
  dataset$measurement_type <- factor(
    factor(dataset$measurement_type),
    levels=unlist(unique(dataset$measurement_type))
  )
  
  # combine domain and aggregate type column values (ie time & mean -> time_mean etc)
  # spread the combined values (combine the rows for the same measurement ID & type
  #   to create one column for each the of the aggregates, 4 in total)
  # add a column to indicate the source of the rows in this dataset
  # move time column in front of the frequency columns to reflect order in original X
  # sort by measurementID > activity > measurement_type
  dataset %>% 
    unite(temp, domain, aggregate_type) %>% 
    spread(temp, value) %>% 
    mutate(source = datasource) %>% 
    relocate(time_mean, time_std, .after = direction) %>%
    arrange(measurementID, activity, measurement_type)
  
}