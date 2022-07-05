using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using System.Data.SqlClient;

namespace FARRMSExcelServerCLR
{
    class BulkDocumentGeneration
    {
        /// <summary>
        /// Document Collection
        /// </summary>
        public List<DocumentTemplate> documentTemplates { get; set; }

        /// <summary>
        /// Total number of concurrent thread executions
        /// </summary>
        private int _batchSize { get; set; }
        /// <summary>
        /// Bulk Batch process ID
        /// </summary>
        private string _batchProcessId;

        /// <summary>
        /// Bulk document generation default intilaization
        /// </summary>
        public BulkDocumentGeneration()
        {
            _batchSize = 10;
        }
        /// <summary>
        /// Intitalize Bulk document generation
        /// </summary>
        /// <param name="batchSize">No of parallel threads to be executed</param>
        /// <param name="batchProcessId"></param>
        public BulkDocumentGeneration(int batchSize, string batchProcessId)
        {
            _batchSize = batchSize;
            if (_batchSize == 0) _batchSize = 10;
            _batchProcessId = batchProcessId;
        }

        public void RunProcess()
        {
            LoadDocumentTemplates();
            //var defaultDoc = excelDocuments.First();
            //GenerateDocument(defaultDoc);

            //return;
            StoredProcedure.PrintMessage($"BackgroundTaskCheck Started");
            try
            {
                int completedDocuments = documentTemplates.Count(x => x.ExecutionStatus == ExecutionStatus.Completed);
                Console.WriteLine($"completedDocuments:{completedDocuments}");

                while (completedDocuments < documentTemplates.Count)
                {
                    int runningThread = this.documentTemplates.Count(x => x.ExecutionStatus == ExecutionStatus.Started);
                    Console.WriteLine($"runningThread:{runningThread}");

                    int take = _batchSize - runningThread;
                    var pendingDocuments = this.documentTemplates.Where(x => x.ExecutionStatus == ExecutionStatus.NotStarted).Take(take).ToList();
                    Console.WriteLine($"take:{take}");
                    Console.WriteLine($"pendingDocuments:{pendingDocuments.Count}");

                    completedDocuments = documentTemplates.Count(x => x.ExecutionStatus == ExecutionStatus.Completed);
                    Console.WriteLine($"completedDocuments:{completedDocuments} Of total documents {documentTemplates.Count}");
                    foreach (var doc in pendingDocuments)
                    {
                        Task.Factory.StartNew(() => GenerateDocument(doc));
                    }
                    //  Dont add extra sleep when process is completed
                    if (completedDocuments < documentTemplates.Count)
                        Thread.Sleep(5000);
                }
                Console.WriteLine("EVERY THING FINISHED");
            }
            catch (Exception ex)
            {
                StoredProcedure.PrintMessage($"MonitorDocumentGenerationProcess {ex.Message}");
                throw ex;
            }
        }

        private void GenerateDocument(DocumentTemplate excelDocument)
        {
            if (excelDocument.TemplateType.ToLower() == "excel")
                CreateDocumentFromExcelTemplate(excelDocument);
            else if (excelDocument.TemplateType.ToLower() == "excel")
                CreateDocumentFromRDLTemplate(excelDocument);
        }

        private void CreateDocumentFromExcelTemplate(DocumentTemplate documentTemplate)
        {
            Console.WriteLine("New Task");
            try
            {
                using (var sqlConnection = new SqlConnection("Context Connection=True"))
                //using (var sqlConnection = new SqlConnection(@"Data Source=CTRMSGDB-D5003.ctrmdevwin.hasops.com,2033;Initial Catalog=TRMTracker_Release;User ID=dev_admin;password=Admin2929"))
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
                StoredProcedure.PrintMessage($"NewTask {ex.Message}");
                throw ex;
            }
        }

        private void CreateDocumentFromRDLTemplate(DocumentTemplate documentTemplate)
        {
            Console.WriteLine("New Task");
            try
            {
                using (var sqlConnection = new SqlConnection("Context Connection=True"))
                //using (var sqlConnection = new SqlConnection(@"Data Source=CTRMSGDB-D5003.ctrmdevwin.hasops.com,2033;Initial Catalog=TRMTracker_Release;User ID=dev_admin;password=Admin2929"))
                {
                    sqlConnection.Open();
                    using(var cmd = new SqlCommand(documentTemplate.CriteriaOrSQl, sqlConnection))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }

            }
            catch (Exception ex)
            {
                StoredProcedure.PrintMessage($"NewTask {ex.Message}");
                throw ex;
            }
        }

        /// <summary>
        /// Load collection of excel document to be generated from adiha_process.dbo.contract_report_template_exceldoc_process_id table
        /// </summary>
        private void LoadDocumentTemplates()
        {
            this.documentTemplates = new List<DocumentTemplate>();
            using (var sqlConnection = new SqlConnection("Context Connection=True"))
            //using (var sqlConnection = new SqlConnection(@"Data Source=CTRMSGDB-D5003.ctrmdevwin.hasops.com,2033;Initial Catalog=TRMTracker_Release;User ID=dev_admin;password=Admin2929"))
            {
                sqlConnection.Open();
                using (SqlCommand cmd = new SqlCommand($"SELECT TOP 10 * FROM adiha_process.dbo.contract_report_template_exceldoc_{_batchProcessId}", sqlConnection))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            documentTemplates.Add(new DocumentTemplate() { ExcelSheetId = rd["excel_sheet_id"].ToInt(), ProcessId = rd["process_id"].ToString(), CriteriaOrSQl = rd["criteria"].ToString(), ExportFormat = rd["export_format"].ToString(), TemplateType = rd["template_type"].ToString() });

                        }
                    }
                }
            }
        }

    }

    public class DocumentTemplate
    {
        public int ExcelSheetId { get; set; }
        public string ProcessId { get; set; }
        public string CriteriaOrSQl { get; set; }
        public string ExportFormat { get; set; }
        public string TemplateType { get; set; }
        public ExecutionStatus ExecutionStatus { get; set; }
        public string UserName { get; internal set; }
    }

    public enum ExecutionStatus
    {
        NotStarted = 0, Started = 1, Completed = 2
    }
}
