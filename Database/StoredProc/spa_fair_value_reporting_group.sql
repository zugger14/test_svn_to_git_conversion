IF OBJECT_ID('[spa_fair_value_reporting_group]') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_fair_value_reporting_group]
GO
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/*	
	exec spa_fair_value_reporting_group 's',  NULL, 81, NULL, NULL, NULL, NULL
	exec spa_fair_value_reporting_group 's',  NULL, 89, NULL, '2010-05-27', NULL, NULL
	exec spa_fair_value_reporting_group 'c',  NULL, 89, 5451, '2010-05-27', 2, 14
*/

CREATE PROCEDURE [dbo].[spa_fair_value_reporting_group]
	@flag char(1),
	@spc_fv_id int = NULL,
	@source_curve_def_id int = NULL,
	@fv_reporting_group_id int = NULL,
	@effective_date varchar(10) = NULL,
	@from_no_of_months int = NULL,
	@to_no_of_months int = NULL
	--@map_no_of_months int = NULL
	
AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(5000)
DECLARE @DBUser VARCHAR(50)
DECLARE @date VARCHAR(50)
DECLARE @val INT
SET @DBUser = dbo.FNADBUser()
SET @date = getdate()
SET @val = ''

IF @flag='s' 

	BEGIN
	
--	SET @SQL='	SELECT pcfm.spc_fv_id [Fair Value ID], dbo.FNADateFormat(pcfm.effective_date) [Effective Date], pcfm.from_no_of_months [Months From], pcfm.to_no_of_months [Months To], sdv.code [Fair Value Reporting Group]
--				FROM price_curve_fv_mapping AS pcfm
--				LEFT JOIN static_data_value sdv
--				ON pcfm.fv_reporting_group_id = sdv.value_id
--				WHERE 1=1'
--		
--		IF (@spc_fv_id IS NOT NULL) 
--			BEGIN
--				SET @SQL = @SQL + ' AND pcfm.spc_fv_id='+CAST(@spc_fv_id as VARCHAR)
--			END
--		IF (@effective_date IS NOT NULL) 
--			BEGIN
--			SET @SQL = @SQL + ' AND dbo.FNADateFormat(pcfm.effective_date) >= '''  CAST(dbo.FNADateFormat(@effective_date) as VARCHAR)  + ''''
--			END
----		IF (@source_curve_def_id IS NOT NULL) 
----			BEGIN
----			SET @SQL=@SQL+' AND source_curve_def_id='+CAST(@source_curve_def_id as VARCHAR)
----			END
--		IF (@source_curve_def_id IS NULL) 
--			BEGIN
--			SET @SQL=@SQL+' AND pcfm.source_curve_def_id=0'
--			END
	SET @SQL = 'SELECT 
					pcfm.effective_date [Effective Date], 
					pcfm.from_no_of_months [Months From], 
					pcfm.to_no_of_months [Months To], 
					sdv.code [Fair Value Reporting Group],
					pcfm.spc_fv_id [Fair Value ID]
				FROM price_curve_fv_mapping pcfm '
	IF @effective_date IS NOT NULL
	BEGIN	
		SET @SQL = @SQL + 'INNER JOIN (
						SELECT fv_reporting_group_id, 
							MAX(effective_date) effective_date
						FROM price_curve_fv_mapping
						WHERE effective_date <= ''' +  @effective_date + ''' AND source_curve_def_id = ' + CAST(@source_curve_def_id AS VARCHAR)  						
						+ 'GROUP BY fv_reporting_group_id
					) AS min_eff_date_row 
				ON pcfm.effective_date = min_eff_date_row.effective_date 
				AND pcfm.fv_reporting_group_id = min_eff_date_row.fv_reporting_group_id'
	END
	SET @SQL = @SQL + '	INNER JOIN  static_data_value sdv ON pcfm.fv_reporting_group_id = sdv.value_id  WHERE pcfm.source_curve_def_id = ' + CAST(@source_curve_def_id AS VARCHAR)
	
	exec spa_print @SQL
	EXEC(@SQL)
	
	END

ELSE IF @flag='g' 
BEGIN
	SET @SQL = 'SELECT
					spc_fv_id,
					pcfm.effective_date , 
					pcfm.from_no_of_months, 
					pcfm.to_no_of_months, 
					pcfm.fv_reporting_group_id,
					source_curve_def_id
				FROM price_curve_fv_mapping pcfm '
	IF @effective_date IS NOT NULL
	BEGIN
		SET @SQL = @SQL + 'INNER JOIN (
						SELECT fv_reporting_group_id, 
							MAX(effective_date) effective_date
						FROM price_curve_fv_mapping
						WHERE effective_date <= ''' +  @effective_date + ''' AND source_curve_def_id = ' + CAST(@source_curve_def_id AS VARCHAR)  						
						+ 'GROUP BY fv_reporting_group_id
					) AS min_eff_date_row 
				ON pcfm.effective_date = min_eff_date_row.effective_date 
				AND pcfm.fv_reporting_group_id = min_eff_date_row.fv_reporting_group_id'
	END
	SET @SQL = @SQL + '	INNER JOIN  static_data_value sdv ON pcfm.fv_reporting_group_id = sdv.value_id  WHERE pcfm.source_curve_def_id = ' + CAST(@source_curve_def_id AS VARCHAR)
	
	EXEC(@SQL)	
END

ELSE IF @flag='a' 
	BEGIN
		SET @SQL='SELECT spc_fv_id, source_curve_def_id, dbo.FNADateFormat(effective_date), from_no_of_months, to_no_of_months, fv_reporting_group_id
				FROM price_curve_fv_mapping
				WHERE 1=1'
		
		IF (@spc_fv_id IS NOT NULL) 
			BEGIN
				SET @SQL=@SQL+' AND spc_fv_id='+CAST(@spc_fv_id as VARCHAR)
			END
		IF (@effective_date IS NOT NULL) 
			BEGIN
			SET @SQL=@SQL+' AND effective_date='''+CAST(dbo.FNADateFormat(@effective_date) as VARCHAR)+''''
		END
	exec spa_print @SQL
	EXEC(@SQL)
		
	END

ELSE IF @flag='i' 
	BEGIN
		INSERT INTO price_curve_fv_mapping(source_curve_def_id, effective_date, from_no_of_months, to_no_of_months, fv_reporting_group_id, create_user, create_ts)
		VALUES(@source_curve_def_id, @effective_date, @from_no_of_months, @to_no_of_months, @fv_reporting_group_id, @DBUser, getdate())
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler 1, "Fair Value Reporting Group", 
					"spa_fair_value_reporting_group", "DB Error", 
					"Error in Insert.", ''
		ELSE
			EXEC spa_ErrorHandler 0, "Fair Value Reporting Group", 
					"spa_fair_value_reporting_group", "Success", 
					"Data Successfully saved.","Recommendation" 
	END

ELSE IF @flag='u' 
	BEGIN
		UPDATE price_curve_fv_mapping 
		SET effective_date=@effective_date ,
			from_no_of_months=@from_no_of_months ,
			to_no_of_months=@to_no_of_months,
			fv_reporting_group_id=@fv_reporting_group_id,
			update_user = @DBUser,
			update_ts = getdate()
		WHERE spc_fv_id=@spc_fv_id
		
		IF @@ERROR <> 0
				EXEC spa_ErrorHandler 1, "Fair Value Reporting Group", 
						"spa_fair_value_reporting_group", "DB Error", 
						"Error in Update.", ''
			ELSE
				EXEC spa_ErrorHandler 0, "Fair Value Reporting Group", 
						"spa_fair_value_reporting_group", "Success",
						"Data Successfully Updated.","Recommendation"
	
	END

ELSE IF @flag='d'
	BEGIN
		DELETE FROM price_curve_fv_mapping
		WHERE spc_fv_id=@spc_fv_id

		IF @@ERROR <> 0
				EXEC spa_ErrorHandler 1, "Fair Value Reporting Group", 
						"spa_fair_value_reporting_group", "DB Error", 
						"Error in Delete.", ''
			ELSE
				EXEC spa_ErrorHandler 0, "Fair Value Reporting Group", 
						"spa_fair_value_reporting_group", "Status",
						"Data Successfully Deleted.","Recommendation"

	END

ELSE IF @flag = 'c'
	BEGIN
		IF EXISTS( SELECT spc_fv_id
					FROM price_curve_fv_mapping 
					WHERE dbo.FNADateFormat(effective_date) = dbo.FNADateFormat(@effective_date)
					AND fv_reporting_group_id = @fv_reporting_group_id
					AND source_curve_def_id = @source_curve_def_id
					AND spc_fv_id <> CASE 
										WHEN @spc_fv_id IS NOT NULL
										THEN  @spc_fv_id
										ELSE ''
									END
		)
		
			EXEC spa_ErrorHandler -1, "Fair Value Reporting Group", 
					"spa_fair_value_reporting_group", "Error",
					"The combination of Effective date and Fair value reporting group should be unique.","Recommendation"
		ELSE 
			EXEC spa_ErrorHandler 0, "Fair Value Reporting Group", 
					"spa_fair_value_reporting_group", "Success",
					"Success","Recommendation"
	END


