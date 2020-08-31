IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[spa_source_minor_location_meter]')
                    AND type in ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_source_minor_location_meter]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/*
Created By: Pawan KC
Date :23/03/2009
Description:For Select,Insert,Update,Delete in the table source_minor_location_meter
Purpose:Maintain the Meter Data of Minor Location as One minor location can have many meters.
*/


CREATE PROC [dbo].[spa_source_minor_location_meter]
    @flag varchar(1),
	@location_meter_id INT=NULL,	
    @meter_id int = NULL,
    @source_minor_location_id int = NULL,
    @imbalance_applied INT=NULL
as 
    DECLARE @Sql_Select varchar(3000),
        @msg_err varchar(2000)


    BEGIN TRY
    
        IF @flag = 'i' 
            BEGIN
				
			
                INSERT  INTO [dbo].[source_minor_location_meter]
                        (
                          [meter_id],
                          [source_minor_location_id],
                          [imbalance_applied]					   
			      )
                VALUES  (
                          @meter_id,
                          @source_minor_location_id,
						  @imbalance_applied	
			      )
            END
        ELSE IF @flag = 'u' 
                BEGIN
					
                    UPDATE  [dbo].[source_minor_location_meter]
                    SET     [meter_id] = @meter_id,
                            [source_minor_location_id] = @source_minor_location_id,
                            [imbalance_applied]=@imbalance_applied
                    WHERE   
						[location_meter_id] = @location_meter_id
                END
            ELSE IF @flag = 's' 
                    BEGIN
                        SET @Sql_Select = ' 	
								SELECT 
									   smlm.location_meter_id [location_meter_id],
									   sml.source_minor_location_id [source_minor_location_id],
									   mi.meter_id [meter_id],
									   smlm.meter_type [meter_type],
									   dbo.FNAGetSQLStandardDate(smlm.effective_date) [effective_date]
								FROM 
										[dbo].source_minor_location_meter smlm
										LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=smlm.source_minor_location_id
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id	
								WHERE 
										smlm.source_minor_location_id='
										+ CONVERT(VARCHAR(20), @source_minor_location_id)

                          EXEC ( @SQL_select)
                    END
               ELSE IF @flag = 'c' 
                        BEGIN	
                            IF @source_minor_location_id IS NOT NULL 
                                select  smlm.meter_id,
                                        mi.recorderid [Meter Name]
                                from    source_minor_location_meter smlm
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id	
                                WHERE   source_minor_location_id = @source_minor_location_id
                            ELSE 
                                select  DISTINCT smlm.meter_id,
                                        mi.recorderid [Meter Name] 
                                from    source_minor_location_meter smlm
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id	
                              
                        END
                ELSE IF @flag = 'e' 
                        BEGIN	
                            IF @source_minor_location_id IS NOT NULL 
                                SELECT  smlm.meter_id,
                                        mi.recorderid [Meter Name]
                                FROM    source_minor_location_meter smlm
										INNER JOIN delivery_path dp ON dp.meter_from = smlm.meter_id
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id	
                                WHERE   source_minor_location_id = @source_minor_location_id
                                AND  dp.imbalance_from = 'y'
                                UNION --ALL
                                SELECT  smlm.meter_id,
                                        mi.recorderid [Meter Name]
                                FROM    source_minor_location_meter smlm
										INNER JOIN delivery_path dp ON dp.meter_to = smlm.meter_id
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id	
                                WHERE   source_minor_location_id = @source_minor_location_id
                                AND dp.imbalance_to = 'y'
                               
                            ELSE 
                                select  DISTINCT smlm.meter_id,
                                        mi.recorderid [Meter Name] 
                                from    source_minor_location_meter smlm
                                INNER JOIN delivery_path dp ON dp.meter_from = smlm.meter_id
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id	
										WHERE dp.imbalance_from = 'y'
										UNION --ALL
								select  DISTINCT smlm.meter_id,
                                        mi.recorderid [Meter Name] 
                                from    source_minor_location_meter smlm
                                INNER JOIN delivery_path dp ON dp.meter_to = smlm.meter_id
										LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id
										WHERE dp.imbalance_to = 'y'	
                              
                        END
               ELSE IF @flag = 'd' 
                            BEGIN	
                                DELETE  [dbo].source_minor_location_meter
                                WHERE   location_meter_id = @location_meter_id
                            END
                            
               ELSE IF @flag = 'a' 
                                SELECT  [meter_id],
                                        [source_minor_location_id],
                                        [imbalance_applied]
                                FROM    [dbo].source_minor_location_meter
                                WHERE   [meter_id] = @meter_id
	
	
					DECLARE @msg varchar(2000)
					SELECT  @msg = ''
					if @flag = 'i' 
						SET @msg = 'Data Successfully Inserted.'
					ELSE 
						if @flag = 'u' 
							SET @msg = 'Data Successfully Updated.'
						ELSE 
							if @flag = 'd' 
								SET @msg = 'Data Successfully Deleted.'

					IF @msg <> '' 
						Exec spa_ErrorHandler 0, 'source_minor_location_meter table',
							'spa_source_minor_location_meter', 'Success', @msg, ''
    END TRY
    
    BEGIN CATCH
    
			DECLARE @error_number int
			SET @error_number = error_number()
			SET @msg_err = ''


			if @flag = 'i' 
				SET @msg_err = 'Fail Insert Data.'
			ELSE 
				if @flag = 'u' 
					SET @msg_err = 'Fail Update Data.'
				ELSE 
					if @flag = 'd' 
						SET @msg_err = 'Fail Delete Data.'

			Exec spa_ErrorHandler @error_number,
				'source_minor_location_meter table',
				'spa_source_minor_location_meter', 'DB Error', @msg_err, ''
    END CATCH
    










