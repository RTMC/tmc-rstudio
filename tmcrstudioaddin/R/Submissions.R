#' @title Submit current exercise and process the response
#'
#' @description Submit the currently chosen exercise to the TMC server
#' and process the \code{JSON} received from the response.
#'
#' @usage submitExercise(path)
#'
#' @param path Path to the currently chosen directory.
#'
#' @details Submits the currently open exercise to the TMC server,
#' queries the server until it has finished processing the submission,
#' reads the data from the \code{JSON} received in the \code{HTTP}
#' response and shows a message popup showing if all of the tests passed or not.
#'
#' @return List of data read from the submission result \code{JSON}. List keys:
#' \code{tests}, \code{exercise_name}, \code{all_tests_passed}, \code{points}, \code{error}.
#' \code{error} is not \code{NULL}if submitting the exercise to the server failed
#'
#' @seealso \code{\link{submitCurrent}}, \code{\link{processSubmissionJson}},
#' \code{\link{showMessage}}

submitExercise <- function(path) {
  submitJson <- list()
  submitJson <- submitCurrent(path)
  submitRes <- list()
  if (is.null(submitJson$error)) {
    submitRes$data <- processSubmissionJson(submitJson$results)
  } else {
    submitRes$error <- submitJson$error
  }
  showMessage(submitRes)
  return(submitRes)
}

#' @title Submit the currently chosen exercise to the TMC server
#'
#' @description Submit the currently chosen exercise to the TMC server and return the
#' submission result \code{JSON}.
#'
#' @usage submitCurrent(path)
#'
#' @param path Path to the currently chosen directory.
#'
#' @details Reads the \code{OAuth2} token and TMC server address from
#' \code{.crendentials.rds} and uploads the currently open exercise to
#' the TMC server. If the upload was successful, starts querying the TMC server for the
#' submission result \code{JSON} until the server has finished processing the tests.
#'
#' @return Submission result with non \code{NULL} \code{results} if processing the tests in the TMC server was
#' successful. List keys: \code{results}, \code{error}. Error is not \code{NULL} if
#' processing the tests ended in error.
#'
#' @seealso \code{\link{getCredentials}}, \code{\link{upload_current_exercise}},
#' \code{\link{getExerciseFromServer}}
submitCurrent <- function(path) {
  submitJson <- list()
  credentials <- tmcrstudioaddin::getCredentials()
  token <- credentials$token
  response <- upload_current_exercise(token, project_path = path)
  if (is.null(response$error)) {
    submitJson <- getExerciseFromServer(response$data, token, 10)
  } else {
    submitJson$error <- response$error
  }
  return(submitJson)
}

#' @title Get the exercise submission results from the TMC server
#'
#' @description Get the exercise submission results from the TMC server
#'
#' @usage getExerciseFromServer(response, token, sleepTime)
#'
#' @param response \code{HTTP} response to the exercise submission upload.
#' @param token \code{OAuth2} token associated with the current login session.
#' @param sleepTime The time to sleep between queries to the tmc-server.
#'
#' @details Queries the server with \code{HTTP-GET} requests until the server
#' has finished processing the exercise submission.
#'
#' @return Submission result with non \code{NULL} \code{results} if processing the tests in the TMC server was
#' successful. List keys: \code{results}, \code{error}. Error is not \code{NULL} if
#' processing the tests ended in error.
#'
#' @seealso \code{\link{get_json_from_submission_url}},
#' \code{\link[shiny]{withProgress}}
getExerciseFromServer <- function(response, token, sleepTime) {
  submitJson <- get_json_from_submission_url(response, token)
  if (is.null(submitJson$error)) {
    while (submitJson$results$status == "processing") {
      if (!is.null(shiny::getDefaultReactiveDomain())) {
        shiny::incProgress(1 / 3)
      }
      Sys.sleep(sleepTime)
      submitJson <- get_json_from_submission_url(response, token)
    }
    if (submitJson$results$status == "error") {
      submitJson$error <- submitJson$results$error
    }
  }
  return(submitJson)
}

#' @title Read data from the submission result JSON
#'
#' @description Read data from the submission result \code{JSON}.
#'
#' @usage processSubmissionJson(submitJson)
#'
#' @param submitJson \code{HTTP} response containg the submission result \code{JSON}.
#'
#' @details Reads the test results, exercise name, boolean depending on if all
#' tests passed or not and the received points form the submission result \code{JSON}.
#'
#' @return List of data read from the submission result \code{JSON}. List keys:
#' \code{tests}, \code{exercise_name}, \code{all_tests_passed}, \code{points}
#'
#' @seealso \code{\link{processSubmission}}
processSubmissionJson <- function(submitJson) {
  submitRes <- list()
  submitRes[["tests"]] <- processSubmission(submitJson)
  submitRes[["exercise_name"]] <- submitJson$exercise_name
  submitRes[["all_tests_passed"]] <- submitJson$all_tests_passed
  submitRes[["points"]] <- submitJson$points
  return(submitRes)
}

#' @title Read test result data from the submission result JSON
#'
#' @description Read test result data from the submission result \code{JSON}.
#'
#' @usage processSubmission(submitJson)
#'
#' @param submitJson HTTP response containing the submission result \code{JSON}.
#'
#' @details Creates a list of test results received from the submission
#' result \code{JSON}.
#'
#' @return List of test results received from the submission result \code{JSON}.
processSubmission <- function(submitJson) {
  tests <- list()
  for (testCase in submitJson$test_cases) {
    result <- list()
    result[["name"]] <- testCase$name
    result[["status"]] <- getStatusFromBoolean(testCase$successful)
    result[["message"]] <- testCase$message
    tests[[length(tests) + 1]]  <- result
  }
  return(tests)
}

getStatusFromBoolean <- function(bol) {
  status <- "fail"
  if (bol) {
    status <- "pass"
  }
  return(status)
}

#' @title Show submission results in a pop-up dialog box
#'
#' @description Show submission reuslts in a pop-up dialog box.
#'
#' @usage showMessage(submitResults)
#'
#' @param submitResults List of data read from the submission result \code{JSON}.
#'
#' @seealso \code{\link{getDialogMessage}}, \code{\link[rstudioapi]{showDialog}}
showMessage <- function(submitResults) {
  message <- getDialogMessage(submitResults)
  rstudioapi::showDialog(title = message$title,
                         message = message$text,
                         url = "")
}

#' @title Get message to display in submission result pop-up dialog.
#'
#' @description Creates a message to be shown on the submit result pop-up dialog from
#' the submission results.
#'
#' @usage getDialogMessage(submitResults)
#'
#' @param submitResults List of data read from the submission result \code{JSON}.
#'
#' @return Message showing if submitting the exercise failed, some tests failed or all
#' tests passed.
getDialogMessage <- function(submitResults) {
  message <- list()
  message$title <- "Results"
  if (!is.null(submitResults$error)) {
    message$title <- "Error"
    errormsg <- submitResults$error
    if (nchar(errormsg) > 300) {
      errormsg <- substr(errormsg, 1, 300)
    }
    message$text <- paste0("<p>", errormsg)
  } else if (submitResults$data$all_tests_passed) {
    points <- paste(submitResults$data$points, collapse = ", ")
    message$text <- paste0("All tests passed on the server.<p><b>Points permanently awarded: ",
                                points, "</b><p>View model solution")
  } else {
    points <- paste(submitResults$data$points, collapse = ", ")
    message$text <- paste0("Exercise ", submitResults$data$exercise_name,
                                " failed partially.<p><b>Points permanently awarded: ", points,
                                "</b><p>Some tests failed on the server.<p>Press OK to see failing tests")
  }
  return(message)
}
