IF OBJECT_ID(N'spa_clear_all_temp_table' ,N'P') IS NOT NULL
    DROP PROCEDURE spa_clear_all_temp_table
GO

/**
	Clear all temporary tables created for some purpose.

	Parameters:
		@nos_of_days	:	Number of days prior to delete.
		@process_id		:	Exact process id to be deleted.
		@exclude_tables  :	List prefix tables not to delete.
*/

CREATE PROC spa_clear_all_temp_table
	@nos_of_days INT = NULL,
	@process_id NVARCHAR(150) = NULL,
	@exclude_tables NVARCHAR(max) = NULL
AS

SET NOCOUNT ON

/*

declare @nos_of_days INT = NULL,
	@process_id VARCHAR(150) = NULL,
	@exclude_tables VARCHAR(max) = 'report_dataset_cdv,deal_settlement,index_fees_settlement' 


if object_id('tempdb..#temp1') is not null drop table #temp1
if object_id('tempdb..#except_tables') is not null drop table #except_tables


--*/


DECLARE @tbl_name  NVARCHAR(130)
DECLARE @tot       INT
DECLARE @cnt       INT
DECLARE @sel_date  DATETIME

IF @nos_of_days IS NOT NULL
	SET @sel_date = dbo.FNAGetSQLStandardDate(GETDATE() - @nos_of_days)
ELSE
	SET @sel_date = dbo.FNAGetSQLStandardDate(GETDATE())

EXEC spa_print @sel_date

CREATE TABLE #temp1(
	sno         INT IDENTITY(1 ,1),
	table_name  NVARCHAR(130) COLLATE DATABASE_DEFAULT 
)

--'batch_export_':exclude export tables in deletion action; export table starts with batch_export_
--'batch_report_power_bi_':exclude power bi tables in deletion action; power bi table starts with batch_report_power_bi_

set @exclude_tables =isnull(nullif(@exclude_tables,'')+',','')+'batch_export_,batch_report_power_bi_'

select tbl.* into #except_tables from dbo.SplitCommaSeperatedValues(@exclude_tables) tbl

IF @process_id IS NULL
BEGIN
	INSERT INTO #temp1 (table_name)
	SELECT [name]
	FROM adiha_process.dbo.sysobjects so WITH(NOLOCK)
		left join #except_tables et on so.[name] like et.[item]+'%'
	WHERE xtype = 'u'
		AND dbo.FNAGetSQLStandardDate(crdate) <= @sel_date
		and et.item is null

END
ELSE
BEGIN
	INSERT INTO #temp1 (table_name)
	SELECT [name]
	FROM adiha_process.dbo.sysobjects so WITH(NOLOCK)
		left join #except_tables et on so.[name] like et.[item]+'%'

	WHERE xtype = 'u'
		AND dbo.FNAGetSQLStandardDate(crdate) <= @sel_date
		AND [name] LIKE '%' + @process_id + '%'
			and et.item is null
END



SET @tot = @@ROWCOUNT
SET @cnt = 1

WHILE @cnt <= @tot
BEGIN
    SELECT @tbl_name = table_name
    FROM #temp1
    WHERE sno = @cnt

    EXEC ('DROP TABLE adiha_process.dbo.[' + @tbl_name+']')
	print @tbl_name
    SET @cnt = @cnt + 1
END