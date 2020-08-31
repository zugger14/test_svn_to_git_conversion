IF OBJECT_ID(N'spa_insert_rec_deals', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_insert_rec_deals]
GO 

CREATE PROCEDURE [dbo].[spa_insert_rec_deals]
	@flag VARCHAR(1), --i  for insert, u for update, d for delete
	@ref_id VARCHAR(50) = NULL,
	@volume FLOAT = NULL,
	@source_book_mapping_id INT = NULL,
	@deal_type VARCHAR(50) = NULL,
	@deal_sub_type VARCHAR(50) = NULL,
	@buy_sell_flag VARCHAR(1) = NULL,
	@start_term VARCHAR(20) = NULL,
	@end_term VARCHAR(20) = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@deal_date VARCHAR(20) = NULL,
	@index VARCHAR(255) = NULL,
	@price FLOAT = NULL,
	@formula VARCHAR(5000) = NULL,
	@currency VARCHAR(50) = NULL,
	@volume_frequency VARCHAR(1) = NULL, --'h' hourly, 'm' monthly, 'd' daily
	@uom VARCHAR(50) = NULL,
	@trader VARCHAR(255) = NULL,
	@counterparty VARCHAR(255) = NULL,
	@category VARCHAR(255) = NULL,
	@broker VARCHAR(255) = NULL,
	@generator VARCHAR(255) = NULL,
	@include_tax_credit VARCHAR(1) = NULL
AS

DECLARE @book varchar(255)
DECLARE @error_message varchar(1000)
DECLARE @farrms_dealId varchar(20)
set @farrms_dealId=''
IF @flag IN ( 'i', 'u')
BEGIN

	select @book = source_system_book_id
	from source_system_book_map ssbm inner join
	source_book sb on sb.source_book_id = ssbm.source_system_book_id1
	where ssbm.book_deal_type_map_id = @source_book_mapping_id
	
	If @book IS NULL
	BEGIN
	
		Select 	'Error' ErrorCode, 
			'spa_insert_rec_deals' Module, 
			'REC Deal' Area, 
			'Error' Status, 
			'Invalid Book Selected' Message, 
			'Please select a valid Book.' Recommendation
	
		RETURN
	END
-- 	if @ref_id is null
-- 	begin
-- 		
-- 		insert farrms_dealId values(getDate())
-- 		set @ref_id=@farrms_dealId + cast(@@identity as varchar)
-- 
-- 	end
	if (isnull(@hour_from, 0) <> 0)
		set @start_term = @start_term + ' ' + cast(@hour_from as varchar) + ':00:00'
	
	if (isnull(@hour_to, 0) <> 0)
		set @end_term = @end_term + ' ' + cast(@hour_to as varchar) + ':00:00'
	
	
	
	declare @user_login_id varchar(50),@tempTable varchar(300) , @process_id varchar(50),@sqlStmt varchar(5000)

	set @user_login_id=dbo.FNADBUser()

	set @process_id=REPLACE(newid(),'-','_')
	
	set @tempTable=dbo.FNAProcessTableName('deal_process', @user_login_id,@process_id)
	
	set @sqlStmt='create table '+ @tempTable+'( 
	 [Book] [varchar] (255)  NULL ,      
	 [Feeder_System_ID] [varchar] (255)  NULL ,      
	 [Gen_Date_From] [varchar] (50)  NULL ,      
	 [Gen_Date_To] [varchar] (50)  NULL ,      
	 [Volume] [varchar] (255)  NULL ,      
	 [UOM] [varchar] (50)  NULL ,      
	 [Price] [varchar] (255)  NULL ,      
	 [Formula] [varchar] (255)  NULL ,      
	 [Counterparty] [varchar] (50)  NULL ,      
	 [Generator] [varchar] (50)  NULL ,      
	 [GIS] [varchar] (255)  NULL ,      
	 [GIS Certificate Number] [varchar] (255)  NULL ,      
	 [GIS Certificate Date] [varchar] (255)  NULL ,      
	 [Deal Type] [varchar] (10)  NULL ,      
	 [Deal Sub Type] [varchar] (10)  NULL ,      
	 [Trader] [varchar] (100)  NULL ,      
	 [Broker] [varchar] (100)  NULL ,      
	 [Index] [varchar] (255)  NULL ,      
	 [Frequency] [varchar] (10)  NULL ,      
	 [Deal Date] [varchar] (50)  NULL ,      
	 [Currency] [varchar] (255)  NULL ,      
	 [Category] [varchar] (20)  NULL ,      
	 [buy_sell_flag] [varchar] (10)  NULL,
	 [source_deal_header_id] [varchar] (20)  NULL )
	'
	
	exec(@sqlStmt)


--	DELETE FROM Transactions

--	INSERT INTO Transactions
--	SELECT @book, @ref_id, @start_term, @end_term, @volume, @uom, @price, @formula, @counterparty,
--	@generator, NULL, NULL, NULL, @deal_type, @deal_sub_type, @trader, @broker, @index,
--	@volume_frequency, @deal_date, @currency, @category, @buy_sell_flag
	
	set @sqlStmt=' INSERT INTO '+ @tempTable +'
	values( '''+ @book+''',nullif('''+ ISNULL(cast(@ref_id as varchar),'') +''',''''),'''+ @start_term +''','''+ @end_term +''','+ 
	cast(@volume as varchar) +','+ isNUll(@uom,'NULL') +','+ isNULL(cast(@price as varchar),'NULL')+',
	'+ isNULL(@formula,'NULL') +','+ isNULL(@counterparty,'NULL') +', '+ isNULL(@generator,'NULL') +

	', NULL, NULL, NULL, '+@deal_type +','+ @deal_sub_type +',
	'+ isNULL(@trader,'NULL') +', '+ isNULL(@broker,'NULL') +', '+ isNUll(@index,'NULL') +', '''+ @volume_frequency +''',
	'''+ @deal_date +''','+ isNULL(@currency,'NULL') +', '+ isNUll(@category,'NULL') +','''+ @buy_sell_flag +''',null)'

	exec(@sqlStmt)

	If @@ERROR <> 0
	BEGIN
		SET @error_message = 'Error on inserting Transactions for REC Deal with Ref ID: ' + @ref_id

		Exec spa_ErrorHandler @@ERROR, 'spa_insert_rec_deals' , 
				'REC Deal', 'Error', @error_message, ''
		Return
	END
--	exec('select * from '+@tempTable)
-- 	select * from Transactions
-- 	return

	DECLARE @user_id varchar(100)
	set @user_id =  dbo.FNADBUser()
	
	--Create transactions
	--print @tempTable
	
if @include_tax_credit is not null
begin
	set @sqlStmt=' INSERT INTO '+ @tempTable +'
	select  '''+ @book+''',nullif('''+ ISNULL(cast(@ref_id as varchar),'') +''',''''),'''+ @start_term +''','''+ @end_term +''','+ 
	cast(@volume as varchar) +','+ isNUll(@uom,'NULL') +',tax_price,
	tax_formula_id,'+ isNULL(@counterparty,'NULL') +', '+ isNULL(@generator,'NULL') +
	', NULL, NULL, NULL, tax_deal_type ,'+ @deal_sub_type +',
	'+ isNULL(@trader,'NULL') +', '+ isNULL(@broker,'NULL') +', tax_benefit_curve_id , '''+ @volume_frequency +''',
	'''+ @deal_date +''','+ isNULL(@currency,'NULL') +', '+ isNUll(@category,'NULL') +','''+ @buy_sell_flag +''',null from rec_generator where generator_id='+ @generator+ ' 
	and tax_benefit_curve_id is not null'

	exec(@sqlStmt)
end

EXEC spb_Process_Transactions @user_id ,@tempTable, 'n','n'

	
	If @@ERROR <> 0
	BEGIN
		SET @error_message = 'Error on creating REC Transactions for REC Deal with Ref ID: ' + @ref_id 
			+ '. Please check message board for detail error messages.'
		Exec spa_ErrorHandler @@ERROR, 'spa_insert_rec_deals' , 
				'REC Deal', 'Error', @error_message, ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_insert_rec_deals' Module, 
			'REC Deal' Area, 
			 @ref_id Status, 
			'REC Transactions successfully created.' Message, 
			'' Recommendation
	
		RETURN
	END
	
END
ELSE IF @flag = 'd'
BEGIN

BEGIN TRAN
	SELECT source_deal_header_id INTO #temp from source_deal where structured_deal_id = @ref_id
	DECLARE @min_date datetime
	DECLARE @max_date_closed datetime
	
	select @min_date = min(as_of_date) from report_measurement_values_inventory
	where link_id in (select SOURCE_DEAL_HEADER_ID from #temp)
	
	select  @max_date_closed  = max(as_of_date) from close_measurement_books
	
	if @max_date_closed IS NOT NULL AND @min_date IS NOT NULL AND
	    @min_date <= @max_date_closed
	BEGIN
		Select 	'Error' ErrorCode, 
			'spa_insert_rec_deals' Module, 
			'REC Deal' Area, 
			 'Error' Status, 
			'Accounting book already closed as of ' + dbo.FNADateFormat(@max_date_closed) + 
				'. Can not delete the transactions as they have accounting entries.' Message, 
			'' Recommendation
	
		RETURN
	END

--	DELETE FROM assignment_audit where 
--	SOURCE_DEAL_HEADER_ID  IN (select SOURCE_DEAL_HEADER_ID from #temp)

--	DELETE FROM unassignment_audit where
--	SOURCE_DEAL_HEADER_ID  IN (select SOURCE_DEAL_HEADER_ID from #temp)

	DELETE FROM report_measurement_values_inventory WHERE
	link_id IN (select SOURCE_DEAL_HEADER_ID from #temp)
	
	DELETE FROM calcprocess_inventory_deals WHERE
	SOURCE_DEAL_HEADER_ID  IN (select SOURCE_DEAL_HEADER_ID from #temp)
	
	DELETE FROM confirm_status WHERE
	SOURCE_DEAL_HEADER_ID  IN (select SOURCE_DEAL_HEADER_ID from #temp)
	
	DELETE FROM GIS_CERTIFICATE WHERE
	SOURCE_DEAL_HEADER_ID IN (select SOURCE_DEAL_HEADER_ID from #temp)

	DELETE FROM SOURCE_DEAL WHERE
	SOURCE_DEAL_HEADER_ID IN (select SOURCE_DEAL_HEADER_ID from #temp)

	If @@ERROR <> 0
	BEGIN
		  	
		  SET @error_message = 'Error found while deleting REC Transactions Deals'
		  Exec spa_ErrorHandler @@ERROR, 'spa_insert_rec_deals' , 
		    'REC Deal', 'Error', @error_message, ''
		   ROLLBACK TRAN	
		  RETURN
	 END
	 Else
	 BEGIN
		  Select  'Success' ErrorCode, 
		   'spa_insert_rec_deals' Module, 
		   'REC Deal' Area, 
		    @ref_id Status, 
		   'REC Transactions successfully deleted.' Message, 
		   '' Recommendation
		  COMMIT TRAN
	 	  RETURN
	 END


END







