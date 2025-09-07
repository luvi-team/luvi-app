-- Create trigger for cycle_data using common function
DROP TRIGGER IF EXISTS set_cycle_data_user_id ON public.cycle_data;
CREATE TRIGGER set_cycle_data_user_id
    BEFORE INSERT ON public.cycle_data
    FOR EACH ROW
    EXECUTE FUNCTION public.set_user_id_from_auth();