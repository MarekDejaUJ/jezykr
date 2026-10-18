# Język R

Materiały do ćwiczeń prowadzonych przez dr. Marka Deję. Sylabus: `UJ.WZZINS.24.17358.26`, rok realizacji 2027/2028.

Strona kursu: <https://marekdejauj.github.io/jezykr/>

Program obejmuje **siedem spotkań po 90 minut i konsultacje projektu trwające 45 minut** — łącznie 15 godzin lekcyjnych. Spotkanie organizacyjne wprowadza projekt R, R Markdown z wynikiem w PDF, typy i struktury danych oraz agenta Microsoft 365 Copilot. Sześć spotkań roboczych realizuje pozostałe treści sylabusa, a ostatnie obejmuje pracę z GitHub Copilot CLI.

## Praca na kursie

Każde spotkanie zaczyna się tak samo: projekt `jezykr`, skrypt startowy `init-v2.R` i szablon pobrany funkcją `pobierz_szablon()`. Skrypt ładuje pakiety (brakujące doinstalowuje), odtwarza identyczne fikcyjne dane CSV i XLSX oraz tworzy obiekty `zgloszenia` i `zgloszenia_analiza`, dlatego żadne spotkanie nie zależy od plików z poprzednich zajęć. Po spotkaniu student oddaje **jeden plik PDF** poleceniem `oddaj_zadanie(numer)` ze skryptu startowego: funkcja sprawdza szablon, renderuje go w nowej sesji R i wysyła `nazwisko_imie_NN.pdf` do folderu spotkania na nc.uj.edu.pl (udostępnienie „File drop”, bez logowania, bez podglądu cudzych plików; ponowne oddanie dodaje nową wersję obok poprzedniej). Adresy siedmiu folderów są zapisane w `site/materialy/init-v2.R`; po wygaśnięciu udziału w Nextcloud funkcja informuje studenta, że folder nie przyjmuje już plików. Projekt grupowy zespół oddaje w MS Teams jako **PDF oraz `.Rmd`**; termin zostanie podany w MS Teams po ogłoszeniu harmonogramu sesji.

Skrypt startowy przygotowuje całe środowisko: przy pierwszym uruchomieniu instaluje brakujące pakiety R razem z zależnościami (`dplyr`, `tidyr`, `ggplot2`, `readxl`, `writexl`, `rmarkdown`, `knitr`, `dlookr`, `explore`, `ggstatsplot`, `effectsize`, `report`, `parameters`, `tinytex`, `curl`, `rstudioapi`; zależności, m.in. `shiny`, dochodzą same), a w sesji interaktywnej bez LaTeX-a instaluje TinyTeX z pakietami `babel-polish`, `hyphen-polish`, `fvextra` i `xurl`. Funkcja `sprawdz_srodowisko()` wypisuje listę kontrolną. W pracowni te same elementy powinny być zainstalowane systemowo (poza profilem użytkownika), bo profile są czyszczone; wtedy skrypt niczego nie instaluje.

Każde spotkanie robocze ma pięć ćwiczeń z prowadzącym i trzy zadania samodzielne. Zadania używają wyłącznie funkcji wprowadzonych w ćwiczeniach tego lub wcześniejszych spotkań.

## Aktualizacja strony

Edytuj źródła w `site/`, a następnie uruchom z katalogu repozytorium:

~~~r
Rscript build.R
~~~

Skrypt tworzy szablony spotkań `site/materialy/szablon-00.Rmd`–`szablon-06.Rmd` z nagłówków ćwiczeń i poleceń na stronach, a następnie renderuje stronę do `docs/`. GitHub Pages publikuje katalog `/docs` z gałęzi `main`. Potrzebne są pakiet `rmarkdown` i Pandoc, dostępny m.in. z RStudio lub Positronem. Szablon projektu `szablon-projekt.Rmd` jest edytowany ręcznie.
