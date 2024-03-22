// m13_externs.h

#ifndef M13_EXTERNS_H_INCLUDED_
#define M13_EXTERNS_H_INCLUDED_

#include <iostream>

extern "C" int m13_left_operand;
extern "C" int __stdcall m13_calculate( int arithmetic_command, int right_operand );    // Defined in m13_calculator.asm
extern "C" void __stdcall print_error( char const* error_msg );   // Defined in m13_externs.cpp

#endif // M13_EXTERNS_H_INCLUDED_
