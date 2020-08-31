IF COL_LENGTH('partition_config_info', 'granule') IS NULL
BEGIN
    ALTER TABLE partition_config_info ADD granule INT
END
GO


IF OBJECT_ID('dbo.[archive_dependency]',N'U') IS  NULL 
BEGIN
	

	CREATE TABLE archive_dependency
	(
		ad_id               TINYINT IDENTITY(1, 1),
		main_table          NVARCHAR(128),
		dependent_table     NVARCHAR(128),
		parent_column       NVARCHAR(500),
		child_column        NVARCHAR(500),
		existence_chk_cols  NVARCHAR(500),
		chk_col_defination  NVARCHAR(4000),
		del_flg             NCHAR(1) DEFAULT 'n',
		update_cols         NVARCHAR(1000)
	)

END

 
GO
IF COL_LENGTH('archive_dependency', 'arch_seq') IS NULL
BEGIN

ALTER TABLE dbo.archive_dependency ADD arch_seq int NULL
END

GO
ALTER TABLE dbo.archive_dependency SET (LOCK_ESCALATION = TABLE)
GO
 