
CREATE TABLE [dbo].[source_deal_error_types](
	[error_type_id] [int] IDENTITY(1,1) NOT NULL,
	[error_type_name] [varchar](255) NOT NULL,
	[error_type_code] [varchar](100) NOT NULL,
	[error_type_description] [varchar](500) NULL,
 CONSTRAINT [PK_source_deal_error_types] PRIMARY KEY CLUSTERED 
(
	[error_type_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET IDENTITY_INSERT [dbo].[source_deal_error_types] ON;
BEGIN TRANSACTION;
INSERT INTO [dbo].[source_deal_error_types]([error_type_id], [error_type_name], [error_type_code], [error_type_description])
SELECT '1', 'Invalid Data Format', 'INVALID_DATA_FORMAT', 'Data being invalid (eg. term being non date, pnl being non numeric)' UNION ALL
SELECT '2', 'Missing Static Data', 'MISSING_STATIC_DATA', 'Static data reference by deal not found' UNION ALL
SELECT '3', 'Expired Tenure', 'EXPIRED_TENURE', 'Terms lesser than as of date' UNION ALL
SELECT '4', 'Data Repetition', 'DATA_REPETITION', 'Data Repetition' UNION ALL
SELECT '5', 'Misc', 'MISC', 'Other reasons' UNION ALL
SELECT '9', 'Deal ID Not Found', 'MISSING_DEAL', 'Deal Id not found' UNION ALL
SELECT '10', '0 MTM value', 'ZERO_MTM', 'MTM for a term for a deal is 0' UNION ALL
SELECT '11', 'Deal Detail Not Matched', 'MISMATCHED_DEAL', 'Deal detail in POS table doesn''t match with existing deal.'

COMMIT;
RAISERROR (N'[dbo].[source_deal_error_types]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO
SET IDENTITY_INSERT [dbo].[source_deal_error_types] OFF;
GO