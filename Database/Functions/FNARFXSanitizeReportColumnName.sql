IF OBJECT_ID(N'FNARFXSanitizeReportColumnName', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARFXSanitizeReportColumnName]
GO 

CREATE FUNCTION [dbo].[FNARFXSanitizeReportColumnName]
(
	@column_name VARCHAR(500)
)
RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @x AS FLOAT
	
	SELECT @column_name = 
	REPLACE(
		REPLACE(
			REPLACE(
				REPLACE(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE(
											REPLACE(
												REPLACE(
													REPLACE(
														REPLACE(
															REPLACE(
																REPLACE(
																	REPLACE(@column_name, '#', '_'), '@', '_'), '$', '_'), '(', '_'), ')', '_'), '/', '_'), '\', '_'), ']', '_'), '[', '_'), ',', '_'), '.', '_'), ':', '_'), '*', '_'), '&', '_'), '%', '_'), '-', '_'), ' ', '_'
	)
	
	                                                 
	RETURN @column_name	
END	
