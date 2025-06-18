#include <stdio.h>

extern char* rev_str;
extern int reverse(char* c); 

int main(){
    char str[20] = "hello";
    int l;

    l = reverse(str);
    printf("%s\n", rev_str);
    return 0;
}