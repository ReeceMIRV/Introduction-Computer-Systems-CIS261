#include <iostream>
#include <string>

#include "m13_externs.h"
#include "m13.h"

// returns unique code for arithmetic operators
int get_operator_code( char arithmetic_operator )
{
    switch( arithmetic_operator ) {
        case '+': return 0;
        case '-': return 1;
        case '*': return 2;
        case '/': return 3;
        case '%': return 4;
        case '=': return 5;
        default:
            return 6; // unknown operator
    }
}//::get_operator_code


// input: arithmetic_operator is '+' '-' '/' '%' and '='
void calculate( char arithmetic_operator, int right_operand ) {
    // call external procedure to do the calculation:
    int error_code = m13_calculate( get_operator_code( arithmetic_operator ), right_operand );
    if ( !error_code ) {
        // everything is good, show the result:
        std::cout << "\t= " << m13_left_operand << '\n';
    } else {
        std::cout << "\t(error code " << error_code << ")\n";
    }
}//::calculate


int process_input()
{
    int number;
    constexpr char Default_arithmetic_operator = '+';
    char arithmetic_operator = Default_arithmetic_operator;

    std::cout << m13_left_operand << arithmetic_operator << " "; // initial prompt
    for(;;) {
        
        char peek_char = std::cin.peek();
        if ( !std::cin ) {
            return 0;
        }
        if ( isspace( peek_char ) ) {
            std::cin.get(); // skip white space
            continue;
        }
        if ( isdigit( peek_char ) ) {
            std::cin >> number; // extract the whole numeric value
            calculate( arithmetic_operator, number );
            std::cout << m13_left_operand << arithmetic_operator << " "; // prompt for next command
            continue;
        } else {
            peek_char = std::cin.get(); // extract only one character
        }
        switch( peek_char ) {
        case '+':
        case '-':
        case '*':
        case '/':
        case '%':
        case '=':
            arithmetic_operator = peek_char;
            break;
        case ';':
            {
                std::string comment;
                std::getline( std::cin, comment );
                // ignore comment
                std::cout << m13_left_operand << arithmetic_operator << " "; // prompt for next command
            }
            break;
        case 'q':
        case 'Q':
            return 0;
        case '?':
            std::cout << "\tsyntax:\n\t\t+N -N *N /N %N =N ;comment\n\twhere N is an int.\n\tType \'quit\' to exit.\n";
            std::cout << m13_left_operand << arithmetic_operator << " "; // prompt for next command
            break;

        default:
            std::cout << "?"; // echo ignored characters as question marks
            break;
        }// switch arithmetic_operator

    }//forever
}//::process_input
