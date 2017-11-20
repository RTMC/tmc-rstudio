#Exercise_id is the identifier of the exercise. For example, 36463.
#Target is the place where zip-file is stored, if it's not deleted.
download_exercise <- function(exercise_id,
                        zip_target = getwd(),
                        zip_name = "temp.zip",
                        exercise_directory) {

  credentials <- tmcrstudioaddin::getCredentials()
  token <- credentials$token
  serverAddress <- credentials$serverAddress

  zip_path <- paste(sep = "", zip_target, "/", zip_name)

  exercises_url <- paste(sep = "", serverAddress, "/", "api/v8/core/exercises/",
                        exercise_id, "/", "download")

  url_config <- httr::add_headers(Authorization = token)

  exercises_response <- httr::GET(exercises_url,
                              config = url_config,
                              write_disk(zip_path, overwrite = TRUE))

  .tmc_unzip(zipfile_name = zip_path, target_folder = exercise_directory)

  tmcrstudioaddin::create_exercise_metadata(exercise_id, exercise_directory)

  return(exercises_response)
}

#Example course id: 242.
download_all_exercises <- function(course_id) {
    credentials <- tmcrstudioaddin::getCredentials()
    token <- credentials$token

    course_url <- tmcrstudioaddin::construct_course_url(course_id)

    course_exercises_url <-
      tmcrstudioaddin::construct_course_exercise_url(course_url)

    # We need the token in the header.
    url_config <- httr::add_headers(Authorization = token)

    course_exercises_response <- httr::GET(course_exercises_url,
                                config = url_config,
                                write_disk("temp.json", overwrite = TRUE))

    course_name_response <- httr::GET(course_url, config = url_config)
    course_name <- httr::content(course_name_response)$name

    course_directory_path <-
      tmcrstudioaddin::construct_directory_path(course_name)

    tmcrstudioaddin::create_directory_and_download(course_directory_path, token)
}

upload_exercise <- function(token, exercise_id, project_path,
                             server_address, zip_name = "temp",
                             remove_zip = TRUE) {
  base_url <- server_address
  exercises_url <- paste(sep = "", base_url, "api/v8/core/exercises/",
                         exercise_id, "/", "submissions")
  url_config <- httr::add_headers(Authorization = token)

  .tmc_zip(project_path, zip_name)

  zipped_file <- paste(sep = "", getwd(), "/", zip_name, ".zip")
  submission_file <- httr::upload_file(zipped_file)

  exercises_response <- httr::POST(exercises_url,
                              config = url_config,
                              encode = "multipart",
                              body = list("submission[file]" = submission_file))

  if (remove_zip) {
    file.remove(paste(sep = "", zip_name, ".zip"))
  }

  return(httr::content(exercises_response))
}

# Zips the current working directory and uploads it to the server
# TODO:
# -Dynamic exercise_id and server_address (currently hardcoded)
upload_current_exercise <- function(token, exercise_id, server_address,
                                     zip_name = "temp", remove_zip = TRUE) {
  upload_exercise(token = token, exercise_id = exercise_id, project_path = getwd(),
                   server_address = server_address, zip_name = zip_name, remove_zip = remove_zip)
}

getAllOrganizations <- function(){
  organizations <- tryCatch({
    credentials <- tmcrstudioaddin::getCredentials()
    url <- paste(credentials$serverAddress, '/api/v8/org.json', sep = "")
    token <- credentials$token
    req <- httr::GET(url = url, config = httr::add_headers(Authorization = token), encode = "json")
    jsonlite::fromJSON(httr::content(req, "text"))
  }, error = function(e){
    list(slug = list())
  })
  return(organizations$slug)
}

getAllCourses <- function(organization) {
  courses <- tryCatch({
    credentials <- tmcrstudioaddin::getCredentials()
    serverAddress <- credentials$serverAddress
    token <- credentials$token
    url <- paste(serverAddress, "/api/v8/core/org/", organization, "/courses", sep = "")
    req <- httr::stop_for_status(httr::GET(url = url, config = httr::add_headers(Authorization = token), encode = "json"))
    jsonlite::fromJSON(httr::content(req, "text"))
  }, error = function(e){
    list(id=list(),name = list())
  })
  return(list(id=courses$id,name=courses$name))
}
getAllExercises <- function(course){
  exercises <- tryCatch({
    credentials <- tmcrstudioaddin::getCredentials()
    serverAddress <- credentials$serverAddress
    token <- credentials$token
    url <- paste(serverAddress, "/api/v8/courses/",course, "/exercises", sep = "")
    req <- httr::stop_for_status(httr::GET(url = url, config = httr::add_headers(Authorization = token), encode = "json"))
    jsonlite::fromJSON(httr::content(req, "text"))

  }, error = function(e){
      list()
  })
}
