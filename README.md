
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RmdConcord

<!-- badges: start -->

[![R-CMD-check](https://github.com/dmurdoch/RmdConcord/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dmurdoch/RmdConcord/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of RmdConcord is to provide support for concordances in R
Markdown files.

This is based on a suggestion and initial code from Heather Turner.
Thanks!

The main use for this in HTML output is to help deciphering HTML Tidy
error messages. If you replace the original driver with
`RmdConcord::html_documentC`, `R CMD check` should report locations in
the original `.Rmd` file.

With PDF output using `patchDVI::pdf_documentC` (from `patchDVI` version
1.11.0 or newer), Synctex output will be enabled, and it will be patched
to refer to the `.Rmd` file. This is helpful in previewers like the one
in TeXworks that can link source to a preview. This package contains
`RmdConcord::pdf_documentC0`, which does part of the work (preparing the
concordance records) but doesn’t do the patching to make previewers work
with it.

## Limitations

The Pandoc Commonmark driver is still in development, so some features
supported in the `rmarkdown` drivers will not be fully supported using
the drivers from this package. At present I am using Pandoc 2.19.2 and I
know of the following missing features:

- Citations, e.g. `[@doe99]`

- Raw LaTeX will need to be “fenced”, e.g. entered as

      ```{=latex}
      LaTeX
      ```

  (The `\pagebreak` and `\newpage` macros receive special treatment, so
  they don’t need fencing as long as they are separated by blank lines
  from text above and below.)

If you notice others, please let me know, e.g. by posting an issue to
the Github site.

These will not cause errors (Markdown doesn’t ever give errors!), but
they won’t be handled properly. We suggest using the `RmdConcord` and
`patchDVI` drivers during early development or to track down obscure
bugs, but using the `rmarkdown` drivers for regular production.

## Installation

This version of `RmdConcord` makes use of some functions that will be
released in R 4.3.0. Those functions have been copied into `RmdConcord`,
so the package should be compatible with older versions of R.

You can install the development version of `RmdConcord` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmurdoch/RmdConcord")
```

## Example

To embed concordances in an R Markdown HTML document, change the output
YAML to `patchDVI::html_documentC`. For a PDF document, use
`patchDVI::pdf_documentC`.

``` yaml
output: patchDVI::html_documentC
```

This is used in the `Sample.Rmd` vignette, which contains an error on
line 23.

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
#> prcssC> intermediates <- tempfile()
#> 
#> prcssC> infile <- system.file("sample/Sample.Rmd", package = "RmdConcord")
#> 
#> prcssC> outfile1 <- file.path(dir, "html_vignette.html")
#> 
#> prcssC> rmarkdown::render(infile,
#> prcssC+                   intermediates_dir = intermediates,
#> prcssC+                   output_file = outfile1,
#> prcssC+                   quiet = TRUE)
#> 
#> prcssC> tidy_validate(outfile1)
#>      line  col msg                                       txt              
#> [1,] "359" "4" "Error: <foobar> is not recognized!"      "<p><foobar></p>"
#> [2,] "359" "4" "Warning: discarding unexpected <foobar>" "<p><foobar></p>"
#> 
#> prcssC> # Next, see them with concordances by setting
#> prcssC> # the output format to use RmdConcord::html_documentC
#> prcssC> # which post-processes the document with processConcordance.
#> prcssC> 
#> prcssC> dir <- tempdir()
#> 
#> prcssC> outfile2 <- file.path(dir, "commonmark.html")
#> 
#> prcssC> rmarkdown::render(infile,
#> prcssC+                   intermediates_dir = intermediates,
#> prcssC+                   output_file = outfile2,
#> prcssC+                   output_format = html_documentC(),
#> prcssC+                   quiet = TRUE)
#> 
#> prcssC> tidy_validate(outfile2)
#>      line  col msg                                       txt       
#> [1,] "319" "1" "Error: <foobar> is not recognized!"      "<foobar>"
#> [2,] "319" "1" "Warning: discarding unexpected <foobar>" "<foobar>"
#>      srcFile      srcLine
#> [1,] "Sample.Rmd" "23"   
#> [2,] "Sample.Rmd" "23"   
#> 
#> prcssC> unlink(c(intermediates, outfile1, outfile2), recursive = TRUE)
```
