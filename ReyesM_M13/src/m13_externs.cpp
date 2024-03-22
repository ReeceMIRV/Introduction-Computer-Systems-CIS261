// m13_externs.cpp

#include <iostream>
#include "m13_externs.h"

// Define global variable with external linkage:
int m13_left_operand = 0;

// Define global function
extern "C" void __stdcall print_error( char const* error_msg )
{
    std::cerr << error_msg;
}
