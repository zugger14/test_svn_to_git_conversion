IF OBJECT_ID(N'spa_verify_deal_id', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_verify_deal_id]
GO 

-- spa_verify_deal_id 'ANC123, ANC124, ANC125, UDAY1111, SUDEEP2, ANC126'
CREATE PROC [dbo].[spa_verify_deal_id] @list_deals VARCHAR(8000)
AS
--declare @list_deals varchar(8000)
DECLARE @invalid_deals  VARCHAR(8000)
DECLARE @match_no       INT
SET @match_no = 0
CREATE TABLE #TMP
(
	source_deal_header_id INT
)
SET  @list_deals=''''+replace(@list_deals,',',''',''')+''''
SET  @invalid_deals=''
EXEC ('insert into #tmp select source_deal_header_id from source_deal_header where deal_id in ('+@list_deals+')')
SELECT  @match_no=@match_no+1 ,
@invalid_deals=@invalid_deals+CASE  WHEN @invalid_deals='' THEN '' ELSE ',' END +deal_id 
FROM #tmp inner join source_deal_header 
ON source_deal_header.source_deal_header_id=#tmp.source_deal_header_id

SELECT CASE WHEN @match_no=0 THEN 'Error' ELSE 'Success' END Status, 
'Deal Filter' Module,'Deal Filter' Area,'Status' Status,
'Deal ID matched found:'+ cast(@match_no AS VARCHAR) Message,
@invalid_deals Deals