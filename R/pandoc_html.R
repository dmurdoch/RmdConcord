# These functions work with Pandoc commonmarkx producing HTML

html_with_concordance <- function(driver) {
  force(driver)
  function(sourcepos = TRUE, ...) {
    res <- driver(...)
    if (test_packages(FALSE)) {
      res$knitr$opts_knit$concordance <- sourcepos
      if (sourcepos) {
        res$knitr$opts_knit$out_format <- "markdown"

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
    }
    res
  }
}

html_documentC <- html_with_concordance(rmarkdown::html_document)

html_vignetteC <- html_with_concordance(rmarkdown::html_vignette)
