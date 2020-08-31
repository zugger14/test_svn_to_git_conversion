--select * from static_data_value where code like '%monthly%' TYPE_ID=700

--delete static_data_value where value_id=707
--select * from static_data_value where TYPE_ID=978
if not exists(select 1 from  static_data_value where value_id=707)
begin
	set identity_insert static_data_value ON
	insert into static_data_value(value_id,type_id,code,description) values(707,700,'Term','Term')
	set identity_insert static_data_value OFF
end

--exec spa_getVolumeFrequency