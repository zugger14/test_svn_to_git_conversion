/** Addition of Required Filter (View level Compulsory field) on data_source_column (Enhancement) - START**/
/* add column required_filter to know view level compulsory with bit 1 */
IF COL_LENGTH('data_source_column', 'required_filter') IS NULL
BEGIN
    ALTER TABLE data_source_column ADD required_filter BIT NULL
END
GO
/* alter column reqd_param to remove not null property */
IF COL_LENGTH('data_source_column', 'reqd_param') IS NOT NULL
BEGIN
    ALTER TABLE data_source_column ALTER COLUMN reqd_param BIT NULL
END
GO
/* Update view level required columns (old data rows) to 0, i.e. view level optional. Further more view level compulsory filters need to be updated manually. */
if COL_LENGTH('data_source_column', 'required_filter') is not null
begin
	update dsc
	set dsc.required_filter = 0
	FROM data_source_column dsc
	where dsc.reqd_param = 1 and dsc.append_filter = 0 AND dsc.required_filter is null

	print 'Updated required_filter to 0 (view level optional) for old data.'
end 
else print 'Column ''required_filter'' does not exist.'
GO
/** Addition of Required Filter (View level Compulsory field) on data_source_column (Enhancement) - END**/