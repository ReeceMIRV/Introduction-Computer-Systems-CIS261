// CIS-261 final poject: "Running Total" calculator

#include <iostream>
#include <cstdlib>

#include "m13.h"

int main()
{
    std::cout << "Type ? for help\n";
    int result = process_input();
    std::cout << "\n";
    system( "pause" );
    std::cout << "Good bye!\n";
    return result;
}
