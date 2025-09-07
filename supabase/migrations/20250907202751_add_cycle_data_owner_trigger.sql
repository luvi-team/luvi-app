create or replace function public.set_user_id_from_auth()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.user_id is null then
    new.user_id := auth.uid();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_cycle_owner on public.cycle_data;
create trigger trg_cycle_owner
before insert on public.cycle_data
for each row
execute function public.set_user_id_from_auth();