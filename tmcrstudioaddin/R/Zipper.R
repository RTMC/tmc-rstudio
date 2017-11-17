
.tmc_zip <- function(folder, target) {
  files_to_zip <- dir(folder, full.names = TRUE)
  zip(zipfile = paste(sep = "", target, ".zip"), file = files_to_zip);
}

.tmc_unzip <- function(zipfile_name, target_folder) {
  unzip(zipfile = zipfile_name, exdir = target_folder)
}
