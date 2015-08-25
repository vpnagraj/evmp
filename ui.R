library(shiny)

shinyUI(navbarPage("Exploring Virginia Medical Practices", 
                   header=(tags$h1("Exploring Virginia Medical Practices", align='center', tags$u(tags$h2("Multilingual Physicians By Speciality", align='center', style="margin-top:10px")))),
                   tabPanel("Home",
                            sidebarPanel(
                                    radioButtons(inputId = "institution", label = "Institution", choices = c("NOT SELECTED", "Inova Alexandria Hospital"="048", "Sentara Williamsburg Regional Medical Center"="120", "University of Virginia Medical Center"= "110", "VCU Health Center & MCV Hospital and Physicians"= "067", "Martha Jefferson Hospital"="063",  "Winchester Medical Center" = "121", "1st Medical Group (Langley AFB)"="157", "Naval Medical Center (Portsmouth)"="163", "Veterans Affairs Medical Center (Richmond)"="114", "Veterans Affairs Medical Center (Hampton)" = "113", "Veterans Affairs Medical Center (Salem)" = "115"), selected="NOT SELECTED")
                            ),
                            
                            mainPanel(
                                    htmlOutput("help"),
                                    plotOutput("plot")
                            )
                   ),
                   tabPanel("About",
                            htmlOutput("summary")
                            
                   )
)
)