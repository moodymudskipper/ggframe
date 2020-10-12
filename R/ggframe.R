as_ggframe <- function(x) {
  class(x) <- union("ggframe", class(x))
  x
}

#' Map aesthetics
#'
#' @param data data
#' @param x x
#' @param y y
#' @param ... ...
#'
#' @return
#' @export
#'
#' @examples
map_aes <- function(data, x, y, ...) {
  attr(data, "aes") <- eval(substitute(alist(x = x, y = y, ...)))
  as_ggframe(data)
}

#' print a ggframe
#'
#' @param x x
#' @param plot whether to plot or print data.frame and attributes
#'
#' @return
#' @export
#'
#' @examples
print.ggframe <- function(x, plot = TRUE) {
  if(!plot) {
    writeLines("# A ggframe")
    aes <- attr(x, "aes")
    aes <- paste0(names(aes), "=", aes, collapse = ", ")
    writeLines(paste0("# aes: ", aes))
    layers <- sapply(attr(x, "layers"), deparse1)

    if(length(layers)) {
      writeLines(paste0("# layers:\n", paste("#", layers, collapse = "\n")))
    }
    print(tibble::as_tibble(x))
    return(invisible(x))
  }
  aes_call <- as.call(c(quote(ggplot2::aes), attr(x, "aes")))
  ggplot_call <- as.call(c(quote(ggplot2::ggplot), quote(x), aes_call))
  plt <- eval(ggplot_call) + lapply(attr(x, "layers"), eval)
  print(plt)
  invisible(x)
}

#' Add a geom
#'
#' @param data data.frame or ggframe
#' @param geom a string so that `geom_<geom>` will be called
#' @param ... passed to `geom_<geom>()`
#'
#' @export
geom <- function(data, geom, ...) {
  geom <- as.symbol(paste0("geom_", geom))
  if(is.null(attr(data, "layers"))) attr(data, "layers") <- list()
  attr(data, "layers") <- append(attr(data, "layers"), substitute(geom(...)))
  as_ggframe(data)
}


#' set theme
#'
#' @param data data.frame or ggframe
#' @param geom a string so that `geom_<geom>` will be called
#' @param ... passed to `geom_<geom>()`
#'
#' @export
set_theme <- function(data, theme, ...) {
  if(is.null(attr(data, "layers"))) attr(data, "layers") <- list()
  if(!missing(theme)) {
    theme <- as.symbol(paste0("theme_", theme))
    attr(data, "layers") <- append(attr(data, "layers"), substitute(theme(...)))
  } else {
    attr(data, "layers") <-
      append(attr(data, "layers"), as.call(
        c(quote(ggplot2::theme), eval(substitute(alist(...))))))
  }
  as_ggframe(data)
}



#' set coord
#'
#' @param data data.frame or ggframe
#' @param geom a string so that `geom_<geom>` will be called
#' @param ... passed to `geom_<geom>()`
#'
#' @export
set_coord <- function(data, coord, ...) {
  coord <- as.symbol(paste0("coord_", coord))
  if(is.null(attr(data, "layers"))) attr(data, "layers") <- list()
  attr(data, "layers") <- append(attr(data, "layers"), substitute(coord(...)))
  as_ggframe(data)
}

#' set scale
#'
#' @param data data.frame or ggframe
#' @param geom a string so that `geom_<geom>` will be called
#' @param ... passed to `geom_<geom>()`
#'
#' @export
set_scale <- function(data, scale, ...) {
  scale <- as.symbol(paste0("scale_", scale))
  if(is.null(attr(data, "layers"))) attr(data, "layers") <- list()
  attr(data, "layers") <- append(attr(data, "layers"), substitute(scale(...)))
  as_ggframe(data)
}


# sort(getNamespaceExports("ggplot2"))

