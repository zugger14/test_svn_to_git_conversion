IF OBJECT_ID(N'[dbo].[spa_find_gis_recon_deals]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_find_gis_recon_deals]
GO



-- exec spa_find_gis_recon_deals 's', 'm', '2004-01-01', '2004-01-31', NULL, NULL, 'p', 'p', '1213'
-- exec spa_find_gis_recon_deals 's', 'm', '2006-01-01', null, null,null,null, null,  null
-- exec spa_find_gis_recon_deals 's', 'm', '2006-01-01', null, null,null,null, null,  'Windy2-Jan06,Windy-Jan06'
-- exec spa_find_gis_recon_deals 's', 'o', '2006-01-01', null, null,null,null, null,  null
-- exec spa_find_gis_recon_deals 's', 'o', '2006-01-01', null, null,null,null, null,  'Windy2-Jan06,Windy-Jan06'
-- exec spa_find_gis_recon_deals 's', 'u', '2006-01-01', '2006-03-31', null,null,'c', 'a',  null
-- exec spa_find_gis_recon_deals 's', 'u', '2006-01-01', null, null,null,null, null,  'Windy2-Jan06,Windy-Jan06'

-- exec spa_find_gis_recon_deals 's', 'u', '2006-01-01', '2006-01-31', null,null,'c', 'a',  'Windy2-Jan06'
-- exec spa_find_gis_recon_deals 's', 'u', '2006-01-01', '2006-01-31', NULL, NULL, 'c', 'a', '01%2F01%2F2006'

-- exec spa_find_gis_recon_deals 'u', 'm', null, null, null,null,null, 'a', 'Windy2-Jan06,Windy-Jan06'
-- exec spa_find_gis_recon_deals 'u', 'o', null, null, null,null,null, 'a', 'Windy2-Jan06,Windy-Jan06'
-- exec spa_find_gis_recon_deals 'u', 'u', null, null, null,null,null, 'a', 'Windy2-Jan06,Windy-Jan06'

CREATE PROCEDURE [dbo].[spa_find_gis_recon_deals] 
			@flag varchar(1), --'s' for select, 'u' for  update
			@flag2 varchar(1), --'m' matches, 'o' Over in FARRMS,'u' Under in FARRMS
			@gen_date_from  varchar(20),
			@gen_date_to  varchar(20) = null,
			@generator_id  int = null,
			@gis_value_id int = null,
			@status varchar(1) = null, --NULL or 'p' , 'c' completed
			@user_action varchar(1) = null,--NULL or 'p' pending user did not decide, 'a' user accepted, 'd' user declined
			@deal_id varchar(8000) = null --for drill down
AS

-- declare @flag varchar(1) --'m' matches, 'o' Over in FARRMS,'u' Under in FARRMS
-- declare @flag2 varchar(1)
-- declare @gen_date_from  varchar(20)
-- declare @gen_date_to  varchar(20)
-- declare @generator_id  int
-- declare @gis_value_id int
-- declare @status varchar(1) --NULL or 'p' , 'c' completed
-- declare @user_action varchar(1)--NULL or 'p' pending user did not decide, 'a' user accepted, 'd' user declined
-- declare @deal_id varchar(50) --for drill down

-- set @flag2='o'
-- set @gen_date_from  = '2006-06-01'
-- set @gen_date_to  = '2006-06-30'
-- set @flag =NULL
-- set @generator_id=23
-- 
-- --set @deal_id = 'Windy-Jan06'
-- --set @deal_id = 'Windy2-Jan06'
-- 
-- set @status = NULL

if @gen_date_to is  null
	set @gen_date_to = @gen_date_from


IF  @deal_id IS NOT NULL
BEGIN
	set @deal_id =  replace(@deal_id, ' ', '')
	set @deal_id =  replace(@deal_id, ',', ''', ''')
	set @deal_id = '''' + @deal_id + ''''

-- 	EXEC spa_print @deal_id
-- 	return
END


DECLARE @sql_stmt varchar(8000)

if @flag2 = 'o'
begin
	if @flag = 'u'
	begin
		set @sql_stmt = 
			' update gis_inventory_prior_month_adjustements set user_action = ''' + @user_action + '''
			where 	original_volume > change_volume_to and
				isnull(status, ''p'') = ''p'' and -- update only allowed for pending status
				isnull(user_action, ''p'') = ''p'' --update allowed only for pending user action
				and source_deal_header_id IN (' + @deal_id + ' ) '
	
--		EXEC spa_print @sql_stmt	

		exec (@sql_stmt)
		--print 'here'	
		--success message
		If @@error <> 0
			Exec spa_ErrorHandler @@error, 'Accept GIS Recons', 
				'spa_find_gis_recon_deals', 'DB Error', 
				'Failed to update GIS Over Recon transactions.', ''
		Else
			Exec spa_ErrorHandler 0, 'Accept GIS Recons', 
				'spa_find_gis_recon_deals', 'Success', 
				'GIS Over Recon transactions updated.', ''

		return
	end

	If @deal_id IS NULL	
		select 	gis.code [GIS], 
			rg.code [Generator], 
			dbo.FNADateFormat(gen_date_from) as [Gen Date], 
			source_deal_header_id [Feeder ID], 
			original_volume [Our Volume], 
			change_volume_to [GIS Volume],
			case 	when (isnull(gr.user_action, 'p') = 'p') then  'Pending' 
				when (isnull(gr.user_action, 'p') = 'a') then  'Accepted'
				else 'Declined' end [User Action],
			Case when (isnull(gr.status,'o') ='c') then 'Completed' else 'Pending' end Status,
			comment Comment
		from 
			gis_inventory_prior_month_adjustements gr left outer join
			static_data_value gis on gis.value_id = gr.gis_value_id left outer join 
			rec_generator rg  on rg.generator_id = gr.generator_id 
		where 	original_volume > change_volume_to and
			gen_date_from between @gen_date_from and @gen_date_to and		
			gr.generator_id = isnull(@generator_id,  gr.generator_id) and
			isnull(gr.gis_value_id, -1) = isnull(@gis_value_id,  isnull(gr.gis_value_id, -1)) and
			isnull(gr.status, 'p') = isnull(@status,  isnull(gr.status, 'p')) and
			isnull(gr.user_action, 'p') = isnull(@user_action,  isnull(gr.user_action, 'p')) 	

	Else
	BEGIN
		SET @sql_stmt = '
		select 	gis.code [GIS], 
			rg.code [Generator], 
			gp.source_deal_header_id  [Detail ID],
			dbo.FNAEmissionHyperlink(2,10131010, cast(sdd.source_deal_header_id as varchar), 
				cast(sdd.source_deal_header_id as varchar),NULL) [ID],
			dbo.FNADateFormat(gp.gen_date_from) [Term Start],
			dbo.FNADateFormat(gp.gen_date_to) [Term End],
			dbo.FNADateFormat(gp.gen_date_from) [GIS Cert Date],
			NULL [Cert From#],
			NULL [Cert To#],
			case 	when (isnull(gp.user_action, ''p'') = ''p'') then  ''Pending'' 
				when (isnull(gp.user_action, ''p'') = ''a'') then  ''Accepted''
				else ''Declined'' end [User Action],
			case when (isnull(gp.status, ''p'') = ''p'') then ''Pending'' else ''Completed'' end [Status] 
		from 	gis_inventory_prior_month_adjustements  gp inner join
			static_data_value gis on gis.value_id = gp.gis_value_id left outer join 
			rec_generator rg  on rg.generator_id = gp.generator_id left outer join
			source_deal_detail sdd on sdd.source_deal_detail_id=gp.source_deal_header_id
			
		where 	gp.change_volume_to < gp.original_volume and
			gp.gen_date_from between ''' + @gen_date_from + ''' and ''' + @gen_date_to + ''' and
			gp.generator_id = ' + case when (@generator_id is null) then ' gp.generator_id ' else cast(@generator_id as varchar) end + ' and
			isnull(gp.status, ''p'') = ' + case when (@status is null) then ' isnull(gp.status, ''p'')' else '''' + @status + '''' end + ' and
			isnull(gp.user_action, ''p'') = ' + case when (@user_action is null) then ' isnull(gp.user_action, ''p'')' else '''' + @user_action + '''' end + ' and
			gp.source_deal_header_id IN (' + @deal_id + ')'
		EXEC spa_print @sql_stmt
		exec (@sql_stmt)
		END
end

if @flag2 = 'u'
begin

	if @flag = 'u'
	begin
		set @sql_stmt = 
			' update gis_inventory_prior_month_adjustements set user_action = ''' + @user_action + '''
			where 	original_volume < change_volume_to and
				isnull(status, ''p'') = ''p'' and -- update only allowed for pending status
				isnull(user_action, ''p'') = ''p'' --update allowed only for pending user action
				and source_deal_header_id IN (' + @deal_id + ' ) '
	
--		EXEC spa_print @sql_stmt	

		exec (@sql_stmt)
		--print 'here'	
		--success message
		If @@error <> 0
			Exec spa_ErrorHandler @@error, 'Accept GIS Recons', 
				'spa_find_gis_recon_deals', 'DB Error', 
				'Failed to update GIS Under Recon transactions.', ''
		Else
			Exec spa_ErrorHandler 0, 'Accept GIS Recons', 
				'spa_find_gis_recon_deals', 'Success', 
				'GIS Under Recon transactions updated.', ''

		return
	end

	If @deal_id IS NULL
		select 	gis.code [GIS], 
			rg.code [Generator], 
			dbo.FNADateFormat(gen_date_from) as [Gen Date], 
			source_deal_header_id [Feeder ID], 
			original_volume [Our Volume], 
			change_volume_to [GIS Volume],
			case 	when (isnull(gr.user_action, 'p') = 'p') then  'Pending' 
				when (isnull(gr.user_action, 'p') = 'a') then  'Accepted'
				else 'Declined' end [User Action],
			Case when (isnull(gr.status, 'o') = 'c') then 'Completed' else 'Pending' end Status,
			comment Comment

		from 	gis_inventory_prior_month_adjustements gr left outer join
			static_data_value gis on gis.value_id = gr.gis_value_id left outer join 
			rec_generator rg  on rg.generator_id = gr.generator_id 
		where 	original_volume < change_volume_to and
			
			gr.gen_date_from = @gen_date_from and gr.gen_date_to=@gen_date_to and
			isnull(gr.generator_id, -1) = isnull(@generator_id,  isnull(gr.generator_id, -1)) and
			isnull(gr.gis_value_id, -1) = isnull(@gis_value_id,  isnull(gr.gis_value_id, -1)) and
			isnull(gr.status, 'p') = isnull(@status,  isnull(gr.status, 'p')) and
			isnull(gr.user_action, 'p') = isnull(@user_action,  isnull(gr.user_action, 'p')) 	
	Else
	begin
		SET @sql_stmt = '
		select 	gis.code [GIS], 
			rg.code [Generator], 
			gr.source_deal_header_id [Detail ID],
			dbo.FNAEmissionHyperlink(2,10131010, cast(sdd.source_deal_header_id as varchar), 
			cast(sdd.source_deal_header_id as varchar),NULL) [ID],
			dbo.FNADateFormat(gr.term_start) [Term Start],
			dbo.FNADateFormat(gr.term_end) [Term End],
			dbo.FNADateFormat(gis_cert_date) [GIS Cert Date],
			gis_cert_number [Cert From#],
			gis_cert_number_to [Cert To#],
			case 	when (isnull(gp.user_action, ''p'') = ''p'') then  ''Pending'' 
				when (isnull(gp.user_action, ''p'') = ''a'') then  ''Accepted''
				else ''Declined'' end [User Action],
			case when (isnull(gp.status, ''p'') = ''p'') then ''Pending'' else ''Completed'' end [Status] 
		from 	gis_reconcillation gr left outer join
			static_data_value gis on gis.value_id = gr.gis_value_id left outer join 
			rec_generator rg  on rg.generator_id = gr.generator_id left outer join
			gis_inventory_prior_month_adjustements  gp on gp.source_deal_header_id = gr.source_deal_header_id 
			left outer join source_deal_detail sdd on sdd.source_deal_detail_id = gr.source_deal_header_id
		where 	gr.gis_cert_number is not null and 
			(gr.source_deal_header_id is null OR gp.change_volume_to > gp.original_volume) and
			gp.generator_id = ' + case when (@generator_id is null) then ' gp.generator_id ' else cast(@generator_id as varchar) end + ' and
			gp.gis_value_id = ' + case when (@gis_value_id is null) then ' gp.gis_value_id ' else cast(@gis_value_id as varchar) end + ' and
			isnull(gp.status, ''p'') = ' + case when (@status is null) then ' isnull(gp.status, ''p'')' else '''' + @status + '''' end + ' and
			isnull(gp.user_action, ''p'') = ' + case when (@user_action is null) then ' isnull(gp.user_action, ''p'')' else '''' + @user_action + '''' end + ' and
			gr.source_deal_header_id IN (' + @deal_id + ')'

		EXEC spa_print @sql_stmt
		EXEC (@sql_stmt)
	
	end
end

If @flag2 ='m'
BEGIN
	if @flag = 'u'
	begin

		set @sql_stmt = 
			' update gis_reconcillation set user_action = ''' + @user_action + '''
			where 	gis_cert_number is not null and
				isnull(status, ''p'') = ''p'' and -- update only allowed for pending status
				isnull(user_action, ''p'') = ''p'' --update allowed only for pending user action
				and source_deal_header_id IN (' + @deal_id + ' ) '
	
--		EXEC spa_print @sql_stmt	

		exec (@sql_stmt)
		--print 'here'	
		--success message
		If @@error <> 0
			Exec spa_ErrorHandler @@error, 'Accept GIS Recons', 
				'spa_find_gis_recon_deals', 'DB Error', 
				'Failed to update GIS Matched Recon transactions.', ''
		Else
			Exec spa_ErrorHandler 0, 'Accept GIS Recons', 
				'spa_find_gis_recon_deals', 'Success', 
				'GIS Matched Recon transactions updated.', ''

	
		return
	end
--select * from gis_reconcillation
	If @deal_id IS NULL
		select 	gis.code [GIS], 
			rg.code [Generator], 
			gr.source_deal_header_id [DealID],
			match_volume [Volume Matched],
			case 	when (isnull(user_action, 'p') = 'p') then  'Pending' 
				when (isnull(user_action, 'p') = 'a') then  'Accepted'
				else 'Declined' end [User Action],
			case when (isnull(status, 'p') = 'p') then 'Pending' else 'Completed' end [Status] 
		
		from 	gis_reconcillation gr left outer join
			static_data_value gis on gis.value_id = gr.gis_value_id left outer join 
			rec_generator rg  on rg.generator_id = gr.generator_id
		where 	gr.gis_cert_number is not null and
			gr.term_start = @gen_date_from and gr.term_end=@gen_date_to and
			gr.generator_id = isnull(@generator_id,  gr.generator_id) and
			gr.gis_value_id = isnull(@gis_value_id,  gr.gis_value_id)and
			isnull(gr.status, 'p') = isnull(@status,  isnull(gr.status, 'p')) and
			isnull(gr.user_action, 'p') = isnull(@user_action,  isnull(gr.user_action, 'p')) 	
-- 		group by gis.code, rg.code, gr.structured_deal_id,
-- 			case 	when (isnull(user_action, 'p') = 'p') then  'Pending' 
-- 				when (isnull(user_action, 'p') = 'a') then  'Accepted'
-- 				else 'Declined' end,
-- 			case when (isnull(status, 'p') = 'p') then 'Pending' else 'Completed' end 
	Else
	BEGIN
		set @sql_stmt = '
		select 	gis.code [GIS], 
			rg.code [Generator], 
			gr.source_deal_header_id [Detail ID],
			dbo.FNAEmissionHyperlink(2,10131010, cast(sdd.source_deal_header_id as varchar), 
			cast(sdd.source_deal_header_id as varchar),NULL) [ID],
			dbo.FNADateFormat(gr.term_start) [Term Start],
			dbo.FNADateFormat(gr.term_end) [Term End],
			dbo.FNADateFormat(gis_cert_date) [GIS Cert Date],
			gis_cert_number [Cert From#],
			gis_cert_number_to [Cert To#],
			case 	when (isnull(user_action, ''p'') = ''p'') then  ''Pending'' 
				when (isnull(user_action, ''p'') = ''a'') then  ''Accepted''
				else ''Declined'' end [User Action],
			case when (isnull(status, ''p'') = ''p'') then ''Pending'' else ''Completed'' end [Status] 
		from 	gis_reconcillation gr left outer join
			static_data_value gis on gis.value_id = gr.gis_value_id left outer join 
			rec_generator rg  on rg.generator_id = gr.generator_id join source_deal_detail sdd 
			on sdd.source_deal_detail_id=gr.source_deal_header_id
		where 	gr.gis_cert_number is not null and
			gr.term_start between ''' + @gen_date_from + ''' and ''' + @gen_date_to + ''' and
			gr.generator_id = ' + case when (@generator_id is null) then ' gr.generator_id ' else cast(@generator_id as varchar) end + ' and
			gr.gis_value_id = ' + case when (@gis_value_id is null) then ' gr.gis_value_id ' else cast(@gis_value_id as varchar) end + ' and
			isnull(gr.status, ''p'') = ' + case when (@status is null) then ' isnull(gr.status, ''p'')' else '''' + @status + '''' end + ' and
			isnull(gr.user_action, ''p'') = ' + case when (@user_action is null) then ' isnull(gr.user_action, ''p'')' else '''' + @user_action + '''' end + ' and
			gr.source_deal_header_id IN (' + @deal_id + ')'

		EXEC spa_print @sql_stmt
		--print case when(@status is null) then 'NULL' else 'xxx' end

		EXEC (@sql_stmt)
	END
END		







