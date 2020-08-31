IF NOT EXISTS (
       SELECT 1
       FROM   ssis_configurations sc
       WHERE  sc.ConfigurationFilter = 'PRJ_Excel_Snapshot'
   )
BEGIN
    INSERT INTO ssis_configurations
      (
        ConfigurationFilter,
        ConfiguredValue,
        PackagePath,
        ConfiguredValueType
      )
    SELECT 'PRJ_Excel_Snapshot',
           '\ExcelSnapshot\Package',
           '\Package.Variables[User::PS_PackageSubDir].Properties[Value]',
           'String'
END
ELSE
	BEGIN
		UPDATE ssis_configurations
		SET
			ConfigurationFilter = 'PRJ_Excel_Snapshot',
			ConfiguredValue = '\ExcelSnapshot\Package',
			PackagePath = '\Package.Variables[User::PS_PackageSubDir].Properties[Value]',
			ConfiguredValueType = 'String'
		WHERE ConfigurationFilter = 'PRJ_Excel_Snapshot'
	END
