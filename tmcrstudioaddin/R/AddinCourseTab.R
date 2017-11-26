.courseTabUI <- function(id, label = "Course tab") {
  ns <- shiny::NS(id)
  miniTabPanel(
    title = "Exercises",
    icon = icon("folder-open"),
    miniContentPanel(
      actionButton(inputId = ns("refreshOrganizations"), label = "Refresh organizations"),
      selectInput(
        inputId = ns("organizationSelect"),
        label = "Select organization",
        choices = list(),
        selected = 1
      ),
      actionButton(inputId = ns("refreshCourses"), label = "Refresh courses"),
      selectInput(
        inputId = ns("courseSelect"),
        label = "Select course",
        choices = list(),
        selected = 1
      ),
      actionButton(inputId = ns("download"), label = "Download exercises"),
      checkboxGroupInput(inputId = ns("exercises"),label="",choices=list())
    )
  )
}

.courseTab <- function(input, output, session) {
  observeEvent(input$refreshOrganizations, {
    tmcrstudioaddin::disable_course_tab()
    choices <- tmcrstudioaddin::getAllOrganizations()
    shiny::updateSelectInput(session, "organizationSelect", label = "Select organization", choices = choices, selected = 1)
    tmcrstudioaddin::enable_course_tab()
  })

  observeEvent(input$organizationSelect, {
    organization <- input$organizationSelect
    courses <- tmcrstudioaddin::getAllCourses(organization)
    choices <- courses$id
    names(choices) <- courses$name
    shiny::updateSelectInput(session, "courseSelect", label = "Select course", choices = choices, selected = 1)
  })

  exercise_map <<- list()

  observeEvent(input$courseSelect, {
    tmcrstudioaddin::disable_course_tab()
    exercises <- tmcrstudioaddin::getAllExercises(input$courseSelect)
    choices <- exercises$id
    names(choices)<-exercises$name
    exercise_map <<- list()
    exercise_map <<- exercises$id
    names(exercise_map) <<- exercises$name
    shiny::updateCheckboxGroupInput(session, "exercises", label = "Downloadable exercises", choices = choices)
    tmcrstudioaddin::enable_course_tab()
  }, ignoreInit=TRUE)

  observeEvent(input$refreshCourses, {
    tmcrstudioaddin::disable_course_tab()
    organization <- input$organizationSelect
    courses <- tmcrstudioaddin::getAllCourses(organization)
    choices <- courses$id
    names(choices) <- courses$name

    if (length(choices) == 0){
      credentials <- tmcrstudioaddin::getCredentials()
      if (is.null(credentials$token)){
        rstudioapi::showDialog("Not logged in", "Please log in to see courses", "")
      }
    }

    shiny::updateSelectInput(session, "courseSelect", label = "Select course", choices = choices, selected = 1)
    tmcrstudioaddin::enable_course_tab()
  }, ignoreInit = TRUE)

  observeEvent(input$download, {
    tmcrstudioaddin::disable_course_tab()

    tryCatch({
      organization <- input$organizationSelect
      courses <- tmcrstudioaddin::getAllCourses(organization)
      courseName <- courses$name[courses$id==input$courseSelect]

      if(!dir.exists(courseName)){
        dir.create(courseName)
      }

      for(exercise in input$exercises){
        name <- returnItem(exercise, exercise_map)
        tmcrstudioaddin::download_exercise(exercise,zip_name=paste(exercise,".zip"), exercise_directory = courseName, exercise_name = name)
      }

      rstudioapi::showDialog("Success","Exercises downloaded succesfully","")
    }, error = function(e){
      rstudioapi::showDialog("Error","Something went wrong","")
    })

    tmcrstudioaddin::enable_course_tab()
  })
}

returnItem <- function(item, list) {
  ret <- ""
  for(name in names(list)) {
    if(list[[name]] == item) {
      ret <- name
    }
  }
  return(ret)
}
