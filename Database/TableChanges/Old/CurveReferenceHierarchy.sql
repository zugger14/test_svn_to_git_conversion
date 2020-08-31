/**********************************************************************/
/* Author	   : Vishwas Khanal										  */
/* Date        : 17.Dec.2008										  */
/* Description : Table for reference Hierarchy of the Curve			  */
/* Purpose     : Demo												  */
/**********************************************************************/

IF OBJECT_ID('dbo.CurveReferenceHierarchy','u') IS NOT NULL
	DROP TABLE dbo.CurveReferenceHierarchy
GO
/****** Object:  Table [dbo].[CurveReferenceHierarchy]    Script Date: 12/18/2008 09:45:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CurveReferenceHierarchy](
	[sno] [int] IDENTITY(1,1) NOT NULL,
	[curveId] INT,
	[factor] [int] NULL,
	[RefID_1] INT,
	[factor_1] [int] NULL,
	[RefID_2] INT,
	[factor_2] [int] NULL,
	[RefID_3] INT,
	[factor_3] [int] NULL,
	[RefID_4] INT,
	[factor_4] [int] NULL,
	[RefID_5] INT,
	[factor_5] [int] NULL,
	[RefID_6] INT,
	[factor_6] [int] NULL,
	[RefID_7] INT,
	[factor_7] [int] NULL,
	[RefID_8] INT,
	[factor_8] [int] NULL,
	[RefID_9] INT,
	[factor_9] [int] NULL,
	[RefID_10] INT,
	[factor_10] [int] NULL,
 CONSTRAINT [PK_17122008] PRIMARY KEY CLUSTERED 
(
	[sno] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF