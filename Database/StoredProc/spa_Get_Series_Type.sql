/****** Object:  StoredProcedure [dbo].[spa_Get_Series_Type]    Script Date: 07/06/2009 17:32:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Get_Series_Type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Get_Series_Type]
/****** Object:  StoredProcedure [dbo].[spa_Get_Series_Type]    Script Date: 07/06/2009 17:32:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec [spa_Get_Series_Type] 's',14300
CREATE PROCEDURE [dbo].[spa_Get_Series_Type]  	
					@flag as char(1),
					@type_id as Integer
AS


SET NOCOUNT ON

DECLARE @errorCode Int

If @flag = 's' 
Begin


	Declare @selectStr Varchar(5000)
	BEGIN
		Set @selectStr = 
			'
		 select type_id,value_id,code Code,description Description ,entity_id,category_id,category_name,[Series Type]
from(
			select 14300 type_id,-1 value_id,''0 Default Inventory'' Code,''Default Inventory'' Description,
			NULL entity_id,NULL category_id,NULL category_name,'''' [Series Type]
			UNION			
			select s.type_id, value_id, code Code, description Description, 
			entity_id,s.category_id,category_name,case when st.forecast_type =''f'' then ''Forecast'' else '''' end as [Series Type]
			from static_data_value s left outer join static_data_category c 
			on c.category_id=s.category_id
			left outer join series_type st on st.series_type_value_id=s.value_id
			where s.type_id = ' + CAST(@type_id AS Varchar) +
			'UNION			
			select 14300 type_id,-2 value_id,''Base Inventory'' Code,''Base Inventory'' Description,
			NULL entity_id,NULL category_id,NULL category_name,'' '' [Series Type]
			UNION
			select 14300 type_id,-3 value_id,''Target'' Code,''Target'' Description,
			NULL entity_id,NULL category_id,NULL category_name,'' '' [Series Type]'

		+') a order by [Series Type],code'	

			--SET @selectStr = @selectStr + ' order by c.category_name,code'
	END
	exec(@selectStr)

END

