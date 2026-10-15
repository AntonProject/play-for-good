# Вариант 1 — исходное ТЗ, игры считаются на фронте

Использовать `install.sql` + общий [START](../START.md).
Существующие глобальные запросы игр/пользователей остаются. Это вариант с
ограничениями объёма клиентской выгрузки, а не обещание точности при 100k игр.
Новые клиентские функции не удаляют старые: переназначаются нужные привязки.

## FF Custom Code

1. Custom Function `ggLocalCalculations`: `games`, `users` List JSON; `context`
   JSON; `category` String; `page`, `pageSize` Integer; `userId` nullable String;
   return JSON. Код `flutterflow/gg_local_calculations.dart`.
2. Custom Action `ggLoadContext(period String,test Boolean)` → JSON.
3. Custom Action `ggBuildLocalData(games List GamesRow,users List UsersRow,
   context JSON,category String,page Integer,pageSize Integer,userId nullable String)` → JSON.
4. Общий `ggClaimSignupBonus(test Boolean)` → JSON.
5. Custom Function `ggLocalFromRows`: nullable List GamesRow/List UsersRow,
   nullable context JSON, category/page/pageSize/userId как выше → JSON.
   Она подходит для прямых привязок к widget Backend Queries: пересчитывается
   при rebuild и не запускает action до готовности запросов.
6. `ggGamesRows(response JSON nullable)` → List GamesRow для истории игр.

Контекст содержит календарь, агрегированные инвайты и бонусы и медали. Сырые
инвайты других пользователей RLS сейчас не отдаёт, поэтому старый список
инвайтов **не добавлять** поверх контекста. Запрос инвайтов можно сохранить
для своих списков, но не использовать повторно в новом рейтинге.

## GoodGamesPage

Page State: `selectedPeriod`, `appliedPeriod` String; `selectedCategory`,
`appliedCategory` String; `ggContext`, `ggData` JSON; `page` Integer=1.

On Load / возврат после игры:

Далее описана последовательная загрузка через actions Query Rows. Если списки
загружаются **widget Backend Queries**, использовать `ggLocalFromRows` в привязках
после загрузки контекста: см. [карту FF](../flutterflow_cli/NATIVE_BINDINGS.md).

1. Существующие запросы игр/пользователей с фильтром среды.
2. `ggLoadContext('auto',test)` → ggContext; записать `$.period.key` в оба period.
3. `ggBuildLocalData(gameRows,userRows,ggContext,'valuable',1,10,currentUserUid)` → ggData.

На подтверждении фильтра: `selected` → `applied`, page=1; получить контекст
по имени периода; пересчитать ggData из уже загруженных игр. Границы дат не
передаются руками: имя выбирается из `ggContext.available_periods`.

| Виджет | Источник |
|---|---|
| Total Good Power всех пользователей за всё время | `ggData.total_good_power_all_time` |
| Год плашки | `ggData.period.season_year` |
| Подиум | `ggData.top_players` |
| Список пользователей | `ggData.players` |
| Имя / баллы / место | `display_name` / `score` / `rank` текущего JSON item |
| Строка текущего пользователя | `ggData.current_user` |
| Независимые медали | `item.awards`, category + place + season_year |
| Meine Games | `ggData.games` — JSON игры; можно через общий `ggGamesRows` получить GamesRow |
| Следующая страница | `pagination.has_more` / `games_pagination.has_more` |

Рейтинг выводится JSON item, а не представительская GamesRow: иначе теряются
пользователи с бонусом/инвайтами, у которых ещё нет игр. Сами запросы игр
остаются прежними. При выборе закрытого сезона рейтинг берётся из сохранённых
результатов, а история Meine Games показывает существующие игры периода.

## UserProfilePage

Получить такой же контекст и выполнить ggBuildLocalData с **ID открытого профиля**,
не всегда текущего пользователя. Привязки:

* Верхние LW/место: `ggData.profile.all_time.good_power` / `.rank`, без +100.
* Stats: `ggData.profile.stats.good_power.value/rank`, `.games.value/rank`,
  `.good_energy.value/rank` для прежнего Punkte per Game (сумма €nergy,
  сохранена по решению пользователя 13 октября).
* Награды: `ggData.profile.awards`; не зависят от выбранной категории.
* Соцсети перенести в верхний блок, ссылки из прежнего user document.
* **Supporters не заменять sponsored_games**: прежняя функция/источник
  остаются до отдельного уточнения значения этой метрики.

Кнопка подтверждения: dirty = selectedPeriod!=appliedPeriod либо категория
изменилась. Тогда чёрный фон/белая галочка. Применять только нажатием.

`flutterflow/gg_basic_preview.dart` — локальный пример вывода результата,
не замена всей страницы FF. Его `response=ggData`, `profile=true/false`.
