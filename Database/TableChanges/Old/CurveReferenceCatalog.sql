/**********************************************************************/
/* Author	   : Vishwas Khanal										  */
/* Date        : 17.Dec.2008										  */
/* Description : Catalog creation for the database					  */
/* Purpose     : Demo												  */
/**********************************************************************/

/* This script has to be run before CurveReferenceHierarchySP is executed. 
   The reason being that CurveReferenceHierarchySP uses "CONTAINS" keyword."CONTAINS"
   is a full text search. Hence the following is required
	1. Full Text Search to be enabled in the database. By default it is disabled.
	2. Catalog to be created. Catalog is nothing but a directory where the the SQL Engine will 
	   keep up all the words found in the columns (the ones which has beed added in the full text search list)
	3. Table name and a primary key column has to be associated with the catalog.Constraint has name to be given for indexing.
	4. The columns where you want the full text to be enabled in the table
	5. Table now to be activated for full text. This means, not the table is ready for full text search use.
	6. Direct the engine to start propagating tracked changes to the full-text index as they occur.

*/

--Full Text Search to be enabling in the database. 
EXEC SP_FULLTEXT_DATABASE 'enable'
go


-- Catalog creation.
EXEC SP_FULLTEXT_CATALOG 'mycatalog', 'create'
go


--Table name and a primary key column associated with the catalog.
EXEC SP_FULLTEXT_TABLE 'CurveReferenceHierarchy', 'create', 'mycatalog', 'PK_17122008'
go



-- Assigning the columns used in the full text search.
exec SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'CURVEID', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_1', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_2', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_3', 'add'

EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_4', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_5', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_6', 'add'

EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_7', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_8', 'add'
EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_9', 'add'

EXEC SP_FULLTEXT_COLUMN 'CurveReferenceHierarchy', 'RefID_10', 'add'
go


-- Activate the table for full text 
EXEC SP_FULLTEXT_TABLE 'CurveReferenceHierarchy', 'activate'
go


-- Direct the engine to start propagating tracked changes to the full-text index as they occur.
EXEC SP_FULLTEXT_TABLE 'CurveReferenceHierarchy', 'Start_background_updateindex';
go


 

