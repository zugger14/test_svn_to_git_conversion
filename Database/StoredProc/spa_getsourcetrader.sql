set ANSI_NULLS ON/****** Object:  StoredProcedure [dbo].[spa_getsourcetrader]    Script Date: 02/27/2009 12:50:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getsourcetrader]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getsourcetrader]

 GO 





-- EXEC spa_getsourcetrader 'b', null
-- eff_test_profile_id should be the book id...


CREATE Proc [dbo].[spa_getsourcetrader] 
@flag char(1),
@eff_test_profile_id int=NULL
as 
if @flag='s'
begin
if @eff_test_profile_id is not null
	select d.source_trader_id trader_id, d.trader_name + CASE WHEN ssd.source_system_id=2 THEN '' ELSE '.' + ssd.source_system_name END AS trader_name
	from portfolio_hierarchy b, fas_strategy c, source_traders d INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id
	where b.entity_id = @eff_test_profile_id
	and  b.parent_entity_id = c.fas_strategy_id
	and (d.source_system_id = c.source_system_id)
    order by d.trader_name asc
else
	select d.source_trader_id trader_id,
	d.trader_name + case when ssd.source_system_id=2 then '' else '.' + ssd.source_system_name end  as trader_name
	from source_system_description ssd inner join source_traders d on d.source_system_id = ssd.source_system_id
	order by trader_name
	

end
if @flag='b' --for blotter mode 0,1
begin
if @eff_test_profile_id is not null
	select d.source_trader_id,  d.trader_name + CASE WHEN ssd.source_system_id=2 THEN '' ELSE '.' + ssd.source_system_name END AS trader_name
	from portfolio_hierarchy b, fas_strategy c, source_traders d INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id
	where b.entity_id = @eff_test_profile_id
	and  b.parent_entity_id = c.fas_strategy_id
	and (d.source_system_id = c.source_system_id)
    order by d.trader_name asc
else
	select d.source_trader_id, 
	d.trader_name + case when ssd.source_system_id=2 then '' else '.' + ssd.source_system_name end  as trader_name
	from source_system_description ssd inner join source_traders d on d.source_system_id = ssd.source_system_id
	order by trader_name
	

end
IF @flag='t'
	BEGIN
		SELECT source_trader_id
		FROM source_traders 
		WHERE user_login_id = dbo.FNADBUser()
	END

if @flag='a' 
begin
select d.source_trader_id,d.source_trader_id trader_id, d.trader_name + CASE WHEN ssd.source_system_id=2 THEN '' ELSE '.' + ssd.source_system_name END AS trader_name
from source_traders d
	 INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id
end
If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'source traders', 
				'spa_getsourcetrader', 'DB Error', 
				'Failed to select source traders.', ''




