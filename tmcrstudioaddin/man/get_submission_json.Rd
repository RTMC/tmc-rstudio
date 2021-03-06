% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/HTTPQueries.R
\name{get_submission_json}
\alias{get_submission_json}
\title{Get exercise submission result JSON}
\usage{
get_submission_json(token, url)
}
\arguments{
\item{token}{\code{OAuth2} token associated with the the current login session to the
TMC server.}

\item{url}{URL where the exercise submission \code{JSON} is fetched from.}
}
\value{
\code{HTTP} response from the TMC server which contains the submission result \code{JSON} if
the server has finished processing the exercise submission.
}
\description{
Get the exercise submission result \code{JSON} file from the TMC server.
}
\details{
Makes a \code{HTTP-GET} request to fetch the exercise submission result \code{JSON}
from the specified URL.
}
\seealso{
\code{\link[httr]{add_headers}}, \code{\link[httr]{GET}}
}
