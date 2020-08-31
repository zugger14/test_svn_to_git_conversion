IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_source_minor_location_paging]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_source_minor_location_paging]
GO 

CREATE PROC [dbo].[spa_source_minor_location_paging]
    @flag VARCHAR(1),
    @source_minor_location_ID VARCHAR(500) = NULL,
    @source_system_id [int] = NULL,
    @source_major_location_ID VARCHAR(500) = NULL,
    @Location_Name VARCHAR(500) = NULL,
    @Location_Description VARCHAR(25) = NULL,
    @Meter_ID VARCHAR(500) = NULL,
    @Pricing_Index INT = NULL,
    @Commodity_id INT = NULL,
    @location_type INT = NULL,
    @time_zone INT = NULL,
    @owner VARCHAR(500) = NULL,
    @operator VARCHAR(500) = NULL,
    @contract INT = NULL,
    @volume FLOAT = NULL,
    @uom INT = NULL,
    @region INT = NULL,
    @is_pool CHAR(1) = NULL,
    @term_pricing_index INT = NULL,
    @bid_offer_formulator_id INT = NULL,
    @profile INT = NULL,
    @proxy_profile INT = NULL,
    @grid_value_id INT = NULL,
	@process_id_paging VARCHAR(200) = NULL, 
	@page_size INT = NULL,
	@page_no INT = NULL,
	@country INT = NULL,
	@is_active VARCHAR(1) = NULL,
	@location_id VARCHAR(500) = NULL
AS 
SET NOCOUNT ON

DECLARE @user_login_id  VARCHAR(50),
        @tempTable      VARCHAR(MAX)
 
DECLARE @flag_paging    CHAR(1)

SET @user_login_id = dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
    SET @flag_paging = 'i'
    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
END

SET @tempTable = dbo.FNAProcessTableName(
        'paging_source_minor_location',
        @user_login_id,
        @process_id_paging
    )

EXEC spa_print @tempTable

DECLARE @sql VARCHAR(MAX)



IF @flag_paging = 'i'
BEGIN
    IF @flag = 'l'
    BEGIN
        SET @sql = 'CREATE TABLE ' + @tempTable + 
            ' (
			sno INT IDENTITY(1,1), 
			
			ID VARCHAR(50),
			[location_id] varchar(500),
			Name VARCHAR(500),
			Description VARCHAR(500),
			[Spot Index] VARCHAR(500),
			[Term Index] VARCHAR(500),
			[Commodity ID] VARCHAR(50),
			[Location Type] VARCHAR(500),
			[Location Group] VARCHAR(500),
			[Time Zone] VARCHAR(500),
			[Grid] VARCHAR(500),
			[Created User] VARCHAR(50),
			[Created Date] VARCHAR(50),
			[Updated User] VARCHAR(50),
			[Updated Date] VARCHAR(50),
			[is_active] VARCHAR(1)
		)'
        
        EXEC spa_print @sql 
        --print @process_id_paging
        --print @user_login_id
        EXEC (@sql)
        
        
        SET @sql = 'INSERT ' + @tempTable + 
            '(
					ID,
					location_id,
					Name,
					Description,
					[Spot Index],
					[Term Index],
					[Commodity ID],
					[Location Type],
					[Location Group],
					[Time Zone]
					,[Grid]
					,[Created User],
					[Created Date],
					[Updated User],
					[Updated Date],
					is_active
		)' +
            ' EXEC spa_source_minor_location ' +
            dbo.FNASingleQuote(@flag) + ',' +
            dbo.FNASingleQuote(@source_minor_location_ID) + ',' +
            dbo.FNASingleQuote(@source_system_id) + ',' +
            dbo.FNASingleQuote(@source_major_location_ID) + ',' +
            dbo.FNASingleQuote(@Location_Name) + ',' +
            dbo.FNASingleQuote(@Location_Description) + ',' +
            dbo.FNASingleQuote(@Meter_ID) + ',' +
            dbo.FNASingleQuote(@Pricing_Index) + ',' +
            dbo.FNASingleQuote(@Commodity_id) + ',' +
            dbo.FNASingleQuote(@location_type) + ',' +
            dbo.FNASingleQuote(@time_zone) + ',' +
            dbo.FNASingleQuote(@owner) + ',' +
            dbo.FNASingleQuote(@operator) + ',' +
            dbo.FNASingleQuote(@contract) + ',' +
            dbo.FNASingleQuote(@volume) + ',' +
            dbo.FNASingleQuote(@uom) + ',' +
            dbo.FNASingleQuote(@region) + ',' +
            dbo.FNASingleQuote(@is_pool) + ',' +
            dbo.FNASingleQuote(@term_pricing_index) + ',' +
            dbo.FNASingleQuote(@bid_offer_formulator_id) + ',' +
            dbo.FNASingleQuote(@profile) + ',' +
            dbo.FNASingleQuote(@proxy_profile) + ',' +
            dbo.FNASingleQuote(@grid_value_id) + ',' + 
            dbo.FNASingleQuote(@country) + ',' +
            dbo.FNASingleQuote(@is_active) + ',' + 
            dbo.FNASingleQuote(@location_id)
        
        EXEC spa_print @sql 
        EXEC (@sql)
        
        SET @sql = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @tempTable
        
        EXEC spa_print @sql
        EXEC (@sql)
    END
   
END

ELSE
BEGIN
	
	DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size 
	IF @page_no > 1 
	SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
	SET @row_from = @page_no

    IF @flag = 'l'
    BEGIN
        SET @sql = 
            'SELECT 
			ID,
			location_id AS [Location ID],
			Name,
			Description,
			[Spot Index],
			[Term Index],
			[Commodity ID],
			[Location Type],
			[Location Group],
			[Time Zone]
			,[Grid]
			,[Created User],
			[Created Date],
			[Updated User],
			[Updated Date],
			is_active
			
		            FROM ' + @tempTable
            + ' WHERE sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND ' + 
            CAST(@row_to AS VARCHAR) + ' ORDER BY sno ASC'
            
		EXEC spa_print @sql 
		EXEC (@sql)               
    END
END