-- Create additional trigger for cycle_data (if not exists)
DROP TRIGGER IF EXISTS trg_cycle_owner ON public.cycle_data;
CREATE TRIGGER trg_cycle_owner
    BEFORE INSERT ON public.cycle_data
    FOR EACH ROW
    EXECUTE FUNCTION public.set_user_id_from_auth();