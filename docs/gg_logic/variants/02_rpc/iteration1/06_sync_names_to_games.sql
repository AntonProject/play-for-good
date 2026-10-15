-- Fix: renaming a user wrote the wrong names into public.games.
-- Run the WHOLE file in the Supabase SQL editor (owner).
--
-- unified_game_processing fills a paid game with
--   games.user_name         = users.display_name   (@handle)
--   games.user_display_name = users.first_name
-- but sync_user_names_across_tables, on a rename, wrote display_name into
-- games.user_display_name and never updated games.user_name (a first_name
-- change did not reach games at all). Now a rename writes the same mapping.
--
-- What it changes:
--   public.sync_user_names_across_tables()  replaced; ONLY its games block differs.
--   posts / invites / followers blocks, the trigger, its rights (SECURITY
--   INVOKER, as before) and the condition on which it runs are unchanged.
-- No data is changed by this file: existing games keep their values.
-- Not touched: sync_organization_names_across_tables (organization names in
-- games stay as they were when the game was paid; the app shows the current
-- organization.title by organization_id).

create or replace function public.sync_user_names_across_tables()
returns trigger language plpgsql as $function$
DECLARE
    updated_posts INTEGER := 0;
    updated_games INTEGER := 0;
    updated_invites INTEGER := 0;
    updated_followers INTEGER := 0;
BEGIN
    -- Only proceed if name-related fields were actually changed
    IF (OLD.display_name IS DISTINCT FROM NEW.display_name) OR
       (OLD.first_name IS DISTINCT FROM NEW.first_name) OR
       (OLD.surname IS DISTINCT FROM NEW.surname) THEN

        -- Update posts table
        IF OLD.display_name IS DISTINCT FROM NEW.display_name THEN
            UPDATE public.posts
            SET
                user_display_name = NEW.display_name
            WHERE
                user_id = NEW.id;

            GET DIAGNOSTICS updated_posts = ROW_COUNT;
            RAISE NOTICE 'Updated % posts for user %', updated_posts, NEW.id;
        END IF;

        -- Update games table (same mapping as unified_game_processing:
        -- user_name = display_name, user_display_name = first_name)
        IF (OLD.display_name IS DISTINCT FROM NEW.display_name) OR
           (OLD.first_name IS DISTINCT FROM NEW.first_name) THEN
            UPDATE public.games
            SET
                user_name = CASE
                    WHEN OLD.display_name IS DISTINCT FROM NEW.display_name
                        THEN COALESCE(NEW.display_name, 'Unknown User')
                    ELSE user_name
                END,
                user_display_name = CASE
                    WHEN OLD.first_name IS DISTINCT FROM NEW.first_name
                        THEN COALESCE(NEW.first_name, 'Unknown User')
                    ELSE user_display_name
                END
            WHERE
                creator_user_id = NEW.id;

            GET DIAGNOSTICS updated_games = ROW_COUNT;
            RAISE NOTICE 'Updated % games for user %', updated_games, NEW.id;
        END IF;

        -- Update invites table (for registered users)
        UPDATE public.invites
        SET
            registered_user_display_name = CASE
                WHEN OLD.display_name IS DISTINCT FROM NEW.display_name THEN NEW.display_name
                ELSE registered_user_display_name
            END,
            registered_user_first_name = CASE
                WHEN OLD.first_name IS DISTINCT FROM NEW.first_name THEN NEW.first_name
                ELSE registered_user_first_name
            END,
            registered_user_surname = CASE
                WHEN OLD.surname IS DISTINCT FROM NEW.surname THEN NEW.surname
                ELSE registered_user_surname
            END
        WHERE
            registered_user_id = NEW.id
            AND was_used = true;

        GET DIAGNOSTICS updated_invites = ROW_COUNT;
        IF updated_invites > 0 THEN
            RAISE NOTICE 'Updated % invites for user %', updated_invites, NEW.id;
        END IF;

        -- Update followers table (for following users)
        IF OLD.display_name IS DISTINCT FROM NEW.display_name THEN
            UPDATE public.followers
            SET
                following_user_name = NEW.display_name
            WHERE
                following_user_id = NEW.id
                AND is_active = true;

            GET DIAGNOSTICS updated_followers = ROW_COUNT;
            IF updated_followers > 0 THEN
                RAISE NOTICE 'Updated % followers for user %', updated_followers, NEW.id;
            END IF;
        END IF;

        -- Log summary
        RAISE NOTICE 'User name sync completed for user % (display_name: %, first_name: %, surname: %)',
            NEW.id, NEW.display_name, NEW.first_name, NEW.surname;

    END IF;

    RETURN NEW;
END;
$function$;
