# John Hopkins University - Getting and Cleaning Data Course
## Capstone Project - Human Activity Recognition Using Smartphones

### Contents
- [Files included in this repository](#files-included-in-this-repository)
- [Order of project requirements](#order-of-project-requirements)
- [Interpreting the requirements](#interpreting-the-requirements)
  - [Step 2](#step-2)
  - [Step 4](#step-4)
  - [Step 5](#step-5)
- [Determining observsation vs variables](#determining-observation-vs-variables)
  - [Direction Components](#direction-components)
  - [Mean and Standard Deviation Values](#mean-and-standard-deviation-values)
  - [Time and Frequency Values](#time-and-frequency-values)
  - [The value of breaking the data down further](#the-value-of-breaking-the-data-down-further)
- [The Process](#the-process)
  - [Reading the Data](#reading-the-data)
  - [Tidying the data](#tidying-the-data)
  - [Merging the training and the test data sets](#merging-the-training-and-the-test-data-sets)
  - [Creating the summarised data set](#creating-the-summarised-data-set)
- [A final note on memory management](#a-final-note-on-memory-management)

### Files included in this repository
|File Name                                                |Description                                                                  |
|---------------------------------------------------------|-----------------------------------------------------------------------------|
|./CodeBook.md                                            |Description of the project, the data files and non-technical description of the transformation and tidying methods used.|
|./data/processed/tidy_Samsung_Galaxy_S_accelerometers.csv|Output file of the non-summarised tidied data (not required for the project).|
|./summarised_Samsung_Galaxy_S_accelerometers.txt         |Output fixed width data file of the summarised data.                         |
|./Getting and Cleaning Data Course Project.Rproj         |Project file for loading the project in R Studio.                            |
|./README.md                                              |Discussion of the projects - reasons for tidying the data in the format used & technical description of functions in the main script|
|./run_analysis.R                                         |Main script to produce both the combined and summarised datasets and output the finalised summary to file|
|./src/dataset.R                                          |Functions for reading transforming and tidying the split data sets          |

### Order of project requirements
Requirements have been addressed in the following order:

- \#2.Extract only the measurements on the mean and standard deviation for each measurement.
- \#4.Appropriately label the data set with descriptive variable names.
- \#3.Use descriptive activity names to name the activities in the data set.
- \#1.Merge the training and the test sets to create one data set.
- \#5.From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

### Interpreting the requirements
#### Step 2
>Extract only the measurements on the mean and standard deviation

While standard deviation is straightforward (all those columns with the sub-string *-std()*), there are many columns that do not include *-mean()* but which include the word mean in the feature name:

|Column Index|Feature Name                        |
|------------|------------------------------------|
|294         |fBodyAcc-meanFreq()-X               |
|295         |fBodyAcc-meanFreq()-Y               |
|296         |fBodyAcc-meanFreq()-Z               |
|373         |fBodyAccJerk-meanFreq()-X           |
|374         |fBodyAccJerk-meanFreq()-Y           |
|375         |fBodyAccJerk-meanFreq()-Z           |
|452         |fBodyGyro-meanFreq()-X              |
|453         |fBodyGyro-meanFreq()-Y              |
|454         |fBodyGyro-meanFreq()-Z              |
|513         |fBodyAccMag-meanFreq()              |
|526         |fBodyBodyAccJerkMag-meanFreq()      |
|539         |fBodyBodyGyroMag-meanFreq()         |
|552         |fBodyBodyGyroJerkMag-meanFreq()     |
|555         |angle(tBodyAccMean,gravity)         |
|556         |angle(tBodyAccJerkMean),gravityMean)|
|557         |angle(tBodyGyroMean,gravityMean)    |
|558         |angle(tBodyGyroJerkMean,gravityMean)|
|559         |angle(X,gravityMean)                |
|560         |angle(Y,gravityMean)                |
|561         |angle(Z,gravityMean)                |

I have omitted the meanFreq() columns based on information in features_info.txt:
> meanFreq(): Weighted average of the frequency components to obtain a mean frequency

From this, I have interpreted this as the meanFreq() value is a factor used to calculate the mean() value so should not be included in the set.

The final 7 angle values appear to be vector values:
> Additional vectors obtained by averaging the signals in a signal window sample.

While mean values may have been used to calculate these, I have not interpreted these as needing to be included in the required dataset.

#### Step 4
>Appropriately label the data set with descriptive variable names. 

I have understood this to mean apply the feature name to each of the imported columns. Labelling can also imply using the R's `label()` function to add descriptive metadata, so this could be interpreted two ways.

#### Step 5
>From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

Variable maybe not the right choice of words here since, depending on the format of the tidied data, there may not be many variables, and of these, it may not even make sense to make mean calculations of those as asked.

I've interpreted this as variables in the raw 'X' files, where each measurement is a single observation ascribed to a particular participant performing a single action and each type of derived measurement is a variable.

Additionally, in my case, Step 4 is completed early in the process and Step 1 is the final stage of assembling the tidied data. For clarity my interpretation of Step 5 is:
>From the final tidied data set created in the steps above, create a second, independent tidy data set with the average of each of the variables found in Step 2 for each activity and each subject.

This also implies that where there is a directional component being measured (X, Y, Z) then an average value for mean and standard deviation is calculated for each of those.

### Determining observation vs variables
There are many ways to slice and dice this dataset, each satisfying the first two principle requirements for tidy data (according to [Hadley Wickham's Tidy Data (Section 2.3)](https://vita.had.co.nz/papers/tidy-data.pdf))

1. Each variable forms a column.
2. Each observation forms a row.

How to apply this to the Human Activity Recognition Using Smartphones dataset?

In the subsetted dataset, there are 66 variables to consider for each measurement.

Scanning these variables, certain patterns start to emerge:

#### Direction Components
Some variables are suffixed with a directional component (-X, -Y, -Z) e.g. `fBodyAcc-mean()-X`, `fBodyAcc-mean()-Y`, `fBodyAcc-mean()-Z`. Each of these is measure of `fBodyAcc-mean()` but in a different direction. 

Should they ever be combined into one value? Quick analysis shows some very different values for each of these which would suggest no. They are separate observations. 

Could it be useful to group data based on either direction or the stem variable being measured? Yes. 

For these reasons, the direction is a variable and split off the measurement type while each remains an observation:

    tBodyAcc-mean()-X | tBodyAcc-mean()-Y | tBodyAcc-mean()-Z

becomes

    tBodyAcc-mean() | X
    tBodyAcc-mean() | Y
    tBodyAcc-mean() | Z

How to deal with those variables that don't have directional component? The direction variable will just have an 'N/A' value for the direction variable.

#### Mean and Standard Deviation Values
The mean and standard deviation values are suffixed with `-mean()` and `-std()` respectively. Since they are measures of two different values for the same observation, they remain a variable in the final dataset. 

Stripping away the suffixes for each leaves us with `tBodyAcc` & `fBodyAcc`.

#### Time and Frequency Values
Each variable is prefixed with a t or f to indicate if this was a measurement in the time domain (seconds) or frequency domain (Hertz). Further, there is often a t and f value for the same measurement variable (e.g. `tBodyAcc` and `fBodyAcc`).

Since they are both values of different qualities for the same derived measurement type (`BodyAcc`), they should be considered variables of the same observation. This leaves us with a derived measurement type with four possible values: 

1. time mean
2. time standard deviation
3. frequency mean
4. frequency standard deviation

#### The value of breaking the data down further
We're left with 13 measurement types:

|   |   |
|---|---|
|1  | BodyAcc           |
|2  | GravityAcc  |
|3  | BodyAccJerk|
|4  | BodyGyro           |
|5  | BodyGyroJerk          |
|6  | BodyAccMag |
|7  | GravityAccMag |
|8  | BodyAccJerkMag |
|9  | BodyGyroMag |
|10  | BodyGyroJerkMag |
|11 | BodyBodyAccJerkMag |
|12 | BodyBodyGyroMag |
|13 | BodyBodyGyroJerkMag |

It's possible to split further breaking into 2 groups for those that begin with Body and those with Gravity. Or does each core type require its own group (e.g. `BodyAcc`, `BodyGyro`, `GravityAcc` etc.) from which additional measurement types may be derived.

In the end, it comes down to what is the right format for the requirement at hand (and perhaps a few proactive additional features if they don't incur unnecessary time and performance, such as the additional measurementID and source columns here which will allow additional methods of grouping and subsetting in the future if required).

>Tidy data is only worthwhile if it makes analysis easier. *- Hadley Wickham*

For the requirements of this project, I've gone with treating each of the measurement types above as an observation (including one observation each for their directional component where applicable):

Taking the `BodyAcc` example above, the messy data is formatted:
|tBodyAcc-mean()-X|tBodyAcc-mean()-Y|tBodyAcc-mean()-Z|tBodyAcc-std()-X|tBodyAcc-std()-Y|tBodyAcc-std()-Z|fBodyAcc-mean()-X|fBodyAcc-mean()-Y|fBodyAcc-mean()-Z|fBodyAcc-std()-X|fBodyAcc-std()-Y|fBodyAcc-std()-Z|
|-----------------|-----------------|-----------------|----------------|----------------|----------------|-----------------|-----------------|-----------------|----------------|----------------|----------------|

Which is transformed to:
|measurement_type|direction|time_mean|time_std|frequency_mean|frequency_std|
|----------------|---------|---------|--------|--------------|-------------|
|BodyAcc         |X        |         |        |              |             |
|BodyAcc         |Y        |         |        |              |             |
|BodyAcc         |Z        |         |        |              |             |

This is repeated for each of the 13 measurement types. Those with no directional component will be a single observation and a string value `'N/A'` in the direction column. Those measurement types with no time values will have a value of `NA` in those columns, likewise for those with no frequency values.

The details of how this is achieved is discussed below.

### The Process
As mentioned earlier, I found the steps best completed out of order. For performance reasons (mostly reducing the amount of memory required), I read and tidied each dataset separately before combining at the end. Stage 1 and Stage 2 discussed below are run once each for test and train.

#### Reading the Data

This stage takes care of the following requirements, in the following order:

 - \#2.	Extract only the measurements on the mean and standard deviation for each measurement. 
 - \#4.	Appropriately label the data set with descriptive variable names. 
 - \#3.	Use descriptive activity names to name the activities in the data set.

The first step here is to read the `features.txt` file and subset the list of features to only those containing the string mean() or std() (see [Interpreting the requirements](#interpreting-the-requirements) above)

The function `get_mean_std_cols()` in datasets.R takes care of this:

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

This gives us a dataframe of the feature names we want and the column index for each. 

To meet Step 3, we'll also need to read in the `activies_labels.txt` dataset. This is achieved with the function get_activity_labels() from dataset.R:

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

The function `create_data_set()` in dataset.R does the reading from the three dataset files plus applies the data read in from activity labels and features above. This function is run once each for the test and train datasets:

	# function: create_data_set
	#
	# Read the X data table from file, add column names and swap activity codes
	# for the corresponding label. 
	# Read the Y data table to include the corresponding subject ID for each measurement.
	# Create a data table with abitrary measurement ID to allow accessing each measurement 
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
	#   Data frame containing all relevant columns labelled with Activity ID's swapped for 
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

The above function completes the following project requirements:

**Step 2**
The `read_fwf` command pulls in only desired data using the column indices founds in the `get_mean_std_cols()` function. Additionally, since we know that the columns from this data source are all of type `number`, we can set this before reading to improve performance and avoid R needing to run 'best guess' algorithms.

**Step 4**
Each variable is labelled with the corresponding feature name using the following command above:

    names(x) <- dfFeatures$description

**Step 3**
The activity codes are replaced with the appropriate label from activity_labels with the following command:

    activity <- lapply(activity, function(x) dfActivityLabels$description[match(x, dfActivityLabels$index)])

Note that a factor is applied to the activity column so that when that column is sorted, it's sorted according to the numeric code value rather than being sorted alphabetically.

#### Tidying the data
The complete tidy process is handled by the function `tidy_dataset()` found in dataset.R. It is run once each for the test and train datasets prior to merging.

From the tidy data structure determined above in [Determining obversation vs variables](#determining-obversation-vs-variables), the first step is to gather all the variables together into one column then separate them into direction and value variables.


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

As well as meeting the intended tidy data structure, the above code adds a factor to the `measurement_type` column so that the column is sorted according to the column index of those original variables rather than sorting alphabetically.

#### Merging the training and the test data sets
Now that there are two identically formatted tidy sets, merging the two is a simple matter of using the `dplyr` function `bind_rows()`:

    final <- bind_rows(dfTidyTrain, dfTidyTest) 

This satisfies the first project requirement.

#### Creating the summarised data set

With the dataset combined and in tidy format, producing the summarised data is straightforward using `dplyr`:

    final_summary <- final %>% 
        group_by(activity, subjectID, measurement_type, direction) %>%
        summarise(
            avg_time_mean = mean(time_mean, na.rm = T), 
            avg_time_std = mean(time_std, na.rm = T),
            avg_frequency_mean = mean(frequency_mean, na.rm = T), 
            avg_frequency_std = mean(frequency_std, na.rm = T)
        ) %>% 
        mutate_at(vars(-group_cols()),~ifelse(is.nan(.), NA,.))

Because not all measure types have both time and frequency measurements, those missing values will result in `NaN` values. The final set converts those values to `NA`.

That's the fifth and final requirement met.

### A final note on memory management
Because this script deals with some large datasets, those no longer required are removed from memory, notably the pre-tidy dataframes once the tidy has completed, and the test/train tidy dataframes once the merge has completed. 

Additionally a garbage clean call (`gc()`) is made after merging to free up any memory still being allocated for deleted objects.




