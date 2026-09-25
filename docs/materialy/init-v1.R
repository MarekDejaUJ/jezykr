# Dane demonstracyjne kursu Język R. Wersja 1: zawartość pozostaje stała.
# Uruchomienie: source(url("https://marekdejauj.github.io/jezykr/materialy/init-v1.R"), local = TRUE)

pakiety_kursu <- function(nazwy) {
  brakujace <- setdiff(nazwy, rownames(installed.packages()))
  if (length(brakujace) > 0L) {
    message("Instaluję brakujące pakiety: ", paste(brakujace, collapse = ", "))
    typ_pakietu <- if (.Platform$OS.type == "windows") "binary" else getOption("pkgType")
    install.packages(brakujace, repos = "https://cloud.r-project.org",
                     type = typ_pakietu, quiet = TRUE)
  }
  nadal_brak <- nazwy[!vapply(nazwy, requireNamespace, logical(1), quietly = TRUE)]
  if (length(nadal_brak) > 0L) {
    stop("Nie udało się zainstalować: ", paste(nadal_brak, collapse = ", "),
         ". Uruchom nową sesję R i zaktualizuj zależności pakietów; sprawdź też internet i uprawnienia do biblioteki R.")
  }
  invisible(nazwy)
}

pakiety_podstawowe <- c("dplyr", "tidyr", "ggplot2", "readxl", "writexl", "rmarkdown")
pakiety_dodatkowe <- getOption("jezykr.pakiety", character())
pakiety_kursu(unique(c(pakiety_podstawowe, pakiety_dodatkowe)))
invisible(lapply(pakiety_podstawowe, function(nazwa) {
  suppressPackageStartupMessages(library(nazwa, character.only = TRUE))
}))

generuj_zgloszenia <- function() {
  set.seed(17358)
  n <- 240L
  data <- as.Date("2027-01-01") + sample(0:179, n, replace = TRUE)
  kanal <- sample(c("Online", "Telefon", "Na miejscu"), n, replace = TRUE,
                  prob = c(0.45, 0.35, 0.20))
  dzial <- sample(c("Katalog", " katalog ", "Repozytorium", "REPOZYTORIUM",
                    "Wsparcie"), n, replace = TRUE,
                  prob = c(0.28, 0.08, 0.27, 0.07, 0.30))
  typ_sprawy <- sample(c("Wyszukiwanie", "Dostęp", "Opis metadanych"), n,
                       replace = TRUE, prob = c(0.48, 0.32, 0.20))
  grupa <- sample(c("A", "B"), n, replace = TRUE)
  czas_min <- round(pmax(3, rnorm(n, mean = 35 + 8 * (kanal == "Telefon") -
                                      5 * (grupa == "B"), sd = 12)))
  ocena <- pmin(5L, pmax(1L, as.integer(round(5 - czas_min / 22 + rnorm(n, 0, 0.9)))))
  koszt <- round(12 + 1.7 * czas_min + rnorm(n, 0, 8), 2)
  prawd_rozwiazania <- plogis(2.8 - 0.035 * czas_min +
                               0.35 * (grupa == "B") -
                               0.45 * (typ_sprawy == "Dostęp"))
  rozwiazano <- ifelse(runif(n) < prawd_rozwiazania, "Tak", "Nie")
  czas_min[c(11, 79)] <- c(-5, 190)
  ocena[c(18, 64, 177)] <- NA_integer_
  dzial[33] <- NA_character_
  koszt[145] <- NA_real_
  data.frame(
    id = sprintf("Z%04d", seq_len(n)), data, kanal, dzial, typ_sprawy,
    grupa, czas_min, ocena, koszt, rozwiazano,
    stringsAsFactors = FALSE
  )
}

zgloszenia <- generuj_zgloszenia()
zgloszenia_analiza <- zgloszenia
zgloszenia_analiza$dzial <- ifelse(
  is.na(zgloszenia_analiza$dzial), NA_character_,
  ifelse(tolower(trimws(zgloszenia_analiza$dzial)) == "katalog", "Katalog",
         ifelse(tolower(trimws(zgloszenia_analiza$dzial)) == "repozytorium",
                "Repozytorium", "Wsparcie"))
)
zgloszenia_analiza$czas_min[
  zgloszenia_analiza$czas_min < 0 | zgloszenia_analiza$czas_min > 120
] <- NA_real_
if (!dir.exists("dane")) dir.create("dane", recursive = TRUE)
if (!file.exists("dane/zgloszenia.csv")) {
  write.csv(zgloszenia, "dane/zgloszenia.csv", row.names = FALSE,
            fileEncoding = "UTF-8", na = "")
}
if (!file.exists("dane/zgloszenia.xlsx")) {
  writexl::write_xlsx(zgloszenia, "dane/zgloszenia.xlsx")
}
message("Dane gotowe: ", nrow(zgloszenia), " fikcyjnych zgłoszeń; folder ",
        normalizePath("dane", winslash = "/", mustWork = TRUE))
