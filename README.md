# bike-share_case-study
## A case study of real-world bike-share data acting as a capstone project for my Google Data Analytics Certificate.

![Tableau Map](https://drive.google.com/uc?export=view&id=1bPFttO5RU8FudxSmCibEroFeHRusWPQn)


## I. Background
Cyclistic is a fictional bike-sharing company that owns more than 5,800 bicycles and over 600 docking stations in the city of Chicago, IL.  Since their launch in 2016, Cyclistic has focused their marketing strategy on boosting general awareness and engaging broad consumer segments.  In order to appeal to the largest possible consumer base, Cyclistic has pricing plans for casual riders  via single-rides & day passes, and consistent riders via annual memberships.

The annual memberships have been found to be much more profitable to the company vs. the casual passes.  Instead of trying to sell annual memberships to brand new customers, the Cyclistic marketing team has decided to develop a marketing campaign to convert their casual riders into annual members.


## II. Business Task
In order to create a successful marketing campaign, the Cyclistic marketing team first needs to understand how the casual riders (**CR**) use the Cyclistic bikes differently from the annual members (**AM**).

Bike-share trip data for one year will be analyzed to answer:

- **What distinguishes a casual rider from an annual member?**
  - How many CR rides took place during the analysis year?
  - How long do CR ride?
  - What bike type do CR prefer?
  - Where do CR ride?
  - When do CR ride?


## III. Prepare
### Reliability of the data:
Cyclistic is a fictional company so -- for the sake of this case-study -- data from Divvy (an actual bike-share company) will be used.

Before analyzing, it's important to consider a few key aspects of the dataset:

- *Data Source*: the bike-share data came from this [Divvy site](https://divvy-tripdata.s3.amazonaws.com/index.html).
- *Licensing*: per this [Data License Agreement](https://divvybikes.com/data-license-agreement), the Divvy bike-share data is:
  - Collected by “Lyft Bikes and Scooters”.
  - Owned by the City of Chicago.
  - Available for public use.
- *Authenticity*: In order to independently verify the authenticity of the data, I was able to confirm that Divvy is owned by the City of Chicago via their website [www.chicago.gov](https://www.chicago.gov), and I was able to navigate to the data directly via the Divvy website [www.divvybikes.com](https://www.divvybikes.com).
- *Current*: The data has been regularly updated each month and is current as of August 2024.
- *Privacy*: This dataset has already been stripped of personally identifiable information (addresses, credit card info, etc.) so there is little concern about privacy issues.

Satisfied that I was working with an official dataset that is original, comprehensive, current, cited, and licensed for public use, I continued with the analysis.

### Time span of the data:
Cyclistic's executive team is primarily interested in the differences between CR and AM, so I will focus on data from the 12 months spanning *9/1/23 - 8/31/2024*.  Older data may skew the results since the usage of the bikes by both CR and AM has likely changed since the company’s inception in 2013.

### Initial data download and storage:
In order to get the bike-share data ready for processing, I performed the following steps:
- Downloaded the 12 monthly original csv files to a personal, unshared folder on Google Drive.
- Stored files in an original csv file folder to retain the original datasets.
- Used the below **cmd** prompt to create one combined csv file from the 12 originals.
  - *`C:\path\to\my\csv_files> copy *.csv combined-divvy-tripdata.csv`*
- Searched for a processing and analysis tool that could handle almost 6,000,000 rows of data.
  - Decided R via RStudio was the best tool for the task.
  - For a detailed description on my search for the best tool, please see the [Appendix](https://github.com/MikeDavidG2/bike-share_case-study/blob/main/04a_Appendix_bike-share_case-study.pdf).


## IV. Process
The data processing steps can be found in the HTML file [01a_Process-bike-tripdata.html](https://mikedavidg2.github.io/bike-share_case-study/01a_Process-bike-tripdata.html) on GitHub.  This document details how the bike-share trip data was:
- Loaded into R.
- Inspected with multiple EDA functions.
- Simplified with the removal of unneeded rows and columns.
- Readied for analysis via newly calculated fields.


## V. Analyze
The data analyzing steps can be found in the R script file [02a_Analyze-bike-tripdata.R](https://github.com/MikeDavidG2/bike-share_case-study/blob/main/02a_Analyze-bike-tripdata.R) on GitHub.  This script details how the bike-share trip data was:
- Analyzed to create pie-charts, bar-charts, and histograms that can help answer the business question.
- Formatted to be used by Tableau for map-making.
- Filtered and extracted so that the Cyclistic executive team can act on the results.

## VI. Share
The results of the analysis can be accessed by:
- Downloading the PowerPoint presentation [Casual-Rider-vs-Member.pptx](https://github.com/MikeDavidG2/bike-share_case-study/blob/main/03a_Results_Casual-Rider-vs-Member.pptx).
- Inspecting the [Tableau map](https://public.tableau.com/app/profile/michael.grue4932/viz/DivvyBikeTrips-Chicago/CasualRiders) which highlights the number of rides started at the most popular stations.
- Data used for the map can be found in:
  - [Stations-For-Map_Casual-Rider.csv](https://github.com/MikeDavidG2/bike-share_case-study/blob/main/03c_Results_Stations-For-Map_Casual-Rider.csv)
  - [Stations-For-Map_Member.csv](https://github.com/MikeDavidG2/bike-share_case-study/blob/main/03d_Results_Stations-For-Map_Member.csv).
- Viewing the [Top-50-Casual-Rider-Stations.csv](https://github.com/MikeDavidG2/bike-share_case-study/blob/main/03b_Results_Top-50-Casual-Rider-Stations.csv).
