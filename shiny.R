library(shiny)
library(DT)
library(ggplot2)
library(dplyr)
library(magrittr)
library(palmerpenguins)
library(shinyWidgets)
ui = fluidPage(
  titlePanel("펭귄 데이터 분석"),
  sidebarLayout(
    sidebarPanel(
      awesomeCheckboxGroup(
        inputId = "species",
        label = "펭귄 종류를 선택하세요.",
        choices = c("Adelie", "Gentoo", "Chinstrap"),
        selected = "Adelie"),
      sliderInput(inputId = 'size',
                  label = "점 크기를 선택하세요",
                  min = 1, max = 10, value = 5),
      selectInput(inputId = 'xlabel',
                  label = 'X축을 선택하세요.',
                  choices = c("bill_length_mm", "bill_depth_mm","flipper_length_mm", "body_mass_g"),),
      selectInput(inputId = 'ylabel',
                  label = 'y축을 선택하세요.',
                  choices = c("bill_length_mm", "bill_depth_mm","flipper_length_mm", "body_mass_g"),
                  selected = "body_mass_g")
    ),
    mainPanel(
      dataTableOutput('penguins_table'),
      plotOutput('penguins_plot')
    )
  )
)
server = function(input, output, session) {
  sel_penguins = reactive({
    penguins %>%
      filter(species %in% input$species)
  })
  output$penguins_table = renderDataTable({
    sel_penguins() %>%
      datatable()
  })
  output$penguins_plot = renderPlot({
    sel_penguins() %>%
      ggplot(aes_string(x = input$xlabel, y = input$ylabel, color='species', shape='sex' )) +
      geom_point(size = as.numeric(input$size))
  })
}
shinyApp(ui, server)
