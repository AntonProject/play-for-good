# Продолжение работы в Play For Good

При работе над Good Games, рейтингами, сезонами, наградами, стартовыми +100
или разделением test/prod сначала прочитать:

1. `docs/gg_logic/HANDOFF.md` — решения пользователя, статус и следующие шаги
   (раздел «Состояние на 15 октября 2026» имеет приоритет над остальным текстом).
2. `docs/gg_logic/DB_REFERENCE.md` — таблицы, поля и функции Good Games v2 в Supabase.
3. `docs/gg_logic/variants/flutterflow_cli/NATIVE_BINDINGS.md` — привязки native FF.

Актуальные исходники этой задачи находятся в `docs/gg_logic/variants/`
(SQL — `02_rpc/iteration1/`, скрипты FF — `flutterflow_cli/`).
`docs/gg_logic/supabase/`, старые `gg_*` и изменения экспортированных страниц
сохранены как предыдущие черновики; не применять их вместо `gg_v2_*`.

Good Games v2 уже внедрён в прод: Supabase и облачный FlutterFlow обновлены.
Порядок изменений облака:

* Supabase: агент готовит SQL, проверяет его на локальной копии и перечисляет,
  что меняется в существующих таблицах. Запускает SQL владелец сам в SQL Editor;
  агент к продовой базе не подключается.
* FlutterFlow: агент делает dry-run (поведение CLI-скриптов по умолчанию) и даёт
  владельцу команду с `--apply`; запись запускает владелец. Сам агент `--apply`
  не запускает. После записи агент выгружает код
  (`flutterflow ai codegen refresh`) и проверяет `flutter analyze`.

Для Flutter/Dart/FlutterFlow использовать
`/Users/a123/.codex/skills/flutter-flutterflow-workflow/SKILL.md`.
Сохранять существующие незакоммиченные изменения. Не удалять файлы/крупные блоки,
не выполнять Git commit/push/deploy и не запускать агентов без явной команды пользователя.
