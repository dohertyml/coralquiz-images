# build_index.R
# Run from the root of coralquiz-images to create/update index.csv
# Expected structure:
#   root/
#     caribbean_benthos/
#       AAGA/
#         someimage.jpg
#       AAGA_BL/
#         anotherimage.png
#     caribbean_corals/
#       ...

build_index <- function(root = ".") {
  # valid image extensions
  exts <- c("jpg", "jpeg", "png", "webp")

  root <- normalizePath(root)

  # list top-level directories (these are the "sources")
  source_dirs <- list.dirs(root, recursive = FALSE, full.names = TRUE)

  # drop hidden dirs (.git etc.) and non-dirs just in case
  source_dirs <- source_dirs[basename(source_dirs) != ".git"]
  source_dirs <- source_dirs[file.info(source_dirs)$isdir %in% TRUE]

  if (!length(source_dirs)) {
    warning("No source directories found under: ", root)
    return(invisible(NULL))
  }

  all_rows <- list()

  for (src_dir in source_dirs) {
    source_name <- basename(src_dir)

    # species folders inside each source
    species_dirs <- list.dirs(src_dir, recursive = FALSE, full.names = TRUE)
    species_dirs <- species_dirs[file.info(species_dirs)$isdir %in% TRUE]

    if (!length(species_dirs)) next

    for (sp_dir in species_dirs) {
      species_key <- basename(sp_dir)

      # list files directly inside the species folder
      files <- list.files(sp_dir, full.names = FALSE)
      if (!length(files)) next

      # keep only image files (case-insensitive)
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

  # write index.csv in the root of coralquiz-images
  outfile <- file.path(root, "index.csv")
  utils::write.csv(idx, file = outfile, row.names = FALSE)
  message("Wrote ", nrow(idx), " rows to ", outfile)

  invisible(idx)
}

# If run via `Rscript build_index.R`, build immediately
if (sys.nframe() == 0L) {
  build_index(".")
}
