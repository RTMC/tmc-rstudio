.courseTabUI <- function(id, label = "Course tab") {
  ns <- shiny::NS(id)
  organizations <-list()
  organizations <-tryCatch({tmcrstudioaddin::getAllOrganizations()})
  miniTabPanel(
    title = "Exercises",
    icon = icon("folder-open"),
    miniContentPanel(
      selectInput(
        inputId = ns("organizationSelect"),
        label = "Select organization",
        choices = organizations,
        selected = 1
      ),
      selectInput(
        inputId = ns("courseSelect"),
        label = "Select course",
        choices = list(),
        selected = 1
      ),
      textOutput(outputId = ns("courseDisplay"))
    )
  )
}

.courseTab <- function(input, output, session) {
  output$courseDisplay <- renderText({
    input$courseSelect
  })
  observeEvent(input$organizationSelect,{
    organization<-input$organizationSelect
    courses <- list()
    tryCatch({
      courses <- tmcrstudioaddin::getAllCourses(organization)
      updateSelectInput(session,"courseSelect",label = "Select course",choices=courses,selected=1)
    })
  })
}
