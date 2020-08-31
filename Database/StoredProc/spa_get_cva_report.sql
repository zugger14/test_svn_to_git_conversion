
if OBJECT_ID('dbo.spa_get_cva_report') is not null
drop proc dbo.spa_get_cva_report
go

--select * from default_probability
--select * from default_recovery_rate

--select * from static_data_value
--select * from counterparty_credit_info
--select * from source_deal_pfe_simulation
--select * from credit_exposure_detail where as_of_date='2012-06-22'

create proc dbo.spa_get_cva_report
@as_of_date varchar(10)='2012-06-25'
,@as_of_date_to varchar(10)='2012-06-25'
,@report_type varchar(1)='d'
,@counterparty_ids varchar(1000) ='19,58'
,@term_start  varchar(10)=null
,@term_end  varchar(10)=null
,@entity_type int=null
,@tenor_option varchar(1)='c'
,@curve_source_id varchar(10)=4500
,@use_simulated_exposures varchar(1)='n'
,@round varchar(1)

--added for paging
,@batch_process_id VARCHAR(250) = NULL,
@batch_report_param VARCHAR(500) = NULL, 
@enable_paging INT = 0,  --'1' = enable, '0' = disable
@page_size INT = NULL,
@page_no INT = NULL
AS
SET NOCOUNT ON 
/*


declare  @as_of_date varchar(10)='2012-06-25'
,@as_of_date_to varchar(10)='2012-06-25'
,@report_type varchar(1)='d'
,@counterparty_ids varchar(1000) ='19'
,@term_start  varchar(10)=null
,@term_end  varchar(10)=null
,@entity_type int=null
,@tenor_option varchar(1)='u'
,@curve_source_id varchar(10)=4500
,@use_simulated_exposures varchar(1)='n'
,@round varchar(1)
 
 
 --*/

-- @tenor_option   = 'u'    : Cumulative
-- @tenor_option   = 'c'    : Contract Month
-- @tenor_option   = 's'    : Summary


/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
--SET @page_size = 3
 
IF @is_batch = 1
   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
IF @enable_paging = 1 --paging processing
BEGIN
   IF @batch_process_id IS NULL
      SET @batch_process_id = dbo.FNAGetNewID()
 
   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
 
   --retrieve data from paging table instead of main table
   IF @page_no IS NOT NULL 
   BEGIN
      SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
      EXEC (@sql_paging) 
      RETURN 
   END
END
 
/*******************************************1st Paging Batch END**********************************************/



declare @st varchar(max),@st1 varchar(max),@distination_table_name varchar(50)
,@st_as_of_date varchar(200),@st_from varchar(max),@st_coulumns varchar(max),@st_group_by varchar(max)


set @as_of_date_to=ISNULL(@as_of_date_to,@as_of_date)

set @st_as_of_date =' src.as_of_date between '''+@as_of_date+''' and '''+@as_of_date+''''

set @st_from=' from dbo.source_deal_cva s '

if ISNULL(@use_simulated_exposures,'n')='y'
begin
	--set @curve_source_id=4505
	set @st_as_of_date = ' src.[run_date] between '''+@as_of_date+''' and '''+@as_of_date+''''
end

set @st = @st_as_of_date 
	+ case when @counterparty_ids is not null then ' and src.Source_Counterparty_ID in ('+@counterparty_ids+')' else '' end
	+ case when @term_start is not null then ' and src.term_start>='''+@term_start+'''' else '' end
	+ case when @term_end is not null then ' and src.term_start<='''+@term_end+'''' else '' end
	+ case when @curve_source_id is not null then ' and src.curve_source_value_id ='+case when  ISNULL(@use_simulated_exposures,'n')='y' then '4505' else @curve_source_id end else '' end
	+ case when @entity_type is not null then ' and sc.type_of_entity ='+cast(@entity_type as varchar) else '' end



set @st_coulumns ='SELECT '''+@as_of_date +''' [As Of Date]'
	+case when @report_type='s' then '' else ',dbo.FNAHyperLinkText(10131010,sdh.deal_id,sdh.source_deal_header_id) [Deal ID]' end 
	+',sc.Counterparty_name Counterparty' 
	+case when @report_type='s' then ',
		ROUND(SUM(s.exposure_to_us), ' + @round + ') [Exposure To Us],
		ROUND(SUM(s.exposure_to_them), ' + @round + ') [Exposure To Them], 
		ROUND(SUM(s.cva), ' + @round + ') CVA, 
		ROUND(SUM(s.dva), ' + @round + ') DVA, ' + case when ISNULL(@use_simulated_exposures, 'n') = 'n' THEN '
		ROUND(SUM(s.d_cva), ' + @round + ') [Discounted CVA],
		ROUND(sum(s.d_dva), ' + @round + ') [Discounted DVA], ' ELSE '' END + '
		ROUND(SUM(' + case when ISNULL(@use_simulated_exposures,'n') = 'y' then 'ce' else 's' end + '.Final_Und_Pnl), ' + @round + ') MTM,
		ROUND(SUM(' + case when ISNULL(@use_simulated_exposures,'n') = 'y' then 'ce.Final_Und_Pnl+(s.cva+s.dva)' else 's.credit_adjustment_mtm' end + '), ' + @round + ') [Credit Adjusted MTM],
		' + case when ISNULL(@use_simulated_exposures, 'n') = 'n' THEN '
		ROUND(SUM(s.adjusted_discounted_mtm), ' + @round + ') [Adjusted Discounted MTM], ' ELSE '' END + '
		MAX(' + case 
					when ISNULL(@use_simulated_exposures, 'n') = 'y' then 'ce' else 's' 
		        end +'.currency_name) Currency' else  
		        case @tenor_option 
					when 'c' then ',dbo.fnadateformat(s.term_start) Term' 
					when 'u' then '' else '' 
		        END  
	 END + ''
	+case when @report_type='s' then '' else 
		+case when  ISNULL(@use_simulated_exposures,'n')='y' then ',
			ROUND(ce.exposure_to_us, ' + @round + ') [Exposure To Us],
			ROUND(ce.exposure_to_them, ' + @round + ') [Exposure To Them],
			ROUND(ISNULL(ce.CVA,0), ' + @round + ') CVA,
			ROUND(ISNULL(ce.DVA,0), ' + @round + ') DVA,
			ROUND(ce.Final_Und_Pnl, ' + @round + ') MTM,
			ROUND(ce.Final_Und_Pnl+(ISNULL(ce.CVA,0)+ISNULL(ce.DVA,0)), ' + @round + ') [Credit Adjusted MTM],
			(ce.currency_name) Currency' 
		else ',
			ROUND(SUM(s.exposure_to_us), ' + @round + ') [Exposure To Us],
			ROUND(SUM(s.exposure_to_them), ' + @round + ') [Exposure To Them], 
			ROUND(SUM(s.cva), ' + @round + ') CVA, 
			ROUND(SUM(s.dva), ' + @round + ') DVA,
			ROUND(SUM(s.d_cva), ' + @round + ') [Discounted CVA], 
			ROUND(SUM(s.d_dva), ' + @round + ') [Discounted DVA],
			ROUND(SUM(s.Final_Und_Pnl), ' + @round + ') MTM,
			ROUND(SUM(s.credit_adjustment_mtm), ' + @round + ') [Credit Adjusted MTM],
			ROUND(SUM(s.adjusted_discounted_mtm), ' + @round + ') [Adjusted Discounted MTM],
			MAX(s.currency_name) Currency'  
		end 
	END + @str_batch_table
	
set @st_group_by=' Group by '+case when ISNULL(@use_simulated_exposures,'n')='y' then 'src.run_date' else 's.as_of_date' end +',sc.Counterparty_name'+ case when @report_type='s' then '' else ',sdh.source_deal_header_id,sdh.deal_id' end
 +case when @report_type='s' then '' else
	case @tenor_option when 'c'  then ',s.term_start' when 'u' then '' else '' end
end

if ISNULL(@use_simulated_exposures,'n')='y'
begin
	set @st_from=' from 
	( 
	select src.run_date,src.Source_Counterparty_ID,src.source_deal_header_id'+case @tenor_option when 'c'  then ',src.term_start' when 'u' then '' else '' end+',sum(src.exposure_to_us) exposure_to_us,sum(src.exposure_to_them) exposure_to_them, sum(src.cva) CVA,sum(src.dva) dVA
	 from dbo.source_deal_cva_simulation src
	 LEFT JOIN source_counterparty sc ON sc.Source_Counterparty_ID = src.Source_Counterparty_ID
	  where '+@st+' group by src.run_date,src.Source_Counterparty_ID,src.source_deal_header_id'+case @tenor_option when 'c'  then ',src.term_start' when 'u' then '' else '' end +') s 
		cross apply
		(
			select src.source_deal_header_id'+case @tenor_option when 'c'  then ',src.term_start' when 'u' then '' else '' end +',sum(src.net_exposure_to_us) exposure_to_us,sum(src.net_exposure_to_them) exposure_to_them
			,sum(src.net_exposure_to_us)/nullif(s.exposure_to_us,0)*s.CVA CVA,sum(src.net_exposure_to_them)/nullif(s.exposure_to_them,0) * s.DVA DVA
			,sum(src.Final_Und_Pnl) Final_Und_Pnl,max(src.currency_name) currency_name
			 from dbo.credit_exposure_detail src inner join source_counterparty sc on src.Source_Counterparty_ID=sc.Source_Counterparty_ID
			 inner join counterparty_credit_info cif on src.Source_Counterparty_ID=cif.Counterparty_id
			left join static_data_value sdv on sdv.code=sc.counterparty_id and sdv.type_id=23000 and cif.cva_data=7
			where '+ replace(replace(@st,'[run_date]','[as_of_date]'),'4505',@curve_source_id)+ ' and src.Source_Counterparty_ID=s.Source_Counterparty_ID and src.as_of_date=s.run_date
				AND src.Source_Deal_Header_ID = s.source_deal_header_id
			group by src.source_deal_header_id'+case @tenor_option when 'c'  then ',src.term_start' when 'u' then '' else '' end+'
		) ce
		'
	set @st_group_by= case when @report_type='s' then ' Group by s.run_date,sc.Counterparty_name' else '' end
	
end

set @st_from =@st_from+'
	inner join dbo.source_counterparty sc on s.Source_Counterparty_ID=sc.Source_Counterparty_ID
	 inner join dbo.source_deal_header sdh on sdh.source_deal_header_id='+case when ISNULL(@use_simulated_exposures,'n')='y' then 'ce' else 's' end+'.source_deal_header_id'
	-- +case when @report_type='s' then '' else ' inner join dbo.source_deal_header sdh on sdh.source_deal_header_id='+case when ISNULL(@use_simulated_exposures,'n')='y' then 'ce' else 's' end+'.source_deal_header_id' end
+case when ISNULL(@use_simulated_exposures,'n')='y' then '' else ' where '+replace(@st,'src.','s.') end

--print @st_coulumns
--print @st_from
--print @st_group_by

exec( @st_coulumns+ @st_from+ @st_group_by)

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_load_forecast_report', 'Load Forecast Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO