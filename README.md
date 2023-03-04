
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RmdConcord

<!-- badges: start -->
<!-- badges: end -->

The goal of RmdConcord is to provide support for concordances in R
Markdown files.

This is based on a suggestion and initial code from Heather Turner.
Thanks!

The main use for this in HTML output is to help deciphering HTML Tidy
error messages. If you replace the original driver with
`patchDVI::html_documentC`, `R CMD check` should report locations in the
original `.Rmd` file.

With PDF output using `patchDVI::pdf_documentC`, Synctex output will be
enabled, and it will be patched to refer to the `.Rmd` file. This is
helpful in previewers like the one in TeXworks that can link source to a
preview.

The `RmdConcord` package also has drivers with the same names as the
ones described above. These are intended to be used by other packages
rather than directly by users: they will leave concordance records in
the file for later handling.

## Installation

This version of `RmdConcord` makes use of some functions that will be
released in R 4.3.0. They are available in a development version of the
`backports` package.

You can install the development version of RmdConcord from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmurdoch/backports")
devtools::install_github("dmurdoch/RmdConcord")
```

## Example

To embed concordances in an R Markdown HTML document, change the output
YAML to `patchDVI::html_documentC`. For a PDF document, use
`patchDVI::pdf_documentC`.

``` yaml
output: patchDVI::html_documentC
```

This is used in the `Sample.Rmd` vignette.

``` r
library(RmdConcord)
example(processConcordance)
#> 
#> prcssC> # This example works on the file inst/sample/Sample.Rmd,
#> prcssC> # which should be a copy of the vignette Sample.Rmd.  This
#> prcssC> # is convenient because RStudio doesn't install vignettes by default.
#> prcssC> 
#> prcssC> # First, see the results without concordances:
#> prcssC> 
#> prcssC> library(RmdConcord)
#> 
#> prcssC> dir <- tempdir()
#> 
#> prcssC> infile <- system.file("sample/Sample.Rmd", package = "RmdConcord")
#> 
#> prcssC> outfile1 <- file.path(dir, "html_vignette.html")
#> 
#> prcssC> rmarkdown::render(infile,
#> prcssC+                   output_file = outfile1,
#> prcssC+                   quiet = TRUE)
#> 
#> prcssC> tools:::tidy_validate(outfile1)
#>      line  col msg                                       txt              
#> [1,] "359" "4" "Error: <foobar> is not recognized!"      "<p><foobar></p>"
#> [2,] "359" "4" "Warning: discarding unexpected <foobar>" "<p><foobar></p>"
#> [3,] "359" "1" "Warning: trimming empty <p>"             "<p><foobar></p>"
#> 
#> prcssC> # Next, see them with concordances by setting
#> prcssC> # the output format to use RmdConcord::html_documentC
#> prcssC> # which post-processes the document with processConcordance.
#> prcssC> # Note that this requires patches to `knitr`, which can be
#> prcssC> # obtained using
#> prcssC> #   install_github("dmurdoch/knitr")
#> prcssC> 
#> prcssC> dir <- tempdir()
#> 
#> prcssC> outfile2 <- file.path(dir, "commonmark.html")
#> 
#> prcssC> rmarkdown::render(infile,
#> prcssC+                   output_file = outfile2,
#> prcssC+                   output_format = RmdConcord::html_documentC(),
#> prcssC+                   quiet = TRUE)
#> 
#> prcssC> RmdConcord:::tidy_validate(outfile2)
#>      line  col msg                                       txt       
#> [1,] "319" "1" "Error: <foobar> is not recognized!"      "<foobar>"
#> [2,] "319" "1" "Warning: discarding unexpected <foobar>" "<foobar>"
#>      srcFile      srcLine
#> [1,] "Sample.Rmd" "23"   
#> [2,] "Sample.Rmd" "23"
```
