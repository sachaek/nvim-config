# Neovim Python IDE

Готовая конфигурация Neovim для Python-разработки. Работает на **Windows** и **Linux**.

## Быстрый старт

### Windows

```powershell
git clone https://github.com/sachaek/nvim-config
cd nvim-config
.\install.bat          # запустить от администратора
```

### Linux

```bash
git clone https://github.com/sachaek/nvim-config
cd nvim-config
chmod +x bootstrap.sh
./bootstrap.sh
```

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

- **Windows**: Python 3, права администратора
- **Linux**: Python 3 + pip, sudo (apt/dnf/pacman)

## Хоткеи

| Клавиша | Действие |
|---------|----------|
| `Space ff` | Найти файлы |
| `Space fg` | Поиск по тексту |
| `gd` | Перейти к определению |
| `K` | Показать документацию |
| `Space ca` | Code action |
| `F5` | Запустить отладку |
| `Space tl` | Запустить тест |
