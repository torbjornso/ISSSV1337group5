# Using pacman to load libraries because so many are needed

if (!require("pacman")) install.packages("pacman"); library(pacman)
p_load(shiny, tidyverse, scales, rvest, janitor, plotly, readxl)

# Creating ui
ui <- fluidPage(

    # Application title
    titlePanel("Charity analysis"),
    
    # Explanation of inputs
    htmlOutput("explanation"),
    
    # Inputs
      # need more strict validation for files?
    # html
    fileInput("html", label = "Upload html file", accept = ".html"),
    numericInput("start", label = "Start", value = 2002),
    numericInput("end", label = "End", value = 2021),
    # Excel
    fileInput("excel", "Upload Excel file", accept = ".xlsx"),
    # Button
    actionButton("click", "Analyse"),
    
    # Outputs (Planning on removing the tables once testing is done)
      # need to work on how to display KPIs
    
    tableOutput("htmltable"),
    tableOutput("exceltable"),
    plotOutput("htmlplot"),
    plotlyOutput("plotlyplot")
)

# Define server logic
server <- function(input, output) {
  
  # function to read html file
  
  read_proff6 <- function(file, start, end){
    read_html(file, encoding = "UTF-8") |> 
      html_node("#inner-frame") |> 
      html_table() |> 
      select( # removing empty column
        REGNSKAPSPERIODE:all_of(start)) |> # using all_of()
      mutate( # removing whitespace
        REGNSKAPSPERIODE = str_squish(REGNSKAPSPERIODE)
      ) |> 
      filter( # removing duplicate table - no idea why it's necessary
        !row_number() > 176
      ) |>
      filter( # removing duplicate rows
        !grepl("Lukk", REGNSKAPSPERIODE)
      ) |> 
      pivot_longer( # tidying data
        all_of(end):all_of(start), names_to = "year") |> # using all_of()
      mutate( # changing to real NAs and turning years into numbers
        value = na_if(value, "-"),
        year = as.integer(year)) |> 
      mutate( # adding currency column
        valutakode = ifelse(REGNSKAPSPERIODE == "Valutakode", value, NA)
      ) |> 
      fill( # filling the currency column
        valutakode, .direction = "updown"
      ) |> 
      filter( # removing dates and redundant currency
        REGNSKAPSPERIODE != "Sluttdato" & REGNSKAPSPERIODE != "Startdato" &
          REGNSKAPSPERIODE != "Valutakode") |> 
      mutate( # removing whitespace in numbers
        value = str_replace_all(value, "\\s", "")
      ) |> 
      mutate( # turning into numbers
        value = as.numeric(value)
      ) |> 
      mutate( # removing years as values
        value = ifelse(grepl("i hele 1000", REGNSKAPSPERIODE), NA, value)
      ) |> 
      mutate( # values no longer in 1000
        value = value * 1000
      ) |> 
      distinct() |> # removing any remaining duplicate rows
      pivot_wider( # pivoting
        names_from = REGNSKAPSPERIODE, values_from = value
      ) |> 
      clean_names() |> # tidying names
      select(-lederlonn_i_hele_1000,
             -resultatregnskap_i_hele_1000,
             -balanseregnskap_i_hele_1000) |> # removing headings
      rename( # making it clear what lonn refers to
        lederlonn = lonn
      ) |> 
      arrange(desc(year)) # arranging by year
  }
  
  # Function to read Excel file
  widen_excel <- function(file){
    read_excel(file) |> 
      mutate(
        Value = Value * 1000
      ) |> 
      unite(
        entry, c(Category, Name), sep = "_"
      ) |> 
      select(-`Sub-category`) |> 
      pivot_wider(names_from = entry, values_from = Value) |> 
      clean_names()
  }
  
  # Creating outputs
  
  output$explanation <- renderText({
    "Please upload the html version of a table from Proff.no
    and enter the start and end years. <p> Then upload an Excel file in the
    approved format."
  })
  
  observe({ # wait for button click
    
    # creating data frame from html file
    htmldata <- reactive({
      read_proff6(input$html$datapath,
                  as.character(input$start), as.character(input$end))
      })
    
    # Creating data frame from Excel file
    exceldata <- reactive({
      widen_excel(input$excel$datapath)
    })
    
    # Creating tables
    
    # creating htmltable
    output$htmltable <- renderTable(
      htmldata()
    )
    
    # Creating exceltable
    output$exceltable <- renderTable(
      exceldata()
    )
    
    # creating plots
    
    # ggplot as reactive function
    lonnplot <- reactive({
      ggplot(data = htmldata(), aes(year, lederlonn)) +
        geom_col() +
        scale_y_continuous(
          labels = scales::label_dollar(prefix = ""))
    })
    
    # Creating ggplot
    output$htmlplot <- renderPlot(
      lonnplot()
    )
    
    # Creating plotly plot
    output$plotlyplot <- renderPlotly(
      ggplotly(lonnplot())
    )
  }) |> 
    bindEvent(input$click) # run on button click
}


# Run the application 
shinyApp(ui = ui, server = server)