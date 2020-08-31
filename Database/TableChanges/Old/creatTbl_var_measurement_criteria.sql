
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[var_measurement_criteria](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[var_criteria_id] [int] NULL,
	[book_id] [int] NULL,
 CONSTRAINT [PK_var_measurement_criteria] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[var_measurement_criteria]  WITH CHECK ADD  CONSTRAINT [FK_var_measurement_criteria_var_measurement_criteria_detail] FOREIGN KEY([var_criteria_id])
REFERENCES [dbo].[var_measurement_criteria_detail] ([id])
GO
ALTER TABLE [dbo].[var_measurement_criteria] CHECK CONSTRAINT [FK_var_measurement_criteria_var_measurement_criteria_detail]