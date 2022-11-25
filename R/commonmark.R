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
  if (sourcepos) {
    res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
    res$pandoc$lua_filters <- c(res$pandoc$lua_filters,
                                system.file("rmarkdown/lua/latex-datapos.lua", package = "RmdConcord"))
    res$pandoc$ext = ".tex"
    res$knitr$opts_knit$concordance <- sourcepos
    res$knitr$opts_knit$out_format <- "markdown"
    pdfengine <- which(res$pandoc$args == "--pdf-engine") + 1
    oldpost <- res$post_processor
    res$post_processor <- function(yaml, infile, outfile, ...) {
      concordanceFile <- paste0(tools::file_path_sans_ext(infile),
                                "-concordance.tex")
      processLatexConcordance(outfile, followConcordance = concordanceFile)
      args <- c("-synctex=1", outfile)
      system2(res$pandoc$args[pdfengine], args)
      synctexfile <- paste0(tools::file_path_sans_ext(outfile),
                            ".synctex")
      patchDVI::patchSynctex(synctexfile)
      newoutfile <- paste0(tools::file_path_sans_ext(outfile),
                           ".pdf")
      if (is.function(oldpost))
        res <- oldpost(yaml, infile, newoutfile, ...)
      else
        res <- newoutfile
      res
    }
  }
  res
}
