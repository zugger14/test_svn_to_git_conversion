-- clear existing settings
DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_CMAInterface', 'PKG_CMAResponse', 'PKG_CMARequest')

-- apply new settings
INSERT ssis_configurations(ConfigurationFilter,ConfiguredValue,PackagePath,ConfiguredValueType)
      SELECT 'PRJ_CMAInterface', 'SPM', '\Package.Variables[User::PS_RequestSystem].Properties[Value]', 'String'
			UNION ALL
      SELECT 'PRJ_CMAInterface', '\CMA\Packages', '\Package.Variables[User::PS_PackageSubDir].Properties[Value]', 'String'
			UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response\source.xsd', '\Package.Variables[User::PS_XsdLocation].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '2', '\Package.Variables[User::PS_SourceSystemId].Properties[Value]', 'Int32'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response', '\Package.Variables[User::PS_SourceFilePath].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response\response.xsd', '\Package.Variables[User::PS_ResponseXsdLocation].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response', '\Package.Variables[User::PS_ResponseFilePath].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response\Processed', '\Package.Variables[User::PS_ProcessedFilePathSource].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response\Processed', '\Package.Variables[User::PS_ProcessedFilePathResponse].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '0', '\Package.Variables[User::PS_IsDst].Properties[Value]', 'Int32'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response\Error', '\Package.Variables[User::PS_ErrorFilePathSource].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '', '\Package.Variables[User::PS_ValuationUnit].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', 'D:\EssentSSIS\CMA\Data\Input\batch','\Package.Variables[User::PS_RequestXmlFolder].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', 'CMA', '\Package.Variables[User::PS_MarketValueId].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '', '\Package.Variables[User::PS_KeyValue].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMARequest', '', '\Package.Variables[User::PS_Granularity].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', 'D:\EssentSSIS\CMA\Data\Output\batch\Response\Error','\Package.Variables[User::PS_ErrorFilePathResponse].Properties[Value]', 'String'
            UNION ALL
      SELECT 'PKG_CMAResponse', '4500', '\Package.Variables[User::PS_CsValueId].Properties[Value]', 'Int32'
            UNION ALL
      SELECT 'PKG_CMAResponse', '77', '\Package.Variables[User::PS_ActValueId].Properties[Value]', 'Int32'

--update import path
UPDATE connection_string SET import_path = 'D:\EssentSSIS\'