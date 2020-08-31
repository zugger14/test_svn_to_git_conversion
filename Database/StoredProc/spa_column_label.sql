IF OBJECT_ID(N'spa_column_label', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_column_label]
 GO 
create proc [dbo].[spa_column_label]
@form_name varchar(150),
@field_name varchar(150),
@label_name varchar(150)=null
as
select isNUll(case customer_label when 'Acc Name' then 'Account Name' when 'Description ACC' then 'A/C Description 1' 
when 'Description ACC2' then 'A/C Description 2' when 'Acc Number' then 'Account Number' else '' end,our_label) label from column_label
where form_name=@form_name and field_name=@field_name



