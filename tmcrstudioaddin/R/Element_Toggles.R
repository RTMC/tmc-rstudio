disable_elements <- function(...) {
  elements <- as.list(substitute(list(...)))[-1L]

  lapply(elements, function(i) {shinyjs::disable(i)})
}

enable_elements <- function(...) {
  elements <- as.list(substitute(list(...)))[-1L]

  lapply(elements, function(i) {shinyjs::enable(i)})
}

disable_submit_tab <- function() {
  disable_elements("runTests", "submit", "showAllResults")
}

enable_submit_tab <- function() {
  enable_elements("runTests", "submit", "showAllResults")
}

disable_course_tab <- function() {
  disable_elements("refreshOrganizations", "organizationSelect", "refreshCourses",
                   "courseSelect", "download", "exercises")
}

enable_course_tab <- function() {
  enable_elements("refreshOrganizations", "organizationSelect", "refreshCourses",
                   "courseSelect", "download", "exercises")
}
