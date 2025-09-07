CREATE OR REPLACE FUNCTION public.set_user_id_from_auth()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.user_id IS NULL OR NEW.user_id <> auth.uid() THEN
    NEW.user_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;