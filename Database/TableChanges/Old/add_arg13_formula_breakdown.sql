IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='formula_breakdown' AND COLUMN_NAME ='arg13')
begin
	alter TABLE [dbo].[formula_breakdown] add
		[arg13] [varchar](50) NULL,
		[arg14] [varchar](50) NULL,
		[arg15] [varchar](50) NULL,
		[arg16] [varchar](50) NULL,
		[arg17] [varchar](50) NULL,
		[arg18] [varchar](50) NULL
 end
 else
	print '	column arg13 is already exist...'

