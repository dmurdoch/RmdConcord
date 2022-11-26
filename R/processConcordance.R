
processConcordance <- function(filename, newfilename = filename,
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

processLatexConcordance <- function(filename, newfilename = filename,
                               rename = NULL,
                               followConcordance = NULL,
                               defineSconcordance = TRUE) {
  # read the file
  lines <- readLines(filename)
  prevConcordance <- NULL
  if (!is.null(followConcordance) && file.exists(followConcordance)) {
    # The file may already have a concordance; chain it on
    conc <- readLines(followConcordance)
    conc <- sub("%$", "", conc)
    conc <- paste(conc, collapse = "")
    conc <- unlist(strsplit(conc, "\\Sconcordance", fixed = TRUE))
    if (length(conc))
      prevConcordance <- as.Rconcordance(conc)
  }
  if (defineSconcordance) {
    # Insert \Sconcordance definition
    beginDoc <- match(TRUE, lines == "\\begin{document}")
    lines <- append(lines, r"(\newcommand{\Sconcordance}[1]{%
\ifx\pdfoutput\undefined%
\csname newcount\endcsname\pdfoutput\fi%
\ifcase\pdfoutput\special{#1}%
\else%
\begingroup%
\pdfcompresslevel=0%
\immediate\pdfobj stream{#1}%
\pdfcatalog{/SweaveConcordance \the\pdflastobj\space 0 R}%
\endgroup%
\fi}

)", beginDoc - 1)
  }
  # insert line breaks
  lines <- gsub("\\datapos{", "%\n\\datapos{", lines, fixed = TRUE)
  # don't lose blank lines; they separate paragraphs.
  lines[lines == ""] <- "\n"
  lines <- unlist(strsplit(lines, "\n", fixed = TRUE))
  srcline <- rep(NA_integer_, length(lines))
  srcfile <- rep(NA_character_, length(lines))
  regexp <- "^\\\\datapos\\{([^}@]*)@?([[:digit:]]*):?[^}]*\\}(.*)"
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
  lines[datapos] <- gsub(regexp, "\\3", lines[datapos])
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

    endDoc <- match(TRUE, lines == "\\end{document}")
    lines <- append(lines, paste0("\\Sconcordance{", as.character(concordance, targetfile = filename), "}"), after = endDoc - 1)
    if (len == length(srcline))
      break
    offset <- offset + len
    srcline <- srcline[-keep]
    srcfile <- srcfile[-keep]
  }
  writeLines(lines, newfilename)
  invisible(newfilename)
}
