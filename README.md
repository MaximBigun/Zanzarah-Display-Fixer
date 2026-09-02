# Zanzarah Display Fixer v0.1.0

Запускаешь `START.bat`, выбираешь `zanthp.exe` и нажимаешь **«Применить фикс»**. Утилита:

- добавляет **1920×1080** в список разрешений;
  
<img width="471" height="425" alt="image" src="https://github.com/user-attachments/assets/191b94c4-639d-4d5d-88de-f318f52bdaae" />


- сразу применяет проверенный нами **Battle HUD Fix 16:9** — HP, энергия прыжка, заклинания и заряды;
- создаёт `zanthp.exe.zdf.bak`; (оригинальный, не патченный zanthp.exe)
- сохраняет Custom Pools и другие дополнительные данные в EXE;
- допускает повторное применение; (при повторном применении ничего не произойдет)
- отказывается писать файл, если структура EXE не похожа на поддерживаемую.

Проверил логику на обоих твоих вариантах: с обычными `800×600` в таблицах и уже графически пропатченным `1920×1080`.

p.s. Для игры надо дополнительная утилита dgVoodoo, где надо будет выставить разрешение 1920х1080.
- Скачайте архив dgVoodoo.zip
- Разархивируйте его в папке "Zanzarah\System"
- Запустите dgVoodooCpl.exe
- В открывшемся окне перейдите на вкладку "DirectX"
- Там поменяйте расширение на 1920х1080 (как на скриншоте) и уберите лишние галочки. После нажмите на "Apply" и на кнопку "OK"


<img width="403" height="496" alt="image" src="https://github.com/user-attachments/assets/1bbcbb89-03e8-4810-a675-9af8e75730e7" />








# Zanzarah Display Fixer v0.1.0 ENG: 

Run START.bat, select zanthp.exe, and click “Apply Fix.” The utility:

- Adds 1920×1080 to the list of resolutions;
- Immediately applies the Battle HUD Fix 16:9 that we’ve tested—HP, jump energy, spells, and charges;
- Creates zanthp.exe.zdf.bak; (the original, unpatched zanthp.exe)
- sSaves Custom Pools and other additional data in the EXE;
- Allows for repeated application; (Nothing will happen if you use it again.)
- refuses to write the file if the EXE structure does not match a supported one.

  
I tested the logic on both of your versions: the one with the standard 800×600 in the tables and the one that’s already graphically patched to 1920×1080.

P.S. To play the game, you'll need the dgVoodoo utility, where you'll need to set the resolution to 1920x1080.

- Download the dgVoodoo.zip archive
- Extract it to the “Zanzarah\System” folder
- Run dgVoodooCpl.exe
- In the window that opens, go to the “DirectX” tab
- There, change the resolution to 1920x1080 (as shown in the screenshot) and uncheck any unnecessary boxes. Then click “Apply” and “OK”











# Последовательность действий: 
Схема теперь такая:

- Устанавливаем Steam Zanzarah.
- Запускаем наш Zanzarah Display Fixer и патчим zanthp.exe.
- Устанавливаем dgVoodoo2 для игры.
- В dgVoodoo выставляем нужное разрешение — базово 1920×1080, а при необходимости можно выше/ultrawide — и максимально доступный объём VRAM.
- Запускаем Zanzarah Startup Menu.
- В игре выбираем 1920×1080×16.
- Наш патч при этом исправляет положение HP, энергии прыжка, заклинаний и зарядов под 16:9






# Step-by-Step Procedure ENG:

Here’s the procedure:

- Install Steam Zanzarah.
- Run our Zanzarah Display Fixer and patch zanthp.exe.
- Install dgVoodoo2 for the game.
- In dgVoodoo, set the desired resolution—1920×1080 by default, but you can go higher or use ultrawide if needed—and the maximum available VRAM.
- Launch the Zanzarah Startup Menu.
- In the game, select 1920×1080×16.
- Our patch adjusts the positioning of HP, jump energy, spells, and charges for a 16:9 aspect ratio.

