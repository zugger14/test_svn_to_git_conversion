IF OBJECT_ID(N'[dbo].[spa_get_counterparty_netting]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_counterparty_netting]
GO 

create procedure [dbo].[spa_get_counterparty_netting]
	@flag char(1),
	@counterparty_id int

AS
BEGIN

	select 
		source_counterparty_id,counterparty_name
	from
		source_counterparty
	where source_counterparty_id=@counterparty_id
	UNION
	select	
		source_counterparty_id,counterparty_name
	from
		source_counterparty
	where
		source_counterparty_id in(select netting_parent_counterparty_id from source_counterparty
			where source_counterparty_id=@counterparty_id)
		
END


