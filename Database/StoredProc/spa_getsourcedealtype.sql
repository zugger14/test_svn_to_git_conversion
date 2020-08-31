/****** Object:  StoredProcedure [dbo].[spa_getsourcedealtype]    Script Date: 05/20/2010 21:18:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getsourcedealtype]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getsourcedealtype]
/****** Object:  StoredProcedure [dbo].[spa_getsourcedealtype] 's', 'y'   Script Date: 05/20/2010 21:18:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 

CREATE PROC [dbo].[spa_getsourcedealtype] 
	@flag NCHAR(1),
	@sub_type NCHAR(1) = 'n',
	@fas_book_id INT = NULL,
	@source_deal_type_id INT = NULL,
	@source_system_id INT = NULL
AS 


DECLARE @stmt NVARCHAR(MAX)

SET @stmt = '
	SELECT DISTINCT 
	       d.source_deal_type_id,
	       d.source_deal_type_name + CASE 
	                                      WHEN ssd.source_system_id = 2 THEN ''''
	                                      ELSE ''.'' + ssd.source_system_name

	                                 END     source_system_name'
IF @flag = 's'	                                 
	SET @stmt = @stmt + '
			   ,CASE 
					WHEN d.source_deal_type_name = ''Spot'' THEN ''s''
					WHEN d.source_deal_type_name = ''Term'' THEN ''t''
					ELSE ''b''
			   END                            AS char_value '

-- For Dropdown
ELSE IF @flag = 'd'
	SET @stmt = @stmt + '' 
	       
SET @stmt = @stmt + '	  
	FROM   portfolio_hierarchy b
	    INNER JOIN fas_strategy c
	        ON  b.parent_entity_id = c.fas_strategy_id 
			AND b.entity_id = ISNULL(' + ISNULL(CAST(@fas_book_id AS NVARCHAR), 'NULL') + ', b.entity_id)
		INNER JOIN source_deal_type d
			ON d.source_system_id = c.source_system_id
			AND  ISNULL(d.sub_type,''n'') = ' + CASE WHEN @sub_type IS NOT NULL THEN '''' + @sub_type + '''' ELSE '''n''' END +
		'INNER JOIN source_system_description ssd
			ON d.source_system_id = ssd.source_system_id 
	WHERE 1 = 1'
	

IF @source_deal_type_id IS NOT NULL
    SET @stmt = @stmt + ' and d.source_deal_type_id = ' + CAST(@source_deal_type_id AS NVARCHAR)


IF @source_system_id IS NOT NULL
    SET @stmt = @stmt + ' and d.source_system_id = ' + CAST(@source_system_id AS NVARCHAR)

SET @stmt = @stmt + 
    '
	order by d.source_deal_type_name+ case when ssd.source_system_id=2 then '''' else ''.''+ ssd.source_system_name END
'

EXEC (@stmt)

--else



If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Deal Type', 
				'spa_getsourcedealtype', 'DB Error', 
				'Failed to select source deal type.', ''





