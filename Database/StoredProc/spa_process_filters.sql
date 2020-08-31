


/****** Object:  StoredProcedure [dbo].spa_process_filters    Script Date: 07/06/2009 19:25:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_process_filters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_process_filters]
/****** Object:  StoredProcedure [dbo].spa_process_filters    Script Date: 07/06/2009 19:25:52 ******/

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--exec spa_process_filters 's'


CREATE procedure [dbo].[spa_process_filters]
		@flag char(1),
		@filterID int=null,
		@filterDesc  varchar(200)=Null,
		@tableName varchar(200)=Null,	
		@columnName varchar(200)=Null,
		@module CHAR(1)

as
BEGIN
DECLARE @sql VARCHAR(8000)	

IF @flag='s'
	BEGIN
 		SET @sql='select 	p.filterID
					from process_filters p
					WHERE 1=1 '
				 +CASE WHEN @module IS NOT NULL THEN ' AND p.module='''+@module+'''' ELSE '' END					
				 +' order by p.precedence asc '
		EXEC(@sql)
	END			

END


