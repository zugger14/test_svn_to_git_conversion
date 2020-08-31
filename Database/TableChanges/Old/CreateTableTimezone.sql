/****** Object:  Table [dbo].[time_zones]    Script Date: 04/12/2010 16:37:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[time_zones]') AND type in (N'U'))
DROP TABLE [dbo].[time_zones]
/****** Object:  Table [dbo].[time_zones]    Script Date: 04/12/2010 16:37:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[time_zones](
	[TIMEZONE_ID] [int] IDENTITY(1,1) NOT NULL,
	[TIMEZONE_NAME] [varchar](60) NOT NULL,
	[OFFSET_HR] [int] NOT NULL CONSTRAINT [DF_TIME_ZONES_OFFSET]  DEFAULT ((-1)),
	[OFFSET_MI] [int] NOT NULL CONSTRAINT [DF_TIME_ZONES_OFFSET_MI]  DEFAULT ((0)),
	[DST_OFFSET_HR] [int] NOT NULL CONSTRAINT [DF_TIME_ZONES_DST_OFFSET]  DEFAULT ((-1)),
	[DST_OFFSET_MI] [int] NOT NULL CONSTRAINT [DF_TIME_ZONES_DST_OFFSET_MI]  DEFAULT ((0)),
	[DST_EFF_DT] [varchar](10) NOT NULL CONSTRAINT [DF_TIME_ZONES_DST_EFF_DT]  DEFAULT ('03210200'),
	[DST_END_DT] [varchar](10) NOT NULL CONSTRAINT [DF_TIME_ZONES_DST_END_DT]  DEFAULT ('11110200'),
	[EFF_DT] [datetime] NOT NULL CONSTRAINT [DF_TIME_ZONES_EFF_DT]  DEFAULT (getdate()),
	[END_DT] [datetime] NOT NULL CONSTRAINT [DF_TIME_ZONES_END_DT]  DEFAULT ('12/31/9999'),
 CONSTRAINT [PK_TIME_ZONES] PRIMARY KEY CLUSTERED 
(
	[TIMEZONE_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT INTO [TIME_ZONES](OFFSET_HR,OFFSET_MI,TIMEZONE_NAME)
SELECT -12,0,'(GMT -12:00) Eniwetok, Kwajalein'
UNION
SELECT -11,0,'(GMT -11:00) Midway Island, Samoa'
UNION
SELECT -10,0,'(GMT -10:00) Hawaii'
UNION
SELECT -9,0,'(GMT -9:00) Alaska'
UNION
SELECT -8,0,'(GMT -8:00) Pacific Time (US & Canada)'
UNION
SELECT -7,0,'(GMT -7:00) Mountain Time (US & Canada)'
UNION
SELECT -6,0,'(GMT -6:00) Central Time (US & Canada), Mexico City'
UNION
SELECT -5,0,'(GMT -5:00) Eastern Time (US & Canada), Bogota, Lima'
UNION
SELECT -4,0,'(GMT -4:00) Atlantic Time (Canada), Caracas, La Paz'
UNION
SELECT -3,5,'(GMT -3:30) Newfoundland'
UNION
SELECT -3,0,'(GMT -3:00) Brazil, Buenos Aires, Georgetown'
UNION
SELECT -2,0,'(GMT -2:00) Mid-Atlantic'
UNION
SELECT -1,0,'(GMT -1:00 hour) Azores, Cape Verde Islands'
UNION
SELECT 0,0,'(GMT) Western Europe Time, London, Lisbon, Casablanca'
UNION
SELECT 1,0,'(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris'
UNION
SELECT 2,0,'(GMT +2:00) Kaliningrad, South Africa'
UNION
SELECT 3,0,'(GMT +3:00) Baghdad, Riyadh, Moscow, St. Petersburg'
UNION
SELECT 3,5,'(GMT +3:30) Tehran'
UNION
SELECT 4,0,'(GMT +4:00) Abu Dhabi, Muscat, Baku, Tbilisi'
UNION
SELECT 4,5,'(GMT +4:30) Kabul'
UNION
SELECT 5,0,'(GMT +5:00) Ekaterinburg, Islamabad, Karachi, Tashkent'
UNION
SELECT 5,5,'(GMT +5:30) Bombay, Calcutta, Madras, New Delhi'
UNION
SELECT 5,75,'(GMT +5:45) Kathmandu'
UNION
SELECT 6,0,'(GMT +6:00) Almaty, Dhaka, Colombo'
UNION
SELECT 7,0,'(GMT +7:00) Bangkok, Hanoi, Jakarta'
UNION
SELECT 8,0,'(GMT +8:00) Beijing, Perth, Singapore, Hong Kong'
UNION
SELECT 9,0,'(GMT +9:00) Tokyo, Seoul, Osaka, Sapporo, Yakutsk'
UNION
SELECT 9,5,'(GMT +9:30) Adelaide, Darwin'
UNION
SELECT 10,0,'(GMT +10:00) Eastern Australia, Guam, Vladivostok'
UNION
SELECT 11,0,'(GMT +11:00) Magadan, Solomon Islands, New Caledonia'
UNION
SELECT 12,0,'(GMT +12:00) Auckland, Wellington, Fiji, Kamchatka'

