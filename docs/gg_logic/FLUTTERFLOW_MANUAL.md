# Ручная настройка FlutterFlow

**Новые инструкции по выбранному варианту:** [variants/START.md](variants/START.md).
Там уже учтены test/prod и начисление +100 в БД. Ниже — предыдущая инструкция,
сохранённая для сравнения; старые ручные прибавления не переносить в новую сборку.

Инструкция для предыдущего подготовленного комплекта. Новые требования
test/prod и включение сохранённого +100 в MVP/Total описаны в
[SCOPE_OPTIONS.md](SCOPE_OPTIONS.md); RPC и привязки ещё требуют адаптации.
После неё убрать клиентские прибавления +100 и использовать бонус из БД.

Dart-страницы служат локальным примером поведения. В FF вручную изменить
существующие страницы, Actions и привязки. Перед началом сохранить FF commit
«До серверного расчёта Good Games»; при доступном Branching создать рабочую ветку.

## Custom Code

Добавить `ggRankings`, `ggProfileStats`, `ggGames` из `flutterflow/actions/`.
Параметры и типы указаны в заголовках файлов. Результат каждого — **JSON**,
не List of JSON. Массив списка находится внутри объекта результата.

Добавить `GgStatsListener` из `flutterflow/gg_stats_listener.dart`:
width/height Double, refreshKey String, onRefresh Action. На каждой странице
один виджет 1×1; callback вызывает Action Block повторного чтения.
`ggPeriodBounds` при серверной фильтрации не нужна: передавать ключ периода.

## GoodGamesPage: Good Heart Games

Page State: period String=`auto`, category String=`valuable`, rankingData JSON.
Action Block: `ggRankings(period,category,1,10,currentUserUid/null)` → rankingData.
Для гостя userId=null. Заменить старые вычисления привязками:

| Виджет | JSON Path |
| --- | --- |
| Общий Good Power за всё время | `$.total_good_power_all_time` |
| Итог выбранного периода (если нужен отдельно) | `$.total_good_power` |
| Год плашки / название периода | `$.period.season_year` / `$.period.label` |
| Подиум / список | Generate Children: `$.top_players` / `$.players` |
| Поля строки | `$.rank`, `$.display_name`, `$.photo_url`, `$.score` текущего элемента |
| Отдельная строка текущего игрока | `$.current_user`, если нет в списке и rank не null |
| Награды строки | Generate Children: `$.awards` текущего игрока |

Asset награды выбирается по badge, год — season_year. MVP-награда сохраняется
при сортировке MAP. Обе категории имеют 1/2/3 места. Текущие места — цифры;
медали и кубок — награды закрытых сезонов.

## Meine Games

Page State: myPeriod=`auto`, myCategory=`valuable`, pageNumber=1,
gamesData JSON, myStatsData JSON. Action Block:
`ggGames(currentUserUid,myPeriod,myCategory,pageNumber,10)` и
`ggProfileStats(currentUserUid,myPeriod)`. Гостю оставить существующий вход.

Список по gamesData.games либо `ggGamesRows(gamesData)` для GamesOrgComp.
Next управляется gamesData.pagination.has_more. При смене фильтра pageNumber=1.
Статистика — поля value/rank из myStatsData.stats.

## UserProfilePage

Page State: profilePeriod=`auto`, profileStatsData JSON. Action Block:
`ggProfileStats(ID открытого профиля,profilePeriod)`.

| Виджет | JSON Path |
| --- | --- |
| Шапка Good Power / место | `$.all_time.good_power` + существующие отображаемые 100 / `$.all_time.rank` |
| Total Good Power статистики | `$.stats.good_power.value` / `$.stats.good_power.rank` |
| Good Games | `$.stats.games.value` / `$.stats.games.rank` |
| Существующая формула Punkte per Game | `$.stats.good_energy.value` / `$.stats.good_energy.rank` |
| Награды | Generate Children: `$.awards`; картинка badge, год season_year |

Существующие +100 сохранить там, где они уже отображались; не добавлять в
рейтинг, общий итог и сохранённые результаты. Supporters не заменять автоматически
на sponsored_games: это разные сущности, формула требует уточнения.
Соцсети перенести вверх, сохранив ссылки. Обновить повторённые активные ветки UI.

## Фильтры и обновление

Категории: valuable/MVP и active/MAP. Периоды брать из `$.available_periods`
любого RPC: key передавать в вызов, label показывать. Следующие сезоны появляются
автоматически с сентября; июль/август по умолчанию показывают последний сезон.

В диалоге хранить черновые значения отдельно от применённых. Если период или
категория изменились — кнопка чёрная, галочка белая. Подтверждение меняет
применённые значения и запускает чтение.

refreshKey listener включает фильтры, вкладку, страницу списка, ID пользователя
и FFAppState.refreshDate. onRefresh вызывает Action Block. Listener читает при
открытии/возврате/из фона/переподключении и Broadcast; закрытие сезона отправляет
такой же Broadcast.

До записи ответа сравнить requested_period, requested_category,
requested_user_id/user_id и page с актуальным состоянием. Устаревший ответ
пропустить. При ошибке сохранить последние корректные данные.

После замены всех вычисляемых привязок отключить полные games/invites queries
для расчётов на этих двух страницах. Сохранить запросы реальной истории,
организаций, постов и отдельного документа профиля, где они нужны.
Home/Energy/админку эта итерация не меняет.

## Supabase — только по команде владельца

Применить `00`, `01`, `02`, `03` (после сверки индексов), `04`.
Для прошлых сезонов выполнить `select gg_internal.finalize_due_seasons();`.
Включить Supabase Cron, применить `05_schedule.sql`, проверить job/history.

Клиент вызывает только три публичных RPC. Таблицы gg_internal.seasons и
gg_internal.season_results напрямую из FF не читать; внутреннюю схему не
открывать в Data API. Закрытие выполняют владелец БД и Cron.

Проверить текущий сезон на нескольких игроках; новая игра обновляет очки/место.
Изменение прошлой игры сохраняет закрытые итоги/награды, но меняет All-Time.
