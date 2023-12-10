# This function works with Pandoc commonmarkx

fix_pandoc_from_options <- function(from, sourcepos) {
  from <- sub("^markdown", "commonmark_x", from)
  from <- sub("[+]tex_math_single_backslash", "", from)
  from <- paste0(from,
                 "+yaml_metadata_block",
                 if (sourcepos) "+sourcepos")
  from
}
