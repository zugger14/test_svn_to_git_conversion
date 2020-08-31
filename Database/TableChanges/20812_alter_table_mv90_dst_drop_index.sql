IF EXISTS (SELECT 1 FROM sys.indexes 
	WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[MV90_DST]') 
	AND name = N'indx_uniq_cur_mv90_dst'
) 
BEGIN
     DROP INDEX [indx_uniq_cur_mv90_dst] ON [dbo].[MV90_DST]
	 PRINT 'Index indx_uniq_cur_mv90_dst dropped'
END

GO