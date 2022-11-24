fix_pandoc_from_options <- function(from, sourcepos) {
  from <- sub("^markdown", "commonmark", from)
  from <- sub("[+]tex_math_single_backslash", "", from)
  from <- paste0(from,
                 "+yaml_metadata_block",
                 if (sourcepos) "+sourcepos")
  from
}

html_with_concordance <- function(driver) {
  force(driver)
  function(sourcepos = TRUE, ...) {
    res <- driver(...)
    if (sourcepos) {
      res$knitr$opts_knit$concordance <- sourcepos
      res$knitr$opts_knit$out_format <- "markdown"

      oldpost <- res$post_processor
      res$post_processor <- function(...) {
        res <- oldpost(...)
        processConcordance(res, res)
        res
      }

      res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
    }
    res
  }
}

html_document_with_concordance <- html_with_concordance(html_document)

html_vignette_with_concordance <- html_with_concordance(html_vignette)

pdf_document_with_concordance <- function(sourcepos = TRUE, ...) {
  res <- pdf_document(...)
  res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
  res
}
