-- READ-ONLY (21.10.2026). Users without their own photo show a red basketball
-- logo instead of the white placeholder: their photo_url is not empty but a
-- shared default image. Which URLs are shared by many users, and where does
-- the value come from (column default)?

-- 1) Most frequent photo_url values (a shared default shows a big count).
select coalesce(nullif(photo_url, ''), '(empty)') as photo_url, count(*) as users
from public.users
group by 1
order by 2 desc
limit 15;

-- 2) Column default of users.photo_url (if any).
select column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'users' and column_name = 'photo_url';
