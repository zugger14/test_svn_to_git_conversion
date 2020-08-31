IF OBJECT_ID(N'spa_getContractMonths', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getContractMonths]
GO 

CREATE PROCEDURE [dbo].[spa_getContractMonths]
	@flag CHAR(1),
	@source_deal_header_id INT,
	@process_id VARCHAR(100) = NULL
AS
	--Declare @user_login_id varchar(100)
	--Declare @tempdetailtable varchar(100)
DECLARE @sql_select VARCHAR(5000)

--set @user_login_id=dbo.FNADBUser()
--set @tempheadertable=dbo.FNAProcessTableName('source_deal_header_temp', @user_login_id,@process_id)
--set @tempdetailtable=dbo.FNAProcessTableName('source_deal_detail_temp', @user_login_id,@process_id)

SET  @sql_select='select dbo.FNACovertToSTDDate(cast(term_start as varchar))+''::''+
dbo.FNACovertToSTDDate(cast(term_end as varchar)),dbo.FNADateFormat(cast(term_start as varchar)) +''-''+ 
dbo.FNADateFormat(cast(term_end as varchar))
from source_deal_detail  where source_deal_header_id='+CAST(@source_deal_header_id AS VARCHAR)+'
 group by term_start,term_end'
--print @sql_select

EXEC (@sql_select)