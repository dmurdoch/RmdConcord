
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RmdConcord

<!-- badges: start -->
<!-- badges: end -->

The goal of RmdConcord is to provide support for concordances in R
Markdown files.

This is based on a suggestion and initial code from Heather Turner.
Thanks!

## Installation

This version of `RmdConcord` makes use of some functions that will be
released in R 4.3.0. They are available in a development version of the
`backports` package.

You can install the development version of RmdConcord from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmurdoch/backports)
devtools::install_github("dmurdoch/RmdConcord")
```

## Example

To embed concordances in an R Markdown HTML document, change the output
YAML to `RmdConcord::html_commonmark_document`.

``` yaml
output: RmdConcord::html_commonmark_document
```

This is used in the `Sample.Rmd` vignette.

``` r
library(RmdConcord)
example(getDataposConcordance)
#> 
#> gtDtpC> # This example works on the file inst/sample/Sample.Rmd,
#> gtDtpC> # which should be a copy of the vignette Sample.Rmd.  This
#> gtDtpC> # is convenient because RStudio doesn't install vignettes by default.
#> gtDtpC> 
#> gtDtpC> # First, see the results without concordances:
#> gtDtpC> 
#> gtDtpC> library(RmdConcord)
#> 
#> gtDtpC> dir <- tempdir()
#> 
#> gtDtpC> infile <- system.file("sample/Sample.Rmd", package = "RmdConcord")
#> 
#> gtDtpC> outfile1 <- file.path(dir, "html_vignette.html")
#> 
#> gtDtpC> rmarkdown::render(infile,
#> gtDtpC+                   output_file = outfile1,
#> gtDtpC+                   quiet = TRUE)
#> 
#> gtDtpC> tools:::tidy_validate(outfile1)
#>      line  col msg                                       txt              
#> [1,] "245" "4" "Error: <foobar> is not recognized!"      "<p><foobar></p>"
#> [2,] "245" "4" "Warning: discarding unexpected <foobar>" "<p><foobar></p>"
#> [3,] "245" "1" "Warning: trimming empty <p>"             "<p><foobar></p>"
#> 
#> gtDtpC> # Next, see them with concordances:
#> gtDtpC> 
#> gtDtpC> dir <- tempdir()
#> 
#> gtDtpC> outfile2 <- file.path(dir, "commonmark.html")
#> 
#> gtDtpC> outfile3 <- file.path(dir, "patched.html")
#> 
#> gtDtpC> rmarkdown::render(infile,
#> gtDtpC+                   output_file = outfile2,
#> gtDtpC+                   output_format = html_commonmark_document(keep_md = TRUE),
#> gtDtpC+                   quiet = TRUE)
#> 
#> gtDtpC> getDataposConcordance(outfile2, outfile3)
#> 
#> gtDtpC> RmdConcord:::tidy_validate(outfile3)
#>      line  col msg                                       txt       
#> [1,] "319" "1" "Error: <foobar> is not recognized!"      "<foobar>"
#> [2,] "319" "1" "Warning: discarding unexpected <foobar>" "<foobar>"
#>      srcFile      srcLine
#> [1,] "Sample.Rmd" "23"   
#> [2,] "Sample.Rmd" "23"
```
