IF OBJECT_ID(N'spa_source_book_mapping_clm', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_book_mapping_clm]
GO 

CREATE PROCEDURE [dbo].[spa_source_book_mapping_clm] 
	@flag CHAR(1) = NULL
AS

IF @flag = 's'
BEGIN
    IF EXISTS( SELECT group1, group2, group3, group4 FROM  source_book_mapping_clm )
    BEGIN
        SELECT 1 id, group1 [group] INTO #temp_sbmc
        FROM   source_book_mapping_clm sbmc UNION ALL
        SELECT 2 id, group2 [group] FROM source_book_mapping_clm UNION ALL
        SELECT 3 id,group3 [group] FROM  source_book_mapping_clm UNION ALL
        SELECT 4 id, group4 [group] FROM  source_book_mapping_clm
        SELECT * FROM   #temp_sbmc
    END
    ELSE
    BEGIN
        SELECT 1,'Group1' UNION ALL
        SELECT 2, 'Group2' UNION ALL 
        SELECT 3, 'Group3' UNION ALL
        SELECT 4, 'Group4'
    END
END
ELSE
BEGIN
    IF EXISTS(
           SELECT group1, group2, group3, group4
           FROM   source_book_mapping_clm
       )
    BEGIN
        SELECT group1, group2, group3, group4
        FROM   source_book_mapping_clm
    END
    ELSE
    BEGIN
        SELECT 'Group1' group1,'Group2' group2, 'Group3' group3, 'Group4' group4
    END
END