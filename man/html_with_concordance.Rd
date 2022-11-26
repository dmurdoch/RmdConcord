\name{html_with_concordance}
\alias{html_with_concordance}
\alias{pdf_with_concordance}
\title{
Convert an R Markdown driver to one that handles concordances.
}
\description{
These functions produce a new driver which matches the old
one in most respects, but adds an argument \code{sourcepos}
(and possibly others).
If that argument is \code{TRUE} (the default) then concordances
are handled by the new driver.

This function is used to produce \code{\link{html_document_with_concordance}} and similar drivers
in this package, but should also work on other drivers that produce
HTML output using Pandoc.
}
\usage{
html_with_concordance(driver)
pdf_with_concordance(driver)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{driver}{
An R Markdown driver that produces HTML, LaTeX or PDF using Pandoc.
}
}
\value{
A new driver function.
}
\examples{
html_with_concordance(rmarkdown::html_fragment)
pdf_with_concordance(rmarkdown::latex_fragment)
}
