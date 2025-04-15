# Simple One-Page Website
# Just a name and a cover photo

# Clear environment
rm(list = ls())

# Set working directory to the project root
setwd("/Users/owuss/Documents/USC/Honours/R/data/git/hugo-based-website-building")

# Load required libraries
library(blogdown)

# Set Hugo version
options(blogdown.hugo.version = "0.146.4")

# Create a simple site
site_name <- "ecologist-pablo"
if (dir.exists(site_name)) {
  unlink(site_name, recursive = TRUE)  # Remove if exists
}

# Create a new site with minimal configuration
blogdown::new_site(
  dir = site_name,
  theme = "zhaohuabing/hugo-theme-cleanwhite",
  format = "toml",
  sample = FALSE,
  force = TRUE
)

# Create images directory
dir.create(file.path(site_name, "static/images"), recursive = TRUE, showWarnings = FALSE)

# IMPORTANT: Place your new photo in the images directory
# The path should be: ecologist-pablo/static/images/your-new-photo.jpg
# Then update the image filename below to match your new photo's name

# Define the image filename to use
image_filename <- "cover-photo1.jpg"  # Change this to your new photo filename

# Create a simple config.toml
config_content <- paste0('baseURL = "/"
title = "Ecologist Pablo"
theme = "hugo-theme-cleanwhite"

[params]
  description = "Marine Conservation Researcher"
  author = "Pablo A. Fuenzalia Miralles"
  # Header image for the home page
  header_image = "/images/', image_filename, '"
  # Sidebar settings
  sidebar_about_description = "Marine Conservation Researcher"
  sidebar_avatar = "/images/', image_filename, '"
  # Additional theme settings
  header_image_height = "500px"
  header_image_position = "center"
  header_image_alt = "Cover Photo"

[menu]
  [[menu.main]]
    identifier = "home"
    name = "Home"
    url = "/"
    weight = 1')

# Remove any hugo.toml file if it exists
if (file.exists(file.path(site_name, "hugo.toml"))) {
  file.remove(file.path(site_name, "hugo.toml"))
}

# Create a simple home page
home_content <- paste0('---
title: "Ecologist Pablo"
date: 2025-04-14
draft: false
header_image: "/images/', image_filename, '"
---

# Ecologist Pablo

Marine Conservation Researcher
')

writeLines(home_content, file.path(site_name, "content/_index.md"))
writeLines(config_content, file.path(site_name, "config.toml"))

# Build and serve the site
setwd(site_name)
blogdown::serve_site()
#blogdown::stop_server()
