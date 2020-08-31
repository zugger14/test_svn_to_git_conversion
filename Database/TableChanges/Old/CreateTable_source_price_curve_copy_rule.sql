/****** Object:  Table [dbo].[source_price_curve_copy_rule]    Script Date: 07/28/2011 09:42:56 ******/
--DROP TABLE [source_price_curve_copy_rule]

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_copy_rule]') AND type in (N'U'))
	CREATE TABLE [dbo].[source_price_curve_copy_rule](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[source_curve_def_id] [int] NOT NULL,
		[curve_type] [char](1) NOT NULL,
		[settlement_curve_type_value_id] [int] NULL,
		[use_expiration_calendar] [char](1) NOT NULL,
		[copy_curve_def_id] [int] NULL
	 CONSTRAINT [PK_source_price_curve_copy_rule_1] PRIMARY KEY CLUSTERED 
	(
		[id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]

	GO

DELETE FROM source_price_curve_copy_rule
-- Insert into [source_price_curve_copy_rule]
INSERT INTO source_price_curve_copy_rule([source_curve_def_id],[curve_type],[settlement_curve_type_value_id],[use_expiration_calendar],[copy_curve_def_id])
SELECT 82,'s',18401,'y',NULL
UNION
SELECT 10,'s',18400,'y',NULL
UNION
SELECT 83,'s',18400,'y',NULL
UNION
SELECT 84,'s',18400,'y',NULL
UNION
SELECT 23,'s',18401,'y',NULL
UNION
SELECT 76,'f',NULL,'n',NULL
UNION
SELECT 77,'f',NULL,'n',NULL
UNION
SELECT 92,'f',NULL,'n',NULL
UNION
SELECT 93,'s',18400,'y',NULL
UNION
SELECT 94,'f',NULL,'n',NULL
UNION
SELECT 95,'s',18400,'y',NULL
UNION
SELECT 97,'f',NULL,'n',NULL
UNION
SELECT 105,'f',NULL,'n',NULL
UNION
SELECT 106,'f',NULL,'n',NULL
UNION
SELECT 107,'s',18402,'y',97
UNION
SELECT 5,'f',NULL,'n',NULL



-- SELECT * FROM source_price_curve_copy_rule where curve_type='s' and use_expiration_calendar='n'


