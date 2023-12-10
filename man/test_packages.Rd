\name{test_packages}
\alias{test_packages}
\title{
Test for sufficient versions of supporting packages
}
\description{
This function tests for the presence of packages
that will support \pkg{RmdConcord} functions.
}
\usage{
test_packages(error = TRUE, pandoc = TRUE)
}
\arguments{
\item{error}{If \code{TRUE}, missing
requirements will result in an error.  If \code{FALSE}, they result in a warning.}
\item{pandoc}{Is Pandoc needed?}
}
\value{
A logical value indicating that the
requirements are present.  Will never return
\code{FALSE} if \code{error} is  \code{TRUE},
it will just trigger an error.
}
\examples{
test_packages()
}
