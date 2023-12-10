\name{commonmark_document}
\alias{html_documentC}
\alias{html_vignetteC}
\alias{pdf_documentC0}
\alias{html_formatC}
\alias{latex_formatC}
\title{
R Markdown drivers to add concordance
}
\description{
These drivers replace the like-named \pkg{rmarkdown}
or \pkg{markdown}
drivers with ones that output Commonmark rather than Pandoc Markdown.
Commonmark is a dialect of Markdown.  The Pandoc driver
for Commonmark supports output of source position information.
By using this function as your output driver, you can get that
in your own documents.

A replacement for \code{markdown::latex_format} is not planned; see the note below.
}
\usage{
html_documentC(sourcepos = TRUE, ...)
html_vignetteC(sourcepos = TRUE, ...)
pdf_documentC0(latex_engine = "pdflatex",
           sourcepos = TRUE,
           defineSconcordance = TRUE,
           ...)
html_formatC(options = list(sourcepos = TRUE), ...)
}
\arguments{
  \item{latex_engine}{
Command to convert \file{.tex} file to \file{.pdf}.
}
  \item{defineSconcordance}{
If \code{TRUE}, insert a definition of the \verb{\Sconcordance}
macro just before \verb{\begin{document}}.
}
  \item{sourcepos}{Whether to include source position information.}
  \item{options}{
The options argument to pass to the base driver.  If
\code{options$sourcepos} is not specified, it will default to
\code{TRUE}.
}
  \item{\dots}{
Other arguments to pass to the base driver.
}
}
\details{
Each driver modifies the standard driver from \pkg{rmarkdown} or
\pkg{markdown}, e.g.
\code{html_documentC} is similar to
\code{\link[rmarkdown]{html_document}}, but uses Commonmark
and adds concordances.
}
\note{
The \code{pdf_documentC0} function adds the concordances,
but they won't be interpreted by LaTeX or PDF previewers.
To get that to happen, use \code{patchDVI::pdf_documentC}.

The \code{html_formatC} function requires \pkg{markdown}
version 1.12.1 or higher.  If a lower version of that
package is installed
\code{html_formatC} will still run, but will issue a
warning and not add any concordances.

The concordances produced by \code{html_formatC} tend to
be off by a few lines as the underlying Commonmark
processor only issues source position records once per
paragraph.

A \code{latex_formatC} driver appears as if it would be
quite messy and is not currently planned.  The issues are:
\itemize{
\item{\pkg{commonmark} doesn't support
source position attributes in LaTeX output}
\item{It doesn't allow edits between the parsing and rendering steps.  This is what \code{pdf_documentC} does.}
\item A possible strategy would be to render first to XML
(which does keep source position attributes), then convert
the XML to LaTeX with macros inserted to record source
positions.  However, \code{markdown::latex_format} produces
the final LaTeX document in several steps, and would have to
support this two-stage rendering on some but not all of
the steps.}
}
\value{
An R Markdown output format object which will add concordance
information.
}
\author{
Duncan Murdoch
}
