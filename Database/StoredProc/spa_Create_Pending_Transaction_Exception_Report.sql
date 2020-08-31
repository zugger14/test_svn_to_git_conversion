IF OBJECT_ID(N'spa_Create_Pending_Transaction_Exception_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Pending_Transaction_Exception_Report]
 GO 



-- DROP PROC spa_Create_Pending_Transaction_Exception_Report


--===========================================================================================
--This Procedure spa_Create_Pending_Transaction_Exception_Report
--Input Parameters:
--@from_date 
--@to_date 
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--===========================================================================================
 CREATE PROC [dbo].[spa_Create_Pending_Transaction_Exception_Report] @from_date varchar(50) = NULL, @to_date varchar(50) = NULL,
	@sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL
 AS

 SET NOCOUNT ON

-- 
-- declare @from_date varchar(50), @sub_entity_id varchar(100), 
--  	@strategy_entity_id varchar(100), 
--  	@book_entity_id varchar(100),  @to_date varchar(100)
--  
-- set @from_date='2/1/2003'
-- set @to_date='4/30/2003'
-- set  @sub_entity_id ='2,1'
-- --set @strategy_entity_id = '3'
-- --set @book_entity_id  = '10'

Declare @Sql_Select varchar(5000)

Declare @Sql_Where varchar(5000)


--==================================================================================================
	
	SET @Sql_Select = 'SELECT     sub.entity_name AS Subdiary, stgy.entity_name AS Strategy, bk.entity_name AS Book, ssd.source_system_name AS [RiskSystemName], 
                      gdh.gen_deal_header_id AS [GenDealNo], grp1.source_book_name AS [Group1], grp2.source_book_name AS [Group2], 
                      grp3.source_book_name AS [Group3], grp4.source_book_name AS [Group4], dbo.FNADateFormat(gdh.deal_date) AS [DealDate], dbo.FNADateFormat(gdh.create_ts) AS [CreatedDate], 
                      gdh.create_user AS [CreatedBy], gdh.number_attempts AS [NoOfAttempts], gen_fas_link_detail.gen_link_id As GenFasLinkDetail
		FROM         source_book grp1 INNER JOIN
                      source_system_book_map ssbm ON grp1.source_book_id = ssbm.source_system_book_id1 INNER JOIN
                      source_book grp2 ON ssbm.source_system_book_id2 = grp2.source_book_id INNER JOIN
                      source_book grp3 ON ssbm.source_system_book_id3 = grp3.source_book_id INNER JOIN
                      source_book grp4 ON ssbm.source_system_book_id4 = grp4.source_book_id INNER JOIN
                      gen_deal_header gdh ON ssbm.source_system_book_id1 = gdh.source_system_book_id1 AND 
                      ssbm.source_system_book_id2 = gdh.source_system_book_id2 AND ssbm.source_system_book_id3 = gdh.source_system_book_id3 AND 
                      ssbm.source_system_book_id4 = gdh.source_system_book_id4 INNER JOIN
                      portfolio_hierarchy bk ON ssbm.fas_book_id = bk.entity_id INNER JOIN
                      portfolio_hierarchy stgy ON bk.parent_entity_id = stgy.entity_id INNER JOIN
                      portfolio_hierarchy sub ON stgy.parent_entity_id = sub.entity_id INNER JOIN
                      source_system_description ssd ON gdh.source_system_id = ssd.source_system_id INNER JOIN
                      gen_fas_link_detail ON gdh.gen_deal_header_id = gen_fas_link_detail.deal_number '
			

	
	SET @Sql_Where = ' WHERE   (gdh.gen_status = ''a'' AND gdh.deal_date BETWEEN CONVERT(DATETIME, ''' + @from_date  +''', 102) AND 
						CONVERT(DATETIME, ''' + @to_date  +''', 102))
					 AND   
					                   (sub.entity_id IN( ' + @sub_entity_id + ')) '
					
	IF @strategy_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (stgy.entity_id IN(' + @strategy_entity_id + ' ))'
	IF @book_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (bk.entity_id IN(' + @book_entity_id + ')) '

	EXEC (@Sql_Select + @Sql_Where)





