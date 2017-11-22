# Need RStudio version > 1.1.67 for rstudioapi::showDialog()
# https://www.rstudio.com/products/rstudio/download/preview/ <- working version

tmcGadget <- function() {
  ui <- miniPage(
    shinyjs::useShinyjs(),
    gadgetTitleBar(title = "TMC RStudio", right = NULL,
                   left = miniTitleBarCancelButton(inputId = "exit", label = "Exit")),

    miniTabstripPanel(
      .loginTabUI(id = "login"),
      .courseTabUI(id = "courses"),
      .submitTabUI(id = "testAndSubmit")
    )
  )

  server <- function(input, output) {

    # Function for the exit button
    observeEvent(input$exit, {
      return(shiny::stopApp())
    })

    shiny::callModule(.loginTab, "login")
    shiny::callModule(.courseTab, "courses")
    shiny::callModule(.submitTab, "testAndSubmit")
  }

  shiny::runGadget(app = ui, server = server)
}

disable_elements <- function(...) {
  elements <- as.list(substitute(list(...)))[-1L]

  lapply(elements, function(i) {shinyjs::disable(i)})
}

enable_elements <- function(...) {
  elements <- as.list(substitute(list(...)))[-1L]

  lapply(elements, function(i) {shinyjs::enable(i)})
}
