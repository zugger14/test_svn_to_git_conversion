IF OBJECT_ID(N'spa_fas_link_detail_dicing', N'P') IS NOT NULL
DROP PROCEDURE spa_fas_link_detail_dicing
 GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_fas_link_detail_dicing]
	@flag varchar(1)='v'
	,@assign_percent float=null
	,@link_id int
	,@source_deal_header_id int
	,@term_start date=null
	,@xml text=null
as	
SET NOCOUNT ON
/*	
--------input parameter----------------------
declare @flag varchar(1)='v'
	,@assign_percent float=.3 --user input percentage
	,@link_id int
	,@source_deal_header_id int=234
	,@term_start date='2011-01-01'
	,@xml text=null
-------------------------

--*/

declare @st varchar(max)
IF @flag = 'v'
BEGIN
	declare @link_deal_term_used_per varchar(200),@process_id varchar(150),@user_login_id varchar(30)

	select @process_id=dbo.fnagetnewid(),@user_login_id =dbo.FNADBUser()

	SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

	SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

	declare @effective_date date=getdate(),@sql varchar(max)

	CREATE TABLE #temp_per_used (term_start date,used_per float)
	
	if OBJECT_ID(@link_deal_term_used_per) is not null
		exec('drop table '+@link_deal_term_used_per)
	
	exec dbo.spa_get_link_deal_term_used_per @as_of_date =@effective_date,@link_ids=null,@header_deal_id =@source_deal_header_id,@term_start=@term_start
		,@no_include_link_id =@link_id,@output_type =0	,@include_gen_tranactions  = 'b',@process_table=@link_deal_term_used_per

	SET @sql = 'INSERT INTO #temp_per_used  (term_start  ,used_per ) SELECT 	term_start, percentage_used from  ' +@link_deal_term_used_per
					
	exec(@sql)		

	declare @msg_per varchar(max)

	select @msg_per =isnull(@msg_per+'; ','') + dbo.FNADateFormat(term_start)+'='+ str((used_per+@assign_percent)*100,6,2) 
	from #temp_per_used 
	where used_per +@assign_percent>1.00002

	IF isnull(@msg_per,'') <>''
	BEGIN
	
		SET @msg_per='The term exceed 100 percentage('+@msg_per+').'
		
		EXEC spa_ErrorHandler -1, 'Fas Link', 'spa_fas_link', 'DB Error', @msg_per, 0
	END 
	ELSE
		EXEC spa_ErrorHandler 0, 'Fas Link', 'spa_fas_link', 'Success', '', 0
END

else if @flag = 'u'
begin

	DECLARE @idoc INT 
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml

	SELECT 
		dbo.FNAStdDate(Term_start) AS Term_start
		,percentage_used = CASE 
			percentage_used
			WHEN  '' THEN '1' 
			ELSE percentage_used
		    END
		, effective_date = CASE 
			dbo.FNAStdDate(effective_date)
			WHEN  '1900-01-01 00:00:00.000' THEN NULL 
			ELSE dbo.FNAStdDate(effective_date)
			END
		,GETDATE() AS update_ts
		,dbo.fnadbuser() AS update_user
			
		INTO #fas_link_detail_dicing
	FROM   OPENXML(@idoc ,'/Root/PSRecordset' ,2)
	WITH (
		Term_start VARCHAR(50) '@term_start'
		,percentage_used float '@percentage_included'
		,effective_date VARCHAR(50) '@effective_date'
		,update_ts DATETIME 'NULL'
		,update_user VARCHAR(50) 'NULL'
	)
	
	DECLARE @link_effective_date DATETIME , @error_message VARCHAR(1000)
	
	SELECT @link_effective_date = dbo.FNAGetSQLStandardDate(link_effective_date) from fas_link_header where link_id = @link_id
		
	IF EXISTS (SELECT 1 FROM #fas_link_detail_dicing tfld WHERE @link_effective_date > effective_date) 
        BEGIN
            SET @error_message = 'Failed to update dicing detail record.' +
                'Effective Date can not be less than the link effective date. One or more selected deals violated this.'
            
            EXEC spa_ErrorHandler 1,
                 'Fas Link detail dicing table',
                 'spa_fas_link_detail_dicing',
                 'DB Error',
                 @error_message,
                 @error_message
            RETURN
        END
	
	--SELECT * FROM #fas_link_detail_dicing;	RETURN;
	
	delete fas_link_detail_dicing from fas_link_detail_dicing d left join  #fas_link_detail_dicing t 
			ON  d.term_start=t.term_start
	where d.link_id =@link_id and d.source_deal_header_id=@source_deal_header_id 
	and t.term_start is null


	
	set @st='MERGE fas_link_detail_dicing AS fldd
	USING #fas_link_detail_dicing t
		ON fldd.link_id =' +cast(@link_id as varchar)+ ' and fldd.source_deal_header_id='+cast(@source_deal_header_id as varchar)+' and fldd.term_start=t.term_start
	WHEN MATCHED AND fldd.percentage_used<>t.percentage_used or ISNULL( fldd.effective_date, ''1900-01-01 00:00:00.000'') <> ISNULL(t.effective_date, ''1900-01-01 00:00:00.000'')
			then UPDATE SET fldd.percentage_used = t.percentage_used,fldd.effective_date = t.effective_date,fldd.update_ts = t.update_ts,fldd.update_user = t.update_user
	--WHEN NOT MATCHED BY SOURCE THEN DELETE
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(link_id,source_deal_header_id,term_start,percentage_used,effective_date,create_ts,create_user)
		VALUES(' +cast(@link_id as varchar)+ ','+cast(@source_deal_header_id as varchar)+',t.term_start,t.percentage_used,t.effective_date, t.update_ts,t.update_user);'
		
	--print @st
	exec(@st)	
	IF @@ERROR <> 0
            EXEC spa_ErrorHandler @@ERROR,
                 'Fas Link detail dicing table',
                 'spa_fas_link_detail_dicing',
                 'DB Error',
                 'Failed to update dicing detail record.',
                 ''
        ELSE
            EXEC spa_ErrorHandler 0,
                 'Link Dedesignation Table',
                 'spa_fas_link_detail_dicing',
                 'Success',
                 'Hedged Items dicing records successfully Updated.',
                 ''
end

else if @flag = 's'
begin
	select case when fldd.source_deal_header_id is null then 0 else 1 end Sel
		,dbo.fnadateformat(sdd.term_start) [Term Start]
		,fldd.percentage_used [Percentage Included]
		,fldd.effective_date [Effective Date]
	from fas_link_detail fld
	inner join source_deal_detail sdd on fld.source_deal_header_id=sdd.source_deal_header_id and sdd.leg=1
	and fld.link_id=@link_id and fld.source_deal_header_id=@source_deal_header_id
	inner join source_deal_header sdh on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join  dbo.fas_link_detail_dicing fldd on fld.link_id=fldd.link_id 
	and  fld.source_deal_header_id =fldd.source_deal_header_id 	and sdd.term_start=fldd.term_start 
	order by sdd.term_start
	
	IF @@ERROR <> 0
            EXEC spa_ErrorHandler @@ERROR,
                 'Fas Link detail dicing table',
                 'spa_fas_link_detail_dicing',
                 'DB Error',
                 'Failed to show dicing detail record.',
                 ''
end
