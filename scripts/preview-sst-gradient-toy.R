#!/usr/bin/env Rscript
# Preview before publishing ai-tutorials/sst-gradient-magnitude/index.qmd
pacman::p_load(terra)

sst_grad_magnitude_layer <- function(sst) {
  res <- terra::res(sst)
  clat <- mean(terra::yFromCell(sst, seq_len(min(5000L, terra::ncell(sst)))), na.rm = TRUE)
  dx_km <- as.numeric(res[1]) * 111.32 * cos(clat * pi / 180)
  dy_km <- as.numeric(res[2]) * 111.32
  w_x <- matrix(c(0, 0, 0, -0.5, 0, 0.5, 0, 0, 0), 3, 3)
  w_y <- matrix(c(0, -0.5, 0, 0, 0, 0, 0, 0.5, 0), 3, 3)
  gx <- terra::focal(sst, w = w_x, fun = sum, na.rm = TRUE, pad = TRUE) / dx_km
  gy <- terra::focal(sst, w = w_y, fun = sum, na.rm = TRUE, pad = TRUE) / dy_km
  sqrt(gx^2 + gy^2)
}

build_toy_sst <- function(n = 80L) {
  sst <- terra::rast(
    ncols = n, nrows = n,
    xmin = 170, xmax = 170.5,
    ymin = -45, ymax = -44.5,
    crs = "EPSG:4326"
  )
  ex <- ext(sst)
  xy <- terra::xyFromCell(sst, 1:ncell(sst))
  lon <- xy[, 1]
  lat <- xy[, 2]
  lon_n <- (lon - ex[1]) / (ex[2] - ex[1])
  lat_n <- (lat - ex[3]) / (ex[4] - ex[3])

  edge_taper <- pmin(
    pmin(lon_n / 0.15, (1 - lon_n) / 0.15),
    pmin(lat_n / 0.15, (1 - lat_n) / 0.15),
    1
  )
  front_lon <- 170.25 + 0.012 * sin((lat_n - 0.5) * 2 * pi * 3)
  v <- 19 + 0.35 * tanh(-(lon - front_lon) / 0.008) * edge_taper
  terra::values(sst) <- v
  list(sst = sst, lon_n = lon_n, lat_n = lat_n)
}

mask_grad_edges <- function(grad, lon_n, lat_n, pad = 0.08) {
  g <- grad
  edge <- lon_n < pad | lon_n > 1 - pad | lat_n < pad | lat_n > 1 - pad
  vals <- terra::values(g)
  vals[edge] <- NA
  terra::values(g) <- vals
  g
}

built <- build_toy_sst(80L)
sst <- built$sst
grad <- sst_grad_magnitude_layer(sst)
grad_show <- mask_grad_edges(grad, built$lon_n, built$lat_n)

out <- "/tmp/sst-gradient-preview-v3.png"
png(out, width = 1000, height = 480, res = 120)
par(mfrow = c(1, 2), mar = c(4, 4, 3, 5))
plot(sst, main = "SST (°C) — 19 °C margins, front through centre")
plot(grad_show, main = expression("|"*nabla*SST|" (°C km"^-1*")"))
par(mfrow = c(1, 1))
dev.off()

interior <- !(built$lon_n < 0.08 | built$lon_n > 0.92 | built$lat_n < 0.08 | built$lat_n > 0.92)
max_in <- max(terra::values(grad)[interior], na.rm = TRUE)
cat("Wrote", out, "\n")
cat("SST range:", range(terra::values(sst), na.rm = TRUE), "\n")
cat("max |grad| interior:", max_in, "\n")
stopifnot(max_in > 0.05, max_in < 3)
