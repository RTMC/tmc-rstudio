#' @title Create the properties file
#'
#' @description Create the \code{properties.rds} file, which includes the path to the directory
#' where the exercises are downloaded into.
#'
#' @usage create_properties_file(tmcr_projects = "tmcr-projects")
#'
#' @param user_set Should be TRUE if user has selected the directory, FALSE if created
#' with default settings. TRUE by default.
#' @param tmcr_projects Name of the directory where the exercises are downloaded into.
#' \code{tmcr-projects} by default.
#' @param tmcr_directory Name of the directory where tmcr_projects is created, .credentials
#' is etc. \code{NA} by default.
#'
#' @return Always \code{NULL}.
#'
#' @seealso \code{\link{get_tmcr_directory}}, \code{\link[base]{saveRDS}}
create_properties_file <- function(user_set = TRUE,
  tmcr_projects = "tmcr-projects",
  tmcr_directory = NA) {
  
  if (is.na(tmcr_directory)) {
    user_home <- Sys.getenv("HOME")
    tmcr_directory <- file.path(user_home, "tmcr")
  }

  properties <- list("tmcr_projects" = 
      paste(tmcr_directory, tmcr_projects, sep = .Platform$file.sep),
    "tmcr_dir" = tmcr_directory, "relative" = FALSE, user_set = user_set)

  properties_path <- get_properties_location()

  saveRDS(properties, properties_path)
}

#' @title Check for the existence of the properties file.
#'
#' @description Check for the existence of the \code{properties.rds} file at the root of the
#' \code{tmcr} directory.
#'
#' @usage check_if_properties_exist()
#'
#' @return \code{TRUE} if the \code{properties.rds} exists at the root of the \code{tmcr}
#' directory, otherwise \code{FALSE}.
#'
#' @seealso \code{\link{get_tmcr_directory}}, \code{\link[base]{file.exists}}
check_if_properties_exist <- function() {
  properties_path <- get_properties_location()

  return(file.exists(properties_path))
}

#' @title Get the tmcr directory path
#'
#' @description Get the file path to the \code{tmcr} directory path.
#'
#' @usage get_tmcr_directory()
#'
#' @details Creates a file path to the \code{tmcr} directory. It is located where the
#' user's \code{HOME} environment variable points to: by default to the \code{home} directory
#' on Linux and \code{user/documents} on Windows. If the \code{tmcr} directory does not exist
#' at the file path then it is created to be at that location.
#'
#' @return File path to the location of the \code{tmcr} directory
#'
#' @seealso \code{\link[base]{Sys.getenv}}, \code{\link[base]{file.path}},
#' \code{\link[base]{files2}}
get_tmcr_directory <- function() {
  properties <- read_properties()
  tmcr_directory <- properties$tmcr_dir

  return(tmcr_directory)
}

#' @title Get the tmcr directory path
#'
#' @description Chech whether directory tmcr exists in the location defined by .properties
#'
#' @usage tmcr_directory_exists()
#'
#' @return Yes if directory tmcr exists, no otherwise
#'
#' @seealso \code{\link[base]{dir.exists}}, \code{\link{read_properties}}
tmcr_directory_exists <- function() {
  return(dir.exists(read_properties()$tmcr_dir))
}

#' @title Create the folder structure tmcr/tmcr-projects if they don't already exist.
#'
#' @description Checks it tmc-projects exists in the place defined by .properties and
#' creates it if it doesn't.
#'
#' @usage create_projects_directory()
#'
#' @return Always \code{NULL}.
#'
#' @seealso \code{\link[base]{dir.exists}},\code{\link[base]{dir.create}},
#' \code{\link{read_properties}}
create_projects_directory <- function() {
  properties <- read_properties()
  tmcr_directory <- properties$tmcr_projects
  if (!dir.exists(tmcr_directory)) {
    dir.create(tmcr_directory, recursive = TRUE)
  }
}

#' @title Get the TMC R-project directory path
#'
#' @description Get the file path to the \code{tmcr-projects} folder, which contains the TMC R
#' exercise projects.
#'
#' @usage get_projects_directory()
#'
#' @details Reads the location of tmcr directory from .properties, creates the directory
#' if it doesn't exist and returns the path.
#'
#' @return The path to tmcr directory
get_projects_directory <- function() {
  properties <- read_properties()
  tmcr_directory <- properties$tmcr_projects

  # if (!dir.exists(tmcr_directory)) {
  #   dir.create(tmcr_directory, recursive = TRUE)
  # }

  return(tmcr_directory)
}

#' @title Read the properties file
#'
#' @description Read and return the data from \code{properties.rds}.
#'
#' @usage read_properties()
#'
#' @details Reads the data from \code{properties.rds} and returns it. If the
#' \code{properites.rds} file does not exist at the \code{tmcr} directory, it is
#' created there.
#'
#' @return An R object created from the data of \code{properties.rds}.
#'
#' @seealso \code{\link{check_if_properties_exist}}, \code{\link{create_properties_file}},
#' \code{\link{get_tmcr_directory}}, \code{\link[base]{readRDS}}
read_properties <- function() {
  if (!check_if_properties_exist()) {
    create_properties_file(user_set = FALSE)
  }

  properties_path <- get_properties_location()
  
  return(readRDS(properties_path))
}

#' @title Get location of properties file
#'
#' @description Checks the location where tmcRtestrunner is installed with \code{installed.packages}
#'
#' @usage get_properties_location()
#'
#' @return Path to the desired .properties file, i.e. install folder of tmcRtestrunner
get_properties_location <- function() {
  addin_root_dir <- installed.packages()["tmcRtestrunner", "LibPath"]
  addin_dir <- paste(addin_root_dir, "tmcrstudioaddin", sep = "/")

  properties_path <- paste(addin_dir, ".properties.rds",
                            sep = .Platform$file.sep)

  return(properties_path)
}