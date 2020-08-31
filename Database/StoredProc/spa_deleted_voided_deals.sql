IF OBJECT_ID('spa_deleted_voided_deals') IS NOT null
DROP PROC spa_deleted_voided_deals
go

--select * from source_deal_header

-- exec spa_deleted_voided_deals 's',NULL,null,null,'n','v'
-- EXEC spa_deleted_voided_deals  @flag_pre='s',@as_of_date='',@source_deal_header_id='',@deal_id='',@show_linked='n',@status='d'
-- EXEC spa_deleted_voided_deals  @flag_pre='s',@as_of_date='',@source_deal_header_id='',@deal_id='',@show_linked='n',@status='d'
-- EXEC spa_deleted_voided_deals  @flag_pre='s',@as_of_date='',@source_deal_header_id='',@deal_id='',@show_linked='n',@status='v'
--EXEC spa_deleted_voided_deals  @flag_pre='s',@as_of_date='',@source_deal_header_id='35127',@deal_id='',@show_linked='a',@status='v'

CREATE PROC spa_deleted_voided_deals
				@flag_pre char(1)=null,
				@deal_id varchar(5000)=null, 
				@source_deal_header_id int=null,				
				@as_of_date varchar(10)=null,
				@show_linked varchar(1)='n',
				@status varchar(1)='v',				
				@as_of_date_to varchar(10)=null,
			@enable_dynamic_loading CHAR(1) = NULL,

				@process_id_paging varchar(200)=NULL, 
				@batch_process_id VARCHAR(250) = NULL,
				@batch_report_param VARCHAR(500) = NULL, 
				@enable_paging INT = 0,		--'1' = enable, '0' = disable
				@page_size INT = NULL,
				@page_no INT = NULL
	AS
	SET NOCOUNT ON

	/*******************************************1st Paging Batch START**********************************************/
 
	DECLARE @str_batch_table VARCHAR (8000) 
	DECLARE @user_login_id VARCHAR (50) 
	DECLARE @sql_paging VARCHAR (8000) 
	DECLARE @is_batch BIT 
	SET @str_batch_table = '' 
	SET @user_login_id = dbo.FNADBUser()  
	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
	IF @is_batch = 1 
	BEGIN 
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
	END
 
	IF @enable_paging = 1 --paging processing 
	BEGIN 
		IF @batch_process_id IS NULL 
		BEGIN 
			SET @batch_process_id = dbo.FNAGetNewID() 
			SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no) 
		END
 
		IF @page_no IS NOT NULL  
		BEGIN 
			SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no) 
			EXEC (@sql_paging)  
			RETURN  
		END 
	END
 
/*******************************************1st Paging Batch END**********************************************/

	IF @deal_id = ''
		SET @deal_id = null
	
	IF @source_deal_header_id = ''
		SET @source_deal_header_id = null

	IF @as_of_date = ''
		SET @as_of_date = null

	IF @as_of_date_to = ''
		SET @as_of_date_to = null
	
	IF @status = ''
	BEGIN
		SET @status = null
	END

	DECLARE @tempTable varchar(300)
	DECLARE @flag char(1)

	SET @user_login_id=dbo.FNADBUser()

	IF @process_id_paging is NULL
	BEGIN
			SET @flag='i'
			SET @process_id_paging=REPLACE(newid(),'-','_')
	END
	SET @tempTable=dbo.FNAProcessTableName('deal_voided',@user_login_id,@process_id_paging)

	--PRINT @tempTable

	DECLARE @sqlStmt VARCHAR(5000)
	
IF @flag='i'
BEGIN 
	IF @status='d'
		SET @sqlStmt = 'CREATE TABLE ' + @tempTable + '(
		sno int  identity(1,1),
		RefID VARCHAR(50),
		DealID int,
		voideddate VARCHAR(50),
		deleteddate VARCHAR(50),
		deletedby VARCHAR(50)
		)'
	ELSE
		SET @sqlStmt = 'CREATE TABLE ' + @tempTable + '(
		sno int  identity(1,1),
		DealID int,RefID varchar(50),LinkID varchar(5000),DealDate varchar(20),VoidedDate  varchar(20),
		TenorPeriod  varchar(50),CounterpartyName  varchar(250),TraderName  varchar(250),
			TranStatus varchar(20)
		)'
	EXEC(@sqlStmt)

	SET @sqlStmt = ' INSERT INTO  ' + @tempTable + ' EXEC spa_deal_voided_in_external '
							+ dbo.FNASingleQuote(@flag_pre) + ' , '
							+ dbo.FNASingleQuote(@deal_id) + ','
							+ dbo.FNASingleQuote(@source_deal_header_id) + ','
							+ dbo.FNASingleQuote(@as_of_date) + ','								
							+ dbo.FNASingleQuote(@show_linked) + ','
							+ dbo.FNASingleQuote(@status) + ','
							+ dbo.FNASingleQuote(@as_of_date_to)

	EXEC(@sqlStmt)	


	IF @enable_dynamic_loading = 'y'
	BEGIN
		DECLARE @temp_process_id VARCHAR(20) = dbo.FNAGETNEWID()
		DECLARE @paging_process_table  VARCHAR(200)
		SET @paging_process_table = dbo.FNAProcessTableName('paging_process_table', @user_login_id, @temp_process_id)

		IF @status = 'd'
		BEGIN
			SET @sqlStmt = 'SELECT DealID,
									RefID,
									VoidedDate,
									DeletedDate,
									DeletedBy 
							INTO ' + @paging_process_table + '
							FROM   ' + @tempTable  +
						' ORDER BY sno ASC'
		END		
		ELSE 
		BEGIN
			SET @sqlStmt = 
				'	SELECT 
						DealID,
						RefID,
						dbo.FNATRMWinHyperlink(''a'', 10233700, LinkID, LinkID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0) AS [LinkID],
						DealDate,
						VoidedDate,
						TenorPeriod,
						CounterpartyName,
						TraderName,
						TranStatus 
					INTO ' + @paging_process_table + '
					FROM ' + @tempTable  + ' t
					INNER JOIN source_deal_header sdh ON sdh.deal_id = t.RefID
					ORDER BY sno ASC
				'
		END
		EXEC (@sqlStmt)
		SELECT @paging_process_table [process_table]
		RETURN
	END

		DECLARE @row_to int
		DECLARE @row_from int
	

		IF @status = 'd'
		SET @sqlStmt = 'SELECT DealID,RefID,VoidedDate,DeletedDate,DeletedBy ' + @str_batch_table + '
 						FROM ' + @tempTable  +
						' ORDER BY sno ASC'
	ELSE 
		SET @sqlStmt='SELECT 
							DealID,
							RefID,
							dbo.FNATRMWinHyperlink(''a'', 10233700, LinkID, LinkID, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0) AS [LinkID],
							DealDate,
							VoidedDate,
							TenorPeriod,
							CounterpartyName,
							TraderName,
							TranStatus 
							' + @str_batch_table + '
		FROM ' + @tempTable  + ' t
		INNER JOIN source_deal_header sdh ON sdh.deal_id = t.RefID
		ORDER BY sno ASC'
	EXEC (@sqlStmt)
END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
	IF @is_batch = 1 
	BEGIN 
		SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 		EXEC (@str_batch_table)
 		SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
			   GETDATE(), 'spa_deleted_voided_deals', 'Delete Voided Deal') --TODO: modify sp and report name
 
		EXEC (@str_batch_table)
		RETURN
	 END
	 --if it is first call from paging, return total no. of rows and process id instead of actual data
	 IF @enable_paging = 1 AND @page_no IS NULL
	 BEGIN
		SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no)
		EXEC (@sql_paging)
	 END
 
/*******************************************2nd Paging Batch END**********************************************/


