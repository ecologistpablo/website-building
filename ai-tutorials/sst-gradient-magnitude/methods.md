# SST gradient magnitude — methods notes (local reference)

Plain-language reference for the public tutorial [`index.qmd`](index.qmd). No private project paths or telemetry workflows.

## Definition

For **one calendar day**, take a single SST field on a regular lat–lon grid (values in **degrees Celsius**). The **horizontal gradient magnitude** is

\[
|\nabla \mathrm{SST}| = \sqrt{\left(\frac{\partial \mathrm{SST}}{\partial x}\right)^2 + \left(\frac{\partial \mathrm{SST}}{\partial y}\right)^2},
\]

with \(\partial/\partial x\) and \(\partial/\partial y\) estimated by **centred finite differences** on the raster cells, and distances expressed in **kilometres**. Output units: **°C km⁻¹**.

This is a **spatial** measure on one daily layer. It is **not**:

- SST change over **time** at a fixed location;
- a domain-wide “front probability” or distance-to-front product;
- a regional average SST before differencing.

## Grid spacing in km

From cell size in degrees (`res` from the raster):

- \(\Delta y_{\mathrm{km}} \approx \Delta\phi \times 111.32\) (one degree of latitude ≈ 111.32 km).
- \(\Delta x_{\mathrm{km}} \approx \Delta\lambda \times 111.32 \times \cos(\phi)\) at the latitude of the grid (use mean lat of the layer or cell centre).

Typical reanalysis grids (e.g. ~0.083° at mid-latitudes) give cell widths of roughly **7–9 km**.

## Centred differences (`terra::focal`)

Use 3×3 weight matrices (sum of weights = 0 for the derivative stencil):

- **∂/∂x:** centre row `[-0.5, 0, 0.5]`, divide by \(\Delta x_{\mathrm{km}}\).
- **∂/∂y:** centre column `[-0.5, 0, 0.5]`, divide by \(\Delta y_{\mathrm{km}}\).

Then \(|\nabla \mathrm{SST}| = \sqrt{g_x^2 + g_y^2}\).

`pad = TRUE` on the focal window avoids losing the outer rim to NA (edge cells are less reliable—flag in QC if needed).

## Typical data source (context only)

Daily SST from ocean reanalysis (e.g. Copernicus Marine [GLORYS12](https://data.marine.copernicus.eu/) physics product on a ~0.083° grid, variable `thetao`) is a common input. Confirm **units are °C** in your extract (`summary()` should look like ocean temperatures, not ~300 K).

## Common mistakes

| Mistake | Why it matters |
|--------|----------------|
| Time derivative instead of space | Completely different ecology and units |
| Forgetting `cos(lat)` on longitude spacing | Gradient wrong by ~cos(φ); worse at high \|lat\| |
| Mixing Kelvin and Celsius across steps | Differences are OK if consistent; point SST and gradient interpretation must match |
| Treating coastal |∇SST| like open-ocean fronts | Nearshore gradients often reflect **coastal structure**, not mesoscale dynamical fronts |

## Resolution limits

At ~0.083°, **mesoscale** fronts (~50–200 km) are **partially** resolved; **sub-mesoscale** filaments and sharp coastal thermal structure are **not** fully captured. Interpret magnitudes accordingly.

## Paste-ready Methods paragraph (generic)

> For each calendar day, thermal frontal intensity was defined as the magnitude of the horizontal sea surface temperature gradient (|∇SST|, °C km⁻¹) on the native model grid. Partial derivatives were estimated with centred finite differences; cell dimensions were converted to kilometres using 111.32 km per degree of latitude, with longitude spacing adjusted by the cosine of latitude. Gradient magnitude was computed as the Euclidean norm of the horizontal partial derivatives. Values were sampled at study locations when linking to movement or behaviour data. Mesoscale fronts are only partially resolved at this grid spacing.

## After you have a gradient raster

Conceptual next steps (not covered in the toy tutorial):

1. **Extract** at animal longitudes/latitudes (`terra::extract`, consistent lon convention −180…180).
2. **Aggregate** to the time step of your model (e.g. daily mean if the response is daily).
3. **Transform** for regression if needed (e.g. log(|∇SST| + ε), then scale with other covariates).

## What this note deliberately omits

- Downloading Copernicus NetCDF (separate lesson).
- Habitat-specific model design, collinearity rules, or map figures tied to a particular study.
