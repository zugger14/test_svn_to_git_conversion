/****** Object:  StoredProcedure [dbo].[spa_get_percentage_dedesignation]    Script Date: 10/02/2009 14:09:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_percentage_dedesignation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_percentage_dedesignation]
/****** Object:  StoredProcedure [dbo].[spa_get_percentage_dedesignation]    Script Date: 10/02/2009 14:09:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_get_percentage_dedesignation 's', 508
-- exec spa_get_percentage_dedesignation 'd', 726

--if @flag = 's' pass link_id  if @flag = 'd' then pass ID from the grid
CREATE proc [dbo].[spa_get_percentage_dedesignation](@flag varchar(1), @id int)
AS
SET NOCOUNT ON
---------------------
--declare @flag varchar(1), @id int
--set @flag = 'd'
--set @id = 733
--drop table #max_date
---------------------
DECLARE @user_login_id VARCHAR(100)
SET @user_login_id = dbo.FNADBUser()

if @flag = 's'
begin
	SELECT  link_id, 
			dbo.FNATRMWinHyperlink('m', 10233700, link_description, ABS(link_id),null,null,null,null,null,null,null,null,null,null,null,0)	AS link_description,
			dbo.FNAUserDateFormat(link_end_date,@user_login_id) link_end_date, 
			dedesignated_percentage, 
			dt.code dedesignation_type
	FROM    fas_link_header inner join
		static_data_value dt on dt.value_id = link_type_value_id
	where 	original_link_id = @id
	order by link_end_date desc
end
else
begin

	--script to undo not probable link
	declare @percentage float
	declare @link_id int
	declare @dedesignation_date varchar(20)
	DECLARE @closed_book_count int
	declare @min_as_of_date datetime

	set @percentage = null
	select @percentage = dedesignated_percentage, @link_id = original_link_id, @dedesignation_date = dbo.FNAGetSQLStandardDate(link_end_date)
	from fas_link_header where link_id = @id

	create table #max_date (as_of_date datetime)
	declare @st_where varchar(500)
	set @st_where =' as_of_date>='''+ @dedesignation_date +''' and link_id='+cast(@link_id as varchar)
--print @st_where
	insert into #max_date (as_of_date) exec  spa_get_Script_ProcessTableFunc 'min','as_of_date','report_measurement_values',@st_where
	select @min_as_of_date = dbo.FNAGetSQLStandardDate(min(as_of_date)) from #max_date

		
	if @percentage is null
		return

--DO NOT CHECK FOR CLOSED PERIOD: UB 08/12/2009
/*
	if @min_as_of_date is not null
	begin
		SELECT     @closed_book_count  = COUNT(*) 
		FROM         close_measurement_books
		WHERE     (as_of_date >= 
			CAST (dbo.FNAGetContractMonth(@min_as_of_date) as datetime))

		
		if (isnull(@closed_book_count, 0) > 0)
		begin
			Select 'Error' ErrorCode, 'Dedesignation' Module, 'spa_get_percentage_dedesignation' Area, 
				'Error' Status, 
				'The selected dedesignation can not be deleted as the Accounting Period has already been closed.' Message, 
				'Please unclose the measurement book before deleting.' Recommendation
			RETURN
		end
	end
*/

	update fas_link_detail set percentage_included = fld.percentage_included + isnull(pre_link.percentage_included, 0) 
	from fas_link_detail fld inner join
	(
	select fdld.source_deal_header_id, fdlh.original_link_id link_id, isnull(fdld.percentage_included, 0) percentage_included
	from   fas_link_header fdlh inner join
		   fas_link_detail fdld on fdld.link_id = fdlh.link_id
	where fdlh.link_id = @id 
	) pre_link on pre_link.link_id = fld.link_id and pre_link.source_deal_header_id = fld.source_deal_header_id


	delete report_measurement_values_expired where link_id = @id
	delete calcprocess_deals_expired where link_id = @id


	delete fas_link_detail where link_id = @id
		
	delete fas_link_header WHERE link_id = @id

	delete fas_dedesignated_link_detail where dedesignated_link_id in (
		select dedesignated_link_id from fas_dedesignated_link_header where original_link_id = @link_id and 
		dedesignation_date = @dedesignation_date)

	delete fas_dedesignated_link_header where original_link_id = @link_id and dedesignation_date = @dedesignation_date
		
	set @st_where=' link_id = '+cast(@link_id as varchar)+' and link_deal_flag = ''l'' and as_of_date >='''+ @dedesignation_date+''''
--print @st_where
	--exec spa_delete_ProcessTable 'report_measurement_values',@st_where
		EXEC('delete report_measurement_values where ' + @st_where)

--	exec spa_delete_ProcessTable 'report_measurement_values_expired',@st_where
	EXEC('delete report_measurement_values_expired where ' + @st_where)


	set @st_where=' link_id = '+cast(@id as varchar)+' and link_deal_flag = ''l'' and as_of_date >='''+ @dedesignation_date+''''
--print @st_where
--	exec spa_delete_ProcessTable 'report_measurement_values',@st_where
		EXEC('delete report_measurement_values where ' + @st_where)

--	exec spa_delete_ProcessTable 'report_measurement_values_expired',@st_where
		EXEC('delete report_measurement_values_expired where ' + @st_where)


	set @st_where=' link_id in (select source_deal_header_id from fas_link_detail where link_id ='+ cast(@link_id as varchar) +' and hedge_or_item = ''h'') and link_deal_flag = ''d'' and as_of_date >='''+ @dedesignation_date+''''
--print @st_where
--	exec spa_delete_ProcessTable 'report_measurement_values',@st_where
		EXEC('delete report_measurement_values where ' + @st_where)

--	exec spa_delete_ProcessTable 'report_measurement_values_expired',@st_where
	EXEC('delete report_measurement_values_expired where ' + @st_where)

	set @st_where=' link_id in (select source_deal_header_id from fas_link_detail where link_id ='+ cast(@id as varchar) +' and hedge_or_item = ''h'') and link_deal_flag = ''d'' and as_of_date >='''+ @dedesignation_date+''''
--print @st_where
--	exec spa_delete_ProcessTable 'report_measurement_values',@st_where
		EXEC('delete report_measurement_values where ' + @st_where)

--	exec spa_delete_ProcessTable 'report_measurement_values_expired',@st_where
	EXEC('delete report_measurement_values_expired where ' + @st_where)

--return

	--
	update fas_link_header  set fully_dedesignated = 'n' where link_id = @link_id
	
	set @st_where=' link_id = '+cast(@link_id as varchar)+' and link_type = ''link'' and  as_of_date >= '''+ @dedesignation_date +''''
	--print @st_where
--	exec spa_delete_ProcessTable 'calcprocess_deals',@st_where
	EXEC('delete calcprocess_deals where ' + @st_where)
	
	--exec spa_delete_ProcessTable 'calcprocess_deals_expired',@st_where
	EXEC('delete calcprocess_deals_expired where ' + @st_where)


	set @st_where=' link_id = '+cast(@id as varchar)+' and link_type = ''link'' and  as_of_date >= '''+ @dedesignation_date +''''
	--print @st_where
--	exec spa_delete_ProcessTable 'calcprocess_deals',@st_where
		EXEC('delete calcprocess_deals where ' + @st_where)

--	exec spa_delete_ProcessTable 'calcprocess_deals_expired',@st_where
		EXEC('delete calcprocess_deals_expired where ' + @st_where)


	set @st_where=' link_type = ''deal'' and link_id in (select source_deal_header_id from fas_link_detail where link_id = '+cast(@link_id as varchar)+' and hedge_or_item = ''h'') and  as_of_date >= '''+ @dedesignation_date +''''
--print @st_where
--	exec spa_delete_ProcessTable 'calcprocess_deals',@st_where
		EXEC('delete calcprocess_deals where ' + @st_where)

--	exec spa_delete_ProcessTable 'calcprocess_deals_expired',@st_where
		EXEC('delete calcprocess_deals_expired where ' + @st_where)


	set @st_where=' link_type = ''deal'' and link_id in (select source_deal_header_id from fas_link_detail where link_id = '+cast(@id as varchar)+' and hedge_or_item = ''h'') and  as_of_date >= '''+ @dedesignation_date +''''
--print @st_where
--	exec spa_delete_ProcessTable 'calcprocess_deals',@st_where
		EXEC('delete calcprocess_deals where ' + @st_where)

--	exec spa_delete_ProcessTable 'calcprocess_deals_expired',@st_where
		EXEC('delete calcprocess_deals_expired where ' + @st_where)



	set @st_where=' link_type = ''link'' and link_id ='+cast(@link_id as varchar)+'  and as_of_date >= '''+ @dedesignation_date +''''
--print @st_where
--	exec spa_delete_ProcessTable 'calcprocess_aoci_release',@st_where
	EXEC('delete calcprocess_aoci_release where ' + @st_where)


	set @st_where=' link_type = ''link'' and link_id ='+cast(@id as varchar)+'  and as_of_date >= '''+ @dedesignation_date +''''
--print @st_where
--	exec spa_delete_ProcessTable 'calcprocess_aoci_release',@st_where
	EXEC('delete calcprocess_aoci_release where ' + @st_where)


--	delete report_netted_gross_net
--	where (link_id = @link_id) AND (link_deal_flag = 'l') and as_of_date >= @dedesignation_date
--	delete report_netted_gross_net
--	where (link_id = @id) AND (link_deal_flag = 'l') and as_of_date >= @dedesignation_date


	If @@ERROR <> 0
		begin
			Exec spa_ErrorHandler  @@ERROR, 'Dedesignation', 
					'spa_get_percentage_dedesignation', 'DB Error', 
					'Failed to delete the selected dedesignation link.', ''
		end
	else
		Select 'Success' ErrorCode, 'Dedesignation' Module, 'spa_get_percentage_dedesignation' Area, 
				'Success' Status, 'Successfully deleted selected dedesignation link.' Message, '' Recommendation


end















