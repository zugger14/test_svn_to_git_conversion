IF OBJECT_ID(N'[dbo].[spa_assign_rec_deals_job]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_assign_rec_deals_job]
GO


CREATE PROCEDURE [dbo].[spa_assign_rec_deals_job] 
		@fas_sub_id varchar(5000) = null,
		@fas_strategy_id varchar(5000) = null,
		@fas_book_id varchar(5000) = null,
		@assignment_type int,
		@assigned_state int,
		@compliance_year int, 
		@assigned_date varchar(20),
		@fifo_lifo varchar(1),
		@volume float,
		@curve_id int = NULL,
		@assigned_counterparty int = null,
		@assigned_price float = null,
		@trader_id int = null,		
		@unassign int = 0,		
		@user_id varchar(50),
		@total_tons float = NULL,
		@gen_state int=NULL,  
		@gen_year int=NULL,  
		@gen_date_from datetime=NULL,  
		@gen_date_to datetime=NULL,  
		@generator_id int=NULL,  
		@counterparty_id int=NULL,
		@book_deal_type_map_id int=NULL,
		@cert_from int=NULL,
		@cert_to int=NULL  

AS 

DECLARE @spa varchar(5000)

DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)

DECLARE @desc varchar(500)

if isnull(@volume, 0) = 0 AND isnull(@total_tons, 0) = 0
BEGIN
	Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid Volume' Status, 
		('Volume in MWh or Tons is required. Please make sure appropriate Volume is entered.')  Message, 
		'' Recommendation		
	Return
END


--if sold make sure these three values are passed
if @unassign=0
BEGIN

If isnull(@assignment_type, 5149) = 5149
begin
	Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals', 'Invalid Category' Status, 
		('You can not assign/unassign RECs to Banked Category as non assigned RECs are banked by default. Please select another category to assign.')  Message, 
		'' Recommendation		
	RETURN
end

If isnull(@assignment_type, 5149) = 5173 
begin
	
	if @assigned_price IS NULL
	BEGIN
		Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid Price' Status, 
			('Price is required to sale a REC. Please make sure appropriate Sold Price is entered.')  Message, 
			'' Recommendation		
		Return
	END

	if @assigned_counterparty IS NULL
	BEGIN
		Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid Counterparty' Status, 
			('Counterparty is required to sale a REC. Please make sure appropriate Counterparty is selected.')  Message, 
			'' Recommendation		
		Return
	END

	if @trader_id IS NULL
	BEGIN
		Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals_job', 'Invalid Trder' Status, 
			('Trader is required to sale a REC. Please make sure appropriate Trader is selected.')  Message, 
			'' Recommendation		
		Return
	END
end
else
begin
	if @assigned_state IS NULL
	BEGIN
		Select 'Error' ErrorCode, 'Assign RECs' Module, 'spa_assign_rec_deals', 'Invalid Assigned State' Status, 
			('State is required to Assign a REC. Please make sure appropriate State is selected.')  Message, 
			'' Recommendation		
		Return
	END	
end

END

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'mtm_' + @process_id


set @fas_sub_id = case when (@fas_sub_id is null) then 'NULL' else '''' + @fas_sub_id + '''' end
set @fas_strategy_id = case when (@fas_strategy_id is null) then 'NULL' else '''' + @fas_strategy_id + '''' end
set @fas_book_id = case when (@fas_book_id is null) then 'NULL' else '''' + @fas_book_id + '''' end


SET @spa = 'spa_assign_rec_deals_schedule ' + @fas_sub_id + ', ' + @fas_strategy_id + ', ' + @fas_book_id + ', ' +
 		cast(@assignment_type as varchar) + ', ' +
 		ISNULL(cast(@assigned_state as varchar),'NULL') + ', ' +
 		cast(@compliance_year as varchar) + ', ''' + 
 		@assigned_date + ''', ''' + @fifo_lifo + ''', ' +
 		ISNULL(cast(@volume as varchar),'NULL') + ', ' +
		isnull(cast(@curve_id as varchar), 'NULL') + ', ' +
		isnull(cast(@assigned_counterparty as varchar), 'NULL') + ', ' +
		isnull(cast(@assigned_price as varchar), 'NULL') + ', ' +
		isnull(cast(@trader_id as varchar), 'NULL') + ', ' +
		isnull(cast(@unassign as varchar), 'NULL') + ', ' +
		isnull('''' + @user_id + '''', 'NULL') + ', ' +
		isnull(cast(@total_tons as varchar), 'NULL') + ', ' +
		isnull(cast(@gen_state as varchar), 'NULL') + ', ' +
		isnull(cast(@gen_year as varchar), 'NULL') + ', ' +
		isnull('''' + cast(@gen_date_from as varchar)+ '''', 'NULL') + ', ' +
		isnull('''' + cast(@gen_date_to as varchar) + '''', 'NULL') + ', ' +
		isnull(cast(@generator_id as varchar), 'NULL') + ', ' +
		isnull(cast(@counterparty_id as varchar), 'NULL') + ', ' +
		isnull(cast(@book_deal_type_map_id as varchar), 'NULL') + ', ' +
		isnull(cast(@cert_from as varchar), 'NULL') + ', ' +
		isnull(cast(@cert_to as varchar), 'NULL') 				
EXEC spa_print @spa

--Return

EXEC spa_run_sp_as_job @job_name, @spa, 'Assign REC', @user_id


Exec spa_ErrorHandler 0, 'Assign Transactions', 
			'spa_assign_rec_deals_job', 'Status', 
			'Assignment of REC Transactions has been run and will complete shortly.', 
			'Plese check/refresh your message board.'







