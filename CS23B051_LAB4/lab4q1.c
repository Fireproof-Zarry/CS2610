#include <stdio.h>

extern char course_name[10]; // global variable for course name

char* getCourse(){
    return course_name;
}

void displayStudentProfile(char* course_name, char* first_name , char* last_name){
    printf("First Name: %s, Last Name: %s, Course: %s\n", first_name, last_name, course_name);
}

