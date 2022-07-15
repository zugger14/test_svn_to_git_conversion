using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using FARRMSUtilities;
using System.Text;

namespace FARRMSExcelServerCLR
{
    class BulkDocumentGeneration
    {
        /// <summary>
        /// Document Collection
        /// </summary>
        public List<DocumentTemplate> documentTemplates { get; set; }

        /// <summary>
        /// Bulk Batch process ID
        /// </summary>
        private readonly string _batchProcessId;
        /// <summary>
        /// Sql Connection string
        /// </summary>
        private readonly string _connectionString;
        /// <summary>
        /// document templates collection dataset process table name
        /// </summary>
        private readonly string _datasetProcessTableName;

        /// <summary>
        /// Bulk document generation default intilaization
        /// </summary>
        public BulkDocumentGeneration()
        {
        }
        /// <summary>
        /// Intitalize Bulk document generation
        /// </summary>
        /// <param name="batchProcessId"></param>
        public BulkDocumentGeneration(string batchProcessId)
        {
            _batchProcessId = batchProcessId;
            _connectionString = "";
            _connectionString = "Context Connection=True";
            //_connectionString = @"Data Source=PSDL20;Initial Catalog=TRMTracker_Enercity;Persist Security Info=True;User ID=sa;password=pioneer";
            _datasetProcessTableName = $"adiha_process.dbo.contract_report_template_exceldoc_{_batchProcessId}";
        }

        /// <summary>
        /// Generate documents according to document templates
        /// </summary>
        public void RunProcesss()
        {
            LoadDocumentTemplates();
            foreach (var item in documentTemplates)
            {
                GenerateDocument(item);
            }

            MoveDocuments();
            UpdateDocumentExportStatus();
        }

        /// <summary>
        /// Move all the exported documents to its output file path
        /// </summary>
        private void MoveDocuments()
        {
            foreach (var item in documentTemplates)
            {
                if (item.Status && File.Exists(item.ExportFileName))
                {
                    try
                    {
                        if (File.Exists(item.OutputFilePath)) File.Delete(item.OutputFilePath);
                        File.Move(item.ExportFileName, item.OutputFilePath);
                    }
                    catch (Exception ex)
                    {
                        ex.LogError("MoveDocuments", "");
                    }
                }
            }
        }
        /// <summary>
        /// Mark document status as true
        /// </summary>
        private void UpdateDocumentExportStatus()
        {
            StringBuilder bld = new StringBuilder();

            foreach (var item in documentTemplates)
            {
                if (item.Status)
                {
                    bld.Append($"{item.Id},");
                }
            }

            string docIds = "";
            if (!string.IsNullOrEmpty(bld.ToString()))
            {
                docIds = bld.ToString().TrimEnd(',');
                using (var cn = new SqlConnection(_connectionString))
                {
                    cn.Open();
                    Helper.ExecuteQuery(cn, $"UPDATE {_datasetProcessTableName} SET [status]=1 WHERE Id IN({docIds})");
                }
            }
        }

        private void GenerateDocument(DocumentTemplate excelDocument)
        {
            try
            {
                if (excelDocument.TemplateType.ToLower() == "excel")
                    CreateDocumentFromExcelTemplate(excelDocument);
                else if (excelDocument.TemplateType.ToLower() == "rdl")
                    CreateDocumentFromRDLTemplate(excelDocument);
                excelDocument.Status = true;
            }
            catch (Exception ex)
            {
                excelDocument.Status = true;
                ex.LogError("GenerateDocument", "");
            }
        }

        /// <summary>
        /// Generate excel document
        /// </summary>
        /// <param name="documentTemplate">DocumentTemplate</param>
        private void CreateDocumentFromExcelTemplate(DocumentTemplate documentTemplate)
        {
            try
            {
                using (var sqlConnection = new SqlConnection(_connectionString))
                {
                    sqlConnection.Open();
                    using (var snapshotInfo = new SnapshotInfo(sqlConnection, documentTemplate))
                    {
                        snapshotInfo.Synchronize();
                    }
                    sqlConnection.Close();
                }
            }
            catch (Exception ex)
            {
                ex.LogError("CreateDocumentFromExcelTemplate", "");
            }
        }

        /// <summary>
        /// Execute Export RDL Wrapper sql command
        /// </summary>
        /// <param name="documentTemplate">DocumentTemplate</param>
        private void CreateDocumentFromRDLTemplate(DocumentTemplate documentTemplate)
        {
            try
            {
                using (var sqlConnection = new SqlConnection(_connectionString))
                {
                    sqlConnection.Open();
                    using (var cmd = new SqlCommand(documentTemplate.CriteriaOrSQl, sqlConnection))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }

            }
            catch (Exception ex)
            {
                ex.LogError("CreateDocumentFromRDLTemplate", "");
            }
        }

        /// <summary>
        /// Load collection of excel document to be generated from adiha_process.dbo.contract_report_template_exceldoc_process_id table
        /// </summary>
        public void LoadDocumentTemplates()
        {
            this.documentTemplates = new List<DocumentTemplate>();
            using (var sqlConnection = new SqlConnection(_connectionString))
            {
                sqlConnection.Open();
                using (SqlCommand cmd = new SqlCommand($"SELECT * FROM {_datasetProcessTableName}", sqlConnection))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            documentTemplates.Add(new DocumentTemplate()
                            {
                                ExcelSheetId = rd["excel_sheet_id"].ToInt()
                            ,
                                ProcessId = rd["process_id"].ToString()
                            ,
                                CriteriaOrSQl = rd["criteria"].ToString()
                            ,
                                ExportFormat = rd["export_format"].ToString()
                            ,
                                TemplateType = rd["template_type"].ToString()
                            ,
                                UserName = rd["user_name"].ToString()
                            ,
                                Id = rd["id"].ToInt()
                            ,
                                OutputFilePath = rd["output_file_path"].ToString()
                            ,
                                Status = rd["status"].ToBool()
                            });

                        }
                    }
                }
            }
        }

    }
}
