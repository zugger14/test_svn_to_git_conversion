
/****** Object:  StoredProcedure [dbo].[spa_complete_compliance_activities_job]    Script Date: 06/15/2009 20:54:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_complete_compliance_activities_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_complete_compliance_activities_job]
/****** Object:  StoredProcedure [dbo].[spa_complete_compliance_activities_job]    Script Date: 06/15/2009 20:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*********
Create By : Anal Shrestha
Created On:09/25/2008
Description: This SP completes the activity or updates the other fields of the table depending on the @flag

if @flag='a'
It willfind risk_control_id from the given parameters and complete the activity.There are 10 columns which are
mapped dynamically to find out the risk_control_id from risk_process_function_map table.

if @flag='p'
It will update the particular field in the table when the activity is completed for that task

EXEC spa_complete_compliance_activities 1,'2008-01-01','<135,136,137><54><12><87><767><88><897>'
*/

CREATE PROC [dbo].[spa_complete_compliance_activities_job]
	@flag CHAR(1), -- 'a' complete the compliance activity, 'p' update the actual process
	@function_id INT=NULL,
	@as_of_date datetime=NULL,
	@param_string VARCHAR(500)=NULL,
	@risk_control_id INT=NULL,
	@control_status INT=NULL,
	@requires_approval CHAR(1)='n',
	@comments VARCHAR(1000)=NULL,
	@status CHAR(1)='c',
	@user_login_id VARCHAR(100)=NULL
	

AS
BEGIN



DECLARE @sql_stmt VARCHAR(500)
DECLARE @sql_stmt_main VARCHAR(500)
DECLARE @split_char VARCHAR(1)
DECLARE @listCol VARCHAR(1000),@listCol_value VARCHAR(1000),@sql VARCHAR(5000),@listCol_compare VARCHAR(1000)
DECLARE @source VARCHAR(100)
	--set @as_of_date=dateadd(month,1,dbo.fnagetcontractmonth(@as_of_date))-1


IF @flag='p'
	BEGIN
			--1. Update Contract Status
			UPDATE Contract_group
			SET
				contract_status=1900 -- 'Approve'
			FROM
				process_risk_controls prc
				JOIN risk_process_function_map_detail rpfmd on prc.risk_control_id=rpfmd.risk_control_id
				JOIN contract_group cg on cg.contract_id=rpfmd.column_value
			WHERE
				 rpfmd.publish_table_id=9 -- contract table id
				 and prc.risk_control_id=@risk_control_id
				 AND ((@requires_approval='y' AND @control_status=729)	OR (@requires_approval='n' AND @control_status=729))
	END

ELSE IF @flag='a' AND @function_id IS NOT NULL
	BEGIN
		-- FIRST Insert the parameter string as a row in a tamproray table
		SET @split_char='><'
		CREATE TABLE #temp_param_value (seq_number INT IDENTITY (1,1) NOT NULL , param_value VARCHAR(50) COLLATE DATABASE_DEFAULT)
		CREATE TABLE #temp_final_value (seq_number INT NOT NULL , param_value VARCHAR(50) COLLATE DATABASE_DEFAULT)
		
		SELECT  @sql_stmt = ' INSERT INTO #temp_param_value SELECT STUFF('''+
							  REPLACE(@param_string,@split_char,''',1,1,'''') UNION ALL SELECT STUFF(''')

		
		SET @sql_stmt = @sql_stmt + ''',1,1,'''')'
		
		EXEC ( @sql_stmt )
		DELETE FROM #temp_param_value WHERE param_value IS NULL
		
		
		insert into 
				#temp_final_value 
		select * from #temp_param_value


		DECLARE @seq_number int,@param_value varchar(100)
		SET @split_char=','


		declare cur2 cursor for
			select 	seq_number,param_value from #temp_final_value where charindex(',',param_value)>0
		open cur2
		fetch next from cur2 into @seq_number,@param_value
		while @@FETCH_STATUS=0
			BEGIN
				

			SELECT  @sql_stmt = ' INSERT INTO #temp_final_value(seq_number,param_value) SELECT '+cast(@seq_number as varchar)+','+
							  REPLACE(@param_value,@split_char,' UNION ALL SELECT '+cast(@seq_number as varchar)+',')

		
			SET @sql_stmt = @sql_stmt + ''

				EXEC(@sql_stmt)
				fetch next from cur2 into @seq_number,@param_value
			END
		close cur2	
		deallocate cur2
		
		delete from #temp_final_value where charindex(',',param_value)>0
		




		SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + ltrim(str((sequence_number)))
				 FROM    risk_process_function rpf 
						 JOIN risk_process_function_map rpfm ON rpf.function_id=rpfm.function_id
						 JOIN risk_process_function_map_detail rpfd ON rpfd.function_map_id=rpfm.function_map_id
				WHERE
						rpf.function_id=@function_id	
				ORDER BY '],[' + ltrim(str((sequence_number))) FOR XML PATH('')), 1, 2, '') + ']'
		
		IF @listCol is null
			SET @listCol='[0]'


		SELECT  @listCol_compare = STUFF(( SELECT DISTINCT '] AND a.[COL ' + ltrim(str((sequence_number)))+']=b.[COL ' + ltrim(str((sequence_number)))
				 FROM    risk_process_function rpf 
						 JOIN risk_process_function_map rpfm ON rpf.function_id=rpfm.function_id
						 JOIN risk_process_function_map_detail rpfd ON rpfd.function_map_id=rpfm.function_map_id
				WHERE
						rpf.function_id=@function_id	
				ORDER BY '] AND a.[COL ' + ltrim(str((sequence_number)))+']=b.[COL ' + ltrim(str((sequence_number))) FOR XML PATH('')), 1, 5, '') + ']'


		SELECT  @listCol_value = STUFF(( SELECT DISTINCT ',max(([' + ltrim(str((sequence_number)))+']))[COL '+ltrim(str((sequence_number)))+']' 
				FROM    risk_process_function rpf 
							 JOIN risk_process_function_map rpfm ON rpf.function_id=rpfm.function_id
							 JOIN risk_process_function_map_detail rpfd ON rpfd.function_map_id=rpfm.function_map_id
				WHERE
						rpf.function_id=@function_id	
				ORDER BY ',max(([' + ltrim(str((sequence_number)))+']))[COL '+ltrim(str((sequence_number)))+']' FOR XML PATH('')), 1,1, '')

		IF @listCol_value is null
			SET @listCol_value='max([0])[0]'



		create table #temp_comp
			(function_id INT,risk_control_id INT)


		SET @sql='
			INSERT INTO #temp_comp
			SELECT b.function_id,b.risk_control_id 
			
			FROM
			(SELECT '+@listCol_value+' FROM
				(SELECT 
					param_value,seq_number	
				FROM 
					#temp_final_value)a
				PIVOT
				(max(param_value) for seq_number
				IN('+@listCol+')) AS PVT ) a

			JOIN
				( SELECT 	function_id,risk_control_id,'+@listCol_value+' FROM
				(SELECT 
					rpf.function_id,rpfd.risk_control_id,rpfd.column_value,rpfd.sequence_number	
				FROM 
					risk_process_function rpf 
					JOIN risk_process_function_map rpfm ON rpf.function_id=rpfm.function_id
					JOIN risk_process_function_map_detail rpfd ON rpfd.function_map_id=rpfm.function_map_id
					JOIN publish_activity_table pat ON pat.publish_table_id=rpfd.publish_table_id
				WHERE
					rpf.function_id='+cast(@function_id	as varchar)+') a
				PIVOT
					(max(column_value) for sequence_number
				IN('+@listCol+')) AS PVT group by  function_id,risk_control_id) b
			ON
				'+@listCol_compare
					
		--print @sql
		EXEC(@sql)		



			select @risk_control_id=risk_control_id from #temp_comp

			DELETE FROM process_risk_controls_activities WHERE risk_control_id=@risk_control_id
				  AND dbo.fnadateformat(as_of_date)=dbo.fnadateformat(@as_of_date)

		IF @risk_control_id IS NOT NULL
		BEGIN
			--Now create the activity 
			EXEC spa_Create_Daily_Risk_Control_Activities @as_of_date,@risk_control_id,'y', 'n', 'y','n'
			
			
			--		--Now Update the activity as completed
			select @source=risk_control_description FROM process_risk_controls WHERE risk_control_id=@risk_control_id

			UPDATE 
				process_risk_controls_activities 
			SET 
				control_status=728, -- completed
				comments=@comments,
				[status]=@status,
				[source]=@source
			WHERE risk_control_id=@risk_control_id
				  AND dbo.fnadateformat(as_of_date)=dbo.fnadateformat(@as_of_date)

			
			SET @as_of_date=dbo.fnadateformat(@as_of_date)
			exec spa_get_outstanding_control_activities_job @as_of_date,@risk_control_id
		END

	END								 


ELSE IF @flag='a' AND @function_id IS NULL AND @risk_control_id IS NOT NULL
	BEGIN


			DELETE FROM process_risk_controls_activities WHERE risk_control_id=@risk_control_id
				   AND dbo.fnadateformat(as_of_date)=dbo.fnadateformat(@as_of_date)


			select @source=risk_control_description FROM process_risk_controls WHERE risk_control_id=@risk_control_id
			EXEC spa_Create_Daily_Risk_Control_Activities @as_of_date,@risk_control_id,'y', 'n', 'y', 'n'

			UPDATE 
				process_risk_controls_activities 
			SET 
				control_status=728, -- completed
				comments=@comments,
				[status]=@status,
				[source]=@source
			WHERE risk_control_id=@risk_control_id
				  AND dbo.fnadateformat(as_of_date)=dbo.fnadateformat(@as_of_date)

			SET @as_of_date=dbo.fnadateformat(@as_of_date)
			exec spa_get_outstanding_control_activities_job @as_of_date,@risk_control_id

	END

END






