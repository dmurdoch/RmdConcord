test_packages <- function(error = TRUE) {
  if (!error)
    stop <- function(...) {
      result <<- FALSE
      warning(...)
    }

  result <- TRUE

  dummy <- knitr::knit  # To suppress check note

  if (!exists("matchConcordance", where = parent.env(environment())))
    stop("RmdConcord requires the backports package containing matchConcordance()")

  result
}
