#ifndef unicode
	#define unicode
#endif
#include once "Network.bi"

Sub CloseSocketConnection(ByVal mSock As SOCKET)
	Shutdown(mSock, 2)
	closesocket(mSock)
End Sub

Function ResolveHost(ByVal sServer As WString Ptr, ByVal ServiceName As WString Ptr)As addrinfoW Ptr
	Dim hints As addrinfoW
	' Если стоит AF_UNSPEC, то неважно, IPv4 или IPv6
	hints.ai_family = AF_UNSPEC ' AF_INET или AF_INET6
	hints.ai_socktype = SOCK_STREAM
	hints.ai_protocol = IPPROTO_TCP
	
	Dim pResult As addrinfoW Ptr = 0
	If GetAddrInfoW(sServer, ServiceName, @hints, @pResult) = 0 Then
		Return pResult
	End If
	Return 0
End Function

Function CreateSocketAndBind(ByVal sServer As WString Ptr, ByVal ServiceName As WString Ptr)As SOCKET
	' Открыть сокет
	Dim iSocket As SOCKET = socket_(AF_UNSPEC, SOCK_STREAM, IPPROTO_TCP)
	If iSocket <> INVALID_SOCKET Then
		' Привязать адрес к сокету
		Dim localIpList As addrinfoW Ptr = ResolveHost(sServer, ServiceName)
		If localIpList <> 0 Then
			' Обойти список адресов и сделать привязку
			Dim pPtr As addrinfoW Ptr = localIpList
			Dim BindResult As Integer = Any
			Do
				BindResult = bind(iSocket, Cast(LPSOCKADDR, pPtr->ai_addr), pPtr->ai_addrlen)
				If BindResult = 0 Then
					' Привязано
					Exit Do
				End If
				pPtr = pPtr->ai_next
			Loop Until pPtr = 0
			' Очистка
			FreeAddrInfoW(localIpList)
			' Привязались к адресу
			If BindResult = 0 Then
				Return iSocket
			End If
		End If
		CloseSocketConnection(iSocket)
	End If
	Return INVALID_SOCKET
End Function

Function ConnectToServer(ByVal sServer As WString Ptr, ByVal ServiceName As WString Ptr, ByVal localServer As WString Ptr, ByVal LocalServiceName As WString Ptr)As SOCKET
	' Открыть сокет
	Dim iSocket As SOCKET = CreateSocketAndBind(localServer, LocalServiceName)
	If iSocket <> INVALID_SOCKET Then
		' Привязать адрес к сокету
		Dim localIpList As addrinfoW Ptr = ResolveHost(sServer, ServiceName)
		If localIpList <> 0 Then
			' Обойти список адресов и сделать привязку
			Dim pPtr As addrinfoW Ptr = localIpList
			Dim ConnectResult As Integer = Any
			Do
				ConnectResult = connect(iSocket, Cast(LPSOCKADDR, pPtr->ai_addr), pPtr->ai_addrlen)
				If ConnectResult = 0 Then
					' Соединено
					Exit Do
				End If
				pPtr = pPtr->ai_next
			Loop Until pPtr = 0
			' Очистка
			FreeAddrInfoW(localIpList)
			' Соединение установлено
			If ConnectResult = 0 Then
				Return iSocket
			End If
		End If
		CloseSocketConnection(iSocket)
	End If
	Return INVALID_SOCKET
End Function
