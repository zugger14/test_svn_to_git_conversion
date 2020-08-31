/****** Object:  StoredProcedure [dbo].[spa_setup_logical_trade_lock]    Script Date: 3/12/2015 ******/
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_setup_logical_trade_lock]') AND TYPE IN (N'P' ,N'PC'))
    DROP PROCEDURE [dbo].[spa_setup_logical_trade_lock]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_setup_logical_trade_lock] 
	@flag CHAR(1),
	@sub_type CHAR(1)='n',
	@fas_book_id INT=NULL,
	@source_deal_type_id INT=NULL,
	@source_system_id INT=NULL,
	@id INT=NULL,
	@del_ids VARCHAR(MAX)= NULL,
	@xml VARCHAR(MAX)=NULL
AS 
SET NOCOUNT ON

DECLARE @stmt             VARCHAR(MAX)
       ,@role_id          INT
       ,@deal_type_id     INT
       ,@sql              VARCHAR(MAX)


IF @flag='s'
BEGIN
    SELECT DISTINCT d.source_deal_type_id AS deal_type_id
          ,d.source_deal_type_name+CASE 
                                        WHEN ssd.source_system_id=2 THEN ''
                                        ELSE ''+''+ssd.source_system_name
                                   END [text]
    FROM   source_deal_type d
           INNER JOIN source_system_description ssd
                ON  d.source_system_id = ssd.source_system_id
    WHERE  1 = 1
END

ELSE  IF @flag='g'
BEGIN
    SELECT dls.id
          ,asr.role_id
          ,sdt.source_deal_type_id
          ,dls.hour
          ,dls.minute
    FROM   deal_lock_setup dls
           LEFT JOIN application_security_role asr
                ON  asr.role_id = dls.role_id
           LEFT JOIN source_deal_type sdt
                ON  sdt.source_deal_type_id = dls.deal_type_id
    WHERE  1 = 1
END

ELSE IF @flag='i'
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT,
		     @xml
		
		SELECT * INTO #temp_trade_lock_grid1
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
		       WITH (
		                id INT '@id',
		                role_id INT '@role_id',
		                deal_type_id VARCHAR(10) '@deal_type_id',
		                [hour] INT '@hour',
		                [minute] INT '@minute'
		            )
		
		SELECT @id = a1.id
		FROM   #temp_trade_lock_grid1 AS a1
		
		UPDATE #temp_trade_lock_grid1
		SET    deal_type_id = NULL
		WHERE  deal_type_id = ''
		
		IF NOT EXISTS(
		       SELECT role_id,
		              deal_type_id,
		              COUNT(*)
		       FROM   #temp_trade_lock_grid1 tla
		       GROUP BY
		              role_id,
		              deal_type_id
		       HAVING COUNT(*) > 1
		   )
		BEGIN
		    IF (@id IS NULL OR @id = '')
		    BEGIN
		        SELECT @role_id = a1.role_id
		        FROM   #temp_trade_lock_grid1 AS a1
		        
		        SELECT @deal_type_id = a1.deal_type_id
		        FROM   #temp_trade_lock_grid1 AS a1
		        
		        SET @deal_type_id = CASE 
		                                 WHEN @deal_type_id = '' THEN NULL
		                                 ELSE @deal_type_id
		                            END 	
		        
		        IF NOT EXISTS(
		               SELECT 1
		               FROM   deal_lock_setup
		               WHERE  role_id = @role_id
		                      AND ISNULL(deal_type_id, '0') = ISNULL(@deal_type_id, '0')
		           )
		        BEGIN
		            INSERT INTO deal_lock_setup
		              (
		                role_id,
		                deal_type_id,
		                [hour],
		                [minute]
		              )
		            SELECT tcg.role_id,
		                   CASE 
		                        WHEN tcg.deal_type_id = '' THEN NULL
		                        ELSE CAST(tcg.deal_type_id AS INT)
		                   END,
		                   tcg.[hour],
		                   tcg.[minute]
		            FROM   #temp_trade_lock_grid1 tcg
		                   LEFT JOIN deal_lock_setup mlr
		                        ON  tcg.id = mlr.id
		            WHERE  mlr.id IS NULL
		        END
		        ELSE
		        BEGIN
		            EXEC spa_ErrorHandler -1,
		                 'Logical Trade Lock.',
		                 'spa_setup_logical_trade_lock',
		                 'Success',
		                 'Duplicate data in (Role Name and Deal Type).',
		                 @id
		        END
		    END
		    ELSE
		    BEGIN
		        UPDATE deal_lock_setup
		        SET    role_id          = a1.role_id,
		               deal_type_id     = a1.deal_type_id,
		               [hour]           = a1.[hour],
		               [minute]         = a1.[minute]
		        FROM   #temp_trade_lock_grid1 AS a1
		               INNER JOIN deal_lock_setup AS a2
		                    ON  a1.id = a2.id
		    END	
		    EXEC spa_ErrorHandler 0,
		         'Logical Trade Lock.',
		         'spa_setup_logical_trade_lock',
		         'Success',
		         'Data has been successfully saved.',
		         @id
		END
		ELSE
		BEGIN
		    EXEC spa_ErrorHandler -1,
		         'Logical Trade Lock.',
		         'spa_setup_logical_trade_lock',
		         'Success',
		         'Duplicate data in (Role Name and Deal Type).',
		         @id
		END
	END TRY
	BEGIN CATCH
		DECLARE @msg VARCHAR(500)
		SELECT @msg = ERROR_MESSAGE() 
		EXEC spa_ErrorHandler -1,
		     'Logical Trade Lock.',
		     'spa_setup_logical_trade_lock',
		     'Success',
		     @msg,
		     @id
	END CATCH
END
	

ELSE IF @flag='d'
BEGIN
    BEGIN TRY
		DELETE dls
		FROM dbo.FNASplit(@del_ids,',') ids
		INNER JOIN deal_lock_setup dls ON dls.id = ids.item

        EXEC spa_ErrorHandler 0
            ,'Logical Trade Lock.'
            ,'spa_setup_logical_trade_lock'
            ,'Success'
            ,'Data has been successfully deleted.'
            ,@del_ids
    END TRY
    BEGIN CATCH
        EXEC spa_ErrorHandler-1
            ,'Logical Trade Lock Delete.'
            ,'spa_setup_logical_trade_lock'
            ,'DB Error'
            ,'Data error on Logical Trade Lock grid. Please check the data in column Role Name and resave.'
            ,''
    END CATCH
END

ELSE IF @flag='r'
BEGIN
    SET @sql = 
        'SELECT role_id AS [value],
                role_name  AS [text]
         FROM   application_security_role
         WHERE  1 = 1
                AND role_id NOT IN (SELECT role_id
                                    FROM   batch_process_notifications
                                    WHERE  1 = 1
                                           AND role_id IS NOT NULL)'
    
    EXEC (@sql)
END

ELSE IF @flag= 'h'
BEGIN
	DECLARE @s_id     INT,
	        @e_id     INT
	
	SET @s_id = 0
	SET @e_id = 24;
	
	WITH CTE(id) AS
	     (
	         SELECT @s_id AS [id]
	         UNION ALL
	         SELECT [id] + 1
	         FROM   CTE
	         WHERE  [id] < @e_id
	     )
	
	SELECT id [value],
	       id [text]
	FROM   CTE 
END

ELSE IF @flag= 'm'
BEGIN
	DECLARE @s_id1     INT,
	        @e_id1     INT
	
	SET @s_id1 = 0
	SET @e_id1 = 60;
	
	WITH CTE(id) AS
	     (
	         SELECT @s_id1 AS [id]
	         UNION ALL
	         SELECT [id] + 1
	         FROM   CTE
	         WHERE  [id] < @e_id1
	     )
	
	SELECT id [value],
	       id [text]
	FROM   CTE 
END
GO