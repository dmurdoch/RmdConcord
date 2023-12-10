# These functions work with the commonmark package

html_formatC <-function(options = list(sourcepos = TRUE), ...) {
  if (!test_packages(FALSE, pandoc = FALSE))
    options$sourcepos <- FALSE
  sourcepos <- options$sourcepos
  if (is.null(sourcepos))
    options$sourcepos <- sourcepos <- TRUE
  res <- markdown::html_format(options = options, ...)
  res$knitr$opts_knit$concordance <- sourcepos
  if (sourcepos) {
    oldpost <- res$post_processor
    res$post_processor <- function(metadata, input_file, output_file, ...) {
      if (!is.null(oldpost))
        res <- oldpost(metadata, input_file, output_file, ...)
      else
        res <- output_file
      processConcordance(res, res)
      res
    }

    res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
  }
  res
}

