

/**
flags:
s => select header information of EDI on grid
i => insert EDI creation info on header and detail tables.
x => extract duns number from provided counterpary.
o => store EDI information after file submit.
d => delete particular EDI file information on table.

**/

/*
select a.create_ts,* from source_system_data_import_status a where a.source = 'EDI File'
select a.create_ts,* from source_system_data_import_status_detail a where a.source = 'EDI File'
/*
delete from source_system_data_import_status where source = 'EDI File'
delete from source_system_data_import_status_detail where source = 'EDI File'
*/


exec spa_get_import_process_status '6C455152_0623_4776_9A7B_74ABC9FB07C3','farrms_admin'
*/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_edi_file_info]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_edi_file_info]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- spa_edi_file_info @flag ='i',@call_from = 'ssis',@error_msg = 'this', @acknowledge = 'A',@process_id = '123123'

CREATE PROCEDURE [dbo].[spa_edi_file_info]
	@flag CHAR(1)
	, @file_name varchar(1000) = null
	, @file_path varchar(1000) = null
	, @create_mode char(1) = null
	, @file_status varchar(50) = null
	, @counterparty_id int = null
	, @call_from varchar(20) = 'edi'
	, @process_id varchar(5000) = null
	, @error_msg VARCHAR(500) = NULL
	, @acknowledge VARCHAR(500) = NULL
	, @create_date_from datetime = null
	, @create_date_to datetime = null
	, @status varchar(50) = 'Not Submitted' --s=> submitted,u=>Not submitted
	,@deal_error_list varchar(2000) = null
	
	
	

AS 
set nocount on

--set form path and script path
declare @adiha_form_path varchar(5000) = '../../../adiha.html.forms/'
	, @adiha_script_path varchar(5000) = '../../../adiha.php.scripts/'
DECLARE @deal_id VARCHAR(500),@deal_error VARCHAR(1000)
DECLARE @individual varchar(500) = null

IF OBJECT_ID ('tempdb..#errorDetails') IS NOT NULL
    DROP TABLE #errorDetails


if @process_id is null
	set @process_id = replace(cast(newid() as varchar(100)), '-', '_')
declare @current_date datetime = getdate(), @user_name varchar(20) = dbo.fnadbuser()

begin
	if @flag = 's'
	begin
		--print 's'
		select 
			dbo.FNADateTimeFormat(d.create_ts, 0) [datetime]
			--d.create_ts [datetime]
			, d.create_user [user]
			, d.type [status]		
			, d.process_id	
			, d.process_id + '^javascript:edi.grid_link_click(' + cast(ROW_NUMBER() over(order by d.create_ts desc) as varchar(500))+ ')^' [process_id_link]
			, dbo.FNAURLDecode(d.recommendation) [file_name]
		from source_system_data_import_status d
		where d.source = 'EDI File' 
			and ((d.type = @status AND @status ='Submitted') OR (d.type <> 'Submitted'))  
			and cast(d.create_ts as date) between cast(isnull(@create_date_from, d.create_ts) as date) and cast(isnull(@create_date_to, d.create_ts) as date)
		--where d.source = 'EDI File' and d.type = 'not_submitted' and d.create_ts between isnull('2015-09-01', d.create_ts) and isnull('2015-09-01', d.create_ts)
		order by d.create_ts desc
			
	end
	if @flag = 'i'
	begin try
		begin tran
		if @call_from = 'edi'
		begin
			insert into source_system_data_import_status(Process_id, code, module, source, type, description, recommendation, create_ts, create_user, rules_name) 
			select @process_id
				, 'Success'
				, 'EDI'
				, 'EDI File'
				, @file_status
				, '<a href="javascript: second_level_drill(''EXEC spa_get_import_process_status_detail^' + @process_id + '^,^EDI File^'')">EDI File Generated.</a>'
				, replace(@file_name, ' ', '_')
				, @current_date
				, @user_name
				, 'EDI File Generation (' + case @create_mode when 'u' then 'File Upload' else 'File Creation' end + ')'
		end
		CREATE TABLE #error_code (deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT ,deal_detail_id VARCHAR(50) COLLATE DATABASE_DEFAULT ,err_code VARCHAR(20) COLLATE DATABASE_DEFAULT ,err_description VARCHAR(400) COLLATE DATABASE_DEFAULT )
		IF @call_from = 'ssis'
		BEGIN
			CREATE TABLE #errorDetails(deal_id VARCHAR(50) COLLATE DATABASE_DEFAULT ,individual_error VARCHAR(1000) COLLATE DATABASE_DEFAULT )
			IF @file_name IS NOT NULL
			BEGIN 
				SET @file_name = RIGHT(@file_name,CHARINDEX('\',REVERSE(@file_name))-1)
				--SET @file_name = LEFT(@file_name,CHARINDEX('.',@file_name)) + 'txt'
			END
			IF NULLIF(@deal_error_list,'') IS NOT NULL
			BEGIN 
				WHILE LEN(@deal_error_list) > 0
						BEGIN
							IF PATINDEX('%|%',@deal_error_list) > 0
							BEGIN
								SET @individual = SUBSTRING(@deal_error_list, 0, PATINDEX('%|%',@deal_error_list))
							--  
								--SELECT @individual
								SET @deal_id= SUBSTRING(@individual, 0, PATINDEX('%,%',@individual))
		
								SELECT @deal_error= SUBSTRING(@individual, LEN(@deal_id + ',') + 1,LEN(@individual))

								SET @deal_error_list = SUBSTRING(@deal_error_list, LEN(@individual + '|') + 1,
																			 LEN(@deal_error_list))

								 INSERT INTO #errorDetails(deal_id,individual_error)
								 SELECT ABS(CAST(@deal_id as INT)),LTRIM(RTRIM(REPLACE(REPLACE(item,'[',''),']',''))) FRom dbo.SplitCommaSeperatedValues(@deal_error)
							END
							ELSE
							BEGIN
								SET @individual = @deal_error_list
								SET @deal_error_list = NULL
								--INSERT INTO #errorDetails(individual_error)
								SET @deal_id= SUBSTRING(@individual, 0, PATINDEX('%,%',@individual))
		
								SELECT @deal_error= SUBSTRING(@individual, LEN(@deal_id + ',') + 1,LEN(@individual))

								SET @deal_error_list = SUBSTRING(@deal_error_list, LEN(@individual + '|') + 1,
																			 LEN(@deal_error_list))

								 INSERT INTO #errorDetails(deal_id,individual_error)
								 SELECT ABS(CAST(@deal_id as INT)),LTRIM(RTRIM(REPLACE(REPLACE(item,'[',''),']',''))) FRom dbo.SplitCommaSeperatedValues(@deal_error)
							END
						END
					INSERT INTO #error_code(deal_id,deal_detail_id,err_code,err_description)
					SELECT DISTINCT sdd.source_deal_header_id,ed.deal_id,individual_error,err_description FROM #errorDetails ed INNER JOIN EDI_Error_definition eed ON eed.err_code = ed.individual_error 
					LEFT JOIN source_deal_detail sdd on sdd.source_deal_detail_id = ed.deal_id
			END
			 IF( NULLIF(@error_msg,'') IS NOT NULL) 
			 BEGIN
				INSERT INTO #error_code(err_code,err_description)
				select err_code,err_Description FRom dbo.SplitCommaSeperatedValues(@error_msg) a INNER JOIN 
				EDI_Error_definition eed On eed.err_code = a.item
				 Where item <> '#'
			 END
			IF( NULLIF(@acknowledge,'') IS NOT NULL) 
			 BEGIN
				INSERT INTO #error_code(err_code,err_description)
				SELECT TOP 1  CASE WHEN @acknowledge = 'R' THEN 
						'Rejected'
						 WHEN @acknowledge = 'A' THEN  
						'Accepted'
						ELSE 
						edd.err_code
					END,
					CASE WHEN @acknowledge = 'R' THEN 
						'-EDI file was rejected'
						 WHEN @acknowledge = 'A' THEN  
						'-EDI file was accepted'
					ELSE 
						'EDI File '+ CASE WHEN CHARINDEX('-',edd.err_Description) >0  THEN LEFT(edd.err_Description,CHARINDEX('-',edd.err_Description)-2) ELSE edd.err_Description END +'ed'
						 +CASE WHEN CHARINDEX('-',edd.err_Description) >0  THEN +', '+ RIGHT(edd.err_Description,CHARINDEX('-',REVERSE(edd.err_Description))-1) ELSE '' END
					END
				FROM EDI_Error_definition edd WHERE err_code = @acknowledge OR @acknowledge = 'A' OR @acknowledge ='R'


			 END
		END 
		ELSE 
		BEGIN
			INSERT INTO #error_code(err_code,err_description)
			select 'edi_file_create', 'EDI file created'
		END 
					
		insert into source_system_data_import_status_detail(process_id,source,type,description,import_file_name,create_ts,create_user,type_error)
		select @process_id
			, 'EDI File'
			, CASE WHEN NULLIF(@acknowledge,'') IS NOT NULL THEN 
					CASE WHEN  @acknowledge IN ('A','R') 
						THEN 'Acknowledgement'  ELSE 'Quick Response ' +
							CASE WHEN NULLIF(@acknowledge,'') = 'WQ' 
								THEN '-Success' 
								ELSE '-Error' 
							END
					END 
			  ELSE 
			      ISNULL(@file_status,'Error') 
			  END
			, CASE WHEN NULLIF(@acknowledge,'') IS NOT NULL THEN 
						CASE WHEN NULLIF(a.deal_detail_id,'') IS NOT NULL THEN 'SLN-' 
						ELSE '' 
						END +
							ISNULL(a.deal_detail_id,'')+CASE WHEN NULLIF(a.deal_detail_id,'') IS NOT NULL THEN '-' ELSE '' END
							 +
							CASE WHEN NULLIF(a.deal_id,'') IS NOT NULL THEN 
								'('+'<span style="cursor: pointer;" onclick="parent.parent.TRMHyperlink(10131010,'+a.deal_id+',''n'',''NULL'')"><font color="#0000ff"><u>'+a.deal_id+'</u></font></span>'+')' 
								ELSE '' 
								END 
			+a.err_code+' '+ a.err_Description   
				 WHEN NULLIF(@error_msg,'') is NOT NULL OR NULLIF(@deal_error_list,'') is NOT NULL THEN 
					 CASE WHEN NULLIF(a.deal_detail_id,'') IS NOT NULL THEN 'SLN-' ELSE '' END +
					ISNULL(a.deal_detail_id,'')+
						a.err_code+' '+ a.err_Description  
				 ELSE 'EDI File generated successfully ' + case when @create_mode = 'c' then '(File created). <span style="cursor: pointer;" onclick="parent.parent.edi_summary_detail_report(''s'',''' + @process_id + ''')"><font color="#0000ff"><u>Summary</u></font></span> <span style="cursor: pointer;" onclick="parent.parent.edi_summary_detail_report(''d'',''' + @process_id + ''')"><font color="#0000ff"><u>Detail</u></font></span>' else '(File uploaded).' end END  
				 
				 + ' <a href="' 
                        + dbo.FNAURLEncode(@adiha_script_path) + 'force_download.php?path=' 
                        + dbo.FNAURLEncode(@adiha_script_path) + 'dev/shared_docs/temp_Note/EDI/Processed/' + dbo.FNAURLEncode(@file_name) + '" download>' + @file_name + '</a>'
				 

			, replace(@file_name, ' ', '_')
			, @current_date
			, @user_name
			, @file_status
			FROM #error_code  a 
		
		commit
		exec spa_ErrorHandler 0
			, 'EDI'
			, 'spa_edi_file_info'
			, 'Success'
			, 'file create success'
			, @create_mode
	end try
	begin catch
		rollback
		declare @err_msg_i varchar(2000) = 'Catch Error(flag i): ' + error_message()
		exec spa_ErrorHandler -1
			, 'EDI'
			, 'spa_edi_file_info'
			, 'Error'
			, 'file create failed'
			, @err_msg_i
		EXEC spa_print 'Catch Error:', @err_msg_i
	end catch
	else if @flag = 'x' --extract duns from counterparty
	begin
		select isnull(sc.customer_duns_number, '') [duns_no] 
		from source_counterparty sc 
		where sc.source_counterparty_id = isnull(@counterparty_id, -1)
	end
	else if @flag = 'y' --extract contract from counterparty
	begin
		select cg.contract_id, cg.contract_name
		from contract_group cg 
		left join counterparty_contract_address cca on cca.contract_id = cg.contract_id
		where cca.counterparty_id = isnull(@counterparty_id, cca.counterparty_id)
	end
	else if @flag = 'o' --after file submit
	begin try
		update d 
		set d.type = @error_msg
		from source_system_data_import_status d
		where d.process_id = @process_id and d.source = 'EDI File'

		update d 
		set d.type = @error_msg, d.description = REPLACE(d.description, 'generated successfully', case @error_msg when 'Submitted' then 'submitted successfully' else 'Transmission Failure' end )
			, d.type_error = @error_msg, d.create_ts = @current_date, d.create_user = @user_name
		from source_system_data_import_status_detail d
		where d.process_id = @process_id and d.type = 'Not Submitted'

		insert into source_system_data_import_status_detail(process_id,source,type,description,import_file_name,create_ts,create_user,type_error)
		select @process_id
			, 'EDI File'
			, @file_status
			, 'EDI File transmitted ' + case @file_status when 'Transmission Success' then 'successfully.' else 'with errors.' end
				+ ' <a href="' 
                        + dbo.FNAURLEncode(@adiha_script_path) + 'force_download.php?path=' 
                        + dbo.FNAURLEncode(@adiha_script_path) + 'dev/shared_docs/temp_Note/EDI/Processed/' + dbo.FNAURLEncode(@file_name) + '" download>' + @file_name + '</a>'
			, replace(@file_name, ' ', '_')
			, @current_date
			, @user_name
			, @file_status
		if @file_status = 'Transmission Success'
			exec spa_ErrorHandler 0
				, 'EDI'
				, 'spa_edi_file_info'
				, 'Success'
				, 'file request status ok save success.'
				, @file_status 
		else exec spa_ErrorHandler 0
				, 'EDI'
				, 'spa_edi_file_info'
				, 'Success'
				, 'file request status failed save success.'
				, @file_status
	end try
	begin catch
	declare @err_msg_o varchar(2000) = 'Catch Error(flag o): ' + error_message()
		exec spa_ErrorHandler -1
			, 'EDI'
			, 'spa_edi_file_info'
			, 'Error'
			, 'file Transmission Status save failed.'
			, @err_msg_o 
	end catch
	else if @flag = 'd' --file delete from edi grid
	begin try
		begin tran
			declare @related_files varchar(5000)
			
			SELECT @related_files = STUFF(
				(SELECT distinct ','  + cast(m.import_file_name AS varchar(500))
				from source_system_data_import_status_detail m
				inner join dbo.SplitCommaSeperatedValues(@process_id) scsv on scsv.item = m.process_id
				where m.source = 'EDI File' AND m.type_error <> 'Data Error'
				FOR XML PATH(''))
			, 1, 1, '')

			delete d
			from source_system_data_import_status_detail d
			inner join dbo.SplitCommaSeperatedValues(@process_id) scsv on scsv.item = d.process_id
			where 1=1

			delete h
			from source_system_data_import_status h
			inner join dbo.SplitCommaSeperatedValues(@process_id) scsv on scsv.item = h.process_id
			where 1=1
		commit
		exec spa_ErrorHandler 0
			, 'EDI'
			, 'spa_edi_file_info'
			, 'Success'
			, 'File delete success.'
			, @related_files
	end try
	begin catch
	declare @err_msg_d varchar(2000) = 'Catch Error(flag d): ' + error_message()
		exec spa_ErrorHandler -1
			, 'EDI'
			, 'spa_edi_file_info'
			, 'Error'
			, 'File delete failed.'
			, @err_msg_d
	end catch
	
end
