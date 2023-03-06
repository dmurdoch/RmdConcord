
fix_pandoc_from_options <- function(from, sourcepos) {
  from <- sub("^markdown", "commonmark_x", from)
  from <- sub("[+]tex_math_single_backslash", "", from)
  from <- paste0(from,
                 "+yaml_metadata_block",
                 if (sourcepos) "+sourcepos")
  from
}

html_with_concordance <- function(driver) {
  force(driver)
  function(sourcepos = TRUE, ...) {
    # Have we got the suggested dependencies?
    test_packages()

    res <- driver(...)
    res$knitr$opts_knit$concordance <- sourcepos
    if (sourcepos) {
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

html_documentC <- html_with_concordance(rmarkdown::html_document)

html_vignetteC <- html_with_concordance(rmarkdown::html_vignette)

pdf_with_concordance <- function(driver) {
  force(driver)
  function(latex_engine = "pdflatex",
           sourcepos = TRUE,
           defineSconcordance = TRUE,
           ...) {

    # Have we got the suggested dependencies?
    test_packages()

    res <- driver(latex_engine = latex_engine, ...)
    res$knitr$opts_knit$concordance <- sourcepos
    if (sourcepos) {
      res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
# res$pandoc$to <- "native"
      # Add filter to insert \datapos markup
      res$pandoc$lua_filters <- c(res$pandoc$lua_filters,
                                  system.file("rmarkdown/lua/pagebreak.lua", package = "RmdConcord"),
                                  system.file("rmarkdown/lua/latex-datapos.lua", package = "RmdConcord")
                                  )
      # Pandoc should produce .tex, not go directly to .pdf
      res$pandoc$RmdConcord_ext <- res$pandoc$ext
      res$pandoc$ext = ".tex"

      # Replace the old post_processor with ours
      res$RmdConcord_post_processor <- res$post_processor
      res$post_processor <- function(yaml, infile, outfile, ...) {
        workdir <- dirname(outfile)
        # We should have a concordance file
        concordanceFile <- paste0(sans_ext(normalizePath(infile)), "-concordance.tex")
        origdir <- setwd(workdir)
        on.exit(setwd(origdir))
        # Modify the .tex file
        processLatexConcordance(outfile, followConcordance = concordanceFile, defineSconcordance = defineSconcordance)

        outfile
      }
    }
    res
  }
}

pdf_documentC0 <- pdf_with_concordance(rmarkdown::pdf_document)
