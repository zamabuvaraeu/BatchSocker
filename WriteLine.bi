#ifndef unicode
	#define unicode
#endif
#include once "windows.bi"

Const NewLineString = !"\r\n"

' Записывает строку в консоль или файл, если вывод перенаправлен
Declare Function WriteString(ByVal hOut As Handle, ByVal s As WString Ptr)As Integer
