
set identity_insert static_data_value on
GO
insert into static_data_value(value_id,type_id,code,description)
select 35,25,'Dispute','Dispute'
GO
set identity_insert static_data_value off
GO
update application_notes set category_value_id=35 where notes_id=66
exec spa_Get_All_Notes '35', '6', NULL, '35', NULL, NULL, NULL
