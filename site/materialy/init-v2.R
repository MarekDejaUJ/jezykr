# Skrypt startowy kursu Język R, wersja 2. Zawartość danych pozostaje stała.
# Uruchomienie w konsoli i w bloku start każdego szablonu:
# source("https://marekdejauj.github.io/jezykr/materialy/init-v2.R", local = TRUE)
#
# Skrypt:
# 1. instaluje brakujące pakiety i ładuje pakiety podstawowe,
# 2. odtwarza fikcyjne pliki w folderze dane/ (CSV, CSV z polskiego Excela, XLSX),
# 3. tworzy folder wyniki/,
# 4. tworzy obiekty zgloszenia (dane surowe) i zgloszenia_analiza (po czyszczeniu),
# 5. udostępnia funkcję pobierz_szablon() do pobierania szablonu spotkania.

adres_kursu <- "https://marekdejauj.github.io/jezykr/materialy/"

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
         ". Uruchom nową sesję R, sprawdź internet i uprawnienia do biblioteki R.")
  }
  invisible(nazwy)
}

pobierz_szablon <- function(numer, plik = NULL, nadpisz = FALSE) {
  nazwa <- if (identical(numer, "projekt")) {
    "szablon-projekt.Rmd"
  } else {
    sprintf("szablon-%02d.Rmd", as.integer(numer))
  }
  if (is.null(plik)) plik <- nazwa
  if (file.exists(plik) && !nadpisz) {
    message("Plik ", plik, " już istnieje. Otwieram go bez nadpisywania.")
  } else {
    download.file(paste0(adres_kursu, nazwa), plik, mode = "wb", quiet = TRUE)
    message("Pobrano szablon do pliku ", plik, ".")
  }
  if (interactive()) utils::file.edit(plik)
  invisible(plik)
}

pakiety_podstawowe <- c("dplyr", "tidyr", "ggplot2", "readxl", "writexl", "rmarkdown")
pakiety_dodatkowe <- getOption("jezykr.pakiety", character())
pakiety_kursu(unique(c(pakiety_podstawowe, pakiety_dodatkowe)))
# Pakiety dodatkowe też są ładowane, bo część z nich (np. dlookr) konfiguruje wykresy dopiero przy załadowaniu.
invisible(lapply(unique(c(pakiety_dodatkowe, pakiety_podstawowe)), function(nazwa) {
  suppressPackageStartupMessages(library(nazwa, character.only = TRUE))
}))

generuj_zgloszenia <- function() {
  # Losowanie jest powtarzalne, a stan generatora użytkownika zostaje przywrócony.
  stan <- if (exists(".Random.seed", envir = globalenv())) {
    get(".Random.seed", envir = globalenv())
  }
  on.exit({
    if (is.null(stan)) {
      if (exists(".Random.seed", envir = globalenv())) rm(".Random.seed", envir = globalenv())
    } else {
      assign(".Random.seed", stan, envir = globalenv())
    }
  })
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

dzialy_kursu <- data.frame(
  dzial = c("Katalog", "Repozytorium", "Wsparcie", "Informacja"),
  budynek = c("A", "B", "A", "C"),
  etaty = c(4, 3, 5, 2),
  stringsAsFactors = FALSE
)

opis_zmiennych <- data.frame(
  zmienna = c("id", "data", "kanal", "dzial", "typ_sprawy", "grupa",
              "czas_min", "ocena", "koszt", "rozwiazano"),
  opis = c("identyfikator zgłoszenia",
           "data wpłynięcia zgłoszenia",
           "kanał kontaktu: Online, Telefon, Na miejscu",
           "dział obsługujący; w danych surowych zapisy są niespójne",
           "rodzaj sprawy: Wyszukiwanie, Dostęp, Opis metadanych",
           "losowo przydzielony wariant procedury: A dotychczasowy, B pilotażowy",
           "czas obsługi zgłoszenia",
           "ocena satysfakcji użytkownika w skali 1-5",
           "koszt obsługi zgłoszenia",
           "czy sprawę rozwiązano przy pierwszym kontakcie: Tak, Nie"),
  jednostka = c("", "dzień", "", "", "", "", "minuty", "punkty", "zł", ""),
  stringsAsFactors = FALSE
)

zgloszenia <- generuj_zgloszenia()

# Reguły czyszczenia używane od spotkania 2: ujednolicone działy i czas spoza 0-120 minut jako brak.
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

# Pliki danych są odtwarzane przy każdym uruchomieniu, więc surowe dane zawsze są takie same.
dir.create("dane", showWarnings = FALSE, recursive = TRUE)
dir.create("wyniki", showWarnings = FALSE, recursive = TRUE)
write.csv(zgloszenia, "dane/zgloszenia.csv", row.names = FALSE,
          fileEncoding = "UTF-8", na = "")
zgloszenia_pl <- zgloszenia
zgloszenia_pl$data <- format(zgloszenia_pl$data, "%d.%m.%Y")
write.csv2(zgloszenia_pl, "dane/zgloszenia_pl.csv", row.names = FALSE,
           fileEncoding = "CP1250", na = "brak")
writexl::write_xlsx(
  list(zgloszenia = zgloszenia, dzialy = dzialy_kursu, opis = opis_zmiennych),
  "dane/zgloszenia.xlsx"
)
rm(zgloszenia_pl, dzialy_kursu, opis_zmiennych)

message("Dane gotowe: ", nrow(zgloszenia), " fikcyjnych zgłoszeń w folderze ",
        normalizePath("dane", winslash = "/", mustWork = TRUE))
