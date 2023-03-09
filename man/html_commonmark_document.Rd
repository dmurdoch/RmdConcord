\name{commonmark_document}
\alias{html_documentC}
\alias{html_vignetteC}
\alias{pdf_documentC0}
\title{
R Markdown drivers to add concordance
}
\description{
These drivers replace the like-named \pkg{rmarkdown}
drivers with ones that output Commonmark rather than Pandoc Markdown.
Commonmark is a dialect of Markdown.  The Pandoc driver
for Commonmark supports output of source position information.
By using this function as your output driver, you can get that
in your own documents.
}
\usage{
html_documentC(sourcepos = TRUE, ...)
html_vignetteC(sourcepos = TRUE, ...)
pdf_documentC0(latex_engine = "pdflatex",
           sourcepos = TRUE,
           defineSconcordance = TRUE,
           ...)
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
Each driver modifies the standard \pkg{rmarkdown} driver, e.g.
\code{html_documentC} is similar to
\code{\link[rmarkdown]{html_document}}, but uses Commonmark
and adds concordances.
}
\note{
The \code{pdf_documentC0} function adds the concordances,
but they won't be interpreted by LaTeX or PDF previewers.
To get that to happen, use \code{patchDVI::pdf_documentC}
once it is released.
}
\value{
An R Markdown output format object which will add concordance
information.
}
\author{
Duncan Murdoch
}
