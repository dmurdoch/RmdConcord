test_knitr <- function() {
  save <- knitr::opts_knit$get(c("concordance", "rmarkdown.pandoc.to"))
  knitr::opts_knit$set(concordance = TRUE, rmarkdown.pandoc.to = "markdown")
  on.exit(knitr::opts_knit$set(save))
  if (!knitr:::concord_mode())
    stop("RmdConcord requires patches to knitr that are available using\n  remotes::install_github('dmurdoch/knitr')")
}

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
    # Have we got the patched knitr?
    test_knitr()

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

html_document_with_concordance <- html_with_concordance(html_document)

html_vignette_with_concordance <- html_with_concordance(html_vignette)

pdf_with_concordance <- function(driver) {
  force(driver)
  function(latex_engine = "pdflatex",
           sourcepos = TRUE,
           defineSconcordance = TRUE, ...) {

    # Have we got the patched knitr?
    test_knitr()

    res <- driver(latex_engine = latex_engine, ...)
    res$knitr$opts_knit$concordance <- sourcepos
    if (sourcepos) {
      res$pandoc$from <- fix_pandoc_from_options(res$pandoc$from, sourcepos)
      # Add filter to insert \datapos markup
      res$pandoc$lua_filters <- c(res$pandoc$lua_filters,
                                  system.file("rmarkdown/lua/latex-datapos.lua", package = "RmdConcord"))
      # Pandoc should produce .tex, not go directly to .pdf
      orig_ext <- res$pandoc$ext
      res$pandoc$ext = ".tex"

      # Replace the old post_processor with ours
      oldpost <- res$post_processor
      res$post_processor <- function(yaml, infile, outfile, ...) {
        # We should have a concordance file
        concordanceFile <- paste0(sans_ext(infile), "-concordance.tex")
        # Modify the .tex file
        processLatexConcordance(outfile, followConcordance = concordanceFile, defineSconcordance = defineSconcordance)

        if (orig_ext != ".tex") {
          # Run pdflatex or other with Synctex output
          args <- c("-synctex=1", outfile)
          system2(latex_engine, args)

          # Apply concordance changes to Synctex file
          synctexfile <- paste0(sans_ext(outfile), ".synctex")
          patchDVI::patchSynctex(synctexfile)
        }

        # Run the old post-processor, if there was one
        newoutfile <- paste0(sans_ext(outfile), ".pdf")
        if (is.function(oldpost))
          res <- oldpost(yaml, infile, newoutfile, ...)
        else
          res <- newoutfile
        res
      }
    }
    res
  }
}

pdf_document_with_concordance <- pdf_with_concordance(pdf_document)
