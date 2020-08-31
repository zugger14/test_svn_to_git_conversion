/***************************************************
* Created By : Mukesh Singh
* Created Date : 11-Sept-2009
* Purpose :To store date from screen Tier Type Properties 
*
****************************************************/

/****** Object:  Table [dbo].[tierTypeProperty]    Script Date: 09/11/2009 11:20:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tierTypeProperty]') AND type in (N'U'))
DROP TABLE [dbo].[tierTypeProperty]
GO

CREATE TABLE [dbo].[tierTypeProperty](
	[tierTypePropertyID] [int] IDENTITY(1,1) NOT NULL,
	[tierTypeValueId] [int] NOT NULL,
	[environmentalProduct] [int] NOT NULL,
	[tierTypePercentage] [float] NOT NULL,
	[create_user] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_tierTypeProperty] PRIMARY KEY CLUSTERED 
(
	[tierTypePropertyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[tierTypeProperty]  WITH CHECK ADD  CONSTRAINT [FK_tierTypeProperty_source_price_curve_def] FOREIGN KEY([environmentalProduct])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[tierTypeProperty]  WITH CHECK ADD  CONSTRAINT [FK_tierTypeProperty_static_data_value] FOREIGN KEY([tierTypeValueId])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
CREATE TRIGGER [TRGINS_tierTypeProperty]
ON [dbo].[tierTypeProperty]
FOR INSERT
AS
UPDATE tierTypeProperty SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  tierTypeProperty.tierTypePropertyID in (select tierTypePropertyID from inserted)
GO

CREATE TRIGGER [TRGUPD_tierTypeProperty]
ON [dbo].[tierTypeProperty]
FOR UPDATE
AS
UPDATE tierTypeProperty SET update_user =  dbo.FNADBUser(), update_ts = getdate() where  tierTypeProperty.tierTypePropertyID in (select tierTypePropertyID from deleted)

GO