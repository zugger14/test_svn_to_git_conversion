IF OBJECT_ID('[dbo].[spa_get_dedesignate_data]') IS NOT NULL
	DROP PROC [dbo].[spa_get_dedesignate_data]

GO

create PROCEDURE [dbo].[spa_get_dedesignate_data] 
	@IDs varchar(1000),
	@process_id varchar(100),
	@flag VARCHAR(1) = NULL
AS
/*
DECLARE @IDs varchar(1000),
					@process_id varchar(100), @flag VARCHAR(1)
					
	SELECT 	@IDs='2',		@process_id='CF162B08_325B_4AD5_BA7E_06E0C0D1DAEA', @flag = 'n'
	DROP TABLE #IDs
	--SELECT * FROM adiha_process.dbo.matching_farrms_admin_F8F5F4CB_BE95_4D24_B84B_C268456AE957

--*/	
SET NOCOUNT ON
	
	declare @ProcessTableName varchar(128),@user_name varchar(100),@process_id_new varchar(50)
	set @user_name=dbo.fnadbuser()
	declare @sql varchar(max)
	SET @ProcessTableName = dbo.FNAProcessTableName('matching', @user_name, @process_id)

	if object_id(@ProcessTableName) is null 
	begin
		Select 'Error' as ErrorCode,  'Dedesignation' as Module,
		'spa_dedesignated_hedges' as Area, 'Error' as Status,
		 'Failed to dedesignate ROWIDs: ' + @IDs + '; process_id:'+@process_id+'; login_id:'+@user_name+' since there has already been deleted process table.Hence, it is required to re-run the report.' as Message, 'Please re-run the report.' as Recommendation
		return
	end
	SELECT rowid=IDENTITY(INT,1,1),* into #IDs FROM dbo.SplitCommaSeperatedValues(@IDs) scsv
--	SELECT rowid=IDENTITY(INT,1,1),* into #IDs FROM dbo.SplitCommaSeperatedValues('1,2,4') scsv
	set @process_id_new=REPLACE(newid(),'-','_')
	IF @flag IS NULL
		-- call when dedesignate link
		BEGIN
--	set @sql=' select 
--		abs(sum([Volume Avail])) vol,dbo.fnadateformat(max([link_effective_date])) [link_effective_date],dbo.fnadateformat(min(term_start)) term_start
--				,dbo.fnadateformat(max(term_end)) term_end,max(p.source_uom_id) uom_id ,max(curve_id) curve_id,max(buy_sell) buy_sell
--	           from  #IDs i 
--		inner join ' +@ProcessTableName+' p on i.item=p.rowid 
--				--left join source_uom su on p.uom=su.uom_name 
--		'
		
		set @sql=' select 
		abs(sum([Volume Avail])) vol,convert(varchar(10),max([link_effective_date]),120) [link_effective_date]
		,convert(varchar(10),min(term_start),120) term_start
				,convert(varchar(10),max(term_end),120) term_end,max(p.source_uom_id) uom_id ,max(curve_id) curve_id,max(buy_sell) buy_sell
	           from  #IDs i 
		inner join ' +@ProcessTableName+' p on i.item=p.rowid 
				--left join source_uom su on p.uom=su.uom_name 
		'
	
		
		END
	ELSE
		-- called whed unprocess or unmatch deals
		BEGIN
			set @sql=' select 
				MAX(CASE WHEN type = ''h'' THEN [Deal ID] 
				ELSE NULL 
				END) h_deal_id, 
				
				MAX(CASE WHEN type = ''i'' THEN [Deal ID] 
				ELSE NULL 
				END) i_deal_id, 
				
				MAX(CASE WHEN type = ''h'' THEN [Deal Ref ID] 
				ELSE NULL 
				END) h_deal_ref_id, 
				
				MAX(CASE WHEN type = ''i'' THEN [Deal Ref ID] 
				ELSE NULL 
				END) i_deal_ref_id
				
				from  #IDs i 
				inner join ' +@ProcessTableName+' p on i.item=p.rowid 
				--left join source_uom su on p.uom=su.uom_name 
				'
		END
			

--	exec spa_print @sql
	exec(@sql)
	