#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Nikolay (yande9@yandex.ru)

 ������ �������:
	"�������" ��� Warface
 ������������� ���������� ������: 1024 X 768
 �opyright 2014

#ce ----------------------------------------------------------------------------


#include <Date.au3>
#Include <ScreenCapture.au3>
#include <File.au3>


#cs===============================================================================
;��������� ������� �� ���������
#ce===============================================================================
Global $WF_accounts_file = "������_�������.txt"               ; ��� ����� � �������� �������
Global $WF_accounts_file_delimiter = " "                     ; ����������� ���������� ������� �������
Global $WF_period = 24*60*60                                 ; ������ ������� "�������"
Global $WF_interval = 15*60                                  ; ����� "�������" (����������) � ���� � �������������
Global $WF_try_count = 3                                     ; ����� ������� ��������� ����
Global $WF_Enable_ScreenShot = True                          ; ��������� ������ ���������
Global $WF_Enable_ScreenShot_in_GameCenter = True            ; ��������� ������ ��������� � ������� ������ mail.ru
Global $WF_LogItemFolder  = "���������_����������_���������" ; ����� ��� ���������� (����������) ���������� ���������
Global $WF_LogErrorFolder = "���������_����������_���������" ; ����� ��� ���������� ������, ���� ���� �� ������� ��������� ������ (��� ����� � ���� �����)
;=================================================================================
Global $WF_number_of_players = 1 ; ����� �������, �� ������� ���� ��������.
Global $WF_popravka = 60*2      ; �������� (����� ��� ����� � ������ �� ����) ��� ������� �������, ����� �������� ����� ����� ��������.


; ������ ������������ ���������, ��� javascript. $msg - ����� ���������
Func alert($msg)
   MsgBox(0, "", $msg, 5)
EndFunc

; �������: �������� � ����. ��������������� �������, ��������� �� ������ ���� � �� �� 2 ������� (Sleep � MouseClick)
; $x - ���������� ���� �� ����������� � ��������
; $y - ���������� ���� �� ��������� � ��������
; $sleepInterval - �������� �������� ����� ������
; $notificationText - �����, ������� ����� ������������� � ����. �� ���������, ����� �������� ������������, ��� �� ������ ������ ������������
; $clickCount - ������� ����� ��� ��������� ��� �������� (�� ��������� - 1 ���)
Func SleepAndClick($x, $y, $sleepInterval, $notificationText, $clickCount=1)
   Local $i
   TrayTip("����������� ��������:", $notificationText, $sleepInterval)
   For $i=1 To $clickCount
	  Sleep($sleepInterval)
	  MouseClick("left", $x, $y, $clickCount)
   Next

EndFunc


; ��������� ������� Game.exe (���������, ���� �� ������� ������� ���� �����)
;Function Name: Kill Proc
;Written By: Amin Babaeipanah
;Usage: _killProc('notepad.exe')
Func _killProc($sPID)
    If IsString($sPID) Then $sPID = ProcessExists($sPID)
    If Not $sPID Then Return SetError(1, 0, 0)
    Return Run(@ComSpec & " /c taskkill /F /PID " & $sPID & " /T", @SystemDir, @SW_HIDE)
EndFunc


; �������� (������) ������ (��������� ��� ��������� � �������), ����� ���������, ��� "�������" � ���� ������ ������� � ����� ������� �������
; $label - ��� ������� ��� ����� ���������, ����� �����, ��� ��� ��������
; $folder - �����, � ������� ������ ��������
Func Screen_Shoot($folder="", $label="")
   Local $asTimePart[4], $asDatePart[4]
   _DateTimeSplit(_NowCalc(), $asDatePart, $asTimePart)
   MouseClick("left", 1, $asTimePart[3]) ; ������� ���������� ������ ����� ����������
   Sleep(1000)                           ; ��� 1 �������,  ���� �� "���������" ���������
   if ($WF_Enable_ScreenShot_in_GameCenter == True) Then Send("{CTRLDOWN}{ALTDOWN}{F3}{CTRLUP}{ALTUP}")
   if ($WF_Enable_ScreenShot) Then _ScreenCapture_Capture($folder&"\"&$label&"_"&$asDatePart[1]&"-"&$asDatePart[2]&"-"&$asDatePart[3]&"_"&$asTimePart[1]&"-"&$asTimePart[2]&"-"&$asTimePart[3]&".jpg")
EndFunc


; ����������, ��� ������ ���� ������ ��������
Func Launch_Warface_Error()
   TrayTip("������:", "����! �� ������� ��������� ����. ��, ��� ������ ��������!", 3, 3)
   Sleep(3000)
   _killProc("GameCenter@Mail.Ru.exe")
EndFunc

; ��������� Warface
Func Launch_Warface()
   Local $pos[4]
   TrayTip("����������� ��������:", "�������� Warface", 3000)
   if (WinWaitActive("����� �������", "", 5) == 0) Then
	  Launch_Warface_Error()
	  Return False
   EndIf
   WinActive("����� �������")
   $pos = WinGetPos("����� �������")
   Sleep(1000)
   SleepAndClick($pos[0] + 200, $pos[1] + 60, 2000, "����� �������: �����", 2)

   ; �������� ������ �� �������� ����, ���� ���, �� ������� ����� ����������� ������
   Sleep(5000)
   if (ProcessExists("Game.exe") == 0) Then
	  Launch_Warface_Error()
	  Return False
   EndIf
   Return True
EndFunc


; ����� �� Warface
; $label - ��� ������
Func Stop_Warface($label="")
   Local $pos[4]
   $pos = WinGetPos("Warface")
   SleepAndClick($pos[2] - $pos[0] - 472, $pos[1] + 640, 3000, '�������� ���������� �������')
   SleepAndClick($pos[2] - $pos[0] - 852, $pos[1] + 480, 3000, '��� ������ "������ PVE-������"')
   SleepAndClick($pos[2] - $pos[0] - 492, $pos[1] + 640, 1000, '�������� ������� 7 ���, � �������� ����� ���� �������� (�.�. ��������� ����� ���� �� 7 ���� �����)', 7)
   SleepAndClick($pos[2] - $pos[0] - 55, $pos[1] + 20, 3000, '��� ������ "�����"')
   SleepAndClick($pos[2] - $pos[0] - 672, $pos[1] + 430, 3000, '����������� "�����"')
   Sleep(5000)

   ; ������������� �������� �������, ���� ���� ��� ��� �� ���������
   if ProcessExists("Game.exe") Then
	  TrayTip("������", "Warface ��� ��� �� ������. ����� �������� � ������������� �������� ������� Game.exe.", 5000, 3)
	  Screen_Shoot($WF_LogErrorFolder, "Error_"&$label)
	  Sleep(1000)
	  _killProc("Game.exe")
   EndIf
EndFunc


; ������ ����� � �������� ������� ("��� ������" ��� ������ � ������, "��� ������������", "������")
; ����� ��������� ������� ����� �������� �� ����� ���� �� ���������� �������� � ���� "������_�_����.txt"
; ���� ������� ������ ����� ������ � ��������� ������������������: "��� ������", "��� ������������", "������"
; ������� ������ ������� ������ ������������ � ����� ������, ��������:

;���� ������������������ ���������
;���� ��������������� ������
;����� supergirl@mail.ru 123

; $file_name - ��� �����, �� �������� ������ ������� ������
; $delimiter - ����������� ���������� ������� ������� (�� ��������� - ������)
; $label     - ��� ������
; $username  - ��� ������������
; $password  - ������
Func Read_Passwords($file_name, $delimiter, ByRef $labels, ByRef $usernames, ByRef $passwords)
   Local $i = 0
   Local $line
   Local $account_data[10]
   Local $count = -1
   FileOpen($file_name, 0)
   For $i = 1 to _FileCountLines($file_name)
	  $line = FileReadLine($file_name, $i)
	  if (StringLen($line) = 0) Then ContinueLoop        ; ���� ������ ������, �� ��������� ��
	  if (StringLeft($line, 1) = ';') Then ContinueLoop  ; ���� ��� ������ - ����������� (������ ������ ������ ";"), �� ��������� ��� ������
	  if (StringLeft($line, 2) = '//') Then ContinueLoop ; ���� ��� ������ - ����������� (������ ��� ������� "//" ), �� ��������� ��� ������
	  $count = $count + 1

	  $account_data = StringSplit($line&" "&" ", $delimiter)
	  ; ������ ����������� �������, ����� �� ���� ������ ������ � ����, ��������� "��� ������" �������� ��������� �����
	  $labels[$count] = StringRegExpReplace($account_data[1], "(?i)[^a-z0-9�-��-�\s]", "")
	  $usernames[$count] = $account_data[2]
	  $passwords[$count] = $account_data[3]
   Next
   FileClose($file_name)
   if ($i < 2) Then Return False ; ���� ���� ������, �� ��������� "����", ����� �� ������ �����������

   ; ����� ����� �������, �� ������� ����� ��������
   $WF_number_of_players = $count

   Return True
EndFunc

; ���������� "��������" (���� ���). �.�. ����� �������� ���: ��������� Warface, ��������� 15 ���, ������� �������� ��� �������, ����� �� ����
; $label - ��� ������
; $interval - �������� � ��������, ������� ����� �������� �� ������� ������
Func Poviset($label, $interval)
   ; ���� �� ������� ��������� ����, �� �������� ������� ����� mail.ru
   if (Launch_Warface() == False) Then Return False
   TrayTip("����������� ��������:", "��� " & Round($interval/(60)) & " ���.", $interval)
   Sleep($interval*1000)
   TrayTip("����������� ��������:", "����� �������� ����������� ��������, ����� ���������, ��� ��� ������ �������.", 10)
   Screen_Shoot($WF_LogItemFolder, $label)
   Stop_Warface($label)
   Return True
EndFunc


; �������������� (������ "������ ��� ������ �������")
; $label    - ��� ������
; $username - ��� ������������
; $password - ������
Func Auth($label, $username, $password)
   TrayTip("����������� ��������:", "����������� ��� ������: " & $label, 3000)
   ;ShellExecute("WarfaceLoader.exe")
   ShellExecute("mailrugames://play/0.1177") ; ������ Warface ����� url
   ; ������ "������ ��� ������ ������
   WinWaitActive('������� �����@Mail.Ru')
   WinActivate("������� �����@Mail.Ru")
   $pos = WinGetPos('������� �����@Mail.Ru')
   Sleep(10000)
   SleepAndClick($pos[2] - $pos[0] - 150, $pos[1] + 185, 1000, "������: ������ ��� ������ �������")
   ; ����� ��� ������������ � ������
   if (WinWaitActive('�����������', "", 5) = 0) Then
	  if (WinWaitActive('��������� ������', "", 5) = 0) Then
		 SleepAndClick($pos[2] - $pos[0] - 150, $pos[1] + 135, 1000, "������, ����� �� �����������. ������: ������")
	  EndIf
   EndIf
   Sleep(1000)
   Send($username & '{Tab}' & $password)
   Sleep(500)
   Send("{ENTER}")
   Sleep(3000)
EndFunc


; �������������� � �������� �� �������
Func Auth_and_Poviset()
   Local $labels[1000], $usernames[1000], $passwords[1000], $key, $result, $label, $poviset_result, $try_count

   ; ���� ��� ������� ������ � ����� "������_�_����.txt", �� ������� "�������" ��� ����������� � ������
   $result = Read_Passwords($WF_accounts_file, $WF_accounts_file_delimiter, $labels, $usernames, $passwords)
   if ($result == False) Then
	  TrayTip("��������������:", "��� ����� "&$WF_accounts_file&". �������� ���� ��� �����������.", 10)
	  Poviset("", $WF_interval)
	  Return
   EndIf

   ; ����� ���� "������" �� �������
   $key = -1
   For $label In $labels
	  $key = $key + 1
	  if ($labels[$key] == "") Then ContinueLoop

	  ; ���� �������� ������, ���� �� ����� ������� ������� ��� ����� ������� �������� ������������ �����
	  $try_count = 0
	  $poviset_result = False
	  While ($poviset_result == False)
		 Auth($labels[$key], $usernames[$key], $passwords[$key])
		 $poviset_result = Poviset($labels[$key], $WF_interval)
		 $try_count = $try_count + 1
		 if ($try_count > $WF_try_count) Then
			TrayTip("�����", "� ������ "&$WF_try_count&" ������� � �� ���� ����� � ����, ������, ����� ����������. ���! ������������ � ����������� ������", 3000, 3)
			Sleep(3000)
			Screen_Shoot($WF_LogErrorFolder, "Error_"&$labels[$key])
			ExitLoop
		 EndIf
	  WEnd
   Next
EndFunc


; ������������� ����������� ������ �������� �������. � ������ ������: ������ - 1 ����, ������� - ������� ��� Warface
; $period - ������ ������� ������� (� ��������)
; $cycle_func - �������, ������� ����� �������� ����� �������� ������
; ������: Schedule(4, "Auth_and_Poviset") - �������� Auth_and_Poviset() ������ 4 �������
; ��������������� ���� ����� ����������, �� ������.

#cs

Func Schedule($period, $cycle_func)
   Local $newTime = _NowCalc(), $asDatePart[4], $asTimePart[4]
   While (True)
	  If (_NowCalc() > $newTime) Then
		 $newTime = _DateAdd('s', $period, $newTime)
		 _DateTimeSplit($newTime, $asDatePart, $asTimePart)
		 Sleep(1000)
		 Call($cycle_func)
		 TrayTip("��������� ����� �:", $asTimePart[1]&":"&$asTimePart[2], $period)
	  EndIf
	  Sleep(1000)
   WEnd
EndFunc
#ce

Func Schedule($period, $cycle_func)
	Local $now = _NowCalc(), $interval_posle_viseniya, $datetime, $asDatePart[10], $asTimePart[10]

	While (True)
		$interval_posle_viseniya = $WF_period - ($WF_interval * $WF_number_of_players + $WF_popravka)
		Call($cycle_func)
		$datetime = _DateAdd('s', $interval_posle_viseniya, _NowCalc())
		_DateTimeSplit($datetime, $asDatePart, $asTimePart)
		TrayTip("��������� ����� �:", $asTimePart[1]&":"&$asTimePart[2], $interval_posle_viseniya-10)
		Sleep($interval_posle_viseniya*1000);
	WEnd
EndFunc


; �������� �������
Func WF_viselka()
	if $WF_period < ($WF_interval * $WF_number_of_players + $WF_popravka) Then
		TrayTip("������", "��������� ������ �������, �� ������ ��������� �������.", 10)
		Sleep(10*1000)
		Return
	EndIf
   Schedule($WF_period, 'Auth_and_Poviset')
EndFunc



