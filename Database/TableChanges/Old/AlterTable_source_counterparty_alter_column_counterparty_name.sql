IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_int_ext_flag')
BEGIN
	--PRINT 'here'
	DROP INDEX source_counterparty.IX_PT_source_counterparty_int_ext_flag
END
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_int_ext_flag1')
BEGIN
	DROP INDEX source_counterparty.IX_PT_source_counterparty_int_ext_flag1
END
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_PT_source_counterparty_int_ext_flag2')
BEGIN
	DROP INDEX source_counterparty.IX_PT_source_counterparty_int_ext_flag2
END
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_source_counterparty')
BEGIN
	ALTER TABLE source_counterparty
	DROP CONSTRAINT IX_source_counterparty
END
IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[source_counterparty]') AND name = N'IX_source_counterparty_1')
BEGIN
	DROP INDEX source_counterparty.IX_source_counterparty_1
	--ALTER TABLE source_counterparty
	--DROP CONSTRAINT IX_source_counterparty_1
END
--
--DROP INDEX source_counterparty.IX_source_counterparty

IF EXISTS (
       SELECT *
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_counterparty]')
   )
    ALTER FULLTEXT INDEX ON [dbo].[source_counterparty] DISABLE
GO

IF EXISTS (SELECT * FROM   sys.fulltext_indexes fti WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_counterparty]'))
    DROP FULLTEXT INDEX ON [dbo].[source_counterparty]
GO

--MAIN ALTER SCRIPT FOR NVARCHAR

ALTER TABLE source_counterparty
ALTER COLUMN counterparty_name NVARCHAR(100)

ALTER TABLE source_counterparty
ALTER COLUMN counterparty_id NVARCHAR(100)

ALTER TABLE source_counterparty
ALTER COLUMN counterparty_desc NVARCHAR(100)

ALTER TABLE source_counterparty_audit
ALTER COLUMN counterparty_name NVARCHAR(100)

ALTER TABLE source_counterparty_audit
ALTER COLUMN counterparty_id NVARCHAR(100)

ALTER TABLE source_counterparty_audit
ALTER COLUMN counterparty_desc NVARCHAR(100)

-- ALTER SCRIPT OVER


CREATE NONCLUSTERED INDEX IX_PT_source_counterparty_int_ext_flag
ON source_counterparty (int_ext_flag)
CREATE NONCLUSTERED INDEX IX_PT_source_counterparty_int_ext_flag1
ON source_counterparty (int_ext_flag)
CREATE NONCLUSTERED INDEX IX_PT_source_counterparty_int_ext_flag2
ON source_counterparty (int_ext_flag)
--
ALTER TABLE source_counterparty
ADD CONSTRAINT IX_source_counterparty UNIQUE (source_system_id, counterparty_id)

CREATE NONCLUSTERED INDEX IX_source_counterparty_1
ON source_counterparty (counterparty_id)

--CREATE NONCLUSTERED INDEX IX_source_counterparty_1
--ON source_counterparty (counterparty_id)

IF NOT EXISTS (
       SELECT 1
       FROM   sys.fulltext_indexes fti
       WHERE  fti.object_id = OBJECT_ID(N'[dbo].[source_counterparty]')
   )
    CREATE FULLTEXT INDEX ON [dbo].[source_counterparty](
        [counterparty_desc] LANGUAGE [English],
        [counterparty_id] LANGUAGE [English],
        [counterparty_name] LANGUAGE [English]
    )
    KEY INDEX [PK_source_counterparty]ON ([TRMTrackerFTI], FILEGROUP [PRIMARY])
--WITH (CHANGE_TRACKING = AUTO, STOPLIST = SYSTEM)
GO