/*
* @Description - Returns SSIS Package Full Path with trailing slash
* @Param - @cfg_filter: Config Filter String
*		   @pkg_path: Variable Name with namespace
* @Returns - Returns Full Path with trailing slash		   
*/
IF OBJECT_ID(N'FNAGetSSISPkgFullPath', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetSSISPkgFullPath]
GO
	
CREATE FUNCTION [dbo].[FNAGetSSISPkgFullPath] (
	@cfg_filter VARCHAR(200),
	@pkg_path VARCHAR(500)
)
RETURNS VARCHAR(2000)
AS
BEGIN
	DECLARE @root VARCHAR(1000), @pkg_dir VARCHAR(1000), @full_path VARCHAR(2000)
	
	SELECT @root = import_path FROM connection_string cs
	SELECT @pkg_dir = sc.ConfiguredValue FROM ssis_configurations sc WHERE 
			sc.ConfigurationFilter = @cfg_filter AND
			sc.PackagePath = '\Package.Variables[' + @pkg_path + '].Properties[Value]'

	SET @full_path = @root + ISNULL(@pkg_dir, '')
	IF RIGHT(@full_path, 1) <> '\'
		SET @full_path = @full_path + '\'
	
	RETURN @full_path
END