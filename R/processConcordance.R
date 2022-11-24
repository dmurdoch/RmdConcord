
processConcordance <- function(filename, newfilename,
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
