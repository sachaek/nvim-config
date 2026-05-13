# Neovim Python IDE

Готовая конфигурация Neovim для Python-разработки на Windows.

## Быстрый старт

```powershell
git clone https://github.com/sachaek/nvim-config
cd nvim-config
.\install.bat
```

Скрипт сам установит Chocolatey → Neovim → Python-пакеты → скопирует конфиг → установит плагины.

## Что внутри

- **LSP**: pyright (автокомплит, диагностика, go-to-definition)
- **Форматтер**: ruff (автоформат при сохранении)
- **Автокомплит**: nvim-cmp с LSP-источником и сниппетами
- **Отладка**: nvim-dap + debugpy (F5)
- **Тесты**: neotest + pytest
- **Навигация**: Telescope (поиск файлов/grep), Oil (файловый менеджер)
- **Тема**: Tokyo Night
- **Git**: gitsigns (признаки gutter)

## Требования

- Windows 10/11
- Python 3 (установленный)
- Права администратора (для установки Neovim)
