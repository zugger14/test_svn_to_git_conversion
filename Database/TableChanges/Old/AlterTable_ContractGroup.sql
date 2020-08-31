/**********************************
Add approval status in contract_group table

select * from contract_group
select * from static_data_value where code like '%approve%'
select * from static_data_value where type_id=1900
select * from static_data_type where internal=1 order by type_id
*********************************/

IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'contract_group' and column_name = 'contract_status')
	ALTER TABLE [dbo].[contract_group] ADD [contract_status] [int] NULL

----########### Insert into static_data_type and static_data_value Contract_status
if not exists(select * from static_data_type where [type_id]=1900)
	INSERT INTO static_data_type([type_id],[type_name],[internal],[description])
	SELECT  1900,'Contract Status',1,'Contract Status'
--
	Set identity_insert static_data_value on
	GO
if not exists(select * from static_data_value where [type_id]=1900)
	insert into static_data_value(value_id,[type_id],[code],[description])
	select 1900,1900,'Approved','Approved'
	UNION
	select 1901,1900,'Unapproved','Unapproved'
	UNION
	select 1902,1900,'Pending','Pending'

	GO		
	Set identity_insert static_data_value off
	GO
