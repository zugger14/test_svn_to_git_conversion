
IF OBJECT_ID(N'[dbo].[spa_get_dedesignation_per_available]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_dedesignation_per_available]
GO 



--@link_id is the designation link id being de-designated
--@d_link_id is the de-designation  link de-designating @link_id
--output is the percentage of the de-designation  link that can be applied for de-desigantion
-- exec spa_get_dedesignation_per_available 110, 111, 1, '2004-06-30'
-- exec spa_get_dedesignation_per_available 52, 80, 1, '2004-06-30'
CREATE PROC [dbo].[spa_get_dedesignation_per_available] 
	@link_id int, 
	@d_link_id int, 
	@d_percentage float, 
	@as_of_date datetime
AS
  

-- -- -- drop table  #temp_Dedes
-- DECLARE @link_id int
-- DECLARE @d_link_id int
-- DECLARE @d_percentage float
-- DECLARE @as_of_date datetime
-- declare @use_regional_date_format varchar(1)
-- 
-- -- SET @link_id = 112
-- -- SET @d_link_id = 113
-- SET @link_id = 110
-- SET @d_link_id = 111
-- -- SET @link_id = 52
-- -- SET @d_link_id = 60
-- --set @use_regional_date_format = 'n'
-- SET @d_percentage = 1
-- SET @as_of_date = '6/30/2004'




CREATE TABLE #temp (
	[Exception] [varchar] (3) COLLATE DATABASE_DEFAULT  NULL ,
	[DedesigHedgingRelID] [int] NULL ,
	[EffectiveDate] [datetime] NULL ,
	[HedgingRelID] [int] NULL ,
	[HedgeItem] [varchar] (5) COLLATE DATABASE_DEFAULT  NULL ,
	[TermStart] [datetime] NULL ,
	[TermEnd] [datetime] NULL ,
	[Index] [varchar] (100) COLLATE DATABASE_DEFAULT  NULL ,
	[DedesignationVolume] [varchar] (30) COLLATE DATABASE_DEFAULT  NULL ,
	[DesignationVolume] [varchar] (30) COLLATE DATABASE_DEFAULT  NULL ,
	[UOMID] [int] NULL ,
	[UOM] [varchar] (100) COLLATE DATABASE_DEFAULT  NULL ,
	[PercentageDedesignated] [varchar] (30) COLLATE DATABASE_DEFAULT  NULL ,
	[AllowedPercentageDedesignation] [varchar] (30) COLLATE DATABASE_DEFAULT  NULL ,
	[PercentageRelationship] [varchar] (30) COLLATE DATABASE_DEFAULT  NULL 
) ON [PRIMARY]

INSERT #temp
exec spa_Validate_Dedesignated_Links @link_id, @d_link_id, @d_percentage, @as_of_date, 'n'

--if proceed option is 0 then  allow to proceed with warning
--if proceed option is 1 then  do not allow...
if (select count(*) from  #temp) = 0
	select 0 as percentage_available, 0 proceed_option
else
	select isnull(min(PercentageRelationship), 0) percentage_available, 0 proceed_option from #temp
	where DedesigHedgingRelID = @d_link_id







