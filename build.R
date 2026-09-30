if (!file.exists("site/_site.yml")) {
  stop("Uruchom Rscript build.R z katalogu głównego repozytorium.")
}
if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  stop("Zainstaluj pakiet rmarkdown: install.packages('rmarkdown').")
}
if (rmarkdown::pandoc_available() == FALSE) {
  stop("Brak Pandoc. Uruchom skrypt w środowisku z Pandoc, np. z RStudio.")
}

adres <- "https://marekdejauj.github.io/jezykr/"
strony <- c("organizacyjne", sprintf("spotkanie-%d", 1:6))
pakiety_spotkan <- list(
  "4" = c("dlookr", "explore", "ggstatsplot"),
  "6" = c("effectsize", "report")
)

# Szablony powstają ze stron: każde ćwiczenie i zadanie dostaje polecenie, blok kodu i miejsce na interpretację.
for (numer in 0:6) {
  strona <- strony[numer + 1L]
  tekst <- readLines(file.path("site", paste0(strona, ".Rmd")), encoding = "UTF-8", warn = FALSE)
  tytul <- sub('^title: "(.*)"$', "\\1", tekst[2], useBytes = TRUE)
  naglowki <- grep("^### (Ćwiczenie|Zadanie) ", tekst)
  stopifnot(length(naglowki) >= 7L)
  pakiety <- pakiety_spotkan[[as.character(numer)]]

  wynik <- c(
    "---",
    sprintf('title: "%s"', tytul),
    'subtitle: "Praca studenta"',
    'author: "Imię i nazwisko"',
    "date: \"`r format(Sys.Date(), '%d.%m.%Y')`\"",
    "lang: pl",
    "papersize: a4",
    "geometry: margin=2.5cm",
    "output:",
    "  pdf_document:",
    "    latex_engine: xelatex",
    "    toc: true",
    "    dev: png",
    "  html_document:",
    "    toc: true",
    "header-includes:",
    "  - \\usepackage{fvextra}",
    "  - \\DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,commandchars=\\\\\\{\\}}",
    "---", "",
    "```{r start, include=FALSE}",
    "knitr::opts_chunk$set(dpi = 300)   # ostre wykresy PNG z polskimi znakami w PDF",
    if (length(pakiety) > 0L) sprintf("options(jezykr.pakiety = c(%s))", paste0('"', pakiety, '"', collapse = ", ")),
    sprintf('source("%smaterialy/init-v2.R", local = TRUE)', adres),
    "```", "",
    sprintf("Instrukcja: <%s%s.html>. Kod ze strony wpisuj lub kopiuj do bloków pod poleceniami i modyfikuj go według wskazówek „Sprawdź i zmień”. Wyniki opisuj własnymi słowami. Dokument renderuj do PDF przyciskiem **Knit**.", adres, strona),
    ""
  )

  for (k in seq_along(naglowki)) {
    linia <- naglowki[k]
    koniec <- if (k < length(naglowki)) naglowki[k + 1L] - 1L else length(tekst)
    fragment <- tekst[linia:koniec]
    brief <- grep("^::: \\{\\.brief", fragment)[1]
    stopifnot(!is.na(brief))
    polecenie <- grep("^\\*\\*Polecenie:\\*\\*", fragment)[1]
    stopifnot(!is.na(polecenie), polecenie > brief)
    tryb <- sub('.*szablon="([^"]*)".*', "\\1", fragment[brief])
    if (identical(tryb, fragment[brief])) tryb <- ""
    etykieta <- sub("^### (Ćwiczenie|Zadanie) ([0-9]+)\\.([0-9]+)\\..*$", "c\\2-\\3", tekst[linia])

    wynik <- c(wynik, sub("^###", "##", tekst[linia]), "", fragment[polecenie], "")
    if (identical(tryb, "tekst")) {
      wynik <- c(wynik, "**Odpowiedź:** uzupełnij.", "")
    } else {
      opcje <- if (nzchar(tryb)) paste0(", ", tryb) else ""
      wynik <- c(wynik, sprintf("```{r %s%s}", etykieta, opcje), "# Twój kod", "```", "",
                 "**Wynik i interpretacja:** uzupełnij własnymi słowami.", "")
    }
  }

  wynik <- c(wynik, "## Kontrola przed oddaniem", "",
             "- [ ] Po restarcie R (Session → Restart R) dokument renderuje się do PDF od początku.",
             "- [ ] Każde ćwiczenie i zadanie ma kod albo odpowiedź oraz interpretację.",
             "- [ ] Zadania samodzielne są moim rozwiązaniem, a użycie SI jest opisane i sprawdzone w R.",
             sprintf("- [ ] Do zadania w MS Teams przesyłam tylko plik `nazwisko_imie_%02d.pdf`.", numer))
  writeLines(enc2utf8(wynik), sprintf("site/materialy/szablon-%02d.Rmd", numer), useBytes = TRUE)
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
