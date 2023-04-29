# -------------------------------------
# These functions were taken from R-devel before R 4.3.0 was released.
# At some point they should be put in backports, but it hasn't been
# updated in a long time...

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

# These functions should be imported from
# backports, but it hasn't been updated yet


# if (getRversion() < "4.3.0") {
  fixWindowsConcordancePaths <- function(split) {
    if (length(split) <= 4)
      return(split)
    # We are looking for a drive letter which should have been at the start
    # of the 2nd or 3rd entry, but will be in an entry by itself

    driveletter <- grep("^[a-zA-Z]$", split[2:4]) + 1
    ofs <- grep("^ofs [[:digit:]]+$", split[4:length(split)]) + 3
    driveletter <- setdiff(driveletter, ofs - 1)

    if (!length(driveletter))
      return(split)

    if (!length(ofs) # no ofs record but length is 5 or more
        || length(split) >= 6) {
      if (2 %in% driveletter) {
        split <- c(split[1],
                   paste(split[2], split[3], sep=":"),
                   split[4:length(split)])
        driveletter <- driveletter - 1
      }
      if (3 %in% driveletter) {
        split <- c(split[1:2],
                   paste(split[3], split[4], sep=":"),
                   split[5:length(split)])
      }
    }
    split
  }

  stringToConcordance <- function(s) {
    split <- strsplit(s, ":")[[1]]
    if (.Platform$OS.type == "windows")
      split <- fixWindowsConcordancePaths(split)
    targetfile <- split[2]
    srcFile <- split[3]
    if (length(split) == 4) {
      ofs <- 0
      vi <- 4
    } else {
      ofs <- as.integer(sub("^ofs ([0-9]+)", "\\1", split[4]))
      vi <- 5
    }
    values <- as.integer(strsplit(split[vi], " ")[[1]])
    firstline <- values[1]
    rledata <- matrix(values[-1], nrow = 2)
    rle <- structure(list(lengths=rledata[1,], values=rledata[2,]), class="rle")
    diffs <- inverse.rle(rle)
    srcLines <- c(firstline, firstline + cumsum(diffs))
    structure(list(offset = ofs, srcFile = srcFile, srcLine = srcLines),
              class = "Rconcordance")
  }

  addConcordance <- function(conc, s) {
    prev <- stringToConcordance(s)
    if (!is.null(prev)) {
      conc$srcFile <- rep_len(conc$srcFile, length(conc$srcLine))
      i <- seq_along(prev$srcLine)
      conc$srcFile[prev$offset + i] <- prev$srcFile
      conc$srcLine[prev$offset + i] <- prev$srcLine
    }
    conc
  }

  print.Rconcordance <- function(x, ...) {
    df <- data.frame(srcFile = x$srcFile, srcLine = x$srcLine)
    rownames(df) <- seq_len(nrow(df)) + x$offset
    print(df)
    invisible(x)
  }

  as.character.Rconcordance <- function(x,
                                        targetfile = "",
                                        ...) {
    concordance <- x
    offset <- concordance$offset
    src <- concordance$srcLine

    result <- character()

    srcfile <- rep_len(concordance$srcFile, length(src))

    while (length(src)) {
      first <- src[1]
      if (length(unique(srcfile)) > 1)
        n <- which(srcfile != srcfile[1])[1] - 1
      else
        n <- length(srcfile)

      vals <- with(rle(diff(src[seq_len(n)])), as.numeric(rbind(lengths, values)))
      result <- c(result, paste0("concordance:",
                                 targetfile, ":",
                                 srcfile[1], ":",
                                 if (offset) paste0("ofs ", offset, ":"),
                                 concordance$srcLine[1], " ",
                                 paste(vals, collapse = " ")
      ))
      offset <- offset + n
      drop <- seq_len(n)
      src <- src[-drop]
      srcfile <- srcfile[-drop]
    }
    result
  }

  as.Rconcordance <- function(x, ...) {
    UseMethod("as.Rconcordance")
  }

  as.Rconcordance.default <- function(x, ...) {
    # clean comments etc.
    s <- sub("^.*(concordance){1}?", "concordance", sub("[^[:digit:]]*$", "", x))
    s <- grep("^concordance:", s, value = TRUE)
    if (!length(s))
      return(NULL)
    result <- stringToConcordance(s[1])
    for (line in s[-1])
      result <- addConcordance(result, line)
    result
  }

  matchConcordance <- function(linenum, concordance) {
    if (!all(c("offset", "srcLine", "srcFile") %in% names(concordance)))
      stop("concordance is not valid")
    linenum <- as.numeric(linenum)
    srcLines <- concordance$srcLine
    srcFile <- rep_len(concordance$srcFile, length(srcLines))
    offset <- concordance$offset

    result <- matrix(character(), length(linenum), 2,
                     dimnames = list(NULL,
                                     c("srcFile", "srcLine")))
    for (i in seq_along(linenum)) {
      if (linenum[i] <= concordance$offset)
        result[i,] <- c("", "")
      else
        result[i,] <- c(srcFile[linenum[i] - offset],
                        with(concordance, srcLine[linenum[i] - offset]))
    }
    result
  }

# }

# End of R-devel borrowings
# -----------------------------------------------------------
