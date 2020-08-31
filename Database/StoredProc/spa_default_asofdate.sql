
GO
/****** Object:  StoredProcedure [dbo].[spa_default_asofdate]    Script Date: 05/02/2010 09:56:35 ******/
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[spa_default_asofdate]')
                    AND type IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_default_asofdate]
go
CREATE PROCEDURE [dbo].[spa_default_asofdate]
    @flag CHAR(1), --'t' Current Date and Tine, 'c' - Current Date
    @module_type VARCHAR(50) = NULL,
    @as_of_date VARCHAR(15) = NULL
AS 
    DECLARE @sql VARCHAR(1000)
    IF @flag = 's' 
        BEGIN
            SET @sql = 'SELECT s.code [Module Type],
							  dbo.FNAGetGenericDate(as_of_date, dbo.FNADBUser())  [As of Date]
						FROM module_asofdate m
						INNER JOIN static_data_value s
						ON m.module_type=s.value_id
						'
						
            IF @module_type IS NOT NULL 
                SET @sql = @sql + ' where m.module_type = '
                    + CAST(@module_type AS VARCHAR)
            EXEC ( @sql
                )
        END
	ELSE IF @flag = 'c' -- current Date
        BEGIN
			DECLARE @current_date VARCHAR(50)
			SET  @current_date = dbo.FNADateTimeFormat(GETDATE(),1)
			SELECT SUBSTRING(@current_date,1, CHARINDEX(' ' , @current_date)-1)
		END	
	ELSE IF @flag = 't' -- current Date &  Time
			SELECT dbo.FNADateTimeFormat(GETDATE(),1)           
    ELSE IF @flag = 'i' 
        BEGIN
			--DECLARE @var_value VARCHAR(100)
			--select @var_value = var_value FROM adiha_default_codes_values WHERE (instance_no = '1') AND (default_code_id = 38) AND (seq_no = 1)
            BEGIN TRY 
				--if ((@var_value is null) OR (@var_value='0'))
				--BEGIN	
					INSERT  INTO module_asofdate(module_type,as_of_date)VALUES(@module_type,@as_of_date)
				--END
				--else if ((@var_value is not null) AND (@var_value='1'))
				--BEGIN	
				--	DECLARE @lastDayinDate varchar(50)
				--	SET @lastDayinDate = dbo.FNALastDayInDate(@as_of_date)
				--	INSERT  INTO module_asofdate(module_type,as_of_date)VALUES(@module_type,@lastDayinDate)
				--END	
			END TRY 
			BEGIN CATCH
				IF @@ERROR=2627 --Violation of PRIMARY KEY constraint 'pk_module_type'. Cannot insert duplicate key.
					Exec spa_ErrorHandler -1, 'Duplicate As Of Date not allowded.', 
					'module_asofdate', 'DB Error', 
					'''As of Date'' for selected ''Module Type'' already exists.', ''
				ElSE If @@error <> 0
					Exec spa_ErrorHandler -1, 'Failed to Insert Data.', 
					'module_asofdate', 'DB Error', 
					'Failed to Insert Data.', ''

			END CATCH

        END
     ELSE IF @flag = 'u' 
        BEGIN
            UPDATE  module_asofdate
            SET     as_of_date = @as_of_date
            WHERE   module_type = @module_type
        END
     ELSE IF @flag = 'd' 
        BEGIN

			SELECT @sql = 'DELETE m FROM module_asofdate m
						INNER JOIN static_data_value s
						ON m.module_type=s.value_id
						WHERE s.code = '''+CAST(@module_type AS VARCHAR)+''''
			EXEC(@sql)		

        END
	 ELSE IF @flag = 'f' --[asofdateto] and [asofdatefrom] that will be one month before than asofdateto.
        BEGIN
			DECLARE @var_value VARCHAR(100)
			SELECT @var_value = var_value FROM adiha_default_codes_values WHERE (instance_no = '1') AND (default_code_id = 38) AND (seq_no = 1)
			
            SET @sql = 'SELECT s.code [Module Type],
							dbo.FNAGetSQLStandardDate(' + 
							CASE WHEN ISNULL(@var_value,'0') = '1' THEN 'dbo.FNALastDayInDate(as_of_date)' ELSE 'as_of_date'  END															  
							+
							')  [As of Date To],  
							dbo.FNAGetSQLStandardDate(dateadd(mm,-1,' +
							CASE WHEN ISNULL(@var_value,'0') = '1' THEN 'dbo.FNALastDayInDate(as_of_date)' ELSE 'as_of_date'  END															  
							+'))  [As of Date From]
						FROM module_asofdate m
						INNER JOIN static_data_value s
						ON m.module_type=s.value_id
						'
            IF @module_type IS NOT NULL 
                SET @sql = @sql + ' where m.module_type = '
                    + CAST(@module_type AS VARCHAR)
            EXEC ( @sql
                )
        END
        
    