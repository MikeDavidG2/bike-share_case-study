# Load libraries and data ====

library(hms)
library(lubridate)
library(dplyr)
library(ggplot2)
library(stringr)
library(reshape2)
library(ggtext)
library(glue)
library(scales)
#library(mapproj)
#library(ggmap)

# Read the data
path_to_data <- "C:/Users/miked/Google_Drive/Personal/Google DA Cert/Course 8 - Capstone/1_Bike-share/proj-process/my_output_folder/processed-divvy-tripdata.rds"
df_procsd <- readRDS(path_to_data)

# View loaded data
View(head(df_procsd))
View(tail(df_procsd))
str(df_procsd)


#========================
# Set frequently used dfs, vars, and funcs ====

# Create filtered df's based on [member_casual]
df_am <- df_procsd %>% filter(member_casual == 'member')
df_cr <- df_procsd %>% filter(member_casual == 'casual')

# How many rides were there in our range between 9/1/2023 and 8/31/2024
tot_num_rides <- nrow(df_procsd)   # 5,699,639
num_am_rides = nrow(df_am)         # 3,653,915 = Number of annual member rides
num_cr_rides = nrow(df_cr)         # 2,045,724 = Number of casual rider rides

# Create a function to calculate percentage
calc_pct <- function(part, whole, digits = 1) {
  round((part / whole) * 100, digits)
}

# Set the colors for the charts
cr_color <- '#e69500'
cr_color_transparent <- '#ffa500'
am_color <- '#556d82'
alt_color_pink <- '#de9185'
alt_color_green <- '#b4deb6'

range_of_data_dates <- '(09-01-23 to 08-31-24)'  # For map subtitles

# Set folder for outputs
my_output_folder <- 'C:/Users/miked/Google_Drive/Personal/Google DA Cert/Course 8 - Capstone/1_Bike-share/proj-analysis/my_output_folder'

# Clean up unneeded dfs and vars
rm(df_procsd)
rm(path_to_data)
gc()


#========================
# HOW MANY:  % of the rides from annual members (am) vs. casual riders (cr) (Pie Chart) ====

title <- "Percent of Rides by Rider Type"

# Calc data for pie chart and begin our summary data frame
sum_df <- data.frame(
  rider_type = c('member', 'casual'),
  pct_of_tot_rides = c(calc_pct(nrow(df_am), tot_num_rides), calc_pct(nrow(df_cr), tot_num_rides)))

# Plot pie chart
ggplot(sum_df, aes(x = '', y = pct_of_tot_rides, fill = rider_type)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  theme_void() +                                          # Remove unnecessary elements
  geom_text(aes(label = paste0(pct_of_tot_rides, "%")),   # Add labels
            position = position_stack(vjust = 0.5),
            color = 'white',
            fontface  = 'bold',
            size = 5) +
  labs(title = title,
       subtitle = range_of_data_dates,
       fill = "Rider Type"
       ) +     # Change chart and legend titles
  scale_fill_manual(values = c("member" = am_color, "casual" = cr_color), # Change chart colors
                    labels = c(glue('Casual    ({comma(num_cr_rides)} rides)'),
                               glue('Member  ({comma(num_am_rides)} rides)'))
                    ) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5, size = 9)
        ) # Center the title)
  
# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


#========================
# TYPE:  Do am and cr use classic or elec? (Stacked bar chart) ====

#------------------------
# Calculate pct of rides that were classic bike vs. electric bike by rider type ----

# calc number both rider types used a classic bike
num_am_rides_classic <- nrow(subset(df_am, rideable_type == 'classic_bike'))
num_cr_rides_classic <- nrow(subset(df_cr, rideable_type == 'classic_bike'))

# calc percent and add to new row in the summary table
sum_df$pct_classic = c(calc_pct(num_am_rides_classic,num_am_rides), calc_pct(num_cr_rides_classic, num_cr_rides))


# calc number both rider types used an electric bike
num_am_rides_electric <- nrow(subset(df_am, rideable_type == 'electric_bike'))
num_cr_rides_electric <- nrow(subset(df_cr, rideable_type == 'electric_bike'))

# calc percent and add to new row in the summary table
sum_df$pct_electric = c(calc_pct(num_am_rides_electric,num_am_rides), calc_pct(num_cr_rides_electric, num_cr_rides))


#------------------------
# Plot stacked bar chart ----

title <- "Classic or Electric Bike by Rider Type"

# Reshape the data into long format for ggplot2 (melt the data frame)
df_melted_bike_tp <- melt(sum_df,
                  id.vars = "rider_type",
                  measure.vars = c("pct_classic", 'pct_electric'),  # Specify the columns to melt
                  variable.name = "bike_type",
                  value.name = "pct")

# Create a stacked bar chart
ggplot(df_melted_bike_tp, aes(x = rider_type, y = pct, fill = bike_type)) +
  geom_bar(stat = "identity") +                                              # Use 'identity' to stack based on values
  geom_text(aes(label = paste0(scales::label_number(accuracy = 0.1)(pct), "%")),  # Add labels to bars
            position = position_stack(vjust = 0.5),
            color = "black",
            size = 5) +  
  labs(title = title,
       subtitle = range_of_data_dates,
       x = "Rider Type",
       y = "%",
       fill = "Bike Type") +                                                 # Title, x & y axis, and legend
  scale_x_discrete(labels = c("casual" = "Casual", "member" = "Member")) +   # Update x-axis labels
  scale_fill_manual(values = c("pct_classic" = alt_color_green, "pct_electric" = alt_color_pink), # Update legend labels and colors
                    labels = c("Classic", "Electric")) + 
  theme_minimal() +
  theme(axis.text.x = element_text(color = c(cr_color, am_color), # Update x-axis label colors and make text bold
                                   face = "bold",
                                   size = 12),
        axis.title.x = element_text(size = 14),    # Make x-axis label larger
        axis.title.y = element_text(size = 12),    # Make y-axis label larger
        plot.title = element_text(hjust = 0.5),    # Center the title
        plot.subtitle = element_text(hjust = 0.5, size = 9)  # Center the subtitle
        ) 


# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


#========================
# Diff in ride_length between am and cr? (Histograms) ====

# TODO in write up: mention that this below issue was found doing the histogram and what I decided to do about it
#   which was rm the negative rows.  The change in the data after the removal was:
#     The change in the average was +1 sec longer for the am's, and no change for the cr's.
#     The change in the median was +2 sec longer for the am's, and no change for the cr's.

# get subset w no negative values in ride_length before calculating this field.
df_am_pos_ride_len <- df_am %>%
  filter(ride_length > 0)

df_cr_pos_ride_len <- df_cr %>%
  filter(ride_length > 0)


#------------------------
# Get avg, med, quantiles for [ride_length] ----

### Average

# Calc avg ride length for am's
avg_am_ride_len <- df_am_pos_ride_len$ride_length %>%
  as.numeric() %>%
  mean() %>%
  round() %>% 
  as_hms()

# Calc avg ride length for cr's
avg_cr_ride_len <- df_cr_pos_ride_len$ride_length %>%
  as.numeric() %>%
  mean() %>%
  round() %>% 
  as_hms()

# set values in the summary table
sum_df$avg_ride_len = c(avg_am_ride_len, avg_cr_ride_len)


### Median

# Calc med ride length for am's
med_am_ride_len <- df_am_pos_ride_len$ride_length %>%
  as.numeric() %>%
  median() %>%
  round() %>% 
  as_hms()

# Calc med ride length for cr's
med_cr_ride_len <- df_cr_pos_ride_len$ride_length %>%
  as.numeric() %>%
  median() %>%
  round() %>% 
  as_hms()

# set values in the summary table
sum_df$med_ride_len = c(med_am_ride_len, med_cr_ride_len)


### Calc other variables

# Convert ride_length to numeric (seconds) for other calcs and plotting histograms
df_am_pos_ride_len$ride_length_seconds <- as.numeric(df_am_pos_ride_len$ride_length)
df_cr_pos_ride_len$ride_length_seconds <- as.numeric(df_cr_pos_ride_len$ride_length)


# Calculate the quantiles of ride_length_seconds
pct_75_am_quantile <- as_hms(quantile(df_am_pos_ride_len$ride_length_seconds, 0.75))
pct_75_cr_quantile <- as_hms(quantile(df_cr_pos_ride_len$ride_length_seconds, 0.75))
pct_90_am_quantile <- as_hms(quantile(df_am_pos_ride_len$ride_length_seconds, 0.9))
pct_90_cr_quantile <- as_hms(quantile(df_cr_pos_ride_len$ride_length_seconds, 0.9))

# set values in the summary table
sum_df$pct_75_quantile = c(pct_75_am_quantile, pct_75_cr_quantile)
sum_df$pct_90_quantile = c(pct_90_am_quantile, pct_90_cr_quantile)


#------------------------
# Histograms for [ride_length] ----


### Annual Member Histogram for [ride_length] ----

# Get annotation for histogram from summary table
anno_am_txt <- paste(
  "Avg Ride Length: ", sum_df %>% filter(rider_type == "member") %>% pull(avg_ride_len), '\n',
  'Median Ride Length: ', sum_df %>% filter(rider_type == "member") %>% pull(med_ride_len), '\n',
  '75th Pct Quartile: ', sum_df %>% filter(rider_type == "member") %>% pull(pct_75_quantile), '\n',  
  '90th Pct Quantile: ', sum_df %>% filter(rider_type == "member") %>% pull(pct_90_quantile), '\n'
)
  
# Create the title text
title_text_am <- glue("<span style='color:{am_color};'><b>Annual Members</b></span> Ride Length")
title <- 'Annual Members Ride Length'  # For saving the plot

# Create am's histogram for ride_length
ggplot(df_am_pos_ride_len, aes(x = ride_length_seconds / 60)) +
  geom_histogram(binwidth = 1, fill = am_color, color = "black", alpha = 0.7) +
  labs(title = title_text_am,
       subtitle = range_of_data_dates,
       x = "Ride Length (minutes)",
       y = "# of Rides") +
  coord_cartesian(xlim = c(0, 90)) +
  theme_minimal() +
  theme(
    plot.title = element_markdown(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    axis.text.x = element_text(hjust = 0.4),
    axis.title.y = element_text(margin = margin(r = 10))
  ) +
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +  # Make the Y axis nums readable
  scale_x_continuous(breaks = seq(0, max(df_am_pos_ride_len$ride_length_seconds / 60), by = 10)) +
  annotate("text", x = 70, y = 190000, label = anno_am_txt, hjust = 1, size = 5)


# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


### Casual Rider Histogram for [ride_length] ----

# Get annotation for histogram from summary table
anno_cr_txt <- paste(
  "Avg Ride Length: ", sum_df %>% filter(rider_type == "casual") %>% pull(avg_ride_len), '\n',
  'Median Ride Length: ', sum_df %>% filter(rider_type == "casual") %>% pull(med_ride_len), '\n',
  '75th Pct Quartile: ', sum_df %>% filter(rider_type == "casual") %>% pull(pct_75_quantile), '\n', 
  '90th Pct Quantile: ', sum_df %>% filter(rider_type == "casual") %>% pull(pct_90_quantile), '\n'
)

# Create the title text
title_text_cr <- glue("<span style='color:{cr_color};'><b>Casual Riders</b></span> Ride Length")
title <- 'Casual Riders Ride Length'  # For saving the plot

# Create cr's histogram for ride_length
ggplot(df_cr_pos_ride_len, aes(x = ride_length_seconds / 60)) +
  geom_histogram(binwidth = 1, fill = cr_color, color = "black", alpha = 0.7) +
  labs(title = title_text_cr,
       subtitle = range_of_data_dates,
       x = "Ride Length (minutes)",
       y = "# of Rides") +
  coord_cartesian(xlim = c(0, 90)) +
  theme_minimal() +
  theme(
    plot.title = element_markdown(hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    axis.text.x = element_text(hjust = 0.4),
    axis.title.y = element_text(margin = margin(r = 10))
  ) +
  scale_y_continuous(
    breaks = c(0, 25000, 50000, 75000, 100000),  # Specify y-axis breaks
    labels = function(x) format(x, big.mark = ",", scientific = FALSE)  # Add commas to labels
    ) +
  scale_x_continuous(breaks = seq(0, max(df_cr_pos_ride_len$ride_length_seconds / 60), by = 10)) + 
  annotate("text", x = 70, y = 70000, label = anno_cr_txt, hjust = 1, size = 5)

# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


# TODO in write up: Over 90% of the annual members are done with their ride within 25 minutes.
#       Over 75% of the annual members are done with their ride within 15 minutes.
#  What percentage of our casual riders are done with their ride within 25 minutes?

# Clean up unneeded dfs
rm(df_am_pos_ride_len)
rm(df_cr_pos_ride_len)
gc()


#========================
# WHEN:  Do cr's ride more on the weekends? (Stacked bar chart) ====

#------------------------
# Calculate pct of rides that were weekend vs. weekday by rider type ----

# calc percent both rider types rode on a weekend
num_am_rides_wknd <- nrow(subset(df_am, is_weekend == TRUE))
num_cr_rides_wknd <- nrow(subset(df_cr, is_weekend == TRUE))

# calc values and add to new row in the summary table
sum_df$pct_wknd = c(calc_pct(num_am_rides_wknd,num_am_rides), calc_pct(num_cr_rides_wknd, num_cr_rides))


# calc percent both rider types rode on a weekday
num_am_rides_wkday <- nrow(subset(df_am, is_weekend == FALSE))
num_cr_rides_wkday <- nrow(subset(df_cr, is_weekend == FALSE))

# calc values and add to new row in the summary table
sum_df$pct_wkday = c(calc_pct(num_am_rides_wkday,num_am_rides), calc_pct(num_cr_rides_wkday, num_cr_rides))


#------------------------
# Plot stacked bar chart ----

title <- "Weekend or Weekday by Rider Type"

# Reshape the data into long format for ggplot2 (melt the data frame)
df_melted_is_wknd <- melt(sum_df,
                  id.vars = "rider_type",
                  measure.vars = c("pct_wknd", 'pct_wkday'),  # Specify the columns to melt
                  variable.name = "is_weekend",
                  value.name = "pct")

# Create a stacked bar chart
ggplot(df_melted_is_wknd, aes(x = rider_type, y = pct, fill = is_weekend)) +
  geom_bar(stat = "identity") +                                              # Use 'identity' to stack based on values
  geom_text(aes(label = paste0(round(pct, 1), "%")),  # Add labels to bars
            position = position_stack(vjust = 0.5),
            color = "black",
            size = 5
            ) +  
  
  labs(title = title,  # Add annotation to chart
       subtitle = range_of_data_dates,
       x = "Rider Type",
       y = "%",
       fill = ""  # No legend needed
       ) +
  
  scale_x_discrete(labels = c("casual" = "Casual", "member" = "Member")) +   # Update x-axis labels
  scale_fill_manual(values = c("pct_wknd" = alt_color_green, "pct_wkday" = alt_color_pink), # Update legend labels and colors
                    labels = c("Weekend", "Weekday")) + 
  theme_minimal() +
  theme(axis.text.x = element_text(color = c(cr_color, am_color), # Update x-axis label colors and make text bold
                                   face = "bold",
                                   size = 12),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 12),
        plot.title = element_text(hjust = 0.5),
        plot.subtitle = element_text(hjust = 0.5, size = 9)
        ) # Center the title

# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


#========================
# WHEN by Month:  Do cr's ride more in certain months? (Overlapping bar charts) ====

# Create the title text
title_text_month <- glue("Number of <span style='color:{cr_color};'><b>Casual Rider</b></span> Rides
                         vs. <span style='color:{am_color};'><b>Annual Member</b></span> Rides by **Month**")
title <- 'Number of Rides by Month'  # For saving the plot


# Reorder the levels of start_month to start with September (abbreviated)
new_levels <- c("Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug")

df_am$start_month <- factor(df_am$start_month, levels = new_levels, ordered = TRUE)
df_cr$start_month <- factor(df_cr$start_month, levels = new_levels, ordered = TRUE)


# Make the plot
ggplot() +
  geom_bar(data = df_am, aes(x = start_month), fill = am_color) +
  geom_bar(data = df_cr, aes(x = start_month), fill = cr_color, width = 0.70) +
  labs(title = title_text_month,
       subtitle = range_of_data_dates,
       x = "Month",
       y = "# of Rides") +
  theme_minimal() +
  theme(
    plot.title = element_markdown(hjust = 0.5),             # Center the title and enable markdown
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    axis.title.x = element_text(margin = margin(t = 5)),   # Pad the X-axis title
    axis.text.x  = element_text(margin = margin(t = -10)),  # Remove padding for the labels
    axis.title.y = element_text(margin = margin(r = 10))  # Pad the Y-axis title
  ) +
  
  # Format the Y-axis labels
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE))  # Make the Y axis nums readable

# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


# Calculate stats for chart
num_cr_jan <-  nrow(df_cr %>% filter(start_month == 'Jan'))
num_cr_may <-  nrow(df_cr %>% filter(start_month == 'May'))

num_am_jan <-  nrow(df_am %>% filter(start_month == 'Jan'))
num_am_may <-  nrow(df_am %>% filter(start_month == 'May'))

pct_jan <- num_cr_jan/num_am_jan
pct_may <- num_cr_may/num_am_may

peak_months_ls <- list('Sep', 'May', 'Jun', 'Jul', 'Aug')
num_cr_peak_months <- nrow(df_cr %>% filter(start_month %in% peak_months_ls))
pct_cr_peak_vs_total_cr <- num_cr_peak_months/num_cr_rides


#========================
# WHEN by Day:  Do cr's ride more on certain days? (overlapping histograms) ====

# Create the title text
title_text_day <- glue("Number of <span style='color:{cr_color};'><b>Casual Rider</b></span> Rides
                         vs. <span style='color:{am_color};'><b>Annual Member</b></span> Rides by **Day**")
title <- 'Number of Rides by Day'  # For saving the plot

ggplot() +
  geom_histogram(data = df_am, aes(x = started_at),  # am histogram
                 binwidth = 86400,
                 fill = am_color,
                 alpha = 0.8) +  # transparency
  geom_histogram(data = df_cr, aes(x = started_at),  # cr histogram
                 binwidth = 86400,
                 fill = cr_color,
                 alpha = 0.9) +  # transparency
  labs(title = title_text_day,
       subtitle = range_of_data_dates,
       x = "Day of Ride",
       y = "# of Rides") +

  # Format the X-axis labels
  scale_x_datetime(  # Set the x-axis labels
    breaks = seq(from = as.POSIXct("2023-09-01"), to = as.POSIXct("2024-09-01"), by = "2 months"),
    labels = date_format("%b `%y"),
    limits = c(as.POSIXct("2023-09-01"), as.POSIXct("2024-09-01"))) +  # Add more frequent labels
  
  # Format the Y-axis labels
  scale_y_continuous(
    labels = scales::comma  # Format y-axis labels with commas
  ) +
  
  theme_minimal() +
  theme(
    axis.title.y = element_text(margin = margin(r = 10)),  # Pad the Y-axis title
    axis.title.x = element_text(margin = margin(t = 5)),   # Pad the X-axis title
    plot.title = element_markdown(hjust = 0.5),             # Center the title and enable markdown
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    axis.text.x  = element_text(margin = margin(t = -5)),  # Remove padding for the labels
    panel.grid.major.y = element_line(color = "gray", size = 0.3))  # Darken major grid lines

# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


#========================
# WHEN:  What time of day do cr riders start their rides vs am riders? (overlapping histograms) ====


# Extract only the time component (as hours and minutes)
df_am$time_of_day_text <- format(df_am$started_at, format = "%H:%M")
df_cr$time_of_day_text <- format(df_cr$started_at, format = "%H:%M")

# Convert the time to a proper POSIXct object for plotting
df_am$time_of_day <- as.POSIXct(df_am$time_of_day_text, format = "%H:%M")
df_cr$time_of_day <- as.POSIXct(df_cr$time_of_day_text, format = "%H:%M")

# Get todays date for scale_x_datetime()
today_date <- format(Sys.Date(), "%Y-%m-%d")


# Create the title text
title_text_day <- glue("Number of <span style='color:{cr_color};'><b>Casual Rider</b></span> Rides
                         vs. <span style='color:{am_color};'><b>Annual Member</b></span> Rides by **Time of Day**")
title <- 'Number of Rides by Time of Day'  # For saving the plot


# Create the plot
ggplot() +
  geom_histogram(data = df_am, aes(x = time_of_day),  # am histogram
                 binwidth = 1800,
                 fill = am_color,
                 alpha = 0.8) +  # transparency
  geom_histogram(data = df_cr, aes(x = time_of_day),  # cr histogram
                 binwidth = 1800,
                 fill = cr_color_transparent,
                 alpha = 0.7) +  # transparency
  
  # Label title, x, and y axis
  labs(title = title_text_day,
       subtitle = range_of_data_dates,
       x = "Time Ride Started",
       y = "# of Rides") +

  # Format the X-axis labels
  scale_x_datetime(
    date_labels = "%l %p",                      # Display only hour and minute
    breaks = seq(from = as.POSIXct(glue("{today_date} 00:00:00")), 
                 to   = as.POSIXct(glue("{today_date} 23:59:59")),
                 by = "2 hours"),    # Label every 2 hours
    expand = expansion(add = c(0, 0))           # Remove padding to ensure axis starts at 00:00
  ) +
  
  # Format the Y-axis labels
  scale_y_continuous(
    labels = scales::comma  # Format y-axis labels with commas
  ) +
  
  theme_minimal() +
  theme(
    axis.title.y = element_text(margin = margin(r = 10)),  # Pad the Y-axis title
    axis.title.x = element_text(margin = margin(t = 5)),   # Pad the X-axis title
    plot.title = element_markdown(hjust = 0.5),            # Center the title and enable markdown
    plot.subtitle = element_text(hjust = 0.5, size = 9),
    panel.grid.major.y = element_line(color = "lightgray", size = 0.3)  # Darken major grid lines
  )             

# Save the plot
output_path <- file.path(my_output_folder, paste0(title, '.png'))
ggsave(output_path, dpi = 300)


#========================
# WHERE:  Map start_station_name and end_station_name (map) ====

#------------------------
# Get data for the map ----

create_count_tbl <- function(df) {
  #'Takes a dataframe with start_station_name and calculates the number of times a ride started from that station.
  #'Filters out all stations with less than 1000 starts
  #'Returns a dataframe with the station name, start lat/long and a count.
  
  # Get a df of the start stations w/ start_lat & start_lng, and a count
  start_stations <- df %>%
    dplyr::filter(!is.na(start_station_name)) %>%  # Removed the rows with na values
    group_by(start_station_name, start_lat, start_lng) %>% 
    summarise(count_start_rides = n(), .groups = 'drop') %>% # Count occurrences while retaining lat/lng columns
    arrange(desc(count_start_rides)) %>% 
    filter(count_start_rides >= 1000)
    
  # View(head(start_stations, 100))
  # View(tail(start_stations, 100))

  
  # # Get a df of the end stations, and a count
  # end_stations <- df %>%
  #   dplyr::filter(!is.na(end_station_name)) %>%  # Removed the rows with na values
  #   group_by(end_station_name) %>% 
  #   summarise(count_end_rides = n(), .groups = 'drop') %>% # Count occurrences while retaining lat/lng columns
  #   arrange(desc(count_end_rides)) 
  # 
  # 
  # View(head(end_stations, 100))
  # View(tail(end_stations, 100))
  # 
  # # Join the dataframes only keeping the top 1000 Start Stations
  # stations_merged <- left_join(
  #   start_stations,
  #   end_stations,
  #   by = c('start_station_name' = 'end_station_name')
  #   ) %>% 
  #   rename(station_name = start_station_name)  # Rename the station name field
  
  
  # Replace NA values in "n" columns with 0 for correct addition then add n columns
  start_stations <- start_stations %>%
    mutate(
      count_start_rides = ifelse(is.na(count_start_rides), 0, count_start_rides))
      #count_end_rides = ifelse(is.na(count_end_rides), 0, count_end_rides)) %>% 
    #mutate(count_start_end_rides = count_start_rides + count_end_rides)   # create new field as the sum of two count fields

      
    # View(head(stations_merged, 100))
    # View(tail(stations_merged, 100))
  
  return(start_stations)
}


# Get df of am rides with at least 1,000 rides starting from the same start_station_name, start_lat, & start_lng
num_start_stations_am <- create_count_tbl(df_am)

# Get df of cr rides with at least 1,000 rides starting from the same start_station_name, start_lat, & start_lng
num_start_stations_cr <- create_count_tbl(df_cr)


# Save dfs to a Excel files
writexl::write_xlsx(list('AM' = num_start_stations_am), file.path(my_output_folder, 'num_start_stations_am.xlsx'))
writexl::write_xlsx(list('CR' = num_start_stations_cr), file.path(my_output_folder, 'num_start_stations_cr.xlsx'))

# TODO - while writing up:  Mention that this returned duplicate stations because some stations had
#   differing lat/long values so they were counted independently.  I solved for this by manually merging the 
#   rows in the cr dataset (keeping the lat/long for the highest count but summing the count values into 1 row for the start_station_name)
#   but I didn't do the same process for the am dataset (there were 10 duplicate stations):
    # 1 Kingsbury St & Erie St      
    # 2 Southport Ave & Waveland Ave
    # 3 Kimbark Ave & 53rd St       
    # 4 May St & Taylor St          
    # 5 Michigan Ave & Jackson Blvd 
    # 6 Canal St & Jackson Blvd     
    # 7 Michigan Ave & 18th St      
    # 8 Damen Ave & Leland Ave      
    # 9 Racine Ave & 18th St        
    # 10 Elizabeth St & Fulton St)

#   This is a good time to mention that
#   an issue with the data is that the lat/long is not necessarily tied to a station and that there should
#   be a second table with the actual lat/long of the station if the company wants a better map of their data.
#   This resulting map is only to give a general idea.

#------------------------
# Make the map ----
# While R studio can make a map here,
# the time it takes to make a map look nice may not be worth it.
# I'm - therefore - going to make a map using Tableau.


## Register Google API key
# TODO - while writing up: Make sure to mention that I had to go onto Google Cloud Console, generate an API key, enable the map services, and restrict the key for security
# register_google(key = "API_KEY_HERE")  

## Get the map using Google as the source
# chicago_map <- get_map(location = c(lon = -87.623177, lat = 41.881832), zoom = 11, source = "google", maptype = "terrain")


# # Map the cr data
# ggmap(chicago_map) +
#   geom_point(data = station_summary_cr,
#              aes(x = start_lng, y = start_lat),
#              color = cr_color,
#              size = 2) +
#   labs(title = "Chicagoland Area with Basemap")




#========================
# WHERE:  Top cr start_station_name and end_station_name (list) ====

# Get a df of the start stations
top_cr_start_stations <- df_cr %>%
  filter(!is.na(start_station_name)) %>% 
  count(start_station_name, sort = TRUE) %>% 
  slice_head(n = 150)

# Get a df of the end stations
top_cr_end_stations <- df_cr %>%
  filter(!is.na(end_station_name)) %>% 
  count(end_station_name, sort = TRUE) %>% 
  slice_head(n = 150)


# Join the dataframes
top_cr_stations_merged <- full_join(
  top_cr_start_stations,
  top_cr_end_stations,
  by = c('start_station_name' = 'end_station_name')
) %>% 
  rename(station_name = start_station_name)  # Rename the remaining station name field


# Replace NA values in "n" columns with 0 for correct addition
top_cr_stations_merged <- top_cr_stations_merged %>%
  mutate(
    n.x = ifelse(is.na(n.x), 0, n.x),
    n.y = ifelse(is.na(n.y), 0, n.y)
  )

# Create new total_count column by adding the two "n" field
top_cr_stations_merged <- top_cr_stations_merged %>%
  mutate(total_count = n.x + n.y)                

# Create a new df with just the 2 fields I want with the highest total_count
top_50_cr_stations <- top_cr_stations_merged %>% 
  select(station_name, total_count) %>% 
  arrange(desc(total_count)) %>% 
  slice_head(n = 50)


# Save df to an Excel file
output_path <- file.path(my_output_folder, 'top_50_cr_stations.xlsx')
writexl::write_xlsx(top_50_cr_stations, output_path)
