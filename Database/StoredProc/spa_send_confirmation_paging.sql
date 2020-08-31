IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_send_confirmation_paging]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_send_confirmation_paging]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************
 * Author: Biju Maharjan
 * Create date: 2013-11-12
 * Descriptions: Send deal confirmation paging
  *******************************************/

create proc [dbo].[spa_send_confirmation_paging] 
		@flag_pre CHAR(1),
		@deal_id_from INT = NULL,
		@deal_id_to INT = NULL,
		@deal_date_from VARCHAR(10) = NULL, 
		@deal_date_to VARCHAR(10) = NULL,
		@counterparty_id INT = NULL,
		@deal_category_id INT = NULL,
		@deal_type_id INT = NULL,
		@deal_sub_type_id INT = NULL,
		@trader_id INT = NULL,
		@confirmation_status VARCHAR(10) = NULL,
		@process_id_paging VARCHAR(500)=NULL, 
		@page_size INT =NULL,
		@page_no INT = NULL
	
AS

DECLARE @user_login_id VARCHAR(50),@tempTable VARCHAR(MAX) ,@flag CHAR(1), @new_flag CHAR(1)

SET @new_flag = @flag_pre
SET @user_login_id = dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
	SET @flag='i'
	SET @process_id_paging = REPLACE(newid(),'-','_')
END

SET @tempTable=dbo.FNAProcessTableName('paging_sourcedealheader', @user_login_id,@process_id_paging)
DECLARE @sqlStmt VARCHAR(MAX)

IF @flag='i'
BEGIN
	SET @sqlStmt='CREATE TABLE '+ @tempTable+'( 
						sno INT  IDENTITY(1, 1),
						deal_id VARCHAR(1000),
						deal_status VARCHAR(1000),
						confirm_status VARCHAR(100),
						deal_date VARCHAR(500),	
						deal_type VARCHAR(500),
						deal_sub_type VARCHAR(100),
						counterparty VARCHAR(500),
						delivery_location VARCHAR(500),
						trader VARCHAR(500),
						deal_category VARCHAR(500),
						contract VARCHAR(500),
						source_deal_header_id int
					)'

	EXEC(@sqlStmt)
		set @sqlStmt=' insert  '+ @tempTable + '
		
		exec spa_send_confirmation ' + 
		dbo.FNASingleQuote(@flag_pre) + ',' + 
		dbo.FNASingleQuote(@deal_id_from) + ',' +
		dbo.FNASingleQuote(@deal_id_to) + ',' +
		dbo.FNASingleQuote(@deal_date_from) + ',' +
		dbo.FNASingleQuote(@deal_date_to) + ',' +
		dbo.FNASingleQuote(@counterparty_id) +  ',' +
		dbo.FNASingleQuote(@deal_category_id) + ',' +
		dbo.FNASingleQuote(@deal_type_id) + ',' +
		dbo.FNASingleQuote(@deal_sub_type_id) + ',' +
		dbo.FNASingleQuote(@trader_id) + ',' +
		dbo.FNASingleQuote(@confirmation_status)
		
		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)	
		SET @sqlStmt='select count(*) TotalRow,'''+@process_id_paging +''' process_id  from '+ @tempTable
		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)
END
ELSE
BEGIN
	DECLARE @row_to INT,@row_from INT
	
	SET @row_to = @page_no * @page_size
	IF @page_no > 1 
		SET @row_from = ((@page_no-1) * @page_size)+1
	ELSE
		SET @row_from = @page_no
	--########### Group Label
	DECLARE @group1 VARCHAR(100),@group2 VARCHAR(100),@group3 VARCHAR(100),@group4 VARCHAR(100)
	IF EXISTS(SELECT group1,group2,group3,group4 FROM source_book_mapping_clm)
	BEGIN	
		SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm
	END
	ELSE
	BEGIN
		SET @group1 = 'Group1'
		SET @group2 = 'Group2'
		SET @group3 = 'Group3'
		SET @group4 = 'Group4'
	 
	END

--######## End

	DECLARE @time_zone_from INT, @time_zone_to INT

	SELECT @time_zone_from= var_value  FROM adiha_default_codes_values  
	WHERE  (instance_no = 1) AND (default_code_id = 36) AND (seq_no = 1)  
  
	SELECT @time_zone_to=timezone_id FROM application_users WHERE user_login_id=@user_login_id

	IF @new_flag != 's'
	BEGIN
			SET @sqlStmt = 'SELECT deal_id,
			                     deal_status,
			                     confirm_status,
			                     deal_date,
			                     deal_type,
			                     counterparty,
			                     delivery_location,
			                     trader,
			                     deal_category,
			                     contract, 
			                     source_deal_header_id
			              FROM    ' + @tempTable  + 
			              ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + CAST(@row_to AS VARCHAR) + 
			              ' ORDER BY sno ASC'
	END
	ELSE
	BEGIN
		SET @sqlStmt = 
		    'SELECT deal_id [Deal ID],
		            deal_status [Deal Status],
		            confirm_status [Confirm Status],
		            deal_date [Deal Date],
		            deal_type [Deal Type],
		            deal_sub_type [Deal Sub Type],
		            counterparty [Counterparty],
		            delivery_location [Delivery Location],
		            trader [Trader],
		            deal_category [Deal Category],
		            contract [Contract], 
		            source_deal_header_id [Source Deal Header ID]
		     FROM   ' + @tempTable + 
		     ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + CAST(@row_to AS VARCHAR)  
			 + ' ORDER BY sno ASC'
	END
	
	EXEC(@sqlStmt)
END
GO