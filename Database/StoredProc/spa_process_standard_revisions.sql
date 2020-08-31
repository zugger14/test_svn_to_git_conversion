IF OBJECT_ID ('[dbo].[spa_process_standard_revisions]','p') IS NOT NULL 
	DROP PROCEDURE [dbo].[spa_process_standard_revisions] 

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
go


CREATE PROCEDURE [dbo].[spa_process_standard_revisions]
    @flag VARCHAR(1),
    @standard_revision_id INT = NULL,
    @standard_id INT = NULL,
    @standard_category_id INT = NULL,
    @standard_name VARCHAR(250) = NULL,
    @standard_description VARCHAR(50) = NULL,
    @standard_url VARCHAR(50) = NULL,
    @standard_priority INT = NULL,
    @standard_owner VARCHAR(50) = NULL,
    @effective_date VARCHAR(15) = NULL
AS 
    DECLARE @sql_stmt VARCHAR(5000)
    
    IF @flag = 'i' 
        BEGIN
-- 	if @standard_id is null
-- 	begin
-- 		--SET IDENTITY_INSERT process_standard_main off
-- 		insert into process_standard_main(standard_name)
-- 		values (@standard_name)
-- 		set @standard_id=SCOPE_IDENTITY()
-- 	end

            IF EXISTS ( SELECT  standard_id
                        FROM    process_standard_revisions
                        WHERE   standard_id = @standard_id
                                AND effective_date = @effective_date ) 
                BEGIN
                    EXEC spa_ErrorHandler -1, 'process_standard_revisions',
                        'spa_process_standard_revisions', 'Success',
                        'Duplicate Effective Date found', ''
                    RETURN
                END
            INSERT  INTO process_standard_revisions
                    (
                      standard_id,
                      standard_category_id,
                      standard_description,
                      standard_url,
                      standard_priority,
                      standard_owner,
                      effective_date
                    )
            VALUES  (
                      @standard_id,
                      @standard_category_id,
                      @standard_description,
                      @standard_url,
                      @standard_priority,
                      @standard_owner,
                      @effective_date 
                    )
        
            IF @@ERROR <> 0 
                EXEC spa_ErrorHandler @@ERROR, "process_standard_revisions",
                    "spa_process_standard_revisions", "DB Error",
                    "Insert of process_standard_revisions data failed.", ''
            ELSE 
                EXEC spa_ErrorHandler 0, 'process_standard_revisions',
                    'spa_process_standard_revisions', 'Success',
                    'process_standard_revisions data successfully inserted.',
                    ''

        END
    ELSE 
        IF @flag = 's' 
            BEGIN

                SET @sql_stmt = ' select standard_revision_id [ID], psr.standard_id [Standard Compliance ID], sdv.description [Standard Category], psm.standard_name [Standard Name] , 
       standard_description [Revision Description], standard_url [URL], sdv1.description [Priority], standard_owner [Owner], 
       dbo.FNADateFormat(psr.effective_date) [Effective Date] 
        FROM process_standard_revisions psr
       join process_standard_main psm on  psr.standard_id=psm.standard_id '
                IF @Effective_date IS NOT NULL 
                    SET @sql_stmt = @sql_stmt
                        + '
       join (select standard_id,max(effective_date) effective_date from process_standard_revisions
	where effective_date<=''' + @Effective_date
                        + ''' group by standard_id) p on p.standard_id=psr.standard_id
	and p.effective_date=psr.effective_date '
                SET @sql_stmt = @sql_stmt
                    + ' left outer join static_data_value sdv on psm.standard_category_id=sdv.value_id
       left outer join static_data_value sdv1 on psr.standard_priority=sdv1.value_id where 1=1'
                IF @standard_name IS NOT NULL 
                    SET @sql_stmt = @sql_stmt
                        + ' and psm.standard_name like ''' + @standard_name
                        + '%'''
                IF @standard_category_id IS NOT NULL 
                    SET @sql_stmt = @sql_stmt
                        + ' and psr.standard_category_id='
                        + CAST(@standard_category_id AS VARCHAR)
                IF @standard_id IS NOT NULL 
                    SET @sql_stmt = @sql_stmt + ' and psm.standard_id='
                        + CAST(@standard_id AS VARCHAR)


                SET @sql_stmt = @sql_stmt
                    + ' order by psr.standard_id,psr.Effective_date '
                exec spa_print  @sql_stmt 
                EXEC ( @sql_stmt
                    )

            END

        ELSE 
            IF @flag = 'm' 
                BEGIN

                    SET @sql_stmt = ' select standard_id [ID],standard_name [Standard/Rule Name], sdv.code Category 
			FROM process_standard_main  left outer join 
			static_data_value sdv on standard_category_id=sdv.value_id
			where 1=1'
                    IF @standard_name IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' and standard_name like ''' + @standard_name
                            + '%'''
                    IF @standard_category_id IS NOT NULL 
                        SET @sql_stmt = @sql_stmt
                            + ' and standard_category_id = '
                            + CAST(@standard_category_id AS VARCHAR)
                    EXEC ( @sql_stmt
                        )

                END
            ELSE 
                IF @flag = 'r' 
                    BEGIN

                        SELECT  standard_revision_id,
                                psm.standard_name + '->'
                                + standard_description AS standard_description
                        FROM    process_standard_revisions psr
                                JOIN process_standard_main psm ON psr.standard_id = psm.standard_id
                        WHERE   psr.standard_id = @standard_id
	

                    END
                ELSE 
                    IF @flag = 'a' 
                        SELECT  standard_revision_id,
                                psm.standard_id,
                                psm.standard_category_id,
                                standard_name,
                                standard_description,
                                standard_url,
                                standard_priority,
                                standard_owner,
                                dbo.FNADateFormat(effective_date) [Effective Date]
                        FROM    process_standard_revisions psr
                                INNER JOIN process_standard_main psm ON psr.standard_id = psm.standard_id
                        WHERE   standard_revision_id = @standard_revision_id
	
    IF @flag = 'u' 
        BEGIN
            IF EXISTS ( SELECT  standard_id
                        FROM    process_standard_revisions
                        WHERE   standard_id = @standard_id
                                AND effective_date = @effective_date
                                AND standard_revision_id <> @standard_revision_id ) 
                BEGIN
                    EXEC spa_ErrorHandler -1, 'process_standard_revisions',
                        'spa_process_standard_revisions', 'Success',
                        'Duplicate Effective Date found ', ''
                    RETURN
                END	

            UPDATE  process_standard_revisions
            SET     standard_id = @standard_id,
                    standard_category_id = @standard_category_id,
                    standard_description = @standard_description,
                    standard_url = @standard_url,
                    standard_priority = @standard_priority,
                    standard_owner = @standard_owner,
                    effective_date = @effective_date
            WHERE   standard_revision_id = @standard_revision_id

            IF @@ERROR <> 0 
                EXEC spa_ErrorHandler @@ERROR, "process_standard_revisions",
                    "spa_process_standard_revisions", "DB Error",
                    "Insert of process_standard_revisions data failed.", ''
            ELSE 
                EXEC spa_ErrorHandler 0, 'process_standard_revisions',
                    'spa_process_standard_revisions', 'Success',
                    'Process Standard Revisions data successfully updated.',
                    ''

        END
    IF @flag = 'd' 
        BEGIN
            DELETE  process_standard_revisions
            WHERE   standard_revision_id = @standard_revision_id
            IF @@ERROR <> 0 
                EXEC spa_ErrorHandler @@ERROR, "process_standard_revisions",
                    "spa_process_standard_revisions", "DB Error",
                    "Delete of process_standard_revisions data failed.", ''
            ELSE 
                EXEC spa_ErrorHandler 0, 'process_standard_revisions',
                    'spa_process_standard_revisions', 'Success',
                    'process_standard_revisions data successfully deleted.',
                    ''

        END



