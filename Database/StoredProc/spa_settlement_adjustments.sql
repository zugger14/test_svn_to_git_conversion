/****** Object:  StoredProcedure [dbo].[spa_settlement_adjustments]    Script Date: 04/09/2009 16:55:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_settlement_adjustments]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_settlement_adjustments]
/****** Object:  StoredProcedure [dbo].[spa_settlement_adjustments]    Script Date: 04/09/2009 16:55:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_settlement_adjustments]
	@flag char(1),
	@counterparty_id int = null,
	@prod_date_from datetime = null,
	@prod_date_to datetime = null,
	@sub_id INT=NULL,
	@contract_ID INT=NULL,
	@deal_set_calc CHAR(1) = 'n',
	@batch_process_id    VARCHAR(50) = NULL, 
	@batch_report_param  VARCHAR(1000) = NULL
AS

	DECLARE @sql VARCHAR(MAX),@user_login_id VARCHAR(50)

	SET @user_login_id=dbo.FNADBUser()

if @flag = 's'
BEGIN
	
	select 
		calc_id AS [Calc ID], invoice_line_item_id AS [Invoice Line Item ID],
		counterparty_name [Counterparty],code [Code],dbo.FNADateFormat(prod_date) [Prod Date],
		allocationvolume_old [Old Volume],allocationvolume_new [New Volume],
		value_old [Old Value],value_new [New Value],volume_diff [Volume Difference],value_diff [Value Difference]
	from settlement_adjustments 
	where counterparty_id=@counterparty_id
		and prod_date between @prod_date_from and @prod_date_to

--	select * from settlement_adjustments 
--	where counterparty_id=@counterparty_id
--		and prod_date between @prod_date_from and @prod_date_to
END


IF @flag = 'i'
BEGIN
DECLARE
	@c_counterparty_id int, 
	@c_prod_date datetime,
	@c_as_of_date datetime,
	@test_process_id VARCHAR(150),
	@str_batch_table VARCHAR(MAX)
	
SET @test_process_id = REPLACE(newid(),'-','_')

--IF @sub_id IS NULL
   SET @sub_id=-1	
   
DECLARE cur_finalized_counterparties cursor for
	SELECT counterparty_id,prod_date,max(as_of_date) from calc_invoice_volume_variance 
	WHERE finalized='y'
		and counterparty_id=@counterparty_id
		and prod_date between @prod_date_from and @prod_date_to
		and contract_id=ISNULL(@contract_id,contract_id)	
	GROUP BY counterparty_id,prod_date

OPEN cur_finalized_counterparties
FETCH NEXT FROM cur_finalized_counterparties into @c_counterparty_id,@c_prod_date,@c_as_of_date

WHILE @@FETCH_STATUS = 0 
BEGIN
	EXEC spa_print ' :: '
		,@c_counterparty_id, ' :: ' 
		,@c_prod_date, ' :: ' 
		,@c_as_of_date, ' :: '


	SET @sql = ' spa_calc_invoice '''+cast(@c_prod_date as VARCHAR)+''','''+cast(@c_counterparty_id as varchar)+''','''+cast(@c_as_of_date as VARCHAR)+''','''+@test_process_id+''',''y'',''y'','+CAST(@sub_id AS VARCHAR)+','+ISNULL(CAST(@contract_id AS VARCHAR),'NULL')+',''n'',NULL,NULL,NULL,NULL,'''+ISNULL(@deal_set_calc,'n')+''',NULL,NULL,''t'''
	
	EXEC spa_print @sql
	exec (@sql)

	fetch next from cur_finalized_counterparties into @c_counterparty_id,@c_prod_date,@c_as_of_date
END

CLOSE cur_finalized_counterparties
deallocate cur_finalized_counterparties


BEGIN
	DECLARE @table_name VARCHAR(150)
	
	SET @table_name = dbo.FNAProcessTableName('calc_invoice_volume_variance', @user_login_id,@test_process_id)
	SET @sql = 'if OBJECT_ID('''+@table_name+''') IS NOT NULL
		EXEC  spa_get_settlement_calc_variance_report ''i'','''+@test_process_id+''''
	EXEC(@sql)
END
--SET @str_batch_table=''        
--IF @batch_process_id IS NOT NULL
--BEGIN      
--	SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)
--END
-- ***************** FOR BATCH PROCESSING **********************************    
 
	--IF  @batch_process_id IS NOT NULL        
	 
	--BEGIN        
	--	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
	--	EXEC(@str_batch_table)     
	--	DECLARE @report_name VARCHAR(100)
	--	SET @report_name = 'Run Settlement Adjustments'        
	--	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(),
	--				 'spa_settlement_adjustment', @report_name) 
	--	EXEC(@str_batch_table)     
	 
	--END        
-- ********************************************************************
END

	DECLARE @model_name VARCHAR(100),@desc VARCHAR(500)
	BEGIN
		SET @model_name = 'Run Settlement Adjustment'
		SET @desc = 'Run Settlement Adjustmen.'
	END		
	 Exec spa_ErrorHandler 0, @model_name, 
				@model_name, 'job', 
				@model_name, 
				'Plese check/refresh your message board.'



