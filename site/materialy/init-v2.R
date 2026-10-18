# Skrypt startowy kursu Język R, wersja 2. Zawartość danych pozostaje stała.
# Uruchomienie w konsoli i w bloku start każdego szablonu:
# source("https://marekdejauj.github.io/jezykr/materialy/init-v2.R", local = TRUE)
#
# Skrypt przygotowuje całe środowisko pracy na kursie:
# 1. instaluje brakujące pakiety R (wszystkie używane na kursie, razem z zależnościami)
#    i ładuje pakiety podstawowe oraz wskazane w opcji jezykr.pakiety,
# 2. w konsoli sprawdza, czy jest LaTeX do tworzenia PDF; gdy go nie ma, instaluje TinyTeX
#    z pakietami potrzebnymi do polskich dokumentów,
# 3. odtwarza fikcyjne pliki w folderze dane/ (CSV, CSV z polskiego Excela, XLSX),
# 4. tworzy folder wyniki/,
# 5. tworzy obiekty zgloszenia (dane surowe) i zgloszenia_analiza (po czyszczeniu),
# 6. udostępnia funkcje pobierz_szablon(), oddaj_zadanie() i sprawdz_srodowisko().
# Na komputerze, na którym wszystko jest już zainstalowane, kroki 1 i 2 trwają ułamek sekundy.

adres_kursu <- "https://marekdejauj.github.io/jezykr/materialy/"

# Pakiety używane na kursie. Instalowane są od razu wszystkie, żeby na spotkaniach 4 i 6
# nie czekać na instalację; zależności (m.in. shiny dla dlookr i explore) dochodzą same.
pakiety_podstawowe <- c("dplyr", "tidyr", "ggplot2", "readxl", "writexl", "rmarkdown", "knitr")
pakiety_spotkan <- c("dlookr", "explore", "ggstatsplot", "effectsize", "report", "parameters")
pakiety_narzedzia <- c("tinytex", "curl", "rstudioapi")
pakiety_latex <- c("babel-polish", "hyphen-polish", "fvextra", "xurl")

# Gdy biblioteka systemowa R jest tylko do odczytu (typowe w pracowni i na Windows),
# pakiety trafiają do biblioteki użytkownika; tworzymy ją, zanim R zapyta o to w okienku.
przygotuj_biblioteke <- function() {
  if (file.access(.libPaths()[1], mode = 2) == 0L) return(invisible(.libPaths()[1]))
  uzytkownika <- strsplit(Sys.getenv("R_LIBS_USER"), .Platform$path.sep, fixed = TRUE)[[1]][1]
  if (is.na(uzytkownika) || !nzchar(uzytkownika)) return(invisible(.libPaths()[1]))
  uzytkownika <- path.expand(uzytkownika)
  if (!dir.exists(uzytkownika)) dir.create(uzytkownika, recursive = TRUE, showWarnings = FALSE)
  .libPaths(c(uzytkownika, .libPaths()))
  invisible(uzytkownika)
}

# Repozytorium CRAN: ustawione w sesji (RStudio ustawia cloud.r-project.org; na Linuxie
# często repozytorium z gotowymi binariami), a gdy nie jest ustawione — cloud.r-project.org.
repozytorium_cran <- function() {
  repos <- getOption("repos")
  cran <- if (!is.null(repos) && "CRAN" %in% names(repos)) unname(repos["CRAN"]) else ""
  if (!nzchar(cran) || identical(cran, "@CRAN@")) cran <- "https://cloud.r-project.org"
  c(CRAN = cran)
}

pakiety_kursu <- function(nazwy) {
  brakujace <- setdiff(nazwy, rownames(installed.packages()))
  if (length(brakujace) > 0L) {
    przygotuj_biblioteke()
    message("Instaluję brakujące pakiety R (", length(brakujace), "): ",
            paste(brakujace, collapse = ", "),
            "\nRazem z zależnościami może to potrwać kilka minut; wykonuje się tylko raz.")
    typ_pakietu <- if (.Platform$OS.type == "windows") "binary" else getOption("pkgType")
    install.packages(brakujace, repos = repozytorium_cran(), type = typ_pakietu, quiet = TRUE)
  }
  # system.file() sprawdza obecność pakietu bez ładowania go (bez komunikatów startowych).
  nadal_brak <- nazwy[!nzchar(vapply(nazwy, function(n) system.file(package = n), character(1)))]
  if (length(nadal_brak) > 0L) {
    stop("Nie udało się zainstalować: ", paste(nadal_brak, collapse = ", "),
         ". Uruchom nową sesję R, sprawdź internet i uprawnienia do biblioteki R.")
  }
  invisible(nazwy)
}

# LaTeX jest potrzebny do PDF. Instalacja TinyTeX wykonuje się tylko w konsoli (nie podczas
# renderowania), raz na komputerze; pakiety LaTeX dla polskich dokumentów są dodawane od razu.
latex_dostepny <- function() {
  nzchar(Sys.which("xelatex")) || nzchar(tinytex::tinytex_root(error = FALSE))
}

przygotuj_latex <- function() {
  if (!interactive()) return(invisible(latex_dostepny()))
  if (!latex_dostepny()) {
    message("Nie znalazłem LaTeX-a do tworzenia PDF. Instaluję TinyTeX (ok. 150 MB); ",
            "to jednorazowe i trwa zwykle 2-5 minut...")
    wynik <- tryCatch({
      tinytex::install_tinytex(extra_packages = pakiety_latex)
      TRUE
    }, error = function(e) {
      message("Instalacja TinyTeX nie powiodła się: ", conditionMessage(e),
              "\nSpróbuj ponownie z dostępem do internetu albo uruchom w konsoli: ",
              "tinytex::install_tinytex()")
      FALSE
    })
    if (!wynik) return(invisible(FALSE))
    message("TinyTeX zainstalowany. Jeżeli pierwsze renderowanie PDF nie zadziała, zrestartuj RStudio.")
  }
  if (tinytex::is_tinytex()) {
    brak <- tryCatch(pakiety_latex[!tinytex::check_installed(pakiety_latex)],
                     error = function(e) character())
    if (length(brak) > 0L) {
      message("Doinstalowuję pakiety LaTeX: ", paste(brak, collapse = ", "))
      tryCatch(tinytex::tlmgr_install(brak), error = function(e) {
        message("Nie udało się doinstalować pakietów LaTeX: ", conditionMessage(e))
      })
    }
  }
  invisible(latex_dostepny())
}

# Lista kontrolna środowiska: do pokazania prowadzącemu albo informatykowi, gdy coś nie działa.
sprawdz_srodowisko <- function() {
  wszystkie <- c(pakiety_podstawowe, pakiety_spotkan, pakiety_narzedzia)
  brak_pakietow <- setdiff(wszystkie, rownames(installed.packages()))
  tinytex_jest <- tinytex::is_tinytex()
  brak_latex <- if (tinytex_jest) {
    tryCatch(pakiety_latex[!tinytex::check_installed(pakiety_latex)], error = function(e) pakiety_latex)
  } else character()
  pandoc <- rmarkdown::pandoc_available("2.0")
  ide <- if (nzchar(Sys.getenv("RSTUDIO"))) "RStudio" else if (nzchar(Sys.getenv("POSITRON"))) "Positron" else "inny"
  internet <- tryCatch({
    con <- url(paste0(adres_kursu, "init-v2.R")); open(con, "r"); close(con); TRUE
  }, error = function(e) FALSE, warning = function(w) FALSE)
  wiersze <- data.frame(
    element = c("R", "IDE", "Pandoc (RStudio/Positron)", "Pakiety R kursu", "LaTeX (xelatex)",
                "Pakiety LaTeX dla polskich dokumentów", "Biblioteka pakietów z prawem zapisu",
                "Połączenie ze stroną kursu"),
    stan = c(
      paste(R.version$major, R.version$minor, sep = "."),
      ide,
      if (pandoc) paste("OK,", as.character(rmarkdown::pandoc_version())) else "BRAK",
      if (length(brak_pakietow) == 0L) "OK" else paste("BRAK:", paste(brak_pakietow, collapse = ", ")),
      if (latex_dostepny()) paste("OK", if (tinytex_jest) "(TinyTeX)" else "(inna dystrybucja)") else "BRAK",
      if (!tinytex_jest) "nie dotyczy" else if (length(brak_latex) == 0L) "OK" else paste("BRAK:", paste(brak_latex, collapse = ", ")),
      if (file.access(.libPaths()[1], mode = 2) == 0L) .libPaths()[1] else paste("tylko odczyt:", .libPaths()[1]),
      if (internet) "OK" else "BRAK"
    ),
    stringsAsFactors = FALSE
  )
  print(wiersze, row.names = FALSE, right = FALSE)
  invisible(wiersze)
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

pakiety_dodatkowe <- getOption("jezykr.pakiety", character())
pakiety_kursu(unique(c(pakiety_podstawowe, pakiety_spotkan, pakiety_narzedzia, pakiety_dodatkowe)))
# Ładowane są pakiety podstawowe i wskazane w opcji jezykr.pakiety; te drugie też, bo część z nich
# (np. dlookr) konfiguruje wykresy dopiero przy załadowaniu.
invisible(lapply(unique(c(pakiety_dodatkowe, setdiff(pakiety_podstawowe, "knitr"))), function(nazwa) {
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

# Oddawanie pracy: oddaj_zadanie(3) zapisuje otwarte pliki, odnajduje w folderze roboczym
# szablon spotkania 3 i sprawdza go, renderuje do PDF w nowej sesji R (tak jak Knit po
# restarcie R) i po potwierdzeniu wysyła wyniki/nazwisko_imie_03.pdf do folderu spotkania
# na nc.uj.edu.pl. Foldery przyjmują pliki bez logowania i nie pokazują prac innych osób.
# Ponowne oddanie dodaje nową wersję obok poprzedniej. oddaj_zadanie(3, wyslij = FALSE)
# wykonuje kontrolę bez wysyłania.
oddaj_zadanie <- local({
  foldery <- c(
    "00" = "https://nc.uj.edu.pl/s/n6FfGbfBamQJbkX",
    "01" = "https://nc.uj.edu.pl/s/MZPw5xASZFjRfCP",
    "02" = "https://nc.uj.edu.pl/s/P3ngMS8JbSKETRM",
    "03" = "https://nc.uj.edu.pl/s/LRA82FMEnqXe7xE",
    "04" = "https://nc.uj.edu.pl/s/QXLXrWAnBe3rzi5",
    "05" = "https://nc.uj.edu.pl/s/ZLWD679fy5X3S99",
    "06" = "https://nc.uj.edu.pl/s/H3sa3LZE3qgnne7"
  )
  nazwy_spotkan <- c("00" = "Spotkanie organizacyjne",
                     stats::setNames(sprintf("Spotkanie %d", 1:6), sprintf("%02d", 1:6)))

  # "Anna Maria Kowalska-Nowak" -> nazwisko "Kowalska-Nowak", imię "Anna Maria"
  autor_szablonu <- function(plik) {
    yaml <- tryCatch(rmarkdown::yaml_front_matter(plik), error = function(e) {
      stop("Nagłówek YAML pliku ", basename(plik), " jest uszkodzony: ", conditionMessage(e),
           "\nPorównaj go z nowym szablonem, np. pobierz_szablon(3, plik = \"wzor.Rmd\").",
           call. = FALSE)
    })
    autor <- yaml$author
    autor <- if (is.character(autor) && length(autor) == 1L) trimws(gsub("\\s+", " ", autor)) else ""
    slowa <- strsplit(autor, " ", fixed = TRUE)[[1]]
    if (length(slowa) < 2L || grepl("nazwisk", tolower(autor)) || !grepl("^[[:alpha:]' -]+$", autor)) {
      stop("Wpisz swoje imię i nazwisko w nagłówku pliku ", basename(plik), ", np.\n",
           "  author: \"Anna Kowalska\"\nZapisz plik i uruchom polecenie ponownie.", call. = FALSE)
    }
    list(nazwisko = slowa[length(slowa)], imie = paste(slowa[-length(slowa)], collapse = " "))
  }

  # "Gęślą Zażółć" -> "gesla_zazolc"; polskie litery zamieniane jawnie, bo iconv różni się między systemami.
  do_nazwy_pliku <- function(x) {
    x <- chartr("\u0105\u0107\u0119\u0142\u0144\u00f3\u015b\u017a\u017c\u0104\u0106\u0118\u0141\u0143\u00d3\u015a\u0179\u017b",
                "acelnoszzACELNOSZZ", x)
    x <- iconv(gsub("'", "", x), "UTF-8", "ASCII//TRANSLIT", sub = "")
    x[is.na(x)] <- ""
    x <- gsub("['`^~\"]", "", x)   # macOS zapisuje "é" jako "'e", a "ü" jako "\"u"
    x <- gsub("[^a-z0-9-]+", "_", tolower(x))
    gsub("^_+|_+$", "", x)
  }

  # Numery spotkań z nagłówków ćwiczeń oraz ćwiczenia bez kodu albo bez odpowiedzi.
  sprawdz_tresc <- function(linie) {
    wzor <- "^##+\\s+((\u0106wiczenie|Zadanie)\\s+([0-9]+)\\.[0-9]+)\\..*$"
    naglowki <- grep(wzor, linie)
    sekcje <- c(grep("^##+\\s", linie), length(linie) + 1L)
    braki <- character()
    for (od in naglowki) {
      do <- sekcje[sekcje > od][1] - 1L
      fragment <- trimws(linie[od:do])
      bez_odpowiedzi <- any(grepl("^\\*\\*[^*]+:\\*\\*\\s*uzupe\u0142nij", fragment))
      starty <- grep("^```+\\s*\\{r", fragment)
      bez_kodu <- any(vapply(starty, function(s) {
        konce <- grep("^```+\\s*$", fragment)
        k <- konce[konce > s][1]
        if (is.na(k)) k <- length(fragment) + 1L
        kod <- fragment[seq_len(k - s - 1L) + s]
        all(kod %in% c("", "# Tw\u00f3j kod"))
      }, logical(1)))
      if (bez_odpowiedzi || bez_kodu) braki <- c(braki, sub(wzor, "\\1", linie[od]))
    }
    list(numery = unique(as.integer(sub(wzor, "\\3", linie[naglowki]))), braki = braki)
  }

  # Szablon spotkania w folderze roboczym rozpoznany po nagłówkach ćwiczeń; z kilku wybierany najnowszy.
  znajdz_szablon <- function(nr) {
    pliki <- list.files(pattern = "\\.Rmd$", ignore.case = TRUE)
    pasujace <- pliki[vapply(pliki, function(p) {
      identical(sprawdz_tresc(readLines(p, encoding = "UTF-8", warn = FALSE))$numery, nr)
    }, logical(1))]
    if (length(pasujace) == 0L) {
      stop("W folderze ", normalizePath(getwd(), winslash = "/"), " nie ma szablonu spotkania ", nr, ".\n",
           "Otwórz projekt jezykr i pobierz szablon: pobierz_szablon(", nr, ") albo podaj plik, ",
           "np. oddaj_zadanie(", nr, ", plik = \"moj-plik.Rmd\").",
           if (length(pliki) > 0L) paste0("\nPliki .Rmd w tym folderze: ", paste(pliki, collapse = ", ")),
           call. = FALSE)
    }
    pasujace <- pasujace[order(file.mtime(pasujace), decreasing = TRUE)]
    if (length(pasujace) > 1L) {
      message("Szablony spotkania ", nr, ": ", paste(pasujace, collapse = ", "), ". Oddaję najnowszy: ",
              pasujace[1], ".\nInny plik wskażesz tak: oddaj_zadanie(", nr, ", plik = \"", pasujace[2], "\").")
    }
    pasujace[1]
  }

  # Renderuje w osobnym procesie R: obiekty z konsoli nie wpływają na wynik, jak przy Knit.
  renderuj <- function(plik, nazwa, format) {
    wyjscie <- file.path(dirname(plik), "wyniki", nazwa)
    if (file.exists(wyjscie)) file.remove(wyjscie)
    if (!nzchar(Sys.getenv("RSTUDIO_PANDOC"))) Sys.setenv(RSTUDIO_PANDOC = rmarkdown::find_pandoc()$dir)
    kod <- sprintf("rmarkdown::render(%s, output_format = '%s', output_file = %s, output_dir = 'wyniki', quiet = TRUE)",
                   encodeString(basename(plik), quote = "'"), format, encodeString(nazwa, quote = "'"))
    stary_folder <- setwd(dirname(plik))
    on.exit(setwd(stary_folder))
    log <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), c("-e", shQuote(kod)),
                                    stdout = TRUE, stderr = TRUE))
    ok <- is.null(attr(log, "status")) && file.exists(wyjscie) && file.size(wyjscie) > 1000
    if (ok && format == "pdf_document") ok <- identical(readBin(wyjscie, "raw", 5L), charToRaw("%PDF-"))
    list(ok = ok, plik = wyjscie, log = log, blad_kodu = any(grepl("^Quitting from", log)))
  }

  # Najważniejszy fragment komunikatów z renderowania: błąd R, błąd LaTeX-a albo ostatnie wiersze.
  fragment_logu <- function(log) {
    log <- log[nzchar(trimws(log)) & !grepl("^Execution halted", log)]
    i <- grep("^Quitting from", log)[1]
    if (!is.na(i)) {
      # Nowszy knitr podaje błąd przed wierszem "Quitting from", starszy po nim; ślad wywołań pomijamy.
      e <- utils::tail(grep("^(Error|B\u0142\u0105d)", log[seq_len(i)]), 1L)
      if (length(e) == 0L) return(paste(log[i:min(length(log), i + 8L)], collapse = "\n"))
      fragment <- log[e:i]
      b <- grep("^Backtrace:", fragment)[1]
      if (!is.na(b)) fragment <- fragment[c(seq_len(b - 1L), length(fragment))]
      return(paste(fragment, collapse = "\n"))
    }
    i <- grep("^! ", log)
    if (length(i) > 0L) return(paste(log[sort(unique(pmin(c(i, i + 1L), length(log))))], collapse = "\n"))
    paste(utils::tail(log, 12L), collapse = "\n")
  }

  # Folder „File drop” przyjmuje PUT bez logowania; NULL oznacza sukces, tekst opisuje problem.
  wyslij_plik <- function(sciezka, link, nick) {
    pakiety_kursu("curl")
    url <- paste0(sub("/s/.*$", "", link), "/public.php/dav/files/", sub("^.*/s/", "", link), "/",
                  utils::URLencode(basename(sciezka), reserved = TRUE))
    odp <- tryCatch(
      curl::curl_upload(sciezka, url, verbose = FALSE,
                        httpheader = c("X-Requested-With: XMLHttpRequest",
                                       paste0("X-NC-Nickname: ", utils::URLencode(nick, reserved = TRUE)))),
      error = function(e) e)
    if (inherits(odp, "error")) return(paste0("brak połączenia z serwerem (", conditionMessage(odp), ")"))
    kod <- odp$status_code
    # Nextcloud zgłasza usunięty lub wygasły udział jako 503 z NotFound w treści odpowiedzi.
    if (kod == 503L && grepl("NotFound", rawToChar(odp$content), fixed = TRUE)) kod <- 404L
    switch(as.character(kod),
           "201" = , "204" = NULL,
           "404" = "folder nie przyjmuje już plików (minął termin albo link wygasł)",
           "401" = , "403" = "folder nie przyjmuje plików bez hasła albo został zamknięty",
           "413" = "plik jest za duży",
           "507" = "w folderze prowadzącego zabrakło miejsca",
           paste0("serwer odrzucił plik (HTTP ", odp$status_code, ")"))
  }

  # Renderowany jest plik z dysku, więc najpierw zapisujemy zmiany z edytora RStudio lub Positrona.
  zapisz_otwarte_pliki <- function() {
    if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
      try(rstudioapi::documentSaveAll(), silent = TRUE)
    } else if (exists(".rs.api.documentSaveAll", mode = "function")) {
      try(get(".rs.api.documentSaveAll", mode = "function")(), silent = TRUE)
    }
  }

  function(numer, plik = NULL, wyslij = TRUE) {
    if (isTRUE(getOption("knitr.in.progress"))) {
      stop("Uruchom oddaj_zadanie() w konsoli, nie w bloku dokumentu.", call. = FALSE)
    }
    klucz <- if (length(numer) == 1L) sprintf("%02d", suppressWarnings(as.integer(numer))) else ""
    if (!klucz %in% names(foldery)) {
      stop("Podaj numer spotkania od 0 do 6, np. oddaj_zadanie(3).", call. = FALSE)
    }
    nr <- as.integer(klucz)
    zapisz_otwarte_pliki()
    if (is.null(plik)) plik <- znajdz_szablon(nr)
    if (!file.exists(plik)) {
      stop("W folderze ", normalizePath(getwd(), winslash = "/"), " nie ma pliku ", plik, ".", call. = FALSE)
    }
    if (!rmarkdown::pandoc_available()) {
      stop("Brak programu Pandoc. Uruchom oddaj_zadanie() w RStudio albo Positronie.", call. = FALSE)
    }
    plik <- normalizePath(plik, winslash = "/")
    autor <- autor_szablonu(plik)
    tresc <- sprawdz_tresc(readLines(plik, encoding = "UTF-8", warn = FALSE))
    if (length(setdiff(tresc$numery, nr)) > 0L) {
      stop("Plik ", basename(plik), " zawiera ćwiczenia ze spotkania ",
           paste(sort(tresc$numery), collapse = ", "), ", a oddajesz pracę ze spotkania ", nr, ".\n",
           "Sprawdź numer w poleceniu albo nazwę pliku.", call. = FALSE)
    }

    nazwa <- paste(do_nazwy_pliku(autor$nazwisko), do_nazwy_pliku(autor$imie), klucz, sep = "_")
    message("Renderuję ", basename(plik), " do PDF w nowej sesji R. To może potrwać około minuty...")
    wynik <- renderuj(plik, paste0(nazwa, ".pdf"), "pdf_document")
    if (!wynik$ok && wynik$blad_kodu) {
      stop("Dokument nie renderuje się w nowej sesji R:\n\n", fragment_logu(wynik$log), "\n\n",
           "Popraw wskazany blok (Knit pokaże ten sam błąd) i uruchom oddaj_zadanie(", nr, ") ponownie.",
           call. = FALSE)
    }
    if (!wynik$ok) {
      message("Nie powstał PDF, prawdopodobnie z powodu LaTeX-a:\n\n", fragment_logu(wynik$log), "\n\n",
              "Sprawdź środowisko poleceniem sprawdz_srodowisko(). Jeśli brakuje LaTeX-a, uruchom ponownie ",
              "skrypt startowy w konsoli (zainstaluje TinyTeX) i zrestartuj RStudio.\n",
              "Teraz przygotowuję wersję HTML, aby praca mogła zostać oddana.")
      wynik_pdf <- wynik
      wynik <- renderuj(plik, paste0(nazwa, ".html"), "html_document")
      if (!wynik$ok) {
        stop("Nie udało się wyrenderować dokumentu ani do PDF, ani do HTML:\n\n",
             fragment_logu(c(wynik_pdf$log, wynik$log)), call. = FALSE)
      }
    }

    rozmiar <- format(structure(file.size(wynik$plik), class = "object_size"), units = "auto", standard = "SI")
    message("\nGotowe do oddania:\n",
            "  plik:   ", wynik$plik, " (", rozmiar, ")\n",
            "  autor:  ", autor$imie, " ", autor$nazwisko, "\n",
            "  folder: ", nazwy_spotkan[[klucz]],
            if (length(tresc$braki) > 0L) paste0("\n  bez kodu lub odpowiedzi: ", paste(tresc$braki, collapse = ", ")))
    if (!wyslij) {
      message("Nie wysyłam (wyslij = FALSE).")
      return(invisible(wynik$plik))
    }
    if (interactive()) {
      tryCatch(utils::browseURL(wynik$plik), error = function(e) NULL)
      odpowiedz <- readline("Obejrzyj plik. Wysłać go prowadzącemu? [t/n]: ")
      if (!tolower(trimws(odpowiedz)) %in% c("t", "tak")) {
        message("Nie wysłano. Gdy będziesz gotowy, uruchom oddaj_zadanie(", nr, ") ponownie.")
        return(invisible(wynik$plik))
      }
    }
    problem <- wyslij_plik(wynik$plik, foldery[[klucz]], paste(autor$nazwisko, autor$imie))
    if (!is.null(problem)) {
      stop("Nie wysłano pliku: ", problem, ".\nPlik jest gotowy: ", wynik$plik, "\n",
           "Możesz go wgrać ręcznie: otwórz ", foldery[[klucz]], " i przeciągnij plik do okna przeglądarki.",
           call. = FALSE)
    }
    message("Oddano plik ", basename(wynik$plik), " do folderu „", nazwy_spotkan[[klucz]], "” (",
            format(Sys.time(), "%d.%m.%Y %H:%M"), ").\n",
            "Jeśli poprawisz pracę przed terminem, uruchom oddaj_zadanie(", nr, ") ponownie.")
    invisible(wynik$plik)
  }
})

przygotuj_latex()

message("Dane gotowe: ", nrow(zgloszenia), " fikcyjnych zgłoszeń w folderze ",
        normalizePath("dane", winslash = "/", mustWork = TRUE),
        if (interactive() && !latex_dostepny()) "\nUwaga: bez LaTeX-a nie powstanie PDF; oddaj_zadanie() wyśle wtedy wersję HTML.")
