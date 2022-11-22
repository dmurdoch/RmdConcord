fix_pandoc_from_options <- function(from, sourcepos) {
  from <- sub("^markdown", "commonmark", from)
  from <- sub("[+]tex_math_single_backslash", "", from)
  from <- paste0(from, 
                 "+yaml_metadata_block", 
                 if (sourcepos) "+sourcepos")
  from
}

html_commonmark_document <- function(sourcepos = TRUE, ...) {
  res <- rmarkdown::html_document(...)
  res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
#  browser()
  res
}


pdf_commonmark_document <- function(sourcepos = TRUE, ...) {
  res <- rmarkdown::pdf_document(...)
  res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
  res
}
