if not exists(select * from information_schema.columns where table_name='contract_group' and column_name='holiday_calender_id')
begin
   alter table contract_group add  holiday_calender_id int
end
