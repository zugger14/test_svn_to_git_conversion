IF OBJECT_ID(N'spa_cum_pnl_series', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_cum_pnl_series]
GO
/*

select * from cum_pnl_series where as_of_date = '2009-07-31'
spa_cum_pnl_series 'b' , 285
exec spa_cum_pnl_series 'a', -19, NULL,'2009-07-31'
exec spa_cum_pnl_series 'e',NULL,-1, '2009-06-14', '2010-07-14'

*/
CREATE PROC [dbo].[spa_cum_pnl_series]
	@flag CHAR(1)
	,@cum_pnl_series_id VARCHAR(2000) = NULL
	,@link_id INT = NULL
	,@book_id INT = NULL
	,@date_from VARCHAR(100) = NULL
	,@date_to VARCHAR(100) = NULL
	,@u_h_mtm DECIMAL(38,10) = NULL
	,@u_i_mtm DECIMAL(38,10) = NULL
	,@d_h_mtm DECIMAL(38,10) = NULL
	,@d_i_mtm DECIMAL(38,10) = NULL
	,@comments VARCHAR(1000) = NULL
	, @xml_value VARCHAR(MAX) = NULL

AS

SET NOCOUNT ON

DECLARE 
	@errorCode INT
	,@Sql_Select VARCHAR(8000)
	

IF @link_id  < 0 
	SET @link_id  = (-1) * @book_id 

IF @flag = 'm'
BEGIN
	DECLARE @doc INT
	IF OBJECT_ID(N'tempdb..#grid_xml') IS NOT NULL DROP TABLE #grid_xml
		
	EXEC sp_xml_preparedocument @doc OUTPUT, @xml_value		

	SELECT NULLIF(cum_pnl_series_id, '') cum_pnl_series_id,
	 dbo.FNAClientToSqlDate(as_of_date) as_of_date,
		link_id,
		u_h_mtm,
		u_i_mtm,
		d_h_mtm,
		d_i_mtm,
		create_user,
		comments
	INTO #grid_xml
	FROM   OPENXML(@doc, '/Grid/GridRow', 1)
	WITH (
		cum_pnl_series_id INT '@cum_pnl_series_id',
		as_of_date VARCHAR(10) '@as_of_date',
		link_id INT '@link_id',
		u_h_mtm FLOAT '@u_h_mtm',
		u_i_mtm FLOAT '@u_i_mtm',
		d_h_mtm FLOAT '@d_h_mtm',
		d_i_mtm FLOAT '@d_i_mtm',
		create_user VARCHAR(50) '@create_user',
		comments VARCHAR(1000) '@comments'
	)
	EXEC sp_xml_removedocument @doc


	--select * from #grid_xml
	--return
	-- Validation starts

	DECLARE @error_message VARCHAR(200)
	IF EXISTS(SELECT link_id FROM #grid_xml
				GROUP BY link_id, as_of_date
				HAVING count(link_id) > 1			
			)
	BEGIN
		SET @error_message = 'Combination of As Of Date and Link must be unique.'
	        
			EXEC spa_ErrorHandler 1, 'PNL Series',   
					'spa_cum_pnl_series','DB Error', 
					@error_message, '',  ''
			RETURN
	END
	
	IF EXISTS(SELECT 1 FROM cum_pnl_series pnl
				INNER JOIN #grid_xml gx ON pnl.as_of_date = gx.as_of_date
					AND pnl.link_id = gx.link_id AND ISNULL(gx.cum_pnl_series_id, -1) <> pnl.cum_pnl_series_id			
			)
	BEGIN
		SET @error_message = 'Combination of As Of Date and Link must be unique.'
	        
			EXEC spa_ErrorHandler 1, 'PNL Series',   
					'spa_cum_pnl_series','DB Error', 
					@error_message, '',  ''
			RETURN
	END
	--Validation Ends
	BEGIN TRANSACTION	
	IF EXISTS(SELECT 1 from #grid_xml where cum_pnl_series_id IS NULL)
	BEGIN
		CREATE TABLE #inserted_pnl_series(cum_pnl_series_id INT)
		INSERT cum_pnl_series (
				as_of_date
				,link_id
				,u_h_mtm
				,u_i_mtm
				,d_h_mtm
				,d_i_mtm
				,create_user
				,create_ts
				,comments
			)
		OUTPUT INSERTED.cum_pnl_series_id
		INTO #inserted_pnl_series
		SELECT as_of_date
				,link_id
				,u_h_mtm
				,u_i_mtm
				,d_h_mtm
				,d_i_mtm
				,create_user
				,GETDATE() 
				,comments
		FROM #grid_xml WHERE cum_pnl_series_id IS NULL
		
		INSERT INTO cum_pnl_series_audit(
				cum_pnl_series_id, as_of_date
				,link_id, u_h_mtm, u_i_mtm
				,d_h_mtm, d_i_mtm, comments
				,create_user, create_ts
			)		
			SELECT 
				rs.cum_pnl_series_id, rs.as_of_date
				,rs.link_id, rs.u_h_mtm, rs.u_i_mtm
				,rs.d_h_mtm, rs.d_i_mtm		
				,rs.comments, rs.create_user, GETDATE()
			FROM cum_pnl_series rs
			INNER JOIN #inserted_pnl_series irs ON irs.cum_pnl_series_id = rs.cum_pnl_series_id
	END
	
	IF EXISTS(SELECT 1 from #grid_xml where cum_pnl_series_id IS NOT NULL)
	BEGIN
		CREATE TABLE #updated_pnl_series(cum_pnl_series_id INT)
		
		UPDATE pnl 
		SET  as_of_date = rs.as_of_date
			, link_id = rs.link_id
			, u_h_mtm = rs.u_h_mtm
			, u_i_mtm = rs.u_i_mtm
			, d_h_mtm = rs.d_h_mtm
			, d_i_mtm = rs.d_i_mtm
			, comments = rs.comments
		OUTPUT INSERTED.cum_pnl_series_id
		INTO #updated_pnl_series
		FROM cum_pnl_series pnl 
		INNER JOIN #grid_xml rs ON rs.cum_pnl_series_id = pnl.cum_pnl_series_id
		
		INSERT INTO cum_pnl_series_audit(
				cum_pnl_series_id, as_of_date
				,link_id, u_h_mtm, u_i_mtm
				,d_h_mtm, d_i_mtm, comments
				,create_user, create_ts
			)		
			SELECT 
				rs.cum_pnl_series_id
				, rs.as_of_date
				, rs.link_id, rs.u_h_mtm, rs.u_i_mtm
				, rs.d_h_mtm
				, rs.d_i_mtm		
				, rs.comments, rs.create_user, GETDATE()
			FROM cum_pnl_series rs
			INNER JOIN #updated_pnl_series irs ON irs.cum_pnl_series_id = rs.cum_pnl_series_id
	END	

	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	BEGIN
		ROLLBACK TRANSACTION --1
		Exec spa_ErrorHandler @errorCode, 'PNLSeries','spa_cum_pnl_series', 'DB Error', 'Failed to save data.', ''
	END
	
	ELSE
	BEGIN
		COMMIT TRANSACTION --1
		Exec spa_ErrorHandler 0, 'PNLSeries', 'spa_cum_pnl_series', 'Success', 'Data saved successfully.', ''
	END
END
ELSE IF @flag IN ('b', 's','e')
BEGIN	
	SET @Sql_Select = 'SELECT ' +
			CASE WHEN @flag = 'e' THEN '' ELSE 'cum_pnl_series_id,' END +	-- Exclude 	the field 'cum_pnl_series_id' for export	
			'as_of_date [As of Date]
			,link_id [Rel ID]
			,u_h_mtm [Hedge MTM]
			,u_i_mtm [Item MTM]
			,d_h_mtm [Dis Hedge MTM]
			,d_i_mtm [Dis Item MTM]
			,comments
			,create_user [Create User]
			,dbo.FNADateTimeFormat(create_ts,2) [Created Date] 
			
		FROM cum_pnl_series WHERE 1 = ' + CASE WHEN @flag = 'b' THEN '2' ELSE '1' END

		IF @date_from IS NOT NULL 
			SET  @Sql_Select =  @Sql_Select + ' AND as_of_date >= ''' + @date_from + ''''
		IF @date_to IS NOT NULL
			SET  @Sql_Select =  @Sql_Select + ' AND as_of_date <= ''' + @date_to + ''''
		IF @link_id IS NOT NULL
			SET  @Sql_Select =  @Sql_Select + ' AND link_id = ' + CAST(@link_id AS VARCHAR)

	SET @Sql_Select =  @Sql_Select + ' ORDER BY as_of_date DESC'
EXEC spa_print @Sql_Select
	EXEC (@Sql_Select )
	RETURN
END
ELSE IF @flag = 'a'
BEGIN
	SELECT 
		dbo.FNACovertToSTDDate(as_of_date) as_of_date, link_id
		,u_h_mtm, u_i_mtm
		,d_h_mtm,d_i_mtm
		,ISNULL((SELECT TOP 1 comments FROM cum_pnl_series_audit WHERE cum_pnl_series_id = @cum_pnl_series_id ORDER BY audit_id DESC),'') AS comments
	FROM cum_pnl_series 
	WHERE cum_pnl_series_id = @cum_pnl_series_id
END

ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT  TOP 1 1 FROM cum_pnl_series WHERE as_of_date = @date_to AND link_id = @link_id)
	BEGIN
		SELECT 'Error'
		,'Combination of As Of Date: ''' + @date_to + ''' and Link: ''' + CAST(@link_id AS VARCHAR) + ''' must be unique.'
		,'spa_cum_pnl_series'
		,'DB Error'
		,'Combination of As Of Date: ''' + @date_to + ''' and Link: ''' + CAST(@link_id AS VARCHAR) + ''' must be unique.'
		, ''	
	END
	ELSE
	BEGIN
		BEGIN TRANSACTION --1	
			INSERT cum_pnl_series (
				as_of_date
				,link_id
				,u_h_mtm
				,u_i_mtm
				,d_h_mtm
				,d_i_mtm
				,create_user
				,create_ts
			)
			VALUES(
				@date_to
				,@link_id
				,@u_h_mtm
				,@u_i_mtm
				,@d_h_mtm
				,@d_i_mtm
				,dbo.FNADBUser()
				,GETDATE()		
			)
			
			SET @cum_pnl_series_id = SCOPE_IDENTITY()
			INSERT INTO cum_pnl_series_audit(
				cum_pnl_series_id, as_of_date
				,link_id, u_h_mtm, u_i_mtm
				,d_h_mtm, d_i_mtm, comments
				,create_user, create_ts
			)		
			SELECT 
				cum_pnl_series_id, as_of_date
				,link_id, u_h_mtm, u_i_mtm
				,d_h_mtm, d_i_mtm		
				,@comments, create_user, create_ts
			FROM cum_pnl_series WHERE cum_pnl_series_id = @cum_pnl_series_id
		
			Set @errorCode = @@ERROR
			If @errorCode <> 0
			BEGIN
				ROLLBACK TRANSACTION --1
				Exec spa_ErrorHandler @errorCode, 'PNLSeries','spa_cum_pnl_series', 'DB Error', 'Fail to insert PNL data.', ''
			END
			
			ELSE
			BEGIN
				COMMIT TRANSACTION --1
				Exec spa_ErrorHandler 0, 'PNLSeries', 'spa_cum_pnl_series', 'Success', 'Cumulative PNL series value Inserted.', ''
			END
	END
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT  TOP 1 1 FROM cum_pnl_series WHERE as_of_date = @date_to AND link_id = @link_id AND cum_pnl_series_id <> @cum_pnl_series_id)
	BEGIN
		SELECT 'Error'
		,'Combination of As Of Date: ''' + @date_to + ''' and Link: ''' + CAST(@link_id AS VARCHAR) + ''' must be unique.'
		,'spa_cum_pnl_series'
		,'DB Error'
		,'Combination of As Of Date: ''' + @date_to + ''' and Link: ''' + CAST(@link_id AS VARCHAR) + ''' must be unique.'
		, ''	
	END
	
	ELSE	
	BEGIN
		BEGIN TRANSACTION --1
		UPDATE cum_pnl_series SET
			as_of_date = @date_to	
			,u_h_mtm = @u_h_mtm
			,u_i_mtm = @u_i_mtm
			,d_h_mtm = @d_h_mtm
			,d_i_mtm = @d_i_mtm
		WHERE cum_pnl_series_id = @cum_pnl_series_id
		
		INSERT INTO cum_pnl_series_audit(
				cum_pnl_series_id, as_of_date
				,link_id, u_h_mtm, u_i_mtm
				,d_h_mtm, d_i_mtm, comments
				,create_user, create_ts
			)		
			SELECT 
				cum_pnl_series_id, as_of_date
				,link_id, u_h_mtm, u_i_mtm
				,d_h_mtm, d_i_mtm		
				,@comments, create_user, create_ts
			FROM cum_pnl_series WHERE cum_pnl_series_id = @cum_pnl_series_id
		
		
		SET @errorCode = @@ERROR
		IF @errorCode <> 0
		BEGIN
			ROLLBACK TRANSACTION --1
			EXEC spa_ErrorHandler @errorCode, 'PNLSeries','spa_cum_pnl_series', 'DB Error', 'Fail to Cumulative PNL series value.', ''
		END
		
		ELSE
		BEGIN
			COMMIT TRANSACTION --1
			EXEC spa_ErrorHandler 0, 'PNLSeries', 'spa_cum_pnl_series', 'Success', 'Cumulative PNL series value updated.', ''		
		END
	END
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRANSACTION --1	
		INSERT INTO cum_pnl_series_audit(
			cum_pnl_series_id, as_of_date
			,link_id, u_h_mtm, u_i_mtm
			,d_h_mtm, d_i_mtm, comments
			,create_user, create_ts
		)		
		SELECT 
			cum_pnl_series_id, as_of_date
			,link_id, u_h_mtm, u_i_mtm
			,d_h_mtm, d_i_mtm		
			,'Deleted', create_user, create_ts
		FROM cum_pnl_series cps
		INNER JOIN dbo.SplitCommaSeperatedValues(@cum_pnl_series_id) i ON i.item = cps.cum_pnl_series_id
	
		DELETE cps 
		FROM cum_pnl_series cps
		INNER JOIN dbo.SplitCommaSeperatedValues(@cum_pnl_series_id) i ON i.item = cps.cum_pnl_series_id
		
			
	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	BEGIN
		ROLLBACK TRANSACTION --1
		EXEC spa_ErrorHandler @errorCode, 'PNLSeries', 'spa_cum_pnl_series', 'DB Error', 'Failed to delete Cumulative PNL series value', ''
		RETURN
	END
	
	ELSE
	BEGIN
		COMMIT TRANSACTION --1
		EXEC spa_ErrorHandler 0, 'PNLSeries', 'spa_cum_pnl_series', 'Success', 'Cumulative PNL series value deleted.', ''
		RETURN
	END
END	
	
	





