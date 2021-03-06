Exploring Virginia Medical Practices
========================================================
author: VP Nagraj       
date: August 25 2015
transition: rotate
font-family: 'Helvetica'

Introduction
========================================================

[Exploring Virginia Medical Practices (EVMP)](http://apps.bioconnector.virginia.edu/evmp) is a web application built with R and the Shiny framework. 

The app is based on open data originally collected by the [Virginia Department of Health Professionals (VDHP) ](http://www.dhp.virginia.gov/) and provides an interface for browsing the multilingual status of Virginia physicians by institution and medical specialty.

Features & Use Cases
========================================================

*Features*
- Dynamically plots proportions of multilingual practioners by specialty
- Processes existing data to calculate 'Proportion Multilingual'
- Uses publicly available, externally maintained records

*Use Cases*
- Hospital administrator needs to know where and how translation services should be allocated
- Patient wants to view a breakdown of the most common specialties (e.g. those with at least 5 practitioners) per institution

Methods
========================================================
EVMP is built entirely in R. It loads several packages including shiny (for the web app), jsonlite and curl (both for data harvesting ), ggplot2 (for plotting), stringr (for data cleaning), dplyr and tidyr (both for data manipulation).

The app calls upon a site that has collected and created API functionality for open data sources ([http://cvillecouncil.us/](http://cvillecouncil.us/)) including the physician information originally collected by the VDHP.

Once harvested the data undergo a series of transformations, including the creation of an indicator for whether or not more than one language (in addition to English) is spoken at the practice, as well as filtering by specialties with only 5 or more practitioners.

Code Example
========================================================

The code below shows how the multilingual variable is created:


```r
json_data$Language <- gsub("English", "", json_data$Language)
json_data$Language <- gsub(",", "", json_data$Language)
json_data$Language <- str_trim(json_data$Language, side="both")

json_data$Language <- factor(json_data$Language)

json_data$Multilingual <- factor(ifelse(grepl("^[A-Z]", json_data$Language),
        json_data$Multilingual <- "YES", 
        json_data$Multilingual <- "NO"))
```

Summary
========================================================

The EVMP app peforms the following steps:

1. Create an API request with the selected institution ID appended
2. Retrieve and parse JSON data
3. Clean-up the language variable
4. Create multilingual indicator
5. Subset data to only include specialties with >= 5 practitioners
6. Create mutilingual proportion variable
7. Plot
