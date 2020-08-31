  IF OBJECT_ID(N'[dbo].[spa_as_of_date]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_as_of_date]
 GO
  
 SET ANSI_NULLS ON
 GO
  
 SET QUOTED_IDENTIFIER ON
 GO
  
-- ===============================================================================================================
-- Author: Bikesh Manandhar
-- Create date: 2017-03-02
-- Description: 
 
-- Params:
-- @flag CHAR(1) - Description of Param2
-- @screen_id : screen to set the as of date
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_as_of_date]
	@flag VARCHAR(50) =NULL,
	@setup_as_of_date_id INT = NULL,
	@screen_id INT = NULL,
	@module_id  VARCHAR(10)= NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT  DISTINCT
		sad.setup_as_of_date_id AS [id],		
		sm_s.display_name  AS [screen],
		sm_m.display_name AS [module],
		sad.as_of_date  AS [as_of_date] 
	FROM setup_as_of_date sad
	INNER JOIN setup_menu sm_m
		ON sm_m.function_id = sad.module_id
	INNER JOIN  setup_menu sm_s
		ON sm_s.function_id = sad.screen_id
		INNER JOIN  setup_menu sm_sa
		ON sm_s.function_id = sad.screen_id
END
IF @flag = 'a'
BEGIN
	SELECT 
		as_of_date , no_of_days, custom_as_of_date
	FROM setup_as_of_date 
	WHERE screen_id = @screen_id
END

ELSE IF @flag = 'b'
BEGIN
	SELECT 
		function_id ,
		display_name  
	FROM setup_menu 
	WHERE parent_menu_id = '13000000' 
	ORDER BY display_name
END

ELSE IF @flag = 'c'
BEGIN
	IF @module_id IS NULL
	BEGIN
		SELECT 
			function_id AS [id],
			display_name AS [value] 
		FROM setup_menu sm
		LEFT JOIN (
			SELECT sm.parent_menu_id 
			FROM setup_menu sm 
				INNER JOIN setup_menu smp ON sm.parent_menu_id = smp.function_id 
			WHERE smp.product_category = '13000000'				
				AND sm.product_category = '13000000'
		)a
		ON sm.function_id = a.parent_menu_id
		WHERE sm.product_category = '13000000'
			AND a.parent_menu_id IS NULL
		UNION ALL
		SELECT sm.function_id AS [id],
			sm.display_name AS [value]  
		FROM setup_menu sm 
		INNER JOIN setup_menu smp 
			ON sm.parent_menu_id = smp.function_id 
		WHERE smp.product_category = '13000000'
			AND sm.product_category = '13000000'
	END
	ELSE
	BEGIN
		SELECT 
			function_id AS [id],
			display_name AS [value] 
		FROM setup_menu sm
		LEFT JOIN (
			SELECT sm.parent_menu_id 
			FROM setup_menu sm 
				INNER JOIN setup_menu smp ON sm.parent_menu_id = smp.function_id 
			WHERE smp.product_category = '13000000'
				AND smp.parent_menu_id = + @module_id 
				AND sm.product_category = '13000000'
		)a
		ON sm.function_id = a.parent_menu_id
		WHERE sm.product_category = '13000000'
			AND sm.parent_menu_id = + @module_id 
			AND a.parent_menu_id IS NULL
		UNION ALL
		SELECT sm.function_id AS [id],
			sm.display_name AS [value]  
		FROM setup_menu sm 
		INNER JOIN setup_menu smp 
			ON sm.parent_menu_id = smp.function_id 
		WHERE smp.product_category = '13000000'
			AND smp.parent_menu_id = + @module_id 
			AND sm.product_category = '13000000'
	END	
END