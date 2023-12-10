test_packages <- function(error = TRUE, pandoc = TRUE) {

  dummy <- knitr::knit  # To suppress check note
  message <- NULL

  if (pandoc && !pandoc_available("2.11.3"))
    message <- "Pandoc 2.11.3 or higher is needed. "

  if (!pandoc && (!requireNamespace("markdown") ||
                  packageVersion("markdown") < "1.12.1"))
    message <- c(message, "markdown v 1.12.1 or higher is needed.")
  if (!length(message))
    TRUE
  else if (error)
    stop(message)
  else {
    warning(message, call. = FALSE)
    FALSE
  }
}
