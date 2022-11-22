\name{html_commonmark_document}
\alias{html_commonmark_document}
\alias{pdf_commonmark_document}
\title{
R Markdown drivers for Commonmark source
}
\description{
Commonmark is a dialect of Markdown.  The Pandoc driver
for Commonmark supports output of source position information.
By using this function as your output driver, you can get that
in your own documents.
}
\usage{
html_commonmark_document(sourcepos = TRUE, ...)
pdf_commonmark_document(sourcepos = TRUE, ...)
}
\arguments{
  \item{sourcepos}{
Whether to include source position information.
}
  \item{\dots}{
Other arguments to pass to \code{\link[rmarkdown]{html_document}}
or \code{\link[rmarkdown]{pdf_document}}.
}
}
\value{
An R Markdown output format object.
}
\author{
Duncan Murdoch
}
