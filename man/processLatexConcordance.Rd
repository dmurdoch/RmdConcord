\name{processLatexConcordance}
\alias{processLatexConcordance}
\title{
Process a LaTeX concordance file.
}
\description{
Pandoc can record concordance information in \code{\\datapos} macros
when converting Commonmark documents to LaTeX.  This retrieves
that information, and rewrites it as standard R concordance
data.
}
\usage{
processLatexConcordance(filename,
                        newfilename = filename,
                        rename = NULL,
                        followConcordance = NULL,
                        defineSconcordance = TRUE)
}
\arguments{
  \item{filename}{
The filename of the LaTeX file produced by Pandoc.
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
  \item{defineSconcordance}{
Whether to insert the definition of the \verb{\\Sconcordance} macro.
  }
}
\value{
Called for the side effect of rewriting the concordance, it returns
\code{newfilename} invisibly.
}
\author{
Duncan Murdoch
}
