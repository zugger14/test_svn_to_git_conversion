IF OBJECT_ID(N'spa_getsourcesystem', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getsourcesystem]
GO 

CREATE PROC [dbo].[spa_getsourcesystem]
	@flag CHAR(1),
	@eff_test_profile_id INT = NULL,
	@strategy_id INT = NULL
AS 
IF @eff_test_profile_id IS NOT NULL
begin
	select d.source_system_id, d.source_system_id source_system_id, d.source_system_name
	from portfolio_hierarchy b, fas_strategy c, source_system_description d
	where b.entity_id = @eff_test_profile_id
	and  b.parent_entity_id = c.fas_strategy_id
	and (d.source_system_id = c.source_system_id)
	
	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'source traders', 
					'spa_getsourcetrader', 'DB Error', 
					'Failed to select source traders.', ''
end
else if @strategy_id is not null
begin
	select d.source_system_id, d.source_system_id source_system_id, d.source_system_name
	from  fas_strategy c, source_system_description d
	where   c.fas_strategy_id = @strategy_id
	and (d.source_system_id = c.source_system_id)
	
	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'source traders', 
					'spa_getsourcetrader', 'DB Error', 
					'Failed to select source traders.', ''
end
else
begin
	select distinct d.source_system_id, d.source_system_id source_system_id, d.source_system_name
	from  fas_strategy c, source_system_description d
	where  d.source_system_id = c.source_system_id 
end






