#' @title Create a JSON file containing exercise metadata
#' @description Create a JSON file containing exercie metadata.
#' @usage create_exercise_metadata(exercise_id, exercise_directory, exercise_name)
#' @param exercise_id ID of the exercise.
#' @param exercise_directory Path to the directory where the exercise is downloaded into.
#' @param exercise_name Name of the exercise.
#' @details Creates a JSON file in the exercise's directory root. The JSON file contains the exercise's name and id,
#' which is used when the user wants to upload their exercise submission to the TMC server.
#' @return Either NULL or an integer status. See \code{\link[base]{connections}} in the \code{base} package for details.
create_exercise_metadata <- function(exercise_id,
    exercise_directory, exercise_name) {

    dir <- paste0(exercise_directory, "/", gsub("-", "/", exercise_name))
    course_directory_path <- file.path(dir, ".metadata.json",
                              fsep = .Platform$file.sep)
    newfile <- file(course_directory_path)

    export_json <- jsonlite::toJSON(list(id = exercise_id,
                    name = basename(exercise_directory)),
                    pretty = TRUE)

    cat(export_json, file = newfile, sep = "\n")
    close(newfile)
}
