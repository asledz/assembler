#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

extern void start (int szer, int wys, float *M, float C, float waga);
extern void place (int ile, int x[], int y[], float temp[]);
extern void step ();

struct Map {
    float *map;
    bool *heaters;
    float *map_akt;
} map;

void showMap (struct Map * m, int wysokosc, int szerokosc) {
    for (int i = 1; i <= wysokosc; i++) {
        for (int j = 1; j <= szerokosc; j++ ) {
            printf("%f  ", m->map[ i * (szerokosc + 2) +j ]);
        }
        printf ("\n");
    }
}

int main (int argc, char *argv[]) {

    if(argc != 4) {
        printf("Incorrect number of arguments on command line :(\n");
        return 0;
    }

    FILE *fptr;
    if ((fptr = fopen(argv[1], "r")) == NULL) {
        printf("Testing file does not exist.\n");
        return 0;
    }

    float coef = atof(argv[2]);
    int kroki = atoi(argv[3]);

    int wysokosc, szerokosc;
    float temperatura;

    fscanf(fptr, "%d", &wysokosc);
    fscanf(fptr, "%d", &szerokosc);
    fscanf(fptr, "%f", &temperatura);

    struct Map *myMap;
    myMap = malloc(sizeof(struct Map));
    myMap->map = malloc(sizeof(float) * (wysokosc + 2) * (szerokosc + 2));
    myMap->map_akt = malloc(sizeof(float) * (wysokosc + 2) * (szerokosc + 2));
    myMap->heaters = malloc(sizeof(bool) * (wysokosc + 2) * (szerokosc + 2));
    
    for (int i = 1; i <= wysokosc; i++) {
        for (int j = 1; j <= szerokosc; j++ ) {
            fscanf(fptr, "%f", &(myMap->map[i * (szerokosc + 2) + j]));
        }
    }

    int ogrzewacze;
    fscanf(fptr, "%d", &ogrzewacze);

    int *x, *y;
    float *temp;
    x = malloc(sizeof(int) * ogrzewacze);
    y = malloc(sizeof(int) * ogrzewacze);
    temp = malloc(sizeof(float) * ogrzewacze);

    for (int i = 0; i < ogrzewacze; i++) {
        fscanf(fptr, "%d", &(x[i]));
        fscanf(fptr, "%d", &(y[i]));
        fscanf(fptr, "%f", &(temp[i]));
    }

    fclose(fptr);

    start (wysokosc, szerokosc, (float *)(myMap), temperatura, coef);
    place (ogrzewacze, x, y, temp);

    printf("Stan przed symulacją:\n");
    showMap (myMap, wysokosc, szerokosc);
    printf("\n");

    for(int i = 0; i < kroki; i++){
        printf("Krok nr. %d\n", i+1);

        step();
        showMap (myMap, wysokosc, szerokosc);
        
        char c;
        scanf("%c", &c);
    }


    free(x);
    free(y);
    free(temp);

    free(myMap->map); 
    free(myMap->map_akt);
    free(myMap->heaters);

    free(myMap);
    return 0;
    
}


