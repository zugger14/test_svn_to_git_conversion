if exists(select 'x' from static_data_value where type_id=5600)
update static_data_value set code ='Complete' where type_id=5600