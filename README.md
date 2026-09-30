# Język R

Materiały do ćwiczeń prowadzonych przez dr. Marka Deję. Sylabus: `UJ.WZZINS.24.17358.26`, rok realizacji 2027/2028.

Strona kursu: <https://marekdejauj.github.io/jezykr/>

Program obejmuje **siedem spotkań po 90 minut i konsultacje projektu trwające 45 minut** — łącznie 15 godzin lekcyjnych. Spotkanie organizacyjne wprowadza projekt R, R Markdown z wynikiem w PDF, typy i struktury danych oraz agenta Microsoft 365 Copilot. Sześć spotkań roboczych realizuje pozostałe treści sylabusa; każde ma pięć ćwiczeń z prowadzącym i trzy zadania samodzielne, a ostatnie obejmuje pracę z GitHub Copilot CLI.

## Praca na kursie

Każde spotkanie zaczyna się tak samo: projekt `jezykr`, skrypt startowy `init-v2.R` i szablon pobrany funkcją `pobierz_szablon()`. Skrypt ładuje pakiety (brakujące doinstalowuje), odtwarza identyczne fikcyjne dane CSV i XLSX oraz tworzy obiekty `zgloszenia` i `zgloszenia_analiza`, dlatego żadne spotkanie nie zależy od plików z poprzednich zajęć. Po spotkaniu student przekazuje w MS Teams **jeden plik PDF** wyrenderowany z szablonu. Projekt grupowy zespół oddaje jako **PDF oraz `.Rmd`**; termin zostanie podany w MS Teams po ogłoszeniu harmonogramu sesji.

W pracowni powinny być zainstalowane na stałe: R, RStudio lub Positron, pakiety `dplyr`, `tidyr`, `ggplot2`, `readxl`, `writexl`, `rmarkdown`, `dlookr`, `explore`, `ggstatsplot`, `effectsize`, `report` oraz TinyTeX. Domyślna instalacja TinyTeX nie zawiera czterech pakietów LaTeX używanych przez szablony; w pracowni należy je doinstalować raz: `tinytex::tlmgr_install(c("babel-polish", "hyphen-polish", "fvextra", "xurl"))`. Na komputerach z dostępem do internetu TinyTeX doinstaluje je sam przy pierwszym renderowaniu.

## Aktualizacja strony

Edytuj źródła w `site/`, a następnie uruchom z katalogu repozytorium:

~~~r
Rscript build.R
~~~

Skrypt tworzy szablony spotkań `site/materialy/szablon-00.Rmd`–`szablon-06.Rmd` z nagłówków ćwiczeń i poleceń na stronach, a następnie renderuje stronę do `docs/`. GitHub Pages publikuje katalog `/docs` z gałęzi `main`. Potrzebne są pakiet `rmarkdown` i Pandoc, dostępny m.in. z RStudio lub Positronem. Szablon projektu `szablon-projekt.Rmd` jest edytowany ręcznie.
