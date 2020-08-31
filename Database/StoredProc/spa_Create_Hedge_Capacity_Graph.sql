
IF OBJECT_ID(N'spa_Create_Hedge_Capacity_Graph', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Hedge_Capacity_Graph]
 GO 



--===========================================================================================
--This Procedure returns source system configuration for each strategy
--Input Parameters:
--@as_of_date - As of date
-- @sub_id - subsidiary Id (optional)
--@strategy_id - strategy Id (optional)
--@book_id - book Id (optional)
--@discount_flag - 'u' or 'd'
--@hedge_type = 'c' or 'f'

--===========================================================================================
-- EXEC spa_Create_Hedge_Capacity_Graph '4/30/2003', '1', null, null, 'c', 2, 'e'
-- DROP PROC spa_Create_Hedge_Capacity_Graph

CREATE PROC [dbo].[spa_Create_Hedge_Capacity_Graph]     
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@report_type char(1), 
	@convert_unit_id int,
	@exception_flag char(1)

	
AS

SET NOCOUNT ON

CREATE TABLE #my_temp
(sub Varchar(100) COLLATE DATABASE_DEFAULT,
strategy varchar(100) COLLATE DATABASE_DEFAULT, 
book varchar(100) COLLATE DATABASE_DEFAULT, 
index_name varchar(100) COLLATE DATABASE_DEFAULT,
contract_month varchar(20) COLLATE DATABASE_DEFAULT,
volume_frequency varchar(20) COLLATE DATABASE_DEFAULT,
volume_uom varchar(20) COLLATE DATABASE_DEFAULT,
asset_vol float,
item_vol float,
net_vol float,
over_hedged varchar(5) COLLATE DATABASE_DEFAULT)

INSERT #my_temp EXEC  spa_Create_Available_Hedge_Capacity_Exception_Report 
					@as_of_date,@sub_entity_id, 
					@strategy_entity_id, @book_entity_id,@report_type,'s',
					@convert_unit_id, @exception_flag


SELECT (Book + '_' + index_name) [Book_Index], isnull((sum(item_vol)/sum(asset_vol)), -1) [PercentageHedged] FROM #my_temp
	GROUP BY (Book + '_' + index_name) ORDER BY (Book + '_' + index_name)


-- EXEC spa_Create_Available_Hedge_Capacity_Exception_Report '4/30/2003', 1, NULL, NULL,'c','s',2, 'e'
					







