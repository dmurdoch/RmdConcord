\name{processConcordance}
\alias{processConcordance}
\title{
Get the concordance from the "datapos" values and record it in
a file.
}
\description{
Pandoc can record concordance information in
\code{datapos} attributes
when converting Commonmark documents to HTML.  This retrieves
that information, and rewrites it as standard R concordance
data.
}
\usage{
processConcordance(filename, newfilename = filename,
                      rename = NULL,
                      followConcordance = TRUE)
}
\arguments{
  \item{filename}{
The filename of the HTML file produced by Pandoc.
}
  \item{newfilename}{
A filename in which to write the changed data.
}
  \item{rename}{
A named character vector.  Names are the names in the \code{datapos}
attributes; values are the names that should be included in the
concordance instead. This might be used since \pkg{knitr} produces a
Markdown file and renames it later.
  }
  \item{followConcordance}{
If \code{filename} already contains concordance data, assume
that the Rmd file was produced automatically, and chain the
concordances.
}
}
\value{
Called for the side effect of rewriting the concordance, it returns
\code{newfilename} invisibly.
}
\author{
Duncan Murdoch
}
\examples{
# This example works on the file inst/sample/Sample.Rmd,
# which should be a copy of the vignette Sample.Rmd.  This
# is convenient because RStudio doesn't install vignettes by default.

# First, see the results without concordances:

library(RmdConcord)
dir <- tempdir()
intermediates <- tempfile()

infile <- system.file("sample/Sample.Rmd", package = "RmdConcord")
outfile1 <- file.path(dir, "html_vignette.html")

rmarkdown::render(infile,
                  intermediates_dir = intermediates,
                  output_file = outfile1,
                  quiet = TRUE)
tidy_validate(outfile1)

# Next, see them with concordances by setting
# the output format to use RmdConcord::html_documentC
# which post-processes the document with processConcordance.

dir <- tempdir()
outfile2 <- file.path(dir, "commonmark.html")
rmarkdown::render(infile,
                  intermediates_dir = intermediates,
                  output_file = outfile2,
                  output_format = html_documentC(),
                  quiet = TRUE)
tidy_validate(outfile2)
unlink(c(intermediates, outfile1, outfile2), recursive = TRUE)
}
