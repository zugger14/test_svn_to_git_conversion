
set ANSI_NULLS ON/****** Object:  StoredProcedure [dbo].[spa_getsourcebrokers]    Script Date: 02/27/2009 12:50:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getsourcebrokers]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getsourcebrokers]

set QUOTED_IDENTIFIER ON
go





--exec spa_getsourcebrokers 's',  120


-- DROP PROC spa_getsourcebrokers
-- EXEC spa_getsourcebrokers 'b', 10
-- eff_test_profile_id should be the book id...


CREATE Proc [dbo].[spa_getsourcebrokers] 
@flag char(1),
@eff_test_profile_id int=NULL
as 

declare @sql_stmt as varchar (5000)
if @flag= 's'
BEGIN

		IF @eff_test_profile_id is not null
			select d.source_broker_id, d.source_broker_id broker_id, d.broker_name
			from portfolio_hierarchy b, fas_strategy c, source_brokers d
			where b.entity_id =@eff_test_profile_id
			and  b.parent_entity_id = c.fas_strategy_id
			and (d.source_system_id = c.source_system_id)
		else
			select d.source_broker_id, d.source_broker_id broker_id,
			d.broker_name + '.' + case when ssd.source_system_id=2 then '' else ssd.source_system_name  end  as broker_name
			from source_system_description ssd, source_brokers d
			where d.source_system_id = ssd.source_system_id
		order by ssd.source_system_name + ',' + broker_name asc

		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, 'source brokers', 
						'spa_getsourcebrokers', 'DB Error', 
						'Failed to select source brokers.', ''

END
if @flag= 'b' -- for blotter mode 0,1
BEGIN
SET @sql_stmt='
	select DISTINCT 
		d.source_counterparty_id,		
		d.counterparty_name + case when ssd.source_system_id=2 then '''' else ''.'' + ssd.source_system_name end as counterparty_name
	from 
		portfolio_hierarchy b inner join 
		fas_strategy c on b.parent_entity_id = c.fas_strategy_id inner join 
		source_system_description ssd on ssd.source_system_id = c.source_system_id inner join
		source_counterparty d on d.source_system_id = ssd.source_system_id 
	where 1=1 '
		+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
		+' and d.int_ext_flag IN(''b'')

	order by counterparty_name asc'

EXEC spa_print @sql_stmt
EXEC(@sql_stmt)

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'source Counterparty', 
				'spa_getsourcecounterparty', 'DB Error', 
				'Failed to select source counterparties.', ''

END
if @flag ='a'
BEGIN
SET @sql_stmt='
	select DISTINCT 
		d.source_counterparty_id,
		d.source_counterparty_id counterparty_id, 
		d.counterparty_name + case when ssd.source_system_id=2 then '''' else ''.'' + ssd.source_system_name end as counterparty_name
	from 
		portfolio_hierarchy b inner join 
		fas_strategy c on b.parent_entity_id = c.fas_strategy_id inner join 
		source_system_description ssd on ssd.source_system_id = c.source_system_id inner join
		source_counterparty d on d.source_system_id = ssd.source_system_id 
	where 1=1 '
		+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' AND b.entity_id ='+CAST(@eff_test_profile_id AS VARCHAR) ELSE '' END 
		+' and d.int_ext_flag IN(''b'')

	order by counterparty_name  asc'

EXEC spa_print @sql_stmt
EXEC(@sql_stmt)

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'source Counterparty', 
				'spa_getsourcecounterparty', 'DB Error', 
				'Failed to select source counterparties.', ''

END





