% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Authentication.R
\name{authenticate}
\alias{authenticate}
\title{Authenticate to a TMC server}
\usage{
authenticate(username, password, serverAddress)
}
\arguments{
\item{username}{Username of a TMC account.}

\item{password}{Password matching the inputed username of a TMC account.}

\item{serverAddress}{Address of the TMC server which the user wants to log in to.}
}
\value{
An \code{OAuth2} token if the authentication was succesful, otherwise returns an error
message.
}
\description{
Fetches the client id and secret from the server and logs in to the server.
}
\details{
Uses the \code{OAuth2} protocol for authentication. Fetches the client id and secret
from the server and uses them along with the username and password to login to the server.
}
\examples{
authenticate(username = "test", password = "hello123",
serverAddress = "https://tmc.mooc.fi")

}
\seealso{
\code{\link{fetchClientIdAndSecret}}, \code{\link[httr]{status_code}},
\code{\link[httr]{content}}, \code{\link{login}}
}
