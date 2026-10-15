# Родные страницы FF: карта переключения

**Уточнение 13 октября:** сначала использовать [iteration1](../02_rpc/iteration1/README.md).
В фильтре оставить valuable/active/generous/social. +100 уже сохранены временно
в JSON новых actions при signup_bonus_migrated=false: на привязанном Text не
прибавлять их ещё раз. Signup/claim из следующего раздела подключать только
последним этапом. layout_mode=final только для выбранного завершённого сезона;
All-Time/месяцы/текущий сезон=current. Само award Visibility только из сохранённых
awards, а не текущего rank. Профиль всегда все awards, список по правилам периода.
Пользователь уже сверстал новый UI: ключи ниже надо сверить со свежим снимком,
не перезаписывать его страницы старой версткой.
Свежая сверка сделана: [FF_BINDINGS_2026_10_13](../02_rpc/FF_BINDINGS_2026_10_13.md)
содержит новые node keys,12 функций, условия цветов/медалей/подписей и порядок
переноса. Этот документ имеет приоритет над прежними конкретными UI-привязками.

Проверено по cloud-снимку Play For Good 1 октября 2026. Скрипт `prepare.sh`
переносит **только Custom Code**. Следующие привязки выполняются в редакторе FF
после выбора комплекта. Node keys приведены для поиска текущих виджетов;
после пересоздания виджета его ключ может измениться.

## Регистрационные +100: дополнение 9 октября

[Аудит текущего FF и Supabase](../../BONUS_AUDIT_2026_10_09.md) подтвердил:
нынешние +100 прибавляются на клиенте без проверки гостевого flow. Оба новых
комплекта дают один бонус подтверждённому аккаунту в каждой среде через ledger.

В первоначальном signup `signInAfterOtpVerification` сохранить `signup_test`
из Environment и в INSERT, и в UPDATE готового профиля. Live Auth-триггер уже
создаёт профиль до OTP, поэтому UPDATE — обычный путь этого проекта.
При обычном login не перезаписывать signup_test. После успешного OTP и готового
профиля с авторизованной сессией обязательно вызвать `ggClaimSignupBonus(test)`,
затем обновить статистику. AFTER INSERT до подтверждения почты бонус не выдаёт.
Для admin signup с сразу подтверждённым email отдельно решить передачу среды
до INSERT/выдачи, иначе default false может создать prod-бонус тестовому аккаунту.
Эти привязки и проверка admin flow ещё не выполнены в облаке.

Полный подготовленный код существующего action для варианта 2:
`02_rpc/integration/sign_in_after_otp_verification.dart`. В FF добавить nullable
Boolean test, передавать Environment.test из каждого вызова. Сценарий CLI
регистрирует семь новых определений, этот существующий action заменить отдельно.

## Общие состояния и периоды

На GoodGamesPage сохранить существующие состояния:

| State | Значение при открытии | Использование |
|---|---|---|
| periodPageUser | auto | Период рейтинга |
| valuePageUser | valuable | MVP/MAP рейтинга |
| periodPageGame | auto | Период Meine Games |
| valuePageGame | valuable | Сортировка Meine Games |
| pageNumberUsers / pageNumberGames | 1 | Страницы списков |
| limit | 10 | Размер страницы |

Параметр маршрута `periodGames` сейчас имеет default `gesamt`: заменить default
на `auto`, иначе его On Load снова перезапишет новый default состояния.
Переданный явно период сохранить. Старая строка `gesamt` ещё поддерживается бэком,
но для новых привязок использовать `all_time`.

В userProfilePage добавить String `ggPeriod = auto`. `userId` брать из **параметра
страницы**, чтобы чужой профиль не запрашивал статистику вошедшего пользователя.

Во всех вызовах `test = Environment.test` (существующий Boolean env `test`).
`auto` означает последний начавшийся сезон: текущий либо уже завершённый.
Даты не вычисляются в виджетах. Функция принимает имя периода и возвращает
объект `period` с ключом, названием, годом и границами.

## Вариант RPC / admin: Action Flow

Добавить JSON Page State на GoodGamesPage:
`ggRanking`, `ggMyStats`, `ggHistory`; на userProfilePage: `ggProfile`.
Добавить Boolean loading и String error либо использовать стандартный UI ошибок FF.
На загрузке показывать loading, при ошибке сохранить предыдущий успешный ответ.

Собрать callback/action block `refreshGoodGames`:

1. Вызвать `ggV2Rankings(periodPageUser,valuePageUser,pageNumberUsers,limit,
   currentUserUid или null,Environment.test)`; результат записать в `ggRanking`.
   Этот вызов доступен гостю: userId=null, он видит настоящий общий рейтинг.
2. Если открыт Meine Games и пользователь зарегистрирован, вызвать
   `ggV2ProfileStats(currentUserUid,periodPageGame,Environment.test)` → `ggMyStats`.
3. При тех же условиях вызвать
   `ggV2Games(currentUserUid,periodPageGame,valuePageGame,pageNumberGames,limit,
   Environment.test)` → `ggHistory`.

`refreshProfile`:

* Для зарегистрированного `page.userId` вызвать
  `ggV2ProfileStats(page.userId,ggPeriod,Environment.test)` → `ggProfile`.
* Если userId='guest' — оставить существующий демонстрационный гостевой экран,
  не вызывать профильный RPC с этим значением.

Эти действия выполнять при открытии страницы, подтверждении фильтра,
переключении вкладки и изменении страницы списка. Можно объединить вызовы
в один callback, чтобы все точки обновления использовали одинаковый flow.

Для обновлений других игроков поставить маленький `GgStatsListener` 1×1
в каждой странице. `onRefresh` → её callback выше; `refreshKey` составить из
периода, категории, номера страницы, вкладки и userId. Не включать в refreshKey
сам полученный JSON — это создаст бесконечные перезагрузки.
Listener сам обновляет при появлении страницы/возврате, resume и Broadcast.
Если initial refresh уже выполняет listener, не дублировать его в On Load.

В admin дополнительно поставить `GgCalendarRefresh` 1×1 с тем же callback:
он перечитает календарь на границе дня, пока приложение открыто. Callback
должен объединять одновременные запросы (loading + pending повтор), чтобы
календарь и listener не запускали две одинаковые цепочки параллельно.

## GoodGamesPage: значения в виджетах

| Текущий элемент | Новый источник |
|---|---|
| Button_ac2vi0vu, Meisterschaft | Текст Good Heart Games |
| Новый Text Total Good Power | `ggRanking.$.total_good_power_all_time` |
| Год в золотой плашке | `ggRanking.$.period.season_year`; для All-Time/месяца показывать название периода, не пустой год |
| Generator ListView_f2ogaegd; гостевой Column_vukwnj3x | Generate Dynamic Children по `ggRanking.$.players` |
| Подиум: Stack_d8ch3pyr / lspkrsgh / y8g2r7sq | `ggRanking.$.top_players[0/1/2]` соответственно первое/второе/третье |
| Гостевой подиум Stack_9s3qgozx / ff59uepl / ymvf9ztj | Тот же `top_players` |
| Строка вошедшего игрока Container_hsks3evp | `ggRanking.$.current_user`; скрыть, если null |
| Meine Games Column_h1seev6d | `ggGamesRows(ggHistory)` → текущая GamesRow в gamesOrgComp |
| Mehr sehen рейтинга | `ggRanking.$.pagination.has_more`; увеличить pageNumberUsers и перечитать |
| Mehr sehen игр, Text_364mucfa | `ggHistory.$.pagination.has_more`; увеличить pageNumberGames и перечитать |

Подиум и строка получают `user_id`, `photo_url`, `display_name`, `rank`, `score`
из того же player JSON. На тап профиль передавать player.user_id. Не искать
текущего игрока в `players`: его может не быть на загруженной странице, для него
уже есть `current_user`.

При сохранении старой модели пагинации (новая страница заменяет список) достаточно
`players`. Если нужен append, складывать страницы в отдельный List<JSON> state,
очищать его при смене фильтра, не дублировать current_user. Номер места берётся
из `player.rank`, а не локального индекса списка.

В `gamesUserComp` (Container_f1ihd94m) добавить optional JSON `playerStats`.
На новых экземплярах передавать текущий player JSON. Переключить:

* Text_g97rioie → `playerStats.$.rank`;
* Text_7r21aqvw → `playerStats.$.score`;
* фото и имя можно брать из playerStats либо сохранить запрос users по user_id.

Если playerStats отсутствует, сохранить старую ветку для других экранов.
Параметры games/invites новых экземпляров после переключения сделать nullable
и не передавать глобальные списки; старые экземпляры сохраняют свои значения.
Не применять `getUserRatingScore` к новым данным: в старой функции есть +100,
а новый ответ уже содержит начисление из БД.

Личные показатели Meine Games:

| Node key | JSON ggMyStats |
|---|---|
| Text_lcr3yy48, games count | `$.stats.games.value` |
| Text_234kysby, games rank | `$.stats.games.rank` |
| Text_r9ptfctp, €nergy per Game | `$.stats.good_energy_per_game.value` |
| Text_3d90ul23, его rank | `$.stats.good_energy_per_game.rank` |
| Text_mvzjzj4t, Good Power per Game | `$.stats.good_power_per_game.value` |
| Text_jmkc3tqq, его rank | `$.stats.good_power_per_game.rank` |

Пустой rank показывать как «—», не как первое место. Числовое форматирование
оставить существующим. Гостевые личные 100 и демо-строки не заменять этими запросами.

## userProfilePage: значения и награды

| Текущий элемент | Источник ggProfile |
|---|---|
| Text_wn608uvw, Good Power в шапке | `$.all_time.good_power` + суффикс LW |
| Text_gsiwo116, место в шапке | `$.all_time.rank` |
| Container_5ql6ygrg, Total Good Power | value=`$.stats.good_power.value`, number=`$.stats.good_power.rank` |
| Container_5gubrshl, Punkte per Game | value=`$.stats.good_energy.value`, number=`$.stats.good_energy.rank` |
| Container_cotbhb97, Good Games | value=`$.stats.games.value`, number=`$.stats.games.rank` |
| Кнопка периода Stats | `$.period.label`; тап открывает выбор периода |
| Новый ряд наград под Info/Posts | Dynamic Children из `$.awards` |

`userProfileInfoStatsRow` уже принимает String title/value/number. Преобразовать
JSON-числа в эти строки через FF formatting. Заголовок профиля остаётся All-Time,
а нижние Stats меняются по выбранному периоду.

Уточнение пользователя 13 октября: несмотря на название Punkte per Game,
сохранить нынешнюю **сумму €nergy**, а не среднее. Поэтому здесь good_energy,
а не good_energy_per_game. У Meine Games отдельный €nergy per Game по-прежнему
использует среднее; не менять его при исправлении профильной привязки.

Строка Supporters сейчас содержит заглушку value=1 и отдельно рассчитанный rank.
`sponsored_games` означает число игр с денежными взносами, **не число людей**.
Его нельзя молча вывести под Supporters. При сохранении старой семантики оставить
value=1, а rank брать из `$.stats.sponsored_games.rank`: текущий
ratingUsersPerUser(...,'social',...) ранжирует по играм с sponsor_money > 0.
Это сохраняет источник ранга; value=1 по-прежнему заглушка, а не число supporters.
Для реального количества supporters потребуется отдельно согласованная метрика.

В списке игроков и профиле награды выводить из `awards`: поле `badge` выбирает
asset, `season_year` — год, `category` — MVP/MAP, `place` — 1/2/3. Это награды
закрытых сезонов; они не зависят от текущей сортировки или текущего player.rank.
Новый кубок/медаль не появляется во время незавершённого сезона. Текущие места
пока показывать цифрами: окончательные assets этих обозначений ещё не предоставлены.
Если у игрока несколько наград, отображать список/обе категории согласно дизайну.

Правило клиента от 12 октября: MVP всегда перед MAP. В строках рейтинга
`awards` уже отфильтрован бэком: All-Time, Diesen Monat и Letzten Monat — все
полученные награды; сезон — только награды выбранного сезона. Текущий сезон
без закрытия возвращает пустой список наград. Не фильтровать по выбранной
категории MVP/MAP: оба типа должны сохраняться при переключении сортировки.
В профиле `$.awards` всегда содержит всю историю наград, независимо от Stats.
Порядок массива: все MVP, затем все MAP; внутри категории новые сезоны первыми.
Генерировать виджеты по массиву, не по award_flags: флаги схлопывают одинаковые
типы наград разных лет. Каждая награда сохраняет season/season_year для подписи.
При большом числе наград использовать Wrap или прокрутку по макету, без обрезания
до двух/трёх бейджей. В basic то же правило применяется к payload списка,
контекст хранит всю историю для профиля.

Социальные кнопки перенести существующим Row выше в шапку/верхнюю часть Info,
сохранив Visibility и действия открытия ссылок. Assets добавляет владелец.

### Профильный диалог userProfile

Настроить также `components/dialogs/user_profile`, а не только userProfilePage.
У него есть собственный параметр userId. Добавить Component State ggProfile JSON
и ggPeriod String=auto; refreshProfile вызывает тот же ggV2ProfileStats с
component.userId. Гость остаётся демо, пустой userId не отправлять в RPC.

| Node key диалога | Новый источник ggProfile |
|---|---|
| Text_wlmhu8bi | `$.all_time.good_power` + LW |
| Container_kwdgrybl | Total Good Power: `$.stats.good_power.value/rank` |
| Container_fhpxyqmi | Punkte per Game: `$.stats.good_energy.value/rank` |
| Container_ezbzws49 | Good Games: `$.stats.games.value/rank` |
| Новый ряд наград | Все `$.awards`, MVP перед MAP |

Для остальных узлов ранга шапки/Supporters повторить источники страницы выше,
найти текущий ratingUsersPerUser и заменить его привязку. Сохранить bio, Posts,
Follow/Favorite и действия соцсетей. На открытие, Apply и возврат обновлять RPC;
при закрытии диалога listener удаляется с компонентом. Не ставить listener только
на родительскую страницу: открытый modal делает её route неактивным.

## Фильтры: goodGamesPlayersFilters и профиль

Компонент `goodGamesPlayersFilters` — Container_585gycim.

* MVP: Row_tr06yypm, значение `valuable`; MAP: Row_d43jxm4p, `active`.
* Скрыть Row_6gj4b12k (generous), Row_ioynq16m (social) и Row_9gv98j5p (recent).
  Их можно оставить в структуре скрытыми, чтобы не затрагивать другие потребители.
* Добавить optional JSON/List<JSON> параметр каталога периодов. Передавать
  `ggRanking.$.available_periods`, либо каталог ggMyStats при Meine Games.
* Generate Dynamic Children по каталогу: подпись item.label, значение item.key.
  Не передавать отображаемое название как ID. Формат key для seed-сезонов:
  `season_2026_27`, `season_2025_26`; другие `last_month`, `this_month`, `all_time`.
* Временно выбранные periodState/valueState при открытии копировать из применённых
  параметров. Если page state равен auto, в параметр period bottom sheet передавать
  эффективный ключ `response.period.key`, чтобы текущий сезон был отмечен. Сам
  page state сохраняет auto до реального выбора; подтверждение без изменений
  ничего не применяет. Тап меняет только temporary state. Подтверждение вызывает существующий
  update(period,value), затем меняет page states и сбрасывает pageNumber=1.
* IconButton_d1rwfoa2: фон чёрный, галочка белая, если periodState != period **или**
  valueState != value; иначе сохранить нейтральное оформление.

В профильном bottom sheet нужны только периоды. Если ggPeriod=auto, передать
effectivePeriod=ggProfile.period.key, инициализировать temporaryPeriod им же
и сравнивать с effectivePeriod, а не со строкой auto. Иначе галочка будет чёрной
сразу при открытии без изменения. Это правило одинаково для страницы и диалога.
Подтверждение обновляет ggPeriod и вызывает refreshProfile. Отмена ничего не применяет.
Оба сезона в каталоге приходят с бэка; в admin автоматически текущий + предыдущий.

## Базовый вариант без переноса текущих рейтингов на RPC

Существующие запросы **игр и пользователей** оставить. Разделить их по test,
игры completed; инвайты для новых расчётов уже включены в контекст, повторно не суммировать.

1. JSON state `ggRankingContext`, `ggGamesContext`, в профиле `ggProfileContext`.
2. On Load/после подтверждения вызвать `ggLoadContext(period,Environment.test)`
   для соответствующего раздела и сохранить JSON. Если периоды совпадают,
   один загруженный контекст можно использовать для обоих разделов.
3. В widget bindings использовать `ggLocalFromRows(existingGames,existingUsers,
   context,category,page,limit,userId)`; он сам преобразует Supabase rows в JSON.
   Пока запросы/контекст не готовы, возвращает пустой JSON — показывать loading.
   Backend Query при обновлении списка вызывает rebuild и пересчёт функции.
4. У него тот же ranking JSON: players/top_players/current_user,
   total_good_power/total_good_power_all_time, period/available_periods,
   pagination. Профиль лежит в **`$.profile`**, история в **`$.games`**;
   для GamesRow вызвать `ggGamesRows(result)`.
5. Применить таблицы привязок выше, только источник заменить на этот результат.
   Не запускать ggBuildLocalData в On Load до готовности widget Backend Queries:
   одноразовый action не пересчитается автоматически. Он подходит, если списки
   загружаются действиями Query Rows последовательно перед его вызовом.

Этот вариант сохраняет стоимость и ограничения загрузки всех игр на фронт.
Награды и бонусные суммы берутся с бэка; стартовые 100 не прибавлять ещё раз.
При смене инвайтов/бонусов контекст перечитать при возврате/подтверждении фильтра.

## Какие запросы отключить после переключения на RPC

В GoodGamesPage глобальные games/invites/users для расчётов больше не нужны.
Основные контейнеры: Container_9l1w54fh, Container_tuzi6e31,
Container_puvoacps, Container_n9xqchnl. Сначала заменить **все** их потребители,
включая условия Visibility, подиум, pagination и параметры gamesUserComp.
Удаление/отключение Backend Query делать только после проверки оставшихся ссылок.

В userProfilePage Container_vja259xs/3tzmxyks и Container_usgqgitn использовались
для глобальных расчётов. Ранги теперь из RPC. Для Supported Organisations
сохранить отдельный запрос **игр page.userId + test**, поскольку данные организаций
не включены в stats RPC. Запрос самой users-строки оставить: bio, соцсети, Posts
и редактирование профиля не возвращаются статистической функцией.

Не отключать запросы других экранов автоматически. Их разделение prod/test
описано в [QUERY_MAP.md](../QUERY_MAP.md); перенос их расчётов — другой объём.

## Админка сезонов, только вариант admin

Сделать native страницу с формой: key, название, год, дата начала, последний день,
состояние закрытия; выбор prod/test. Доступ проверить сервером, а не одним Visibility.

| Действие | ggSeasonsAdmin(operation,input,test) |
|---|---|
| Загрузить список | list, `{}`, выбранная среда → `$.seasons` |
| Сохранить | save, `{season_key,label,season_year,starts_on,last_day}`, среда |
| Предпросмотр MVP/MAP | preview, `{season_key}`, среда → `$.top_players` / `$.map.top_players` |
| Тестовое закрытие завершённого периода | finalize_test, `{season_key}`, true |

Даты передавать YYYY-MM-DD. Последний день включительный: SQL сам прибавляет день
для ends_at. После save перечитать list. Locked-сезон нельзя редактировать;
закрытие prod выполняется Cron, в форме нет ручной кнопки prod finalize.
Для проверки тестового топа можно создать отдельный уже завершённый тестовый
период, не пересекающий существующие сезоны, и задать game_date тестовых игр
в его диапазоне. Не редактировать сохранённый prod-топ вручную.

## Последняя проверка в тестовой сборке

* Один бонус100 после подтверждённой регистрации; повторный вход не удваивает его.
* Тестовая и продовая игры не смешиваются; MVP/MAP и Total согласованы.
* Оба сезона, обе границы, месяцы и All-Time; auto в паузе между сезонами.
* После игры баллы и ранг обновляются на возврате; после игры другого пользователя
  — по listener. Проверить также reconnect/resume и ошибку RPC.
* Закрытие тестового сезона сохраняет оба топ-3, награда MVP остаётся в MAP.
* Фильтр не применяется до галочки; отмена сохраняет старые значения.
* Скролл сверху не открывает белый фон; снизу сохраняет обычное поведение.

SQL-тесты и CLI dry-run не заменяют этот проход по настоящим привязкам FF.
