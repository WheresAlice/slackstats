library(shiny)
library(prophet)

# Define UI for application that draws a graph
ui <- fluidPage(
   
   # Application title
   titlePanel("Slack Stats"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput("variable", "Variable:",
                     c("Total Users" = "Total.Users",
                       "Full Members" = "Full.Members",
                       "Guests" = "Guests",
                       "Daily Active Users" = "Daily.Active.Users",
                       "Daily Users Posting Messages" = "Daily.Users.Posting.Messages",
                       "Weekly Active Users" = "Weekly.Active.Users",
                       "Weekly Users Posting Messages" = "Weekly.Users.Posting.Messages",
                       "Messages in Public Channels" = "Messages.in.Public.Channels",
                       "Messages in Private Channels" = "Messages.in.Private.Channels",
                       "Messages in Shared Channels" = "Messages.in.Shared.Channels",
                       "Messages in DMs" = "Messages.in.DMs",
                       "Percentage of Messages Posted in Public Channels" = "X..of.Messages.Posted.in.Public.Channels",
                       "Percentage of Messages Posted in Private Channels" = "X..of.Messages.Posted.in.Private.Channels",
                       "Percentage of Messages Posted in DMs" = "X..of.Messages.Posted.in.DMs",
                       "Percentage of Messages Read in Public Channels" = "X..of.Messages.Read.in.Public.Channels",
                       "Percentage of Messages Read in Private Channels" = "X..of.Messages.Read.in.Private.Channels",
                       "Percentage of Messages Read in DMs" = "X..of.Messages.Read.in.DMs",
                       "Public Workspace Channels" = "Public.Workspace.Channels",
                       "Messages Posted" = "Messages.Posted")
                     )
      ),
      
      # Plot the prophet output
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
     slack <- read.csv("slack.csv")
     
     # Do some cleaning up
     clean_slack <- slack[slack$Total.Users != 0,]
     dates <- as.POSIXct(strptime(clean_slack$Date, "%Y-%m-%d"))
     
     # Pick which variable to predict (Total.Users is most useful)
     prophet_df <- data.frame(dates, c(clean_slack[input$variable]))
     
     # Make a dataframe that prophet is happy with
     names(prophet_df) =c("ds","y")
     m <- prophet(prophet_df)
     
     # Predict the next two years
     future = make_future_dataframe(m, periods = 365 * 2)
     forecast = predict(m, future)
     
     # Generate a dataframe with predicted values
     future_df <- forecast[c('ds', 'yhat', 'yhat_lower', 'yhat_upper')]
     
     # Plot the graph
     plot(m, forecast)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

