--Author: Tara Nath Subedi
--Issue Against: 2291
--Purpose: Dashboard Report Enhancement
--Dated: 2010-05-09
--create dashboard_report_template_group table.
--Modify dashboard_report_template Table.
IF OBJECT_ID(N'dashboard_report_template_group', N'U') IS NULL 
    BEGIN
        CREATE TABLE [dbo].[dashboard_report_template_group]
            (
              [report_template_group_id] [int] IDENTITY(1, 1)
                                               NOT NULL,
              [report_template_header_id] [int] NULL,
              [user_login_id] [varchar](50) NULL,
              [report_name] [varchar](100) NULL,
              [report_section] [int] NULL,
              [report_type] [char],
              CONSTRAINT [PK_dashboard_report_template_group] PRIMARY KEY CLUSTERED ( [report_template_group_id] ASC )
                WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
                       IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                       ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY],
              CONSTRAINT [IX_dashboard_report_template_group] UNIQUE NONCLUSTERED ( [report_template_header_id] ASC, [report_section] ASC )
                WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
                       IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                       ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
            )
        ON  [PRIMARY]

        PRINT 'Table ''dashboard_report_template_group'' created.'

    END
GO

--Modifying table dashboard_report_template, 
--dropping report_name column
--column "report_template_header_id" renamed to "report_template_group_id"
--changing foreign key and unique key to point to "report_template_group_id"

--drop column report_name
IF EXISTS ( SELECT  'X'
            FROM    INFORMATION_SCHEMA.COLUMNS
            WHERE   table_name = 'dashboard_report_template'
                    AND column_name = 'report_name' ) 
    ALTER TABLE dashboard_report_template DROP COLUMN report_name
GO

IF OBJECT_ID(N'IX_dashboard_report_template', N'UQ') IS NOT NULL 
    ALTER TABLE dashboard_report_template DROP CONSTRAINT [IX_dashboard_report_template]
GO

IF OBJECT_ID(N'FK_dashboard_report_template_dashboard_report_template_header',
             N'F') IS NOT NULL 
    ALTER TABLE dashboard_report_template DROP CONSTRAINT [FK_dashboard_report_template_dashboard_report_template_header]
GO

--change dashboard_report_template table's column report_template_header_id to report_template_group_id
IF EXISTS ( SELECT  'X'
            FROM    INFORMATION_SCHEMA.COLUMNS
            WHERE   table_name = 'dashboard_report_template'
                    AND column_name = 'report_template_header_id' ) 
    ALTER TABLE dashboard_report_template DROP COLUMN report_template_header_id
GO

IF NOT EXISTS ( SELECT  'X'
                FROM    INFORMATION_SCHEMA.COLUMNS
                WHERE   table_name = 'dashboard_report_template'
                        AND column_name = 'report_template_group_id' ) 
    ALTER TABLE dashboard_report_template
    ADD report_template_group_id INT
GO

IF OBJECT_ID(N'FK_dashboard_report_template_dashboard_report_template_group',
             N'F') IS NULL 
    BEGIN
        ALTER TABLE [dbo].[dashboard_report_template]
                WITH NOCHECK
        ADD CONSTRAINT [FK_dashboard_report_template_dashboard_report_template_group] FOREIGN KEY ( [report_template_group_id] ) REFERENCES [dbo].[dashboard_report_template_group] ( [report_template_group_id] )
        ALTER TABLE [dbo].[dashboard_report_template]
                CHECK CONSTRAINT [FK_dashboard_report_template_dashboard_report_template_group]
    END
GO

IF OBJECT_ID(N'IX_dashboard_report_template', N'UQ') IS NULL 
    BEGIN
        ALTER TABLE dashboard_report_template
        ADD CONSTRAINT [IX_dashboard_report_template] UNIQUE NONCLUSTERED ( [report_template_group_id] ASC, [report_section] ASC )
                WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
                       IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
                       ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90 )
    END
GO
