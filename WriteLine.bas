#include once "WriteLine.bi"

Function WriteString(ByVal hOut As Handle, ByVal s As WString Ptr)As Integer
	Dim intLength As DWORD = lstrlen(s)
	
	' Количество символов, выведенных на консоль или записанных в файл
	Dim CharsCount As DWORD = Any
	
	If WriteConsole(hOut, s, intLength, @CharsCount, 0) = 0 Then
		' Возможно, вывод перенаправлен, нужно записать в файл
		WriteFile(hOut, s, intLength * SizeOf(WString), @CharsCount, 0)
		
		Return CharsCount \ SizeOf(WString)
	Else
		Return CharsCount
	End If
	
End Function
