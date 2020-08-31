--
-- STORED PROCEDURE
--     spa_combo_year
--
-- DESCRIPTION
--     Display year for combo
--
-- PARAMETERS
--		@start_date
--         * Starting Year
--		@end_year
--		   * Ending Year
--
-- RESULT VALUE
--     -Display year values for combo.
--

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_combo_year]') AND TYPE IN (N'P', N'PC'))
BEGIN
DROP PROCEDURE [dbo].[spa_combo_year]
END
GO

CREATE PROCEDURE [dbo].[spa_combo_year]	
	@flag  CHAR(1),	
	@start_date INT = NULL,				
	@end_date INT = NULL
	
AS
IF @flag = 's'
BEGIN
	WITH yearlist as (
			select @start_date as year, 
				   @start_date as ID 
			union all 
			select	yl.year + 1 as year,
					yl.ID + 1 as ID
			from yearlist yl where yl.year + 1 <= @end_date 
			) 
			select ID AS id, year AS value 
			FROM yearlist ORDER by year ASC
END