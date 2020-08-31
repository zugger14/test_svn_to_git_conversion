--select * from static_data_value where type_id=20700

Update static_data_value set code='Paid',description='Paid' where value_id=20701
Update static_data_value set code='Invoice Sent',description='Invoice Sent' where value_id=20700

DELETE FROM static_data_value where value_id=20704
