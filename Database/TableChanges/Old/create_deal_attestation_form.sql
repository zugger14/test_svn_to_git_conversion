IF OBJECT_ID('deal_attestation_form','U') IS NOT NULL 
	DROP TABLE deal_attestation_form 
GO 
	
/****** Object:  Table [dbo].[deal_attestation_form]    Script Date: 11/02/2009 17:31:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[deal_attestation_form](
	[attestation_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_detail_id] [int] NULL,
	[generator_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[generator_name] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[fuel_type_value_id] [int] NULL,
	[volume] [float] NULL,
	[generation_date] [datetime] NULL,
	[nox_emissions] [float] NULL,
	[so2_emissions] [float] NULL,
	[co2_emissions] [float] NULL,
	[generation_period] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[deal_attestation_form]  WITH CHECK ADD  CONSTRAINT [FK_deal_attestation_form_source_deal_detail] FOREIGN KEY([source_deal_detail_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])