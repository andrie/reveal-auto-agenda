
quarto_render <- function(filename) {
  system2("quarto", glue::glue("render {filename} --quiet"))
  invisible(TRUE)
}


quarto_html_read <- function(filename) {
  readr::read_lines(filename) |>  paste(collapse = "\n")
}
  
quarto_expect_text <- function(filename, text) {
  html <- quarto_html_read(filename)
  grepl(text, html)
}
