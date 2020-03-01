
# Import packages to be used
using Pkg
using CSV
using DataFrames 
using Query
using StatsPlots

# Read in data from the csv file from https://www.kaggle.com/sudalairajkumar/novel-corona-virus-2019-dataset#2019_nCoV_data.csv
data = CSV.read(FILEPATH);

# create data frame containing relevant columns.
df = DataFrame(date = data[:2], cities = data[:3], country = data[:4], confirmed = data[:6], deaths = data[:7], recovered = data[:8])

# Filter data frame for data from the most recent day.
filter = DataFrame(df |> @filter(_.date == "02/17/2020 22:00:00"))

# Use groupby to group data by their countries.
gd = groupby(filter, :country, skipmissing = true);

# Combine data for countries.
corona_country = combine(gd, :confirmed => sum, :deaths => sum, :recovered => sum);

# Sort the data in descending order starting from the country with the most confirmed cases.
corona_sorted = sort(corona_country, :confirmed_sum, rev=true)

using Plots

# Create a bar chart to show the top 6 countries affected.
@df head(corona_sorted) bar(:country, :confirmed_sum, size = (700, 700), title = ("Confirmed Cases in Top 6 Places Affected by COVID-19"), xlabel = ("Country"), ylabel = ("Confirmed Cases"))

using DataFramesMeta

using Query

# Filter the data to include data on cities in the US.
filter_US = DataFrame(filter |> @filter(_.country == "US"))

# Create a pie-chart showing the distribution of confirmed cases in cities in the US.
@df filter_US pie(:cities, :confirmed, size = (1000, 400))

df_time = DataFrame(date = data[:2], confirmed = data[:6], deaths = data[:7], recovered = data[:8]);

gd_time = groupby(df_time, :date, skipmissing = true);

# Combine the data by adding all elements in each date.
corona_time = combine(gd_time, :confirmed => sum, :deaths => sum, :recovered => sum)

# Create a line plot to show increase in confirmed cases per day (globally).
@df corona_time plot(:date, :confirmed_sum, size = (700, 700), title = ("Global Confirmed Cases Over Time"), xlabel = ("Days After 22nd Jan"), ylabel = ("Confirmed Cases"), yaxis = (0:5000:80000), xaxis = (0:5:30))


# Create a line plot to show increase in death cases per day (globally).
@df corona_time plot(:date, :deaths_sum, size = (700, 700), title = ("Global Death Cases Over Time"), xlabel = ("Days After 22nd Jan"), ylabel = ("Death Cases"), yaxis = (0:100:2000), xaxis = (0:5:30))


# Create a line plot to show increase in recovered cases per day (globally).
@df corona_time plot(:date, :recovered_sum, size = (700, 700), title = ("Global Recovered Cases Over Time"), xlabel = ("Days After 22nd Jan"), ylabel = ("Recovered Cases"), yaxis = (0:2000:14000), xaxis = (0:5:30))


# Filter out the data relevant to China.
filter2 = DataFrame(df |> @filter(_.country != "China" && _.country != "Mainland China"))

gd_nochina = groupby(filter2, :country, skipmissing = true);

# Create a data frame containing the country and their confirmed, death and recovered cases.
df_ratio = DataFrame(Country = corona_sorted[:1], Confirmed = corona_sorted[:2], Deaths = corona_sorted[:3], Recovered = corona_sorted[:4])


# Calculate the percentage of recovered over the sum of confirmed cases and deaths, and store it in a new column.
df_ratio[:Recovery_Percentage] = 100*(df_ratio[:Recovered] ./ (df_ratio[:Confirmed] + df_ratio[:Deaths]));

df_ratio

# Create a bar chart showing the efficiency of recovery per country.
@df df_ratio bar(:Country, :Recovery_Percentage, size = (1000, 1000), title = ("Recovery Efficiency per Country"), xlabel = ("Country"), ylabel = ("Percentage Recovered"), yaxis = (0:10:100))
