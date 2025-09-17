-- Common helper functions for RLS and triggers

-- Function to auto-set user_id from auth.uid() on INSERT
CREATE OR REPLACE FUNCTION public.set_user_id_from_auth()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    NEW.user_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;