# ZanZarah Display Fixer + Language Patch

Патч для Steam-версии **ZanZarah: The Hidden Portal**.

Он исправляет проблемы отображения на современных системах, добавляет разрешение **1920×1080**, исправляет положение элементов HUD для формата 16:9 и добавляет шесть языков: English, Русский, Українська, Čeština, Polski и Français.

## Установка

1. В Steam выполните проверку целостности файлов игры.
2. Распакуйте этот репозиторий в отдельную папку.
3. Запустите `install.bat` **от имени администратора**.
4. Выберите корневую папку игры `...\ZanZarah`.
5. Дождитесь завершения установки и локальной подготовки русского PAK.
6. Запустите `System\dgVoodooCpl.exe`.

### Настройка dgVoodoo

На вкладке **DirectX**:

- Output API: `Best available one`;
- Resolution: `1920x1080`;
- VRAM: максимальное доступное значение;
- снимите лишние экспериментальные галочки;
- нажмите **Apply**, затем **OK**.

При первом запуске в стартовом меню игры обязательно выберите разрешение:

`1920x1080x16`

После этого откройте меню языков, выберите язык и нажмите **Apply**. Игра перезапустит стартовое меню с выбранной локализацией.

## Поддерживаемые языки

- **English** — оригинальный текст, озвучка и видео.
- **Русский** — русский текст, озвучка и видео.
- **Українська** — украинский текст, озвучка и видео.
- **Čeština** — чешский текст и шрифты; английские озвучка и видео используются как резерв.
- **Polski** — польский текст, шрифты и видео; английская озвучка используется как резерв.
- **Français** — французский текст, озвучка и видео.

## Восстановление

Запустите `restore.bat` из папки патча. Резервные копии создаются в папке `zms_backup` рядом с игрой.

---

# English

This patch is for the Steam version of **ZanZarah: The Hidden Portal**. It fixes modern display issues, adds **1920×1080**, fixes the 16:9 HUD layout, and adds six languages: English, Russian, Ukrainian, Czech, Polish and French.

## Installation

1. Verify the game files in Steam.
2. Extract this repository to a separate folder.
3. Run `install.bat` **as administrator**.
4. Select the game root folder, `...\ZanZarah`.
5. Wait for the installation and the local Russian PAK build to finish.
6. Run `System\dgVoodooCpl.exe`.

### dgVoodoo settings

On the **DirectX** tab, set `Output API` to `Best available one`, set the resolution to `1920x1080`, choose the maximum available VRAM, disable unnecessary experimental options, then click **Apply** and **OK**.

On the first game launch, the Startup Menu must use:

`1920x1080x16`

Open the language menu, select a language and click **Apply**. The Startup Menu will restart using the selected localization.

## Languages

English, Russian, Ukrainian, Czech, Polish and French are included. Czech uses English audio/video as fallback; Polish uses English audio as fallback. French includes French text, voice audio and videos.

## Restore

Run `restore.bat`. Backups are stored in the game's `zms_backup` folder.

---

# Русский

Патч исправляет проблемы с дисплеем, добавляет 1920×1080, исправляет HUD для 16:9 и добавляет английский, русский, украинский, чешский, польский и французский языки.

Порядок: проверить файлы Steam → запустить `install.bat` от администратора → выбрать папку игры → настроить `System\dgVoodooCpl.exe` на 1920×1080 → в стартовом меню выбрать **1920×1080×16** → выбрать язык и нажать **Apply**.

---

# Українська

Патч виправляє проблеми дисплея, додає 1920×1080, виправляє HUD для 16:9 та додає англійську, російську, українську, чеську, польську й французьку мови.

Порядок: перевірити файли Steam → запустити `install.bat` від адміністратора → вибрати папку гри → налаштувати `System\dgVoodooCpl.exe` на 1920×1080 → у стартовому меню вибрати **1920×1080×16** → вибрати мову та натиснути **Apply**.

---

# Čeština

Patch opravuje problémy se zobrazením, přidává rozlišení 1920×1080, upravuje HUD pro poměr 16:9 a přidává šest jazyků. Spusťte `install.bat` jako správce, nastavte dgVoodoo na 1920×1080 a ve Startup Menu vždy vyberte **1920×1080×16**. Poté vyberte jazyk a stiskněte **Apply**.

---

# Polski

Patch naprawia problemy z wyświetlaniem, dodaje rozdzielczość 1920×1080, poprawia HUD dla proporcji 16:9 i dodaje sześć języków. Uruchom `install.bat` jako administrator, ustaw dgVoodoo na 1920×1080, a w Startup Menu wybierz **1920×1080×16**. Następnie wybierz język i kliknij **Apply**.

---

# Français

Le patch corrige les problèmes d'affichage, ajoute la résolution 1920×1080, corrige le HUD au format 16:9 et ajoute six langues. Lancez `install.bat` en tant qu'administrateur, configurez dgVoodoo en 1920×1080 et sélectionnez obligatoirement **1920×1080×16** dans le Startup Menu. Choisissez ensuite la langue et cliquez sur **Apply**.
