# -------------------------------------
# This function isn't exported from tools, but we want to use it.

tidy_validate <-
  function(f, tidy = "tidy") {
    tidy <- Sys.which(tidy)
    if (length(tidy) > 1 ||
        is.na(tidy) ||
        !length(tidy) ||
        !nchar(tidy)) {
      warning("HTML tidy not found")
      return(NULL)
    }
    z <- suppressWarnings(system2(tidy,
                                  c("-language en", "-qe",
                                    ## <FIXME>
                                    ## HTML Tidy complains about empty
                                    ## spans, which may be ok.
                                    ## To suppress all such complaints:
                                    ##   "--drop-empty-elements no",
                                    ## To allow experimenting for now:
                                    Sys.getenv("_R_CHECK_RD_VALIDATE_RD2HTML_OPTS_",
                                               "--drop-empty-elements no"),
                                    ## </FIXME>
                                    f),
                                  stdout = TRUE, stderr = TRUE))
    if(!length(z)) return(NULL)
    ## Strip trailing \r from HTML Tidy output on Windows:
    z <- trimws(z, which = "right")
    ## (Alternatively, replace '$' by '[ \t\r\n]+$' in the regexp below.)
    s <- readLines(f, warn = FALSE)
    m <- regmatches(z,
                    regexec("^line ([0-9]+) column ([0-9]+) - (.+)$",
                            z))
    m <- unique(do.call(rbind, m[lengths(m) == 4L]))
    p <- m[, 2L]
    concordance <- as.Rconcordance(grep("^<!-- concordance:", s, value = TRUE))
    result <- cbind(line = p, col = m[, 3L], msg = m[, 4L], txt = s[as.numeric(p)])

    if (!is.null(concordance))
      result <- cbind(result, matchConcordance(p, concordance = concordance))

    result
  }

# End of R-devel borrowings
# -----------------------------------------------------------
