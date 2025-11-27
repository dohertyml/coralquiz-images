# build_index.R
# Run from the root of coralquiz-images to create/update index.csv

build_index <- function(root = ".") {
  # valid image extensions
  exts <- c("jpg", "jpeg", "png", "webp")

  # list top-level directories (sources)
  source_dirs <- list.dirs(root, recursive = FALSE, full.names = TRUE)

  # drop things like .git if present
  source_dirs <- source_dirs[basename(source_dirs) != ".git"]

  all_rows <- list()

  for (src_dir in source_dirs) {
    source_name <- basename(src_dir)

    # species folders inside each source
    species_dirs <- list.dirs(src_dir, recursive = FALSE, full.names = TRUE)
    if (!length(species_dirs)) next

    for (sp_dir in species_dirs) {
      species_key <- basename(sp_dir)

      files <- list.files(sp_dir, full.names = FALSE)
      if (!length(files)) next

      # keep only image files
      keep <- tolower(tools::file_ext(files)) %in% exts
      files <- files[keep]
      if (!length(files)) next

      all_rows[[length(all_rows) + 1L]] <- data.frame(
        source      = source_name,
        species_key = species_key,
        filename    = files,
        stringsAsFactors = FALSE
      )
    }
  }

  if (!length(all_rows)) {
    warning("No image files found; index.csv not written.")
    return(invisible(NULL))
  }

  idx <- do.call(rbind, all_rows)

  # sort for neatness
  idx <- idx[order(idx$source, idx$species_key, idx$filename), ]

  utils::write.csv(idx, file = "index.csv", row.names = FALSE)
  message("Wrote index.csv with ", nrow(idx), " rows.")
  invisible(idx)
}

# If run as a script via Rscript, build immediately
if (sys.nframe() == 0L) {
  build_index()
}
