# Pablo Fuenzalida — website

A [Quarto](https://quarto.org) website: a marine-ecology-themed landing page, a
**Blog**, and **R Tutorials**. Light, minimalist "ocean science" aesthetic —
white space, Deep Ocean Blue (`#0077B6`) and Inter — set in `theme.scss`.

## Preview locally

```sh
quarto preview      # live reload at http://localhost:****
quarto render       # build the static site into _site/
```

## Add a blog post

Copy an existing post folder, rename it, edit the front matter:

```sh
cp -r blog/posts/welcome blog/posts/my-new-post
```

```yaml
---
title: "My new post"
date: 2026-07-01
categories: [news, fieldwork]  # up to 3 tags — they appear in the blog's category filter
description: "One line for the listing."
---
```

## Add an R tutorial

Same idea under `tutorials/posts/`. R chunks run at render time and follow
[wurli/r-best-practice](https://github.com/wurli/r-best-practice) conventions.
Rendered output is cached in `_freeze/` (committed) so CI publishes without R.

## Add a background photo

The landing page (`index.qmd`) uses a reusable `.photo-section` block. Drop an
image in `images/`, copy the block, and point `--bg:url(...)` at it.

## Deploy

Pushing to `main` triggers `.github/workflows/publish.yml`, which renders and
publishes to the `gh-pages` branch. Enable **Settings → Pages → Branch:
gh-pages** once in the repo.

## Before going live — fill in the `TODO`s in `_quarto.yml`

- GitHub username, ORCID iD, and the `site-url`.

---

`app.R`, `www/`, and `rsconnect/` are the separate Shiny app — not part of this site.
