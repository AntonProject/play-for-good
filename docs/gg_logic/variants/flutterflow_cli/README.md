# Перенос Custom Code через FlutterFlow CLI

Этот сценарий регистрирует функции, actions и служебные widgets в проекте FF.
Он **не заменяет страницы Dart-файлами** и не переключает их источники данных.
Родные страницы настраиваются по [карте привязок](NATIVE_BINDINGS.md).

По умолчанию выполняется dry-run: получить актуальный проект, собрать кандидат,
проверить его валидатором FF, сохранить отчёт. Облако и Supabase не изменяются.
Здесь нет команды применения SQL.

## Три комплекта

```sh
bash docs/gg_logic/variants/flutterflow_cli/prepare.sh basic
bash docs/gg_logic/variants/flutterflow_cli/prepare.sh rpc
bash docs/gg_logic/variants/flutterflow_cli/prepare.sh admin
```

| Вариант | Добавляемый Custom Code |
|---|---|
| basic | ggClaimSignupBonus, GgScrollBoundary, ggLocalCalculations, ggLocalFromRows, ggBuildLocalData, ggLoadContext, ggGamesRows |
| rpc | ggClaimSignupBonus, GgScrollBoundary, ggV2Rankings, ggV2ProfileStats, ggV2Games, ggGamesRows, GgStatsListener |
| admin | Комплект rpc + ggSeasonsAdmin, GgCalendarRefresh |

Панели-примеры из `flutterflow/` не импортируются как замена native-страниц.
Код, типы и аргументы определены в `custom_code.json`; у Custom Functions
передаётся только тело, у Custom Actions/Widgets — исходник целиком.
Повторная регистрация обновляет те же определения и сохраняет их ключи.
Переключение пакета не удаляет функции предыдущего пакета.

Доступ берётся из локального secret env, ключ в репозиторий не записывается.
SDK скачивается в отдельный workspace. Подготовленный workspace:
`/private/tmp/ff-ai-pfg-transfer`. SDK 0.0.41 использовался при подготовке.

## Локальная проверка без сети

В уже инициализированном workspace можно проверить пакет на сохранённом proto:

```sh
bash docs/gg_logic/variants/flutterflow_cli/prepare.sh rpc \
  --offline-snapshot /private/tmp/ff-ai-pfg-transfer/project.pb
```

Проверяет регистрацию, отсутствие изменений страниц и повторное применение.
Это не компиляция пользовательской сборки и не проверка визуальных привязок.
Приватные `before-*.pb`/`candidate-*.pb` находятся только в workspace с правами 600:
они могут содержать настройки бэка. Не прикладывать их к Git или публичному чату.

## Применение после команды владельца

1. Создать FlutterFlow Commit текущего состояния, записать ID. По возможности
   создать FF-ветку и взять **её project ID из URL**, а не Git branch name.
2. Применить выбранный SQL отдельно в согласованную БД; проверить тестовую среду.
3. Запустить dry-run на **том же project ID**, на который будет перенос.
4. Если dry-run успешен, выполнить следующий вызов только после разрешения:

```sh
bash docs/gg_logic/variants/flutterflow_cli/prepare.sh rpc \
  --workspace /private/tmp/ff-ai-pfg-transfer-branch \
  --project-id FF_BRANCH_PROJECT_ID \
  --apply --backup-commit SAVED_FF_COMMIT_ID
```

Параметр `--backup-commit` фиксирует, что резервная версия сохранена владельцем;
скрипт не создаёт и не проверяет этот Commit самостоятельно. `--apply` — реальная
запись Custom Code в FF. Коммит FlutterFlow не является Git-коммитом.

После применения проверить remote Custom Code и компиляцию в FF, затем выполнить
привязки из `NATIVE_BINDINGS.md`. Не переключать production UI на RPC до SQL.

## Что переносится вручную

* Backend Query/Action Flow и JSON-поля в native виджетах двух страниц.
* Периоды в bottom sheet, выбранное/подтверждённое значение, обновление по возврату.
* Изображения и награды по `awards`, социальные ссылки, обёртка скролла.
* test у чтений и записей других потребителей; signup и claim бонуса.
* Native форма управления сезонами и её доступ для администратора, если выбран admin.
* Применение SQL, первый backfill, сохранение прошлых итогов, Cron.

CLI умеет изменять native страницы, но подготовленный сценарий ограничен
Custom Code согласно решению менять страницы руками. Автопривязки страниц
этим комплектом не заявляются и не запускаются.
