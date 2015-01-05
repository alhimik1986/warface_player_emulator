warface_player_emulator
=======================

Виселка для Warface или симулятор игрока Warface

Сегодня весь мир охвачен on-line играми. От нечего делать, тратят на них силы и время. Кто-то тратит больше денег и меньше сил, но суть одна - страдают фигней. Даже взрослые (вместо того, чтобы искать нормальную работу или квалифицироваться в нормальную должность) просто играют, погружая себя в болото "нищебродской" стабильности.

Для тех, кто желает заняться действительно нужными делами, (но при этом, вспомнив ностальгическое развлечение, в какой-то момент оттянуться с накопленными знаками возвращения) предлагаю виселку.

Суть простая: запустить игру и повисеть 10-15 минут, пока не появится очередной предмет, затем закрыть игру. С этим легко справляется скрипт, написанный на языке autoIt, который кликает мышью, запускает игру, вводит тексты (для входа в аккаунт) и т.д.

<b>Возможности:</b>
<ul>
	<li> Повисеть за себя и за других: друзей, знакомых соседей, мам, пап и детей (такое тоже бывает) - до 200 человек. Для этого необходимо прописать их пароли в файле "Пароли_игроков.txt"</li>
	<li> Убедиться, что предмет получен. Для этого нужно зайти в папку "Скриншоты_полученных_предметов" посмотреть скриншот со своим именем за нужную дату</li>
	<li> Прога висит 2 раза в день каждые 12 часов для надежности</li>
	<li> Регулировать время пребывания в игре, корректировать координаты перемещения мыши  и т.д., но это под силу не всем. Для этого необходимо скачать <a href="https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe">autoit</a>, отредактировать (в программе autoit) файл warface.au3 (при желании WarfaceLib.au3), и скомпиллировать файл warface.au3 (нажав F7)</li>
</ul>

<b>Недостатки:</b>
<ul>
	<li> Главный недостаток - повисеть можно только не сервере "Альфа".</li>
	<li> Второй недостаток: скрипт не может понять, что игра обновляется и каждый раз закрывает и открывает игровой центр, думая, что не туда кликает. Приходится после каждого обновления игры заново запускать скрипт.</li>
</ul>

Недостатки временные, они будут исправлены со временем, когда оно у меня появится.
