# -------------------------------------
# These functions are taken from R-devel

# This modifies an existing concordance by following links specified
# in a previous one.

followConcordance <- function(conc, prevConcordance) {
  if (!is.null(prevConcordance)) {
    curLines <- conc$srcLine
    curFile <- rep_len(conc$srcFile, length(curLines))
    curOfs <- conc$offset

    prevLines <- prevConcordance$srcLine
    prevFile <- rep_len(prevConcordance$srcFile, length(prevLines))
    prevOfs <- prevConcordance$offset

    if (prevOfs) {
      prevLines <- c(rep(NA_integer_, prevOfs), prevLines)
      prevFile <- c(rep(NA_character_, prevOfs), prevFile)
      prevOfs <- 0
    }
    n0 <- max(curLines)
    n1 <- length(prevLines)
    if (n1 < n0) {
      prevLines <- c(prevLines, rep(NA_integer_, n0 - n1))
      prevFile <- c(prevFile, rep(NA_character_, n0 - n1))
    }
    new <- is.na(prevLines[curLines])

    conc$srcFile <- ifelse(new, curFile,
                           prevFile[curLines])
    conc$srcLine <- ifelse(new, curLines,
                           prevLines[curLines])
  }
  conc
}

tidy_validate <-
  function(f, tidy = "tidy") {
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
