#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         Nikolay (yande9@yandex.ru)

 Задача скрипта:
	"Виселка" для Warface
 Рекомендуемое разрешение экрана: 1024 X 768
 Сopyright 2014

#ce ----------------------------------------------------------------------------


#include <Date.au3>
#Include <ScreenCapture.au3>
#include <File.au3>


#cs===============================================================================
;Настройки виселки по умолчанию
#ce===============================================================================
Global $WF_accounts_file = "Пароли_игроков.txt"               ; Имя файла с учетными данными
Global $WF_accounts_file_delimiter = " "                     ; Разделитель параметров учетных записей
Global $WF_period = 24*60*60                                 ; Период запуска "Виселки"
Global $WF_interval = 15*60                                  ; Время "висения" (нахождения) в игре в миллисекундах
Global $WF_try_count = 3                                     ; Число попыток запустить игру
Global $WF_Enable_ScreenShot = True                          ; Разрешить делать скриншоты
Global $WF_Enable_ScreenShot_in_GameCenter = True            ; Разрешить делать скриншоты в игровом центре mail.ru
Global $WF_LogItemFolder  = "Скриншоты_полученных_предметов" ; Папка для скриншотов (фотографий) полученных предметов
Global $WF_LogErrorFolder = "Скриншоты_полученных_предметов" ; Папка для скриншотов ошибок, если игру не удалось завершить мышкой (все пихаю в одну папку)
;=================================================================================
Global $WF_number_of_players = 1 ; Число игроков, за которых надо повисеть.
Global $WF_popravka = 60*2      ; Поправка (время для входа и выхода из игры) для расчета времени, после которого нужно снова повисеть.


; Аналог всплывающего сообщения, как javascript. $msg - текст сообщения
Func alert($msg)
   MsgBox(0, "", $msg, 5)
EndFunc

; Функция: задержка и клик. Вспомогательная функция, позволяет не писать одни и те же 2 строчки (Sleep и MouseClick)
; $x - координата мыши по горизонтали в пикселях
; $y - координата мыши по вертикали в пикселях
; $sleepInterval - интервал задержки перед кликом
; $notificationText - Текст, который будет высвечиваться в трее. Он необходим, чтобы говорить пользователю, что на данный момент выполнятется
; $clickCount - сколько число раз повторить это действие (по умолчанию - 1 раз)
Func SleepAndClick($x, $y, $sleepInterval, $notificationText, $clickCount=1)
   Local $i
   TrayTip("Выполняется операция:", $notificationText, $sleepInterval)
   For $i=1 To $clickCount
	  Sleep($sleepInterval)
	  MouseClick("left", $x, $y, $clickCount)
   Next

EndFunc


; Завершить процесс Game.exe (необходим, если не удалось закрыть игру мышью)
;Function Name: Kill Proc
;Written By: Amin Babaeipanah
;Usage: _killProc('notepad.exe')
Func _killProc($sPID)
    If IsString($sPID) Then $sPID = ProcessExists($sPID)
    If Not $sPID Then Return SetError(1, 0, 0)
    Return Run(@ComSpec & " /c taskkill /F /PID " & $sPID & " /T", @SystemDir, @SW_HIDE)
EndFunc


; Скриншот (захват) экрана (необходим для просмотра в журнале), чтобы убедиться, что "висение" в игре прошло успешно и игрок получил предмет
; $label - это префикс для файла скриншота, чтобы знать, чей это скриншот
; $folder - папка, в которую делать скриншот
Func Screen_Shoot($folder="", $label="")
   Local $asTimePart[4], $asDatePart[4]
   _DateTimeSplit(_NowCalc(), $asDatePart, $asTimePart)
   MouseClick("left", 1, $asTimePart[3]) ; Пытаюсь пошевелить мышкой перед скриншотом
   Sleep(1000)                           ; Жду 1 секунду,  пока не "проснется" компьютер
   if ($WF_Enable_ScreenShot_in_GameCenter == True) Then Send("{CTRLDOWN}{ALTDOWN}{F3}{CTRLUP}{ALTUP}")
   if ($WF_Enable_ScreenShot) Then _ScreenCapture_Capture($folder&"\"&$label&"_"&$asDatePart[1]&"-"&$asDatePart[2]&"-"&$asDatePart[3]&"_"&$asTimePart[1]&"-"&$asTimePart[2]&"-"&$asTimePart[3]&".jpg")
EndFunc


; Оповестить, что запуск игры прошел неудачно
Func Launch_Warface_Error()
   TrayTip("Ошибка:", "Черт! Не удалось запустить игру. ОК, щас заново попробую!", 3, 3)
   Sleep(3000)
   _killProc("GameCenter@Mail.Ru.exe")
EndFunc

; Запустить Warface
Func Launch_Warface()
   Local $pos[4]
   TrayTip("Выполняется операция:", "Запускаю Warface", 3000)
   if (WinWaitActive("Выбор сервера", "", 5) == 0) Then
	  Launch_Warface_Error()
	  Return False
   EndIf
   WinActive("Выбор сервера")
   $pos = WinGetPos("Выбор сервера")
   Sleep(1000)
   SleepAndClick($pos[0] + 200, $pos[1] + 60, 2000, "Выбор сервера: Альфа", 2)

   ; Проверяю удачно ли запущена игра, если нет, то процесс будет повторяться заново
   Sleep(5000)
   if (ProcessExists("Game.exe") == 0) Then
	  Launch_Warface_Error()
	  Return False
   EndIf
   Return True
EndFunc


; Выход из Warface
; $label - имя игрока
Func Stop_Warface($label="")
   Local $pos[4]
   $pos = WinGetPos("Warface")
   SleepAndClick($pos[2] - $pos[0] - 472, $pos[1] + 640, 3000, 'Закрываю полученный предмет')
   SleepAndClick($pos[2] - $pos[0] - 852, $pos[1] + 480, 3000, 'Жму кнопку "Список PVE-миссий"')
   SleepAndClick($pos[2] - $pos[0] - 492, $pos[1] + 640, 1000, 'Закрываю предмет 7 раз, у которого истек срок действия (т.к. предметов может быть до 7 штук сразу)', 7)
   SleepAndClick($pos[2] - $pos[0] - 55, $pos[1] + 20, 3000, 'Жму кнопку "Выход"')
   SleepAndClick($pos[2] - $pos[0] - 672, $pos[1] + 430, 3000, 'Подтверждаю "Выход"')
   Sleep(5000)

   ; Принудительно завершаю процесс, если игра все еще не завершена
   if ProcessExists("Game.exe") Then
	  TrayTip("Ошибка", "Warface все еще не закрыт. Делаю скриншот и принудительно завершаю процесс Game.exe.", 5000, 3)
	  Screen_Shoot($WF_LogErrorFolder, "Error_"&$label)
	  Sleep(1000)
	  _killProc("Game.exe")
   EndIf
EndFunc


; Чтение файла с учетными данными ("Имя игрока" для записи в журнал, "Имя пользователя", "Пароль")
; Чтобы несколько игроков могли повисеть на одной игре им необходимо написать в файл "Пароли_к_игре.txt"
; свои учетные данные через пробел в следующей последовательности: "Имя игрока", "Имя пользователя", "Пароль"
; учетные данные каждого игрока записываются с новой строки, например:

;Вася ЕгоИмяПользователя ЕгоПароль
;Ваня ИмяПользователя Пароль
;Елена supergirl@mail.ru 123

; $file_name - Имя файла, из которого читать учетные данные
; $delimiter - разделитель параметров учетных записей (по умолчанию - пробел)
; $label     - Имя игрока
; $username  - Имя пользователя
; $password  - Пароль
Func Read_Passwords($file_name, $delimiter, ByRef $labels, ByRef $usernames, ByRef $passwords)
   Local $i = 0
   Local $line
   Local $account_data[10]
   Local $count = -1
   FileOpen($file_name, 0)
   For $i = 1 to _FileCountLines($file_name)
	  $line = FileReadLine($file_name, $i)
	  if (StringLen($line) = 0) Then ContinueLoop        ; Если строка пустая, то пропускаю ее
	  if (StringLeft($line, 1) = ';') Then ContinueLoop  ; Если эта строка - комментарий (первый символ строки ";"), то пропускаю эту строку
	  if (StringLeft($line, 2) = '//') Then ContinueLoop ; Если эта строка - комментарий (первые два символа "//" ), то пропускаю эту строку
	  $count = $count + 1

	  $account_data = StringSplit($line&" "&" ", $delimiter)
	  ; Удаляю запрещенные символы, чтобы не было ошибки записи в файл, поскольку "Имя игрока" является префиксом файла
	  $labels[$count] = StringRegExpReplace($account_data[1], "(?i)[^a-z0-9а-яА-Я\s]", "")
	  $usernames[$count] = $account_data[2]
	  $passwords[$count] = $account_data[3]
   Next
   FileClose($file_name)
   if ($i < 2) Then Return False ; Если файл пустой, то возвращаю "Ложь", чтобы не делать авторизацию

   ; Узнаю число игроков, за которых нужно повисеть
   $WF_number_of_players = $count

   Return True
EndFunc

; Собственно "повисеть" (один раз). Т.е. такие операции как: Запустить Warface, подождать 15 мин, сделать скриншот для журнала, выйти из него
; $label - имя игрока
; $interval - интервал в секундах, который нужно повисеть за каждого игрока
Func Poviset($label, $interval)
   ; Если не удастся запустить игру, то закрываю игровой центр mail.ru
   if (Launch_Warface() == False) Then Return False
   TrayTip("Выполняется операция:", "Жду " & Round($interval/(60)) & " мин.", $interval)
   Sleep($interval*1000)
   TrayTip("Выполняется операция:", "Делаю скриншот полученного предмета, чтобы убедиться, что все прошло успешно.", 10)
   Screen_Shoot($WF_LogItemFolder, $label)
   Stop_Warface($label)
   Return True
EndFunc


; Авторизоваться (Ссылка "Играть под другим логином")
; $label    - Имя игрока
; $username - Имя пользователя
; $password - Пароль
Func Auth($label, $username, $password)
   TrayTip("Выполняется операция:", "Авторизуюсь под именем: " & $label, 3000)
   ;ShellExecute("WarfaceLoader.exe")
   ShellExecute("mailrugames://play/0.1177") ; Запуск Warface через url
   ; Кликаю "Играть под другим именем
   WinWaitActive('Игровой центр@Mail.Ru')
   WinActivate("Игровой центр@Mail.Ru")
   $pos = WinGetPos('Игровой центр@Mail.Ru')
   Sleep(10000)
   SleepAndClick($pos[2] - $pos[0] - 150, $pos[1] + 185, 1000, "Кликаю: играть под другим логином")
   ; Ввожу имя пользователя и пароль
   if (WinWaitActive('Авторизация', "", 5) = 0) Then
	  if (WinWaitActive('Настройка логина', "", 5) = 0) Then
		 SleepAndClick($pos[2] - $pos[0] - 150, $pos[1] + 135, 1000, "Видимо, игрок не авторизован. Кликаю: Играть")
	  EndIf
   EndIf
   Sleep(1000)
   Send($username & '{Tab}' & $password)
   Sleep(500)
   Send("{ENTER}")
   Sleep(3000)
EndFunc


; Авторизоваться и повисеть за каждого
Func Auth_and_Poviset()
   Local $labels[1000], $usernames[1000], $passwords[1000], $key, $result, $label, $poviset_result, $try_count

   ; Если нет учетных данных в файле "Пароли_к_игре.txt", то вызываю "виселку" без авторизации и выхожу
   $result = Read_Passwords($WF_accounts_file, $WF_accounts_file_delimiter, $labels, $usernames, $passwords)
   if ($result == False) Then
	  TrayTip("Предупреждение:", "Нет файла "&$WF_accounts_file&". Запускаю игру без авторизации.", 10)
	  Poviset("", $WF_interval)
	  Return
   EndIf

   ; Иначе буду "висеть" за каждого
   $key = -1
   For $label In $labels
	  $key = $key + 1
	  if ($labels[$key] == "") Then ContinueLoop

	  ; Буду пытаться висеть, пока не будет удачной попытки или число попыток превысит максимальное число
	  $try_count = 0
	  $poviset_result = False
	  While ($poviset_result == False)
		 Auth($labels[$key], $usernames[$key], $passwords[$key])
		 $poviset_result = Poviset($labels[$key], $WF_interval)
		 $try_count = $try_count + 1
		 if ($try_count > $WF_try_count) Then
			TrayTip("Капец", "Я сделал "&$WF_try_count&" попыток и не смог войти в игру, видимо, игрок безнадежен. Все! Переключаюсь к следующиему игроку", 3000, 3)
			Sleep(3000)
			Screen_Shoot($WF_LogErrorFolder, "Error_"&$labels[$key])
			ExitLoop
		 EndIf
	  WEnd
   Next
EndFunc


; Периодический бесконечный запуск заданной функции. В данном случае: период - 1 день, функция - виселка для Warface
; $period - период запуска функции (в секундах)
; $cycle_func - функция, которую нужно вызывать через заданный период
; Пример: Schedule(4, "Auth_and_Poviset") - вызывает Auth_and_Poviset() каждые 4 секунды
; Закомментировал этот метод расписания, он глючит.

#cs

Func Schedule($period, $cycle_func)
   Local $newTime = _NowCalc(), $asDatePart[4], $asTimePart[4]
   While (True)
	  If (_NowCalc() > $newTime) Then
		 $newTime = _DateAdd('s', $period, $newTime)
		 _DateTimeSplit($newTime, $asDatePart, $asTimePart)
		 Sleep(1000)
		 Call($cycle_func)
		 TrayTip("Следующий заход в:", $asTimePart[1]&":"&$asTimePart[2], $period)
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
		TrayTip("Следующий заход в:", $asTimePart[1]&":"&$asTimePart[2], $interval_posle_viseniya-10)
		Sleep($interval_posle_viseniya*1000);
	WEnd
EndFunc


; Запускаю виселку
Func WF_viselka()
	if $WF_period < ($WF_interval * $WF_number_of_players + $WF_popravka) Then
		TrayTip("Ошибка", "Увеличьте период висения, он меньше интервала висения.", 10)
		Sleep(10*1000)
		Return
	EndIf
   Schedule($WF_period, 'Auth_and_Poviset')
EndFunc



