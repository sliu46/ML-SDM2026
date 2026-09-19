# ============================================================
# Ecological Informatics / Elsevier figure style
# Full-width artwork: 190 mm x 100 mm; Arial; 600 dpi
# ============================================================

journal_output_dir <- "F:/PythonItem/bib/Second8.30/image/journal_figures"
journal_width_mm <- 190
journal_height_mm <- 100
journal_dpi <- 600
journal_font_family <- "Arial"
journal_base_size <- 9

# Uniform typography at the final printed size. Elsevier's general
# recommendation is approximately 7 pt; 9 pt is used here to address
# the reviewer's concern that lettering in several figures was too small.
journal_theme <- function(base_theme = ggplot2::theme_bw(
  base_size = journal_base_size,
  base_family = journal_font_family
)) {
  base_theme +
    ggplot2::theme(
      text = ggplot2::element_text(
        family = journal_font_family,
        colour = "black"
      ),
      axis.title = ggplot2::element_text(size = 10, face = "plain"),
      axis.text = ggplot2::element_text(size = 9, colour = "black"),
      legend.title = ggplot2::element_text(size = 9, face = "plain"),
      legend.text = ggplot2::element_text(size = 8),
      plot.title = ggplot2::element_text(size = 11, face = "bold"),
      plot.subtitle = ggplot2::element_text(size = 9),
      plot.caption = ggplot2::element_text(size = 8),
      plot.margin = ggplot2::margin(4, 4, 4, 4, unit = "mm")
    )
}

save_journal_figure <- function(
  plot,
  filename_stem,
  output_dir = journal_output_dir,
  width_mm = journal_width_mm,
  height_mm = journal_height_mm,
  dpi = journal_dpi
) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_stem <- file.path(output_dir, filename_stem)

  # Vector version preferred for plots, with fonts retained by Cairo PDF.
  ggplot2::ggsave(
    filename = paste0(output_stem, ".pdf"),
    plot = plot,
    device = grDevices::cairo_pdf,
    width = width_mm,
    height = height_mm,
    units = "mm",
    bg = "white",
    limitsize = FALSE
  )

  # High-resolution raster version accepted by Elsevier for combination art.
  ggplot2::ggsave(
    filename = paste0(output_stem, ".tiff"),
    plot = plot,
    device = "tiff",
    width = width_mm,
    height = height_mm,
    units = "mm",
    dpi = dpi,
    compression = "lzw",
    bg = "white",
    limitsize = FALSE
  )

  # PNG preview at exactly the same physical size and resolution.
  ggplot2::ggsave(
    filename = paste0(output_stem, ".png"),
    plot = plot,
    device = "png",
    width = width_mm,
    height = height_mm,
    units = "mm",
    dpi = dpi,
    bg = "white",
    limitsize = FALSE
  )

  invisible(output_stem)
}
