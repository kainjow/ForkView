//
// Created by Kevin Wojniak on May 11, 2015.
// Copyright (c) 2015 Kevin Wojniak. All rights reserved.
//
// This is a tool that exports all color palettes in the OS.
// See "Inside Macintosh: Imaging With QuickDraw" for details.

#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>

#ifndef __i386__
#error "Must compile as 32-bit!"
#endif

int main (int argc, const char * argv[]) {
    // These were removed from the headers in 10.7, but are still in the framework
    extern CTabHandle GetCTable(short);
    extern void DisposeCTable(CTabHandle);
    
    FILE *f = fopen("palettes.htm", "w");
    fprintf(f, "<html><head><title>GetCTable</title><style>td {width: 50px; height: 50px; }</style></head><body>\n");
    short i = -32768;
    for (int n = 0; n < 65536; ++i, ++n) {
        CTabHandle t = GetCTable(i);
        if (t) {
            CTabPtr ptr = *t;
            const int sz = ptr->ctSize + 1;
            printf("let palette%d: [FVRGBColor] = [\n", i);
            fprintf(f, "<h1>[%d] %d</h1>\n", i, sz);
            fprintf(f, "<table>\n");
            for (int j = 0; j < sz; ++j) {
                const ColorSpec *s = &ptr->ctTable[j];
                if (j == 0 || (j % 16) == 0) {
                    if (n > 0) {
                        fprintf(f, "</tr>\n");
                    }
                    fprintf(f, "<tr>\n");
                }
                int r = (s->rgb.red / 65535.) * 255;
                int g = (s->rgb.green / 65535.) * 255;
                int b = (s->rgb.blue / 65535.) * 255;
                printf("    FVRGBColor(r: %d, g: %d, b: %d),\n", r, g, b);
                fprintf(f, "<td bgcolor=\"#%02X%02X%02X\"></td>\n", r, g, b);
            }
            printf("]\n");
            fprintf(f, "</tr></table>\n");
            DisposeCTable(t);
        }
    }
    fprintf(f, "</body></html>\n");
    fclose(f);
    return 0;
}
