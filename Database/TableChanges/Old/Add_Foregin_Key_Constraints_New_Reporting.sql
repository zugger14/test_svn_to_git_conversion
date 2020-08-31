IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'report_dataset_paramset'           --table name
                    AND ccu.COLUMN_NAME = 'report_dataset_paramset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_paramset] WITH NOCHECK ADD CONSTRAINT [PK_report_dataset_paramset] PRIMARY KEY([report_dataset_paramset_id])

/*********************************************** Data Source Column START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'data_source_column'           --table name
                    AND ccu.COLUMN_NAME = 'source_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[data_source_column] WITH NOCHECK ADD CONSTRAINT [FK_data_source_column_data_source] FOREIGN KEY([source_id])
REFERENCES [dbo].[data_source] ([data_source_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'data_source_column'           --table name
                    AND ccu.COLUMN_NAME = 'widget_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[data_source_column] WITH NOCHECK ADD CONSTRAINT [FK_data_source_column_report_widget] FOREIGN KEY([widget_id])
REFERENCES [dbo].[report_widget] ([report_widget_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'data_source_column'           --table name
                    AND ccu.COLUMN_NAME = 'datatype_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[data_source_column] WITH NOCHECK ADD CONSTRAINT [FK_data_source_column_report_datatype] FOREIGN KEY([datatype_id])
REFERENCES [dbo].[report_datatype] ([report_datatype_id])
/*********************************************** Data Source Column END *****************************************************/


/*********************************************** Report Dataset START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset'           --table name
                    AND ccu.COLUMN_NAME = 'report_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_report] FOREIGN KEY([report_id])
REFERENCES [dbo].[report] ([report_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset'           --table name
                    AND ccu.COLUMN_NAME = 'source_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_data_source] FOREIGN KEY([source_id])
REFERENCES [dbo].[data_source] ([data_source_id])
/*********************************************** Report Dataset END ****************************************************/


/*********************************************** Report Page START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_page'           --table name
                    AND ccu.COLUMN_NAME = 'report_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_page] WITH NOCHECK ADD CONSTRAINT [FK_report_page_report] FOREIGN KEY([report_id])
REFERENCES [dbo].[report] ([report_id])
/*********************************************** Report Page END ****************************************************/

/*********************************************** Report Dataset Relationship START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_relationship'           --table name
                    AND ccu.COLUMN_NAME = 'dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_relationship] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_relationship_report_dataset_dataset_id] FOREIGN KEY([dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_relationship'           --table name
                    AND ccu.COLUMN_NAME = 'from_dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_relationship] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_relationship_report_dataset_from_dataset_id] FOREIGN KEY([from_dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_relationship'           --table name
                    AND ccu.COLUMN_NAME = 'to_dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_relationship] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_relationship_report_dataset_to_dataset_id] FOREIGN KEY([to_dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_relationship'           --table name
                    AND ccu.COLUMN_NAME = 'from_column_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_relationship] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_relationship_data_source_column_from_column_id] FOREIGN KEY([from_column_id])
REFERENCES [dbo].[data_source_column] ([data_source_column_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_relationship'           --table name
                    AND ccu.COLUMN_NAME = 'to_column_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_relationship] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_relationship_data_source_column_to_column_id] FOREIGN KEY([to_column_id])
REFERENCES [dbo].[data_source_column] ([data_source_column_id])
/*********************************************** Report Dataset Relationship END ****************************************************/


/*********************************************** Report Paramset START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_paramset'           --table name
                    AND ccu.COLUMN_NAME = 'page_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_paramset] WITH NOCHECK ADD CONSTRAINT [FK_report_paramset_report_page] FOREIGN KEY([page_id])
REFERENCES [dbo].[report_page] ([report_page_id])
/*********************************************** Report Paramset END ****************************************************/


/*********************************************** Report Dataset Paramset START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_paramset'           --table name
                    AND ccu.COLUMN_NAME = 'paramset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_paramset] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_paramset_report_paramset] FOREIGN KEY([paramset_id])
REFERENCES [dbo].[report_paramset] ([report_paramset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_dataset_paramset'           --table name
                    AND ccu.COLUMN_NAME = 'root_dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_dataset_paramset] WITH NOCHECK ADD CONSTRAINT [FK_report_dataset_paramset_report_dataset] FOREIGN KEY([root_dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])
/*********************************************** Report Dataset Paramset END ****************************************************/


/*********************************************** Report Param START ****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_param'           --table name
                    AND ccu.COLUMN_NAME = 'dataset_paramset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_param] WITH NOCHECK ADD CONSTRAINT [FK_report_param_report_dataset_paramset] FOREIGN KEY([dataset_paramset_id])
REFERENCES [dbo].[report_dataset_paramset] ([report_dataset_paramset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_param'           --table name
                    AND ccu.COLUMN_NAME = 'dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_param] WITH NOCHECK ADD CONSTRAINT [FK_report_param_report_dataset] FOREIGN KEY([dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_param'           --table name
                    AND ccu.COLUMN_NAME = 'column_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_param] WITH NOCHECK ADD CONSTRAINT [FK_report_param_data_source_column] FOREIGN KEY([column_id])
REFERENCES [dbo].[data_source_column] ([data_source_column_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_param'           --table name
                    AND ccu.COLUMN_NAME = 'operator'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_param] WITH NOCHECK ADD CONSTRAINT [FK_report_param_report_param_operator] FOREIGN KEY([operator])
REFERENCES [dbo].[report_param_operator] ([report_param_operator_id])
/*********************************************** Report Param END ****************************************************/


/*********************************************** Report Page Chart Start****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_page_chart'           --table name
                    AND ccu.COLUMN_NAME = 'page_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_page_chart] WITH NOCHECK ADD CONSTRAINT [FK_report_page_chart_report_page] FOREIGN KEY([page_id])
REFERENCES [dbo].[report_page] ([report_page_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_page_chart'           --table name
                    AND ccu.COLUMN_NAME = 'root_dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_page_chart] WITH NOCHECK ADD CONSTRAINT [FK_report_page_chart_report_dataset] FOREIGN KEY([root_dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])
/*********************************************** Report Page Chart ENd ****************************************************/

/*********************************************** Report Chart Column Start****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_chart_column'           --table name
                    AND ccu.COLUMN_NAME = 'chart_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_chart_column] WITH NOCHECK ADD CONSTRAINT [FK_report_chart_column_report_page_chart] FOREIGN KEY([chart_id])
REFERENCES [dbo].[report_page_chart] ([report_page_chart_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_chart_column'           --table name
                    AND ccu.COLUMN_NAME = 'dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_chart_column] WITH NOCHECK ADD CONSTRAINT [FK_report_chart_column_report_dataset] FOREIGN KEY([dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_chart_column'           --table name
                    AND ccu.COLUMN_NAME = 'column_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_chart_column] WITH NOCHECK ADD CONSTRAINT [FK_report_chart_column_data_source_column] FOREIGN KEY([column_id])
REFERENCES [dbo].[data_source_column] ([data_source_column_id])
/*********************************************** Report Chart Column END****************************************************/


/*********************************************** Report Page Tablix Start****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_page_tablix'           --table name
                    AND ccu.COLUMN_NAME = 'page_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_page_tablix] WITH NOCHECK ADD CONSTRAINT [FK_report_page_tablix_report_page] FOREIGN KEY([page_id])
REFERENCES [dbo].[report_page] ([report_page_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_page_tablix'           --table name
                    AND ccu.COLUMN_NAME = 'root_dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_page_tablix] WITH NOCHECK ADD CONSTRAINT [FK_report_page_tablix_report_dataset] FOREIGN KEY([root_dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])
/*********************************************** Report Tablix Column Start****************************************************/


/*********************************************** Report Tablix Column Start****************************************************/
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_tablix_column'           --table name
                    AND ccu.COLUMN_NAME = 'tablix_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_tablix_column] WITH NOCHECK ADD CONSTRAINT [FK_report_tablix_column_report_page_tablix] FOREIGN KEY([tablix_id])
REFERENCES [dbo].[report_page_tablix] ([report_page_tablix_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_tablix_column'           --table name
                    AND ccu.COLUMN_NAME = 'dataset_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_tablix_column] WITH NOCHECK ADD CONSTRAINT [FK_report_tablix_column_report_dataset] FOREIGN KEY([dataset_id])
REFERENCES [dbo].[report_dataset] ([report_dataset_id])

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'report_tablix_column'           --table name
                    AND ccu.COLUMN_NAME = 'column_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].[report_tablix_column] WITH NOCHECK ADD CONSTRAINT [FK_report_tablix_column_data_source_column] FOREIGN KEY([column_id])
REFERENCES [dbo].[data_source_column] ([data_source_column_id])
/*********************************************** Report Tablix Column Start****************************************************/








  

  






