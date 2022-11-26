\name{html_document_with_concordance}
\alias{html_document_with_concordance}
\alias{html_vignette_with_concordance}
\alias{pdf_document_with_concordance}
\title{
R Markdown drivers to add concordance
}
\description{
These drivers output Commonmark rather than Pandoc Markdown.
Commonmark is a dialect of Markdown.  The Pandoc driver
for Commonmark supports output of source position information.
By using this function as your output driver, you can get that
in your own documents.
}
\usage{
html_document_with_concordance(sourcepos = TRUE, ...)
html_vignette_with_concordance(sourcepos = TRUE, ...)
pdf_document_with_concordance(latex_engine = "pdflatex",
           sourcepos = TRUE,
           defineSconcordance = TRUE, ...)
}
\arguments{
  \item{sourcepos}{
Whether to include source position information.
}
  \item{latex_engine}{
Command to convert \file{.tex} file to \file{.pdf}.
}
  \item{defineSconcordance}{
If \code{TRUE}, insert a definition of the \verb{\Sconcordance}
macro just before \verb{\begin{document}}.
}
  \item{\dots}{
Other arguments to pass to the base driver.
}
}
\details{
Each driver modifies the standard \pkg{rmarkdown} driver whose
name precedes \dQuote{with_concordance}, e.g. \code{html_document_with_concordance} is similar to \code{\link[rmarkdown]{html_document}}.
}
\value{
An R Markdown output format object which will add concordance
information.
}
\author{
Duncan Murdoch
}
