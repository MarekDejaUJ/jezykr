if (!file.exists("site/_site.yml")) {
  stop("Uruchom Rscript build.R z katalogu głównego repozytorium.")
}
if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Zainstaluj pakiet rmarkdown: install.packages('rmarkdown').")
}
if (rmarkdown::pandoc_available() == FALSE) {
  stop("Brak Pandoc. Uruchom skrypt w środowisku z Pandoc, np. z RStudio.")
}

# Szablony zawierają dokładnie te same polecenia co strony spotkań.
for (numer in seq_len(10L)) {
  sciezka <- sprintf("site/spotkanie-%d.Rmd", numer)
  tekst <- readLines(sciezka, encoding = "UTF-8", warn = FALSE)
  start <- grep("^## Learn", tekst)
  koniec <- tail(grep("^(Oddaj|Zapisz) ", tekst), 1L)
  stopifnot(length(start) == 1L, length(koniec) == 1L, koniec > start)
  tytul <- sub('^title: "(.*)"$', '\\1', tekst[2], useBytes = TRUE)
  instrukcje <- tekst[start:(koniec - 1L)]
  wynik <- c(
    "---", paste0('title: "', tytul, ' — praca studenta"'),
    'author: "Imię i nazwisko"',
    "output:", "  html_document:", "    toc: true", "---", "",
    sprintf("Instrukcja online: <https://marekdejauj.github.io/jezykr/spotkanie-%d.html>.", numer),
    "Przykładowy kod z ramek poniżej wpisz lub zmodyfikuj w bloku **Twoja praca**. Dodaj własne rozwiązanie części Challenge.",
    "", "```{r start, message=FALSE, warning=FALSE}",
    if (numer == 8L) 'options(jezykr.pakiety = c("dlookr", "explore", "ggstatsplot"))',
    'source(url("https://marekdejauj.github.io/jezykr/materialy/init-v1.R"), local = TRUE)',
    "```", ""
  )
  cwiczenie <- 0L
  for (linia in instrukcje) {
    wynik <- c(wynik, linia)
    if (grepl('class="tilt-card criteria"', linia, fixed = TRUE)) {
      cwiczenie <- cwiczenie + 1L
      wynik <- c(wynik, "", "**Twoja praca — kod:**", "",
                 sprintf("```{r cw%d}", cwiczenie),
                 "# Wpisz i uruchom własny kod.", "```", "",
                 "**Wynik i interpretacja:** uzupełnij własnymi słowami.", "")
    }
  }
  stopifnot(cwiczenie == 3L)
  wynik <- c(wynik, "", "## Kontrola przed oddaniem", "",
             "- [ ] Dokument renderuje się od początku w czystej sesji R.",
             "- [ ] Wszystkie trzy ćwiczenia zawierają kod i interpretację.",
             "- [ ] Część Challenge jest samodzielnym rozwiązaniem.",
             "- [ ] Do zadania MS Teams dołączam tylko ten plik `.Rmd`.")
  writeLines(wynik, sprintf("site/materialy/szablon-%02d.Rmd", numer), useBytes = TRUE)
}

# docs jest wyłącznie wynikiem renderowania; usunięcie usuwa stare strony i zasoby.
korzen <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
cel <- normalizePath("docs", winslash = "/", mustWork = FALSE)
stopifnot(identical(dirname(cel), korzen), basename(cel) == "docs")
if (dir.exists(cel)) unlink(cel, recursive = TRUE)
rmarkdown::render_site("site", quiet = TRUE)
dir.create("docs/materialy", recursive = TRUE, showWarnings = FALSE)
zasoby <- list.files("site/materialy", full.names = TRUE, recursive = FALSE)
stopifnot(all(file.copy(zasoby, "docs/materialy", overwrite = TRUE)))
stopifnot(file.copy("jezyk-r-uj-wzzins-24-17358-26.pdf", "docs/materialy", overwrite = TRUE))
file.create("docs/.nojekyll")
message("Strona gotowa w katalogu docs/.")
