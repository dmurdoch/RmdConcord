
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RmdConcord

<!-- badges: start -->
<!-- badges: end -->

The goal of RmdConcord is to provide support for concordances in R
Markdown files.

## Installation

You can install the development version of RmdConcord from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dmurdoch/RmdConcord")
```

## Example

To embed concordances in an R Markdown HTML document, change the output
YAML to `RmdConcord::html_commonmark_document`.

``` yaml
output: RmdConcord::html_commonmark_document
```
