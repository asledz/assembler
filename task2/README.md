# Opis rozwiązania:

1. Główna część zadania - funkcja changeColoring:
    - zaimplementowana w coloring.s
    - działanie opisane w nagłówku pliku
2. "Wrapper" w C :
    - funkcja main, pobierająca argumenty
    - funkcja readFile - czytająca z pliku
    - funkcja writeFile - pisząca do pliku
    - działanie opisane w nagłówku pliku

# Uruchamianie rozwiązania:

w folderze z plikami coloring.s, coloring-main.c oraz Makefile należy:

1. wykonać formułę 'make' - tworzy plik wykonywalny coloring

2. Wykonać plik wykonywalny ./coloring:
    - ./coloring <sciezka/do/pliku.ppm> 
    - ./coloring <sciezka/do/pliku.ppm> <waga_skladowa_R> <waga_skladowa_G> <waga_skladowa_B>

Stworzy to plik:
sciezka/do/pliku.pgm 
