FROM rocker/shiny
RUN R -e "install.packages(c('prophet'))"