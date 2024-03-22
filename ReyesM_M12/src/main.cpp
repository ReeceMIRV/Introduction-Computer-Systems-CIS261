// http://www.cplusplus.com/reference/cstring/strncpy/

#include <cstring>

int main()
{
    char const* source = "hello";
    char destination[ 80 ] = { 0 };
    int str_len = strlen( source );
    strncpy( destination, source, str_len );
    return 0;
}

/*
00911759 8B 45 F4             mov         eax,dword ptr [source]  
0091175C 50                   push        eax  
0091175D E8 11 F9 FF FF       call        _strlen (0911073h)  
00911762 83 C4 04             add         esp,4  
00911765 89 45 90             mov         dword ptr [str_len],eax

00911768 8B F4                mov         esi,esp  
0091176A 8B 45 90             mov         eax,dword ptr [str_len]  
0091176D 50                   push        eax  
0091176E 8B 4D F4             mov         ecx,dword ptr [source]  
00911771 51                   push        ecx  
00911772 8D 55 9C             lea         edx,[destination]  
00911775 52                   push        edx  
00911776 FF 15 70 B1 91 00    call        dword ptr [__imp__strncpy (091B170h)]  
0091177C 83 C4 0C             add         esp,0Ch  


*/