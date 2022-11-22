\name{getDataposConcordance}
\alias{getDataposConcordance}
\title{
Get the concordance from the datapos values.
}
\description{
Pandoc can record concordance information in datapos attributes
when converting Commonmark documents to HTML.  This retrieves
that information, and rewrites it as standard R concordance
data.
}
\usage{
getDataposConcordance(filename, newfilename,
                      rename = NULL,
                      followConcordance = TRUE)
}
\arguments{
  \item{filename}{
The filename of the HTML file produced by Pandoc.
}
  \item{newfilename}{
A new name in which to write the changed data.
}
  \item{rename}{
A named character vector.  Names are the names in the \code{datapos}
attributes; values are the names that should be included in the
concordance instead, since \pkg{knitr} produces a Markdown
file but renames it later.
  }
  \item{followConcordance}{
If \code{filename} already contains concordance data, assume
that the Rmd file was produced automatically, and chain the
concordances.
}
}
\value{
Called for the side effect of rewriting the concordance.
}
\author{
Duncan Murdoch
}
\examples{
# First, see the results without concordances:

library(RmdConcord)
dir <- tempdir()
outfile1 <- file.path(dir, "html_vignette.html")
rmarkdown::render("~/svn/MyR/RmdConcord/vignettes/Sample.Rmd",
                  output_file = outfile1,
                  quiet = TRUE)
tools:::tidy_validate(outfile1)

# Next, see them with concordances:

dir <- tempdir()
outfile2 <- file.path(dir, "commonmark.html")
outfile3 <- file.path(dir, "patched.html")
rmarkdown::render("~/svn/MyR/RmdConcord/vignettes/Sample.Rmd",
                  output_file = outfile2,
                  output_format = html_commonmark_document(keep_md = TRUE),
                  quiet = TRUE)
getDataposConcordance(outfile2, outfile3, rename = c("Sample.knit.md" = "commonmark.md"))
RmdConcord:::tidy_validate(outfile3)
readLines(file.path(dir, "commonmark.md"))
}
