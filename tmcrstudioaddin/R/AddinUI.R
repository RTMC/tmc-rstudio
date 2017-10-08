library(miniUI)
library(shiny)

.log_in_tab <- miniTabPanel(
  title = "Log in",
  icon = icon("user-circle-o"),

  miniContentPanel(

    h1("Log in"),

    # inputId allows the server to access the values given by user
    textInput("username", label = "Username", value = ""),
    passwordInput("password", label = "Password", value = ""),

    actionButton(inputId = "login", label = "Log in")
  )
)

.courses_and_excersises_tab <- miniTabPanel(
  title = "Exercises",
  icon = icon("folder-open"),

  miniContentPanel(
    selectInput(
      inputId = "course_select",
      label = "Select course",

      choices = list(

        "Introduction to Statistics and R I" = "Course 1",
        "Introduction to Statistics and R II" = "Course 2",
        "Data mining" = "Course 3"
      ),

      selected = 1
    ),

    # *Output function shows info from server
    textOutput(outputId = "course_display")
  )
)

.test_and_submit_tab <- miniTabPanel(
  title = "Test & Submit",
  icon = icon("check"),

  miniContentPanel(
    actionButton(inputId = "run_tests", label = "Run tests"),
    actionButton(inputId = "submit", label = "Submit to server"),
    checkboxInput(inputId = "show_all_results", label = "Show all results", value = FALSE),
    uiOutput(outputId = "test_results_display")
  )
)

ui <- miniPage(
  gadgetTitleBar(title = "TMC RStudio", right = NULL,
                 left = miniTitleBarCancelButton(inputId = "exit", label = "Exit")),

  miniTabstripPanel(
    .log_in_tab,
    .courses_and_excersises_tab,
    .test_and_submit_tab
  )
)

# Usage: create_terminal_app() creates a new terminal window that runs the shiny app server
# Then use rstudioapi::viewer("http://127.0.0.1:6866")
# The port and address are defined in cmd4 in the create_terminal_app() function
# Since the terminal does not use Rstudio, when using this you cannot call rstudioapi eg. in login message
# create_terminal_app()
# rstudioapi::viewer("http://127.0.0.1:6866")
create_terminal_app <- function() {
  cmd1 <- "Rscript -e \"app_comp = list();"
  cmd2 <- "app_comp[['ui']] <- tmcrstudioaddin::ui;"
  cmd3 <- "app_comp[['server']] <- tmcrstudioaddin::server;"
  cmd4 <- "shiny::runApp(appDir = app_comp, port = 6866, host = '127.0.0.1')\""
  rstudioapi::terminalExecute(paste0(cmd1, cmd2, cmd3, cmd4))
}
