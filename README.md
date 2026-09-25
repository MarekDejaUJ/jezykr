# Język R

Materiały do ćwiczeń prowadzonych przez dr. Marka Deję. Sylabus: `UJ.WZZINS.24.17358.26`, rok realizacji 2027/2028, 15 godzin ćwiczeń.

Strona kursu: <https://marekdejauj.github.io/jezykr/>

## Praca na kursie

Instrukcje i szablony `.Rmd` są dostępne na stronie. Każdy student tworzy na swoim komputerze projekt RStudio lub folder w Positronie, pobiera szablon spotkania i oddaje **jeden uzupełniony plik `.Rmd`** do zadania w MS Teams. Pierwszy blok kodu w szablonie pobiera skrypt inicjalizacyjny, instaluje brakujące pakiety i odtwarza dane ćwiczeniowe. Projekt grupowy ma odrębny szablon.

## Aktualizacja strony

Edytuj źródła w `site/`, następnie uruchom z katalogu repozytorium:

```r
Rscript build.R
```

Skrypt renderuje stronę R Markdown i kopiuje pliki do `docs/`. GitHub Pages należy ustawić na gałąź `main`, katalog `/docs`. Renderowanie wymaga pakietu `rmarkdown` oraz Pandoc (dostarczanego m.in. z RStudio). Pliki w `docs/` są publikowaną wersją strony.
