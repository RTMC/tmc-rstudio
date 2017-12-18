# Need RStudio version > 1.1.67 for rstudioapi::showDialog()
# https://www.rstudio.com/products/rstudio/download/preview/ <- working version

#' @title Run the TMC addin
#'
#' @description Run the TMC addin on the \code{RStudio} viewer pane.
#'
#' @usage tmcGadget()
#'
#' @details The TMC \code{RStudio} addin was made using \code{\link[shiny]{shiny-package}}, which
#' allows making web applications and \code{RStudio} addins using \code{R}.
tmcGadget <- function() {
  # Assign the UI_disabled variable as a global variable
  assign(x = "UI_disabled", value = FALSE, envir = .GlobalEnv)

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

  server <- function(input, output, session) {

    globalReactiveValues <- reactiveValues(downloadedExercises = downloadedExercisesPaths())

    # Function for the exit button
    observeEvent(input$exit, {
      if(UI_disabled) return()

      return(shiny::stopApp())
    })

    if (!read_properties()$user_set) {
      showModal(modalDialog(
        textInput(inputId = "tmcr_dir",
          label = "Choose a directory where directory \"tmcr\" and \"tmcr-projects\" inside it are created",
          value = normalizePath("~", winslash = "/")),
        title = "Select the location for downloaded tmcr projects",
        footer = actionButton("set_dir", "Set directory")
      ))
    }

    observeEvent(input$set_dir, {
      tryCatch({
        parent_dir <- input$tmcr_dir
        parent_dir <- normalizePath(parent_dir)
        tmcr_dir <- file.path(parent_dir, "tmcr")
        create_properties_file(user_set = TRUE, tmcr_directory = tmcr_dir)
        removeModal()
      }, warning = function(w) {
        rstudioapi::showDialog(
          title = "Please try again. Make sure the directory exists.",
          message = paste("Warning:\n", w$message),
          url = "")
      }, error = function(e) {
        rstudioapi::showDialog(
          title = "Please try again. Make sure the directory exists.",
          message = paste("Warning:\n", e$message),
          url = "")
      })
    })

    shiny::callModule(.loginTab, "login")
    shiny::callModule(.courseTab, "courses", globalReactiveValues = globalReactiveValues)
    shiny::callModule(.submitTab, "testAndSubmit", globalReactiveValues = globalReactiveValues)
  }

  shiny::runGadget(app = ui, server = server)
}
