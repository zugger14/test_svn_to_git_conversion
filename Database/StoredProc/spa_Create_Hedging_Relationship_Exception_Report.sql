IF OBJECT_ID(N'spa_Create_Hedging_Relationship_Exception_Report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Hedging_Relationship_Exception_Report]
 GO 



-- DROP PROC spa_Create_Hedging_Relationship_Exception_Report

--===========================================================================================
--This Procedure create Measuremetnt Reports
--Input Parameters:
--@as_of_date - effective date
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@used_option - takes 'a', 'u' corresponding to 'all' , 'used' report
--===========================================================================================
 CREATE PROC [dbo].[spa_Create_Hedging_Relationship_Exception_Report] @as_of_date varchar(50) = NULL, @sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL,
	@used_option char(1)
 AS

 SET NOCOUNT ON

-- -- 
-- declare @as_of_date varchar(50), @sub_entity_id varchar(100), 
--  	@strategy_entity_id varchar(100), 
--  	@book_entity_id varchar(100),  @used_option char(1)
--  
-- set @as_of_date='4/30/2003'
-- set  @sub_entity_id ='1'
-- set @used_option ='u'
-- set @strategy_entity_id = null --'3'
-- set @book_entity_id  = null --'10'

Declare @Sql_Select varchar(5000)

Declare @Sql_From varchar(5000)

Declare @Sql_Where varchar(5000)

Declare @Sql_GpBy varchar(5000)


Declare @Sql1 varchar(8000)
Declare @Sql2 varchar(8000)

--==================================================================================================

IF @used_option = 'a' 

BEGIN

	
	SET @Sql_Select = 'SELECT     sub.entity_name AS Subsidiary, stgy.entity_name AS Strategy, bk.entity_name AS Book, 
				fehrt.eff_test_profile_id AS [Hedging Relationship Type ID], 
		                fehrt.eff_test_name AS [Relationship Type Name], 
				CASE WHEN (fehrt.risk_mgmt_strategy =''n'' OR fehrt.risk_mgmt_policy = ''n'' OR formal_documentation = ''n'') 
				THEN ''Yes'' ELSE ''No'' END AS [Documentation Exception], 
		                CASE WHEN (fehrt.init_eff_test_approach_value_id = fehrt.on_eff_test_approach_value_id AND
						fehrt.init_assmt_curve_type_value_id = fehrt.on_assmt_curve_type_value_id AND
						fehrt.init_curve_source_value_id = fehrt.on_curve_source_value_id AND
						fehrt.init_number_of_curve_points = fehrt.on_number_of_curve_points)
				THEN ''No'' ELSE ''Yes'' END AS [Initial And Ongoing Assessment Difference], 
				CASE WHEN(fehrt.inherit_assmt_eff_test_profile_id IS NOT NULL)
				THEN ''YES'' ELSE ''NO'' END AS [Inherit Assessment Value], 
				dbo.FNADateFormat(fehrt.create_ts) AS [Created Date], 
				fehrt.create_user AS [Created By], 
				ISNULL((CAST(day(fehrt.profile_approved_date) As Varchar) + ''/'' + 
					CAST(month(fehrt.profile_approved_date) As Varchar) + ''/'' + 
					CAST(year(fehrt.profile_approved_date) AS Varchar)),'''') AS [Approved Date], 
				ISNULL(fehrt.profile_approved_by,'''') AS [Approved By]
			FROM         portfolio_hierarchy sub(NOLOCK) INNER JOIN
		                      portfolio_hierarchy stgy(NOLOCK) INNER JOIN
		                      fas_eff_hedge_rel_type fehrt(NOLOCK) INNER JOIN
		                      portfolio_hierarchy bk(NOLOCK) ON fehrt.fas_book_id = bk.entity_id 
						ON stgy.entity_id = bk.parent_entity_id 
						ON sub.entity_id = stgy.parent_entity_id '
			
	
	
	SET @Sql_Where = ' WHERE   (fehrt.effective_start_date <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102)) AND   
						                      (sub.entity_id IN( ' + @sub_entity_id + ')) '
					
	IF @strategy_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (stgy.entity_id IN(' + @strategy_entity_id + ' ))'
	IF @book_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (bk.entity_id IN(' + @book_entity_id + ')) '

	EXEC (@Sql_Select + @Sql_Where)
	
END


IF @used_option = 'u' 

BEGIN

	
	SET @Sql_Select = 'SELECT     sub.entity_name AS Subsidiary, stgy.entity_name AS Strategy, bk.entity_name AS Book, 
				fehrt.eff_test_profile_id AS [Hedging Relationship Type ID], 
		                fehrt.eff_test_name AS [Relationship Type Name], 
				CASE WHEN (fehrt.risk_mgmt_strategy =''n'' OR fehrt.risk_mgmt_policy = ''n'' OR formal_documentation = ''n'') 
				THEN ''Yes'' ELSE ''No'' END AS [Documentation Exception], 
		                CASE WHEN (fehrt.init_eff_test_approach_value_id = fehrt.on_eff_test_approach_value_id AND
						fehrt.init_assmt_curve_type_value_id = fehrt.on_assmt_curve_type_value_id AND
						fehrt.init_curve_source_value_id = fehrt.on_curve_source_value_id AND
						fehrt.init_number_of_curve_points = fehrt.on_number_of_curve_points)
				THEN ''No'' ELSE ''Yes'' END AS [Initial And Ongoing Assessment Difference], 
				CASE WHEN(fehrt.inherit_assmt_eff_test_profile_id IS NOT NULL)
				THEN ''YES'' ELSE ''NO'' END AS [Inherit Assessment Value], 
				dbo.FNADateFormat(fehrt.create_ts) AS [Created Date], 
				fehrt.create_user AS [Created By], 
				ISNULL((CAST(day(fehrt.profile_approved_date) As Varchar) + ''/'' + 
					CAST(month(fehrt.profile_approved_date) As Varchar) + ''/'' + 
					CAST(year(fehrt.profile_approved_date) AS Varchar)),'''') AS [Approved Date], 
				ISNULL(fehrt.profile_approved_by,'''') AS [Approved By]
			FROM         portfolio_hierarchy sub(NOLOCK) INNER JOIN
		                      portfolio_hierarchy stgy(NOLOCK) INNER JOIN
		                      fas_eff_hedge_rel_type fehrt(NOLOCK) INNER JOIN
		                      portfolio_hierarchy bk(NOLOCK) ON fehrt.fas_book_id = bk.entity_id 
						ON stgy.entity_id = bk.parent_entity_id 
						ON sub.entity_id = stgy.parent_entity_id 
				INNER JOIN
                      			(SELECT DISTINCT eff_test_profile_id FROM fas_link_header(NOLOCK) 
						WHERE   (link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date  +''', 102))) flh
					ON fehrt.eff_test_profile_id = flh.eff_test_profile_id '

	
	SET @Sql_Where = '  AND   (sub.entity_id IN( ' + @sub_entity_id + ')) '
					
	IF @strategy_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (stgy.entity_id IN(' + @strategy_entity_id + ' ))'
	IF @book_entity_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (bk.entity_id IN(' + @book_entity_id + ')) '

	
	EXEC (@Sql_Select + @Sql_Where)
	
END







