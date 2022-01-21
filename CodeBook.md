# John Hopkins University - Getting and Cleaning Data Course
## Capstone Project - Human Activity Recognition Using Smartphones

### Contents
- [Source Data](#source-data)
- [Description of Project](#description-of-project)
- [Usage](#usage)
  - [Assumptions](#assumptions)
- [Outputs](#outputs)
- [Description of Data](#description-of-data)
  - [Measurement Types](#measurement-types)
  - [final Dataset](#final-dataset)
    - [Factors](#factors)
  - [final_summary Dataset](#final_summary-dataset)
- [Transformations](#transformations)
  - [Reading the data](#reading-the-data)
  - [Tidying the data](#tidying-the-data)
  - [Combining the data](#combining-the-data)
  - [Producing the summary](#producing-the-summary)

### Source Data
The raw data set was obtained from the UCI Machine Learning Repository and represents the recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors.

Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.

A full description of the source data can be found [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones), while the dataset itself can be downloaded from [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

### Description of Project
The purpose of this project is to extract calculated means and standard deviations for each of the derived measurement types for both train and test data sets and to produce a combined data set that adheres to tidy data principles (best outlined by Hadley Whickham's paper titled [Tidy Data](https://vita.had.co.nz/papers/tidy-data.pdf)). From this, produce a second, independent tidy data set with the average of each variable for each activity and each subject.

Further reading on the methodology, assumptions and reasoning for the format of the tidied data can be found below in [Transformations](#transformations) and in the [README file](./README.md).

### Usage
    run_analysis

To read in the summarised tidy data set, use the following code:

    data <- read.table('summarised_Samsung_Galaxy_S_accelerometers.txt', header = TRUE)
    View(data)

To read in the full data set, use the following code:

    data <- read.csv('./data/processed/tidy_Samsung_Galaxy_S_accelerometers.csv')
    View(data)
    
#### Assumptions:
- The Human Activity Recognition Using Smartphones Dataset has been unzipped to ./data/raw, its original file structure preserved.
- The file dataset.R containing functions for the processing of the dataset is found in ./src
- The following libraries have been installed on the machine running this script: dplyr, tidyr, readr, stringr

### Outputs
When run, the script will produce two datasets and one file:
- **final**: dataset containing the full set of data from the test and train datasets as described above
- **final_summary**: dataset containing the summary of the final dataset as described above
- **summarised_Samsung_Galaxy_S_accelerometers.txt**: fixed width format file containing the data from the final summary, written to the same directory as the script.

### Description of Data

Both data sets treat the derived measurement types as separate observations. Some of these have a direction component (X, Y, Z). split out to one observation per direction. Some types have a time measurement, some have a frequency measurement, some have both. 

In this manner, there are 13 distinct types of derived measurement.

#### Measurement Types

A list of these measurement types and their characteristics is shown below.

|Measurement        |Directional|Time     |Frequency|Description|
|-------------------|-----------|---------|---------|---------|
|BodyAcc            |Yes         |Yes |Yes      |Body Acceleration|
|GravityAcc         |Yes         |Yes |No       |Gravity Acceleration|
|BodyAccJerk        |Yes         |Yes |Yes      |Body Acceleration Jerk|
|BodyGyro           |Yes         |Yes |Yes      |Body Angular Velocity|
|BodyGyroJerk       |Yes         |Yes |No       |Body Angular Velocity Jerk|
|BodyAccMag         |No        |Yes |Yes      |Body Acceleration Magnitude|
|GravityAccMag      |No        |Yes |No       |Gravity Acceleration Magnitude|
|BodyAccJerkMag     |No        |Yes |No       |Body Acceleration Jerk Magnitude|
|BodyGyroMag        |No        |Yes |No       |Body Angular Velocity Magnitude|
|BodyGyroJerkMag    |No        |Yes |No       |Body Angular Velocity Jerk Magnitude|
|BodyBodyAccJerkMag |No        |No  |Yes      |Body Acceleration Jerk Magnitude|
|BodyBodyGyroMag    |No        |No  |Yes      |Body Angular Velocity Magnitude|
|BodyBodyGyroJerkMag|No        |No  |Yes      |Body Angular Velocity Jerk Magnitude|

#### final Dataset
A dataframe with 236,877 observations and 10 variables.

Represents the combined data from both test and train in best determined tidy format for the purpose of final output. 

As per the requirements, only data from those columns from the original data relating to mean and std of each measurement type are included. Here, interpreted to be those columns containing the sub-string mean() and std(). See the README.md file for reasoning behind this.

|Variable        |Description                                                                                                                                                      |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
|measurementID *int*|Arbitrary ID that identifies the measurement row that the measured value was taken from. Retains the ability to group data by measurement if needed.             |
|subjectID *num*|The ID of the subject (participant) the measurement relates to. |
|activity *factor*|The type of activity the participant was undertaking for the measurement.|
|measurement_type *factor*|The derived measurement type (see below).|
|direction *chr*|If applicable, the direction component of the derived measurement (X, Y, Z) or N/A if not applicable.                                                             |
|time_mean *num*|If the derived measurement has a time component, the mean for the measurement is displayed here.                                                                 |
|time_std *num*|If the derived measurement has a time component, the standard deviation for the measurement is displayed here.                                                  |
|frequency_mean *num*|If the derived measurement has a frequency component, the mean for the measurement is displayed here.                                                            |
|frequency_std *num*|If the derived measurement has a frequency component, the standard deviation for the measurement is displayed here.                                             |
|source *chr*|Column to indicate if the measurement came from the training or test dataset. Retains the ability to subset the data based on source should the need arise later.|

**Note**: the code book for the source data does not specify the units for the derived time and frequency measurements. It is assumed here that they are in Standard International units (seconds and Hertz respectively).

##### Factors
Two variables are factored, the levels applied in the order that they appear in the raw data:

`activity` is applied as per the original code value:
|   |   |
|---|---|
|1  | WALKING           |
|2  | WALKING_UPSTAIRS  |
|3  | WALKING_DOWNSTAIRS|
|4  | SITTING           |
|5  | STANDING          |
|6  | LAYING |

`measurement_type` is ordered as per column order in the raw data:
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

#### final_summary Dataset
A dataframe with 4,140 observations and 8 variables.

In the raw dataset (and therefore the final), for each activity, each measurement was recorded multiple times (although the number of times is not consistent across subjects). 

The final_summary dataset represents the average of each measurement type for each activity and each subject (participant). As per the final dataset, if a measurement type has directional components (X, Y, Z) then these are kept as separate observations. Additionally, means and standard deviations for time and frequency measurements are displayed in their own columns. Where there is no time measurement for a measurement type, a value of `NA` is returned for those columns, likewise for frequency.

See [Transformations](#transformations) below for more information.

From the description for the required output, it is interpreted as *"for each activity, then for each subject, calculate the average mean and std values for each observation"*, and is therefore grouped in the order `activity`, `subjectID`, `measurement_type`, `direction`.
|Variable        |Description                                                                                                                                                      |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|
|activity *factor*|The type of activity the participant was undertaking for the measurement.|
|subjectID *num*|The ID of the subject (participant) the measurement relates to.|
|measurement_type *factor*|The derived measurement type (see below).|
|direction *chr*|If applicable, the direction component of the derived measurement (X, Y, Z) or N/A if not applicable.|
|avg_time_mean *num*|If the derived measurement has a time component, the average of the mean for the measurement is displayed here.|
|avg_time_std *num*|If the derived measurement has a time component, the average of the standard deviation for the measurement is displayed here.|
|avg_frequency_mean *num*|If the derived measurement has a frequency component, the average of the mean for the measurement is displayed here.|
|avg_frequency_std *num*|If the derived measurement has a frequency component, the average of the standard deviation for the measurement is displayed here.|

### Transformations
Each dataset is read and tidied before being combined.

Details of each function named here are described in README.md

#### Reading the data
Before reading the data files, the common files containing the activity labels and the X data file column headers are read:
1. `get_activity_labels()` reads activity_labels.txt from the raw data root directory
2. `get_mean_std_cols()` reads features.txt from the same directory then subsets to only include those column names containing the sub-string mean() or std()

Both of these functions are found in ./src/dataset.R

There are three data files to be read for each dataset which is handled by the `create_data_set()` function found in ./src/dataset.R

1. X_*dataset*.txt containing the measurement data
2. y_*dataset*.txt containing the activity code being performed for each measurement in X
3. subject_*dataset*.txt containing the ID of the subject (participant) for each measurement in X

The process then for assembling the base data for each dataset (test & train) is:
1. Read the dataset selecting only the subsetted feature list, set all columns to numeric
2. Set column names to feature description
3. Read activity list for dataset
4. Apply activity names to activity list
5. Create factor for activity labels in the order they appear in the activity_labels.txt definition file. Sorting by activity will be by their numeric order rather than alphabetically. 
6. Read subject list for dataset
7. Create unique ID for each measurement
8. Combine dataframes to add measurementID, subjectID and activity into one data set using `bind_cols()`

#### Tidying the data
The data tidying process is handled entirely by the `tidy_dataset()` function found in ./src/dataset.R, which is run once each for test and train data before merging.

The logic used (where the reasoning is discussed in README.md) is that each measurement type (and their directional component where applicable) is an observation (i.e. a row). 

Direction is considered a variable of an observation which could be X, Y, Z or N/A. Where there are directional components for a measurement type, there will be three observations per measurement (X, Y, Z). The directional component is not applicable to all measurement types. For those types, there will be one observation.

The mean and standard deviation for the time measurement, and the mean and standard deviation for the frequency measurement are all considered variables of each of those observations. 

For certain measurement types, time measurements may not exist, while for others, frequency measurements may not exist.

In all, there are 23 observations per measurement.

For example, taking the raw data for `BodyAcc`, there are 12 columns relating to mean and std:

|Column Index|Measurement Variable|
|------------|--------------------|
|1           |tBodyAcc-mean()-X   |
|2           |tBodyAcc-mean()-Y   |
|3           |tBodyAcc-mean()-Z   |
|4           |tBodyAcc-std()-X    |
|5           |tBodyAcc-std()-Y    |
|6           |tBodyAcc-std()-Z    |
|266         |fBodyAcc-mean()-X   |
|267         |fBodyAcc-mean()-Y   |
|268         |fBodyAcc-mean()-Z   |
|269         |fBodyAcc-std()-X    |
|270         |fBodyAcc-std()-Y    |
|271         |fBodyAcc-std()-Z    |

These columns will be converted from:

|tBodyAcc-mean()-X|tBodyAcc-mean()-Y|tBodyAcc-mean()-Z|tBodyAcc-std()-X|tBodyAcc-std()-Y|tBodyAcc-std()-Z|fBodyAcc-mean()-X|fBodyAcc-mean()-Y|fBodyAcc-mean()-Z|fBodyAcc-std()-X|fBodyAcc-std()-Y|fBodyAcc-std()-Z|
|-----------------|-----------------|-----------------|----------------|----------------|----------------|-----------------|-----------------|-----------------|----------------|----------------|----------------|

To:
|measurement_type|direction|time_mean|time_std|frequency_mean|frequency_std|
|----------------|---------|---------|--------|--------------|-------------|
|BodyAcc         |X        |         |        |              |             |
|BodyAcc         |Y        |         |        |              |             |
|BodyAcc         |Z        |         |        |              |             |


For measurement types with no directional component, this will be a single observation with the direction value set to the string 'N/A'.

The process for this is as follows:
1. Gather columns - one row per measurement & aggregate type.
2. Separate gathered column based on direction vector x, y, z or none.
3. Swap direction NA's for string 'N/A'.
4. Separate the aggregate type for each measurement type (mean, std).
5. Create a column indicating whether each measurement was for time or frequency.
6. Strip the t/f prefix of each measurement type.
7. Create a factor for the measurement types based on current order (still in original) sorting will be on their column order as they appeared in the original X data file rather than alphabetically.
8. Combine domain and aggregate type column values (ie time & mean -> time_mean etc).
9. Spread the combined values (combine the rows for the same measurement id & type to create one column for each the of the aggregates, 4 in total).
10. Add a column to indicate the source of the rows in this dataset.
11. Move time column in front of the frequency columns to reflect order in original data.
12. Sort by measurementID > activity > measurement_type.

#### Combining the data
Once both data sets have been read and tidied, the `measurementID` of the test data is incremented by the maximum value of `measurementID` in the training set to ensure a continuous series and no conflicts.

The final step is to combine the two sets using `bind_rows()`.

#### Producing the summary
No transformation is required for this stage:
1. The complete dataset is passed through a set of `dplyr` functions to group by `activity`, `subjectID`, `measurement_type` & `direction`.
2. Summarise with mean for each of the four value columns. The columns are named `avg_time_mean`, `avg_time_std`, `avg_frequency_mean` & `avg_frequency_std` respectively.
3. Replace all `NaN` values with `NA` where those measurement types do not have a time or frequency value.