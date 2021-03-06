% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RunResultHtml.R
\name{createRunSourcingFailHtml}
\alias{createRunSourcingFailHtml}
\title{Create HTML for displaying a run or sourcing fail}
\usage{
createRunSourcingFailHtml(runResults)
}
\arguments{
\item{runResults}{Results from the failed attempt of running tests.}
}
\value{
A single \code{Shiny} \code{HTML} tag object containing all of the elements in
the created \code{HTML} run result output.
}
\description{
Create \code{HTML} for displaying a run or sourcing fail.
}
\details{
Creates an \code{HTML} view for displaying information related to a run- or
sourcing fail
}
\seealso{
\code{\link[shiny]{tags}}
}
