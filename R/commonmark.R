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

latex_formatC0 <- function(latex_engine = "pdflatex",
                          options = list(sourcepos = TRUE),
                          defineSconcordance = TRUE,
                          ...) {

  # Have we got the suggested dependencies?
  test_packages(pandoc = FALSE)

  sourcepos <- options$sourcepos

  if (is.null(sourcepos))
    options$sourcepos <- sourcepos <- TRUE

  res <-  markdown::latex_format(options = options,
                                 latex_engine = latex_engine, ...)
  res$knitr$opts_knit$concordance <- sourcepos
  if (sourcepos) {

    # Should produce .tex, not go directly to .pdf
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
      processLatexConcordance(outfile, followConcordance = concordanceFile, defineSconcordance = defineSconcordance,
                              infile = infile)

      outfile
    }
  }
  res
}
