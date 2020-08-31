SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('spa_deal_voided_in_external') IS NOT NULL
	DROP  PROCEDURE spa_deal_voided_in_external
GO

CREATE PROCEDURE [dbo].[spa_deal_voided_in_external] 
@flag VARCHAR(1),
@deal_id VARCHAR(5000)=NULL,
@source_deal_header_id INT=NULL,
@as_of_date VARCHAR(10)=NULL,
@show_linked VARCHAR(1)='n',
@status VARCHAR(1)='v',
@as_of_date_to VARCHAR(10)=NULL

AS
SET NOCOUNT ON
DECLARE @st_select VARCHAR(MAX),@st_from VARCHAR(2000),@st_where VARCHAR(2000)

IF @flag = 's'
BEGIN
  IF ISNULL(@status, 'v') = 'v'
	BEGIN
		SELECT * INTO #tmp FROM (
			SELECT source_deal_header_id,update_ts voided_date, 'v' tran_status FROM source_deal_header WHERE source_system_book_id1 = -10
				UNION ALL
			SELECT source_deal_header_id,voided_date, tran_status FROM deal_voided_in_external --where isnull(tran_status,'v')='v'
		) aa
		
		CREATE INDEX idx_aaaaaa ON #tmp (source_deal_header_id)
		SET @st_select='sdh.source_deal_header_id DealID,sdh.deal_id RefID,
		 max(fld.link_id)  LinkID, dbo.FNADateFormat(sdh.deal_date) DealDate,dbo.FNADateFormat(voided_date) VoidedDate,
		dbo.FNADateFormat(min(term_start)) +'' ~ '' + dbo.FNADateFormat(max(term_end)) TenorPeriod
						,sc.counterparty_name CounterpartyName,tr.trader_name TraderName,	
							CASE coalesce(sel_deal.tran_status, ''Voided'')
							WHEN ''v'' THEN ''Voided''
							WHEN ''d'' THEN ''Deleted''
							else sel_deal.tran_status
						END TranStatus '

		SET @st_from=' source_deal_header sdh 
						INNER JOIN source_deal_detail sdd 
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
						inner join  #tmp sel_deal on sdh.source_deal_header_id=sel_deal.source_deal_header_id '
						+ 
						CASE 
							WHEN ISNULL(@show_linked,'n')='y' THEN ' INNER ' 
							WHEN @show_linked = 'a' THEN ' LEFT '
							ELSE ' LEFT ' 
						END 
						+
						' join fas_link_detail fld on sdh.source_deal_header_id=fld.source_deal_header_id 
						left join source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
						left join source_traders tr on tr.source_trader_id=sdh.trader_id 
						'
		SET @st_where=' 1=1 '
		IF @deal_id IS NOT NULL
			SET @st_where=@st_where + ' and sdh.deal_id LIKE ''%' + @deal_id + '%'''
		IF @source_deal_header_id  IS NOT NULL
			SET @st_where=@st_where + ' and sdh.source_deal_header_id=' + CAST(@source_deal_header_id AS VARCHAR)
		IF @deal_id IS NULL AND @source_deal_header_id IS NULL
		BEGIN 
			SET @st_where=' isnull(sel_deal.tran_status,''v'')=''' + ISNULL(@status ,'v') + ''''
			IF @as_of_date  IS NOT NULL and @as_of_date_to is null
				SET @st_where=@st_where + ' and convert(date,sel_deal.voided_date,120)>=''' + @as_of_date +''''
			IF @as_of_date  IS  NULL and @as_of_date_to is NOT null
				SET @st_where=@st_where + ' and convert(date,sel_deal.voided_date,120)<=''' + @as_of_date_to +''''
			IF @as_of_date  IS not NULL and @as_of_date_to is NOT null
			BEGIN	
				SET @st_where=@st_where + ' and convert(date,sel_deal.voided_date,120)<=''' + @as_of_date_to +''''
				SET @st_where=@st_where + ' and convert(date,sel_deal.voided_date,120)>=''' + @as_of_date +''''
			END
			SET @st_where=@st_where + CASE WHEN ISNULL(@show_linked,'n')='y' THEN ''
											WHEN @show_linked = 'a' THEN ' '
											ELSE ' and fld.source_deal_header_id is null' END
		END
	
	--PRINT ('select ' + @st_select + ' from ' + @st_from + ' where ' + @st_where +'
	--	group by sdh.source_deal_header_id,sdh.deal_id, sdh.deal_date,sel_deal.voided_date,sc.counterparty_name,tr.trader_name,sel_deal.tran_status ')
	EXEC  ('select ' + @st_select + ' from ' + @st_from + ' where ' + @st_where +'
		group by sdh.source_deal_header_id,sdh.deal_id, sdh.deal_date,sel_deal.voided_date,sc.counterparty_name,tr.trader_name,sel_deal.tran_status ')
	
	END
	ELSE
	BEGIN
		SET @st_select='select distinct deal_id RefID,source_deal_header_id DealID,dbo.FNADateFormat(voided_date) VoidedDate,dbo.FNADateFormat(update_ts) DeletedDate,update_user DeletedBy 
				from deal_voided_in_external where tran_status=''d'''
			
			IF @deal_id IS NULL AND @source_deal_header_id IS NULL
			BEGIN
				SET @st_where = ''
				IF @as_of_date  IS NOT NULL and @as_of_date_to is null
					SET @st_where=@st_where + ' and convert(date,voided_date,120)>=''' + @as_of_date +''''
				IF @as_of_date  IS  NULL and @as_of_date_to is NOT null
					SET @st_where=@st_where + ' and convert(date,voided_date,120)<=''' + @as_of_date_to +''''
				IF @as_of_date  IS not NULL and @as_of_date_to is NOT null
				BEGIN	
					SET @st_where=@st_where + ' and convert(date,voided_date,120)<=''' + @as_of_date_to +''''
					SET @st_where=@st_where + ' and convert(date,voided_date,120)>=''' + @as_of_date +''''
				END
			END
			
			IF @st_where IS NOT NULL AND @st_where <>''
				BEGIN
					SET @st_select = @st_select + @st_where
				END 
			IF @deal_id IS NOT NULL
			BEGIN
					SET @st_select = @st_select + ' and deal_id=''' + @deal_id +''''
			END

			IF @source_deal_header_id IS NOT NULL
			BEGIN
					SET @st_select = @st_select + ' and source_deal_header_id=''' + CAST(@source_deal_header_id AS VARCHAR) +''''
			END
			
			SET @st_select = @st_select + ' order by deal_id'
		EXEC(@st_select)
	END
END

ELSE IF @flag='u'
BEGIN
	declare @delete_delete_status varchar(50)
	BEGIN TRY
		BEGIN TRAN
		SET @deal_id=REPLACE(@deal_id,'''','')
		EXEC spa_print @deal_id

		EXEC('SELECT top(1) fld.source_deal_header_id  into #tmp_existance_checking from fas_link_detail fld
				inner join deal_voided_in_external s  on s.source_deal_header_id=fld.source_deal_header_id
				and s.source_deal_header_id IN  (' + @deal_id + ')')
		IF @@ROWCOUNT > 0
		BEGIN
			ROLLBACK TRAN
			EXEC spa_ErrorHandler -1
				, 'Delete Voided Deal'
				, 'spa_sourcedealheader'
				, 'DB Error'
				, 'Void deal is participating in a hedging relationship. Please remove the deal from the hedging relationship before deleting it.'			
				, ''
		END	
		ELSE
		BEGIN
		
			EXEC('update deal_voided_in_external 
						SET tran_status=''d''
							from  deal_voided_in_external s 
						left join fas_link_detail fld on s.source_deal_header_id=fld.source_deal_header_id
						--INNER JOIN source_deal_header h ON h.deal_id = s.deal_id
						where s.source_deal_header_id IN  (' + @deal_id + ') and fld.source_deal_header_id is null')

			
			
				declare @deal_id1 varchar(2000)
				SET @deal_id1=''+@deal_id+''
				
				EXEC spa_source_deal_header  @flag='d',@deal_ids=@deal_id1,@comments='Delete for test'
				COMMIT TRAN
		END				
	END TRY
	BEGIN CATCH
		DECLARE @err_msg VARCHAR(5000)
		SET @err_msg='Failed deleting record (' + ERROR_MESSAGE() +').'
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1
			, 'Delete Voided Deal'
			, 'spa_sourcedealheader'
			, 'DB Error'
			--, 'Void deal is participating in a hedging relationship. Please remove the deal from the hedging relationship before deleting it.'
			, @err_msg
			, ''
	END CATCH
	
END
GO