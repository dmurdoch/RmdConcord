\name{tidy_validate}
\alias{tidy_validate}
\title{
Reproduce tidy validation done in R 4.3.0.
}
\description{
This function is taken from R-devel, to test the
use of \pkg{RmdConcord} in checking packages.
}
\usage{
tidy_validate(f, tidy = "tidy")
}
\arguments{
  \item{f}{
An \file{HTML} file to test.
}
  \item{tidy}{
The name of the \code{HTML Tidy} executable.
}
}
\value{
An object showing issues in the file and
locations in the source file.
}
