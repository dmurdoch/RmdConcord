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

getDataposConcordance <- function(filename, newfilename,
                                  rename = NULL,
                                  followConcordance = TRUE) {
  # read the file
  lines <- readLines(filename)
  prevConcordance <- NULL
  if (followConcordance) {
    # The file may already have a concordance comment if the
    # HTML was produced by R Markdown; chain it onto the one
    # indicated by the data-pos attributes
    conc <- grep("^<!-- concordance:", lines)
    if (length(conc)) {
       prevConcordance <- as.Rconcordance(lines[conc])
       lines <- lines[-conc]
    }
  }
  # insert line breaks
  lines <- gsub(" </span><span ", "</span>\n<span ", lines, fixed = TRUE)
  lines <- unlist(strsplit(lines, "\n", fixed = TRUE))
  srcline <- rep(NA_integer_, length(lines))
  srcfile <- rep(NA_character_, length(lines))
  regexp <- ".*<[^>]+ data-pos=\"([^\"]*)@([[:digit:]]+):.*"
  datapos <- grep(regexp, lines)
  if (length(datapos) == 0)
    stop("No data-pos attributes found.")
  srcline[datapos] <- as.integer(sub(regexp, "\\2", lines[datapos]))
  srcfile[datapos] <- sub(regexp, "\\1", lines[datapos])
  oldname <- names(rename)
  for (i in seq_along(rename))
    srcfile[datapos] <- sub(oldname[i], rename[i], srcfile[datapos], fixed = TRUE)
  # Remove the data-pos records now.  There might be several on a line
  # but we want to ignore them all
  lines[datapos] <- gsub("(<[^>]+) data-pos=\"[^\"]+\"", "\\1", lines[datapos])
  offset <- 0
  repeat {
    if (all(is.na(srcline)))
      break
    nextoffset <- min(which(!is.na(srcline))) - 1
    if (nextoffset > 0) {
      srcline <- srcline[-seq_len(nextoffset)]
      srcfile <- srcfile[-seq_len(nextoffset)]
      offset <- offset + nextoffset
    }
    repeat {
      len <- min(which(is.na(srcline)) - 1, length(srcline))
      keep <- seq_len(len)
      if (all(is.na(srcline[-keep])))
        break
      nextsection <- len + min(which(!is.na(srcline[-keep])))
      if (srcfile[nextsection] == srcfile[len]) {
        srcline[(len+1):(nextsection-1)] <- srcline[len]
        srcfile[(len+1):(nextsection-1)] <- srcfile[len]
      } else
        break
    }

    concordance <- structure(list(offset = offset,
                                  srcLine = srcline[keep],
                                  srcFile = srcfile[keep]),
                             class = "Rconcordance")
    if (!is.null(prevConcordance))
      concordance <- followConcordance(concordance, prevConcordance)
    lines <- c(lines, paste0("<!-- ", as.character(concordance), " -->"))
    if (len == length(srcline))
      break
    offset <- offset + len
    srcline <- srcline[-keep]
    srcfile <- srcfile[-keep]
  }
  writeLines(lines, newfilename)
  invisible(newfilename)
}

setwd("~/temp")
getDataposConcordance("Untitled.html", "Untitled2.html")
