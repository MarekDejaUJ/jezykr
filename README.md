# Język R

Materiały do ćwiczeń prowadzonych przez dr. Marka Deję. Sylabus: `UJ.WZZINS.24.17358.26`, rok realizacji 2027/2028.

Strona kursu: <https://marekdejauj.github.io/jezykr/>

Program obejmuje **siedem spotkań po 90 minut i konsultacje projektu trwające 45 minut** — łącznie 15 godzin lekcyjnych. Spotkanie organizacyjne wprowadza R, środowisko pracy i asystenta w Microsoft Copilot Chat. Sześć kolejnych spotkań realizuje pozostałe treści sylabusa, w tym pracę z GitHub Copilot CLI na ostatnim spotkaniu roboczym.

## Praca na kursie

Instrukcje i szablony `.Rmd` są dostępne na stronie. Student pracuje w projekcie RStudio lub folderze Positrona i przekazuje **jeden uzupełniony plik `.Rmd`** przez zadanie MS Teams. Pierwszy blok szablonu pobiera wersjonowany skrypt inicjalizacyjny i odtwarza fikcyjne dane CSV oraz XLSX. Grupowy projekt ma osobny szablon; termin zostanie podany w MS Teams po ogłoszeniu harmonogramu sesji.

## Aktualizacja strony

Edytuj źródła w `site/`, a następnie uruchom z katalogu repozytorium:

~~~r
Rscript build.R
~~~

Skrypt tworzy szablony ćwiczeń z treści stron i renderuje stronę do `docs/`. GitHub Pages publikuje katalog `/docs` z gałęzi `main`. Potrzebne są pakiet `rmarkdown` i Pandoc, dostępny m.in. z RStudio lub Positronem.
