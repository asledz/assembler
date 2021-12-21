/*
Anita Śledź 406384

Plik obsługujący
- główną część programu (funkcja main)
- czytania z pliku
    - czyta z podanego na wejście pliku
    - przepisuje bitmapę do char*
    - sprawdza formatowanie nagłówka pliku
- pisania do pliku
    - pisze do pliku grey.pgm
        - czyta z bitmapy po pierwszym bicie
        - pisze odpowiedni nagłówek

Używa funkcji changeColoring, która jest opisana w pliku coloring.s

Implementacja czytania obrazka .ppm korzystała z implementacji opisanej w pierwszej odpowiedzi na to pytanie: https://stackoverflow.com/questions/2693631/read-ppm-file-and-store-it-in-an-array-coded-with-c
*/

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

int RW, GW, BW;

extern void changeColoring (char* matrix, int width, int height);

int width, height;
char* readFile (char* filename) {    
    FILE *fptr;

    if ((fptr = fopen(filename, "r")) == NULL) {
        printf("Image file does not exist.\n");
        return NULL;
    }

    char identifier1, identifier2;
    fscanf (fptr, "%c%c", &identifier1, &identifier2);
    if (!(identifier1 == 'P' && (identifier2 == '3' || identifier2 == '6'))) {
        printf ("File has a wrong header. Are you sure it is a correct .ppm file?");
        return NULL;
    }

    // Ignore the comments
    char c;
    c = getc(fptr);
    if (c == '#') {
        while(getc(fptr) != '\n');
        c = getc(fptr);
    }
    ungetc(c, fptr);
    
    // Get width and height
    // int width, height;
    fscanf(fptr, "%d %d", &width, &height);

    // Ignore the comments
    c = getc(fptr);
    if (c == '#') {
        while(getc(fptr) != '\n');
        c = getc(fptr);
    }
    ungetc(c, fptr);

    // Get rgb component
    int rgb_component;
    fscanf(fptr, "%d", &rgb_component);

    // Malloc the image (characters)
    char *image = malloc (sizeof(char) * width * height * 3);
    
    int index = 0;
    unsigned int r, g, b;
    int i;
    for (i = 0; i < width * height; i++) {
        fscanf(fptr, "%u%u%u", &r, &g, &b);

        image[index] = (r);
        image[index+1] = (g);
        image[index+2] = (b);

        index += 3;
    }

    fclose(fptr);
    return image;
}

void writeFile (char *image, char *filename) {
    FILE *fp;
    int filenamesize = strlen(filename);
    filename[filenamesize-2] = 'g';

    fp = fopen (filename, "w");

    fprintf(fp, "P2\n%d %d\n255\n", width, height);
    int i, index = 0;
    for (i = 0; i < width * height; i++) {
        fprintf(fp, "%hhu", image[index]);
        if ((i+1) % width == 0) {
            fprintf(fp, "\n");
        } else {
            fprintf(fp, " ");
        }
        index += 3;
    }

    fclose(fp);
}

int main (int argc, char *argv[]) {
    if (argc != 2 && argc != 5) {
        printf("Incorrect number of arguments. Program only takes path to file as an argument.");
        return 0;
    }

    if (argc == 5 && (atoi(argv[2]) + atoi(argv[3]) + atoi(argv[4]) != 256)) {
        printf("Given weights are not correct - they should sum up to 256");
        return 0;
    } 
    
    /* weight: */
    if (argc == 5) {
        RW = atoi(argv[2]);
        GW = atoi(argv[3]);
        BW = atoi(argv[4]);
    } else {
        RW = 77;
        GW = 151;
        BW = 28;
    }

    /* Converting the file to char* */
    char* filename = argv[1];
    char *image = readFile(filename);
    if (image == NULL) {
        printf (" Processing image failed.\n");
        return 0;
    }

    changeColoring(image, width, height);
    writeFile(image, filename);
    return 0;
}