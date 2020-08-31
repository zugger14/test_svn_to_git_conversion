
/****** Object:  StoredProcedure [dbo].[spa_ems_publish_report]    Script Date: 06/15/2009 20:52:46 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_publish_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_publish_report]
/****** Object:  StoredProcedure [dbo].[spa_ems_publish_report]    Script Date: 06/15/2009 20:52:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_ems_publish_report 'i',NULL,'2008-10-01','1440'

CREATE proc [dbo].[spa_ems_publish_report]
	@flag CHAR(1),
	@id varchar(500) = NULL,
	@as_of_date DATETIME = NULL,
	@sub_id VARCHAR(100)=NULL,
	@strategy_entity_id VARCHAR(100)=NULL,
	@book_entity_id VARCHAR(100)=NULL,
	@user_login_id varchar(100)=NULL

AS
SET NOCOUNT ON 
declare @sql_stmt varchar(1000)

if @user_login_id is null
	set @user_login_id=dbo.fnadbuser()


IF @flag = 's'
BEGIN

set @sql_stmt = 'SELECT id,ph.entity_name AS [Subsidiary],ph1.entity_name AS [Strategy],
		ph2.entity_name AS [Book],
		dbo.FNADateFormat(epr.as_of_date) [Publish Date], epr.create_user [Published By], dbo.FNADateFormat(epr.create_ts) [Published On] 
		  
FROM   ems_publish_report epr
		  left join portfolio_hierarchy ph ON ph.entity_id=epr.sub_id and ph.hierarchy_level=2
		  left join portfolio_hierarchy ph1 ON ph1.entity_id=epr.strategy_entity_id and ph1.hierarchy_level=1
		  left join portfolio_hierarchy ph2 ON ph2.entity_id=epr.book_entity_id and ph2.hierarchy_level=0
WHERE 1=1'

if @sub_id is not null 
		set @sql_stmt = @sql_stmt + ' and sub_id=' + cast(@sub_id as varchar)

if @strategy_entity_id is not null  
		set @sql_stmt = @sql_stmt + ' and strategy_entity_id=' + cast(@strategy_entity_id as varchar)

if @book_entity_id is not null 
		set @sql_stmt = @sql_stmt + ' and book_entity_id=' + cast(@book_entity_id as varchar)

--print @sql_stmt

exec(@sql_stmt)
	
	IF @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Publish Report', 
				'spa_ems_publish_report', 'DB Error', 
				'Failed to retrieve Publish Report date.', ''
	ELSE
		Exec spa_ErrorHandler 0, 'Publish Report', 
				'spa_ems_publish_report', 'Success', 
				'Succeded to retrieve Publish dates.', ''

END


--Check Publish Report or not
IF @flag = 'c'
BEGIN
	IF exists (SELECT as_of_date FROM ems_publish_report WHERE as_of_date >=
			dbo.FNAGetContractMonth(@as_of_date) and sub_id=@sub_id 
												 or strategy_entity_id=@strategy_entity_id
												 or  book_entity_id=@book_entity_id)
		SELECT 'Published' Status
	ELSE
		SELECT 'Not Published' Status

END


ELSE IF @flag = 'i'
BEGIN

	if @sub_id is null
	begin
		if @strategy_entity_id is null
		begin
			if @book_entity_id is not null
			begin
				select @strategy_entity_id = ph2.entity_id, @sub_id = ph3.entity_id  from portfolio_hierarchy ph1
				join portfolio_hierarchy ph2 on ph2.entity_id = ph1.parent_entity_id
				join portfolio_hierarchy ph3 on ph3.entity_id = ph2.parent_entity_id
				where ph1.entity_id = @book_entity_id
			end
		end
		else
			select @sub_id = ph2.entity_id  from portfolio_hierarchy ph1
			join portfolio_hierarchy ph2 on ph2.entity_id = ph1.parent_entity_id
			where ph1.entity_id = @strategy_entity_id
		end

		INSERT INTO ems_publish_report
			(as_of_date,sub_id,strategy_entity_id,book_entity_id)
		VALUES 
			   (@as_of_date,@sub_id,@strategy_entity_id,@book_entity_id)


---############# Check if the Target exceeds

			DECLARE @role_id varchar(100),@risk_control_id INT,@message VARCHAR(1000)


			CREATE TABLE #ems_target(opCo VARCHAR(100) COLLATE DATABASE_DEFAULT,source VARCHAR(500) COLLATE DATABASE_DEFAULT,Emission_type VARCHAR(20) COLLATE DATABASE_DEFAULT,term DATETIME,Inventory FLOAT, target FLOAT,UOM VARCHAR(20) COLLATE DATABASE_DEFAULT)
			
			INSERT INTO #ems_target
			EXEC spa_check_emissions_target_limit @sub_id,@strategy_entity_id,@book_entity_id,NULL,@as_of_date		

			IF EXISTS(select * from #ems_target WHERE target<Inventory)
			BEGIN
				SET @risk_control_id=189
				SET @message='Emissions Target Exceeded for some sources'
				--SET @message=@message+'<a target="_blank" href="dev/spa_html.php?spa=EXEC spa_check_emissions_target_limit '''''+@sub_id +''''','''''+@strategy_entity_id +''''','''''+@book_entity_id+''''',NULL,'''''+CAST(@as_of_date AS VARCHAR)+'''''&__user_name__='+@user_login_id+'">' + 
				--' Click here...' +'</a>'
				
				SET @message=@message+'<a target="_blank" href="dev/spa_html.php?spa=EXEC spa_check_emissions_target_limit ' 
				+ (CASE WHEN @sub_id IS NULL THEN 'NULL' ELSE '' + @sub_id + '' END) + ',' 
				+ (CASE WHEN @strategy_entity_id IS NULL THEN 'NULL' ELSE '' + @strategy_entity_id + '' END) + ',' 
				+ (CASE WHEN @book_entity_id IS NULL THEN 'NULL' ELSE '' + @book_entity_id + '' END) + ',NULL,'''''+CAST(@as_of_date AS VARCHAR)+'''''&__user_name__='+@user_login_id+'">' + 
				' Click here...' +'</a>'
				
				EXEC spa_print @message
				
				SET @sql_stmt =' EXEC spa_complete_compliance_activities ''a'',NULL,'''+cast(getdate() AS VARCHAR)+''',''<>'','+CAST(@risk_control_id AS VARCHAR)+',NULL,NULL,'''+@message+''',''v'''
				
				--print @sql_stmt
				EXEC(@sql_stmt)
			END
		
	IF @@ERROR <> 0
		BEGIN
		Exec spa_ErrorHandler @@ERROR, 'Publish Report', 
				'spa_ems_publish_report', 'DB Error', 
				'Failed to insert a Data', ''
		RETURN
		END
	ELSE
		Exec spa_ErrorHandler 0, 'Publish Report', 
				'spa_ems_publish_report', 'Success', 
				'Succeded to insert Data.', ''

END

 Else if @flag = 'd'
begin

	

	exec('delete from ems_publish_report
	where id in('+@id+')')
	 

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Publish Report', 
				'spa_ems_publish_report', 'DB Error', 
				'Failed to delete data from Published Report.', ''
	else
		Exec spa_ErrorHandler 0, 'Publish Report', 
				'spa_ems_publish_report', 'Success', 
				'Succeded to delete a Published Report date.', ''

end 















