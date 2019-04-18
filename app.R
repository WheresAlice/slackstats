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
                     c("Total Users" = "Total.membership",
                       "Full Members" = "Full.Members",
                       "Guests" = "Guests",
                       "Daily Active Users" = "Daily.active.members",
                       "Daily Users Posting Messages" = "Daily.members.posting.messages",
                       "Weekly Active Users" = "Weekly.active.members",
                       "Weekly Users Posting Messages" = "Weekly.mambers.posting.messages",
                       "Messages in Public Channels" = "Messages.in.public.channels",
                       "Messages in Private Channels" = "Messages.in.private.channels",
                       "Messages in Shared Channels" = "Messages.in.shared.Channels",
                       "Messages in DMs" = "Messages.in.DMs",
                       "Percentage of Messages Posted in Public Channels" = "Percent.of.messages..public.channels",
                       "Percentage of Messages Posted in Private Channels" = "Percent.of.messages..private.channels",
                       "Percentage of Messages Posted in DMs" = "Percent.of.messages..DMs",
                       "Percentage of Message Views in Public Channels" = "Percent.of.views..public.channels",
                       "Percentage of Message Views in Private Channels" = "Percent.of.views..private.channels",
                       "Percentage of Message Views in DMs" = "Percent.of.views..DMs",
                       "Files uploaded" = "Files.uploaded",
                       "Messages posted by members" = "Messages.posted.by.members",
                       "Public Workspace Channels" = "Public.channels..single.workspace",
                       "Messages Posted" = "Messages.Posted",
                       "Messages posted by apps" = "Messages.posted.by.apps")
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
     clean_slack <- slack[slack$Total.membership != 0,]
     dates <- as.POSIXct(strptime(clean_slack$Date, "%Y-%m-%d"))
     
     # Pick which variable to predict (Total.membership is most useful)
     prophet_df <- data.frame(dates, c(clean_slack[input$variable]))
     
     # Make a dataframe that prophet is happy with
     names(prophet_df) =c("ds","y")
     m <- prophet(daily.seasonality = TRUE)
     m <- add_country_holidays(m, country_name = "UK")
     m <- fit.prophet(m, prophet_df)
     #m <- prophet(prophet_df)

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

