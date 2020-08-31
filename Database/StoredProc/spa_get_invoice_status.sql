IF OBJECT_ID(N'[dbo].[spa_get_invoice_status]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_invoice_status]
GO 

create proc [dbo].[spa_get_invoice_status]
AS

select 'v' as status_id, 'Voided' as Code
union
select 's' as status_id, 'Sent' as Code






