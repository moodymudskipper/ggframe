as_ggframe <- function(x) {
  class(x) <- union("ggframe", class(x))
  x
}

#' Map aesthetics
#'
#' @param .data data
#' @param x x
#' @param y y
#' @param ... ...
#' @export
map_aes <- function(.data, x, y, ...) {
  attr(.data, "aes") <- eval(substitute(alist(x = x, y = y, ...)))
  as_ggframe(.data)
}

#' print a ggframe
#'
#' @param x x
#' @param plot whether to plot or print data.frame and attributes
#' @param ... for compatibility with other methods
#'
#' @export
print.ggframe <- function(x, plot = TRUE, ...) {
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
  plt <- as_ggplot(x)
  print(plt)
  invisible(x)
}


#' Convert ggframe to ggplot
#'
#' @param x ggframe object
#'
#' @export
as_ggplot <- function(x) {
  aes_call <- as.call(c(quote(ggplot2::aes), attr(x, "aes")))
  ggplot_call <- as.call(c(quote(ggplot2::ggplot), quote(x), aes_call))
  plt <- eval(ggplot_call) + lapply(attr(x, "layers"), eval)
  plt
}

#' Add a geom
#'
#' @param .data data.frame or ggframe
#' @param geom a string so that `geom_<geom>` will be called
#' @param ... passed to `geom_<geom>()`
#'
#' @export
geom <- function(.data, geom, ...) {
  geom <- as.symbol(paste0("geom_", geom))
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  attr(.data, "layers") <- append(attr(.data, "layers"), substitute(geom(...)))
  as_ggframe(.data)
}


#' facet
#'
#' @param .data data.frame or ggframe
#' @param facet a string so that `facet_<facet>` will be called
#' @param ... passed to `facet_<facet>()`
#'
#' @export
facet <- function(.data, facet, ...) {
  facet <- as.symbol(paste0("facet_", facet))
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  attr(.data, "layers") <- append(attr(.data, "layers"), substitute(facet(...)))
  as_ggframe(.data)
}


#' set theme
#'
#' @param .data data.frame or ggframe
#' @param theme a string so that `theme_<theme>` will be called
#' @param ... passed to `theme_<theme>()`
#'
#' @export
set_theme <- function(.data, theme, ...) {
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  if(!missing(theme)) {
    theme <- as.symbol(paste0("theme_", theme))
    attr(.data, "layers") <- append(attr(.data, "layers"), substitute(theme(...)))
  } else {
    attr(.data, "layers") <-
      append(attr(.data, "layers"), as.call(
        c(quote(ggplot2::theme), eval(substitute(alist(...))))))
  }
  as_ggframe(.data)
}



#' set coord
#'
#' @param .data data.frame or ggframe
#' @param coord a string so that `coord_<coord>` will be called
#' @param ... passed to `coord_<coord>()`
#'
#' @export
set_coord <- function(.data, coord, ...) {
  coord <- as.symbol(paste0("coord_", coord))
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  attr(.data, "layers") <- append(attr(.data, "layers"), substitute(coord(...)))
  as_ggframe(.data)
}

#' set scale
#'
#' @param .data data.frame or ggframe
#' @param scale a string so that `scale_<scale>` will be called
#' @param ... passed to `scale_<scale>()`
#'
#' @export
set_scale <- function(.data, scale, ...) {
  scale <- as.symbol(paste0("scale_", scale))
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  attr(.data, "layers") <- append(attr(.data, "layers"), substitute(scale(...)))
  as_ggframe(.data)
}

#' set guide
#'
#' @param .data data.frame or ggframe
#' @param guide a string so that `guide_<guide>` will be called
#' @param ... passed to `guide_<guide>()`
#'
#' @export
set_guide <- function(.data, guide, ...) {
  guide <- as.symbol(paste0("guide_", guide))
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  attr(.data, "layers") <- append(attr(.data, "layers"), substitute(guide(...)))
  as_ggframe(.data)
}

#' set labs
#'
#' @param .data data.frame or ggframe
#' @inheritParams ggplot2::labs
#'
#' @export
set_labs <- function(.data, ... , title = ggplot2::waiver(), subtitle = ggplot2::waiver(), caption = ggplot2::waiver(),
                     tag = ggplot2::waiver()) {
  if(is.null(attr(.data, "layers"))) attr(.data, "layers") <- list()
  sc <- sys.call()
  sc[[1]] <- quote(labs)
  sc[[2]] <- NULL
  attr(.data, "layers") <- append(attr(.data, "layers"), sc)
  as_ggframe(.data)
}

ggplot_build.ggframe <- function(plot) {
  ggplot2::ggplot_build(as_ggplot(plot))
}
