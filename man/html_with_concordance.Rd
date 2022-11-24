\name{html_with_concordance}
\alias{html_with_concordance}
\title{
Convert an R Markdown HTML driver to one that handles concordances.
}
\description{
This function produces a new driver which matches the old
one in most respects, but adds an argument \code{sourcepos}.
If that argument is \code{TRUE} (the default) then concordances
are handled by the new driver.

This function is used to produce \code{\link{html_document_with_concordance}} and similar drivers
in this package, but should also work on other drivers that produce
HTML output using Pandoc.
}
\usage{
html_with_concordance(driver)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{driver}{
An R Markdown driver that produces HTML using Pandoc.
}
}
\value{
A new driver function.
}
\examples{
html_with_concordance(rmarkdown::html_fragment)
}
