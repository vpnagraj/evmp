library(shiny)
library(jsonlite)
library(stringr)
library(ggplot2)
library(dplyr)
library(curl)

shinyServer(function(input, output) {
        
        output$help <- renderText({
                
                txt <- "<h3>GET STARTED</h3>
                <em>Select an institution to view its physician specialities and proportion of multilingual practices</em>"
                
                if (input$institution=="NOT SELECTED")
                        return(txt)
                
        })
        
        output$plot <- renderPlot({
                
                library(dplyr)
                library(tidyr)
                if (input$institution=="NOT SELECTED")
                        return(NULL)
                
                ## create json query to pull records
                
                json_url <- "http://www.cvillecouncil.us/physician-organization/"
                json_file <- paste(json_url, input$institution, sep="")
                
                ## pull all records from healthcare providers at the selected institution
                
                json_data <- fromJSON(txt=json_file, simplifyDataFrame = TRUE)$nodes$node
                
                for (i in 1:nrow(json_data)) {
                        
                        json_data$Speciality[i] <- strsplit(json_data$`Medical Specialty`, split=":")[[i]][1]
                        
                }
                
                json_data$Name <- tolower(paste(json_data$`First Name`, json_data$`Last Name`, sep=" "))
                json_data$Name <- gsub("\\b([a-z])([a-z]+)", "\\U\\1\\L\\2" ,json_data$Name, perl=TRUE)
                
                json_data$Language <- gsub("Telephone Interpretation", "", json_data$`Health Languages Spoken`)
                json_data$Language <- gsub("English", "", json_data$Language)
                json_data$Language <- gsub(",", "", json_data$Language)
                json_data$Language <- str_trim(json_data$Language, side="both")
                
                json_data$Language <- factor(json_data$Language)
                
                ## create multilingual indicator variable
                json_data$Multilingual <- factor(ifelse(grepl("^[A-Z]", json_data$Language),
                                                        json_data$Multilingual <- "YES", 
                                                        json_data$Multilingual <- "NO"))
                
                ## clean up speciality variable duplicates and factor
                
                json_data$Speciality <- gsub("Orthopaedic Surgery, Orthopaedic Surgery", "Orthopaedic Surgery", json_data$Speciality)
                json_data$Speciality <- gsub("Family Practice, Family Practice", "Family Practice", json_data$Speciality)
                json_data$Speciality <- gsub("Pediatrics, Pediatrics", "Pediatrics", json_data$Speciality)
                json_data$Speciality <- gsub("Neurology, Neurology", "Neurology", json_data$Speciality)
                json_data$Speciality <- gsub("Anesthesiology, Anesthesiology", "Anesthesiology", json_data$Speciality)
                json_data$Speciality <- gsub("Internal Medicine, Internal Medicine", "Internal Medicine", json_data$Speciality)
                
                json_data$Speciality <- factor(json_data$Speciality, exclude = "0002")
                
                json_data <- 
                        json_data %>%
                        select(Multilingual,Speciality)  %>% 
                        filter(!is.na(Speciality)) %>%
                        group_by(Speciality) %>% 
                        summarise(Proportion.Multilingual = sum(Multilingual=="YES")/n(), Sample.Size=cut(n(), breaks=c(0,5,10,20,100,9999), labels=c("1-4","5-10", "11-20", "21-100", "> 100"))) %>%
                        filter(Sample.Size != "1-4")
        
                g <- 
                        ggplot(json_data, aes(Speciality, Proportion.Multilingual, fill=Sample.Size, guide_legend(title="Sample Size"))) +
                        geom_bar(stat="identity") +
                        geom_point(aes(col=Sample.Size)) +
                        ylab("Proportion Multilingual") +
                        coord_flip() 
                g
               
        })
        
        output$summary <- renderText({
                
                txt <- "<h2>About</h2>
                <p>Exploring Virginia Medical Practices (EVMP) was developed entirely using the R programming language. The app uses several packages to harvest the data from an externally maintained, publicly available Application Programming Interface (API). Use the button below to access slides detailing the methods, features and use cases for the app.</p>
                <a href='http://vpnagraj.github.io/evmp/evmp.html'><button class='btn btn-default'>Click To View EVMP Presentation</button></a>
                <a href='http://https://github.com/vpnagraj/evmp/'><button class='btn btn-default'>Click To View Code For EVMP</button></a>"

                
        })
})