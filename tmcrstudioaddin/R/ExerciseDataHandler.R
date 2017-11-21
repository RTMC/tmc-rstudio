all_jsons_to_download <- function(json_exercises,
    token, course_directory_path) {

  for (i in 1:length(json_exercises)) {
    tmcrstudioaddin::from_json_to_download(i, json_exercises,
       course_directory_path)
  }
}

construct_course_url <- function(course_id) {
  base_url <- tmcrstudioaddin::getCredentials()$serverAddress
  course_url <- paste(sep = "",
          base_url, "/", "api/v8/courses", "/", course_id)
  return(course_url)
}

construct_course_exercise_url <- function(course_url) {
  course_exercises_url <- paste(sep = "/", course_url, "exercises")
  return(course_exercises_url)
}

construct_directory_path <- function(course_name) {
  # Name of the course is retrieved from the server.
  user_home <- Sys.getenv("HOME")
  r_home <- file.path(user_home, "tmcr-projects")

  # The path where we want to download the exercises.
  course_directory_path <- file.path(r_home, course_name,
                            fsep = .Platform$file.sep)
  return(course_directory_path)
}

create_directory_and_download <- function(course_directory_path, token) {

      dir.create(course_directory_path,
          showWarnings = FALSE, recursive = TRUE)
      json_exercises <- jsonlite::read_json("temp.json")
      tmcrstudioaddin::all_jsons_to_download(json_exercises,
          token, course_directory_path)

      file.remove("temp.json")
}

create_exercise_metadata <- function(exercise_id,
    exercise_directory, exercise_name) {

  directory <- paste0(exercise_directory, "/", gsub("-", "/", exercise_name))
  course_directory_path <- file.path(directory,
    "metadata.json", fsep = .Platform$file.sep)

   newfile <- file(course_directory_path)
   export_json <- jsonlite::toJSON(list(id = exercise_id,
                   name = basename(exercise_directory)),
                   pretty = TRUE)

   cat(export_json, file = newfile, sep = "\n")
   close(newfile)
}

# Helper function that takes as arguments the iteration number i that indicates
# the number of the exercise to be downloaded, json_exercises which is the list
# containing all the info of the course, token, and course_directory_path
# (where we want to store the exercises).
from_json_to_download <- function(exercise_iteration,
  json_exercises, course_directory_path) {

    exercise_id <- json_exercises[exercise_iteration][[1]]$id
    exercise_name <- json_exercises[exercise_iteration][[1]]$name
    exercise_dir <- paste(sep = "/", course_directory_path, exercise_name)

    download_exercise(exercise_id, zip_target = course_directory_path,
                      exercise_directory = exercise_dir,
                      exercise_name = exercise_name)
}

read_data_from_exercise <- function(course_name, exercise_name) {
    path <- construct_directory_path(course_name)
    metadata_path <- file.path(path, exercise_name, "metadata.json",
        fsep = .Platform$file.sep)
    json <- jsonlite::read_json(metadata_path)
    return(json)
}

read_data_from_current_exercise <- function() {
    metadata_path <- file.path(getwd(),
            "metadata.json",
            fsep = .Platform$file.sep)

    json <- jsonlite::read_json(metadata_path)
    return(json)
}
