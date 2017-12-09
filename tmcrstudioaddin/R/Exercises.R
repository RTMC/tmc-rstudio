#' @title Get the currently open exercise
#' @description Get the currently open exercise (the exercise which is located at the current working directory).
#' @usage exerciseFromWd()
#' @details Checks if the current working directory is a subfolder in the TMC projects -folder.
#' @return Name of the exercise directory. If the current working directory isn't an exercise folder, returns an
#' empty string.

# Returns the exercise that is selected as wd.
# If wd doenst contain an exercise returns "".
exerciseFromWd <- function() {
  dirname <- dirname(getwd())
  basename <- basename(getwd())

  # Current wd is not an exercise (a folder in exercises_path)
  if(dirname != get_projects_folder() || !(basename %in% downloadedExercises())) {
    return("")
  } else {
    return(basename)
  }
}

#' @title Get a list of downloaded exercises
#' @description Get a list of the names of downloaded exercises.
#' @usage downloadedExercises()
#' @return List containing the names of the exercises.
#Returns a list of downloaded exercises
downloadedExercises <- function() {
  return(c("", list.dirs(path = get_projects_folder(), full.names = FALSE, recursive = FALSE)))
}

#' @title Get a file path to the specified exercise
#' @description Get a file path to the specified exercise.
#' @usage getExercisePath(exercise)
#' @param exercise Name of the exercise
#' @return File path to the exercise which name was given as a parameter
#' @examples getExercisePath("0_0_helloworld")
getExercisePath <- function(exercise) {
  return(paste0(get_projects_folder(), "/", exercise))
}

#' @title Source exercise .R files
#' @description Source the .R files contained in the exercise directory's \code{R} folder.
#' @usage sourceExercise(exercise)
#' @param exercise Name of the exercise which .R files are sourced
sourceExercise <- function(exercise) {
  env <- new.env()
  for (file in list.files(pattern = "[.]R$", path = paste0(getExercisePath(exercise), "/R"),
                          full.names = TRUE)) {
    cat("Sourcing file: ", file, "\n\n")
    source(file, env, print.eval = TRUE)
  }
}
