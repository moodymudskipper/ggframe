.onAttach <- function(libname, pkgname) {
  if("package:ggplot2" %in% search())
    .S3method("ggplot_build", class = "ggframe", method = ggplot_build.ggframe)
  else
  setHook(packageEvent("ggplot2", "attach"), function(...)
    .S3method("ggplot_build", class = "ggframe", method = ggplot_build.ggframe))
}

