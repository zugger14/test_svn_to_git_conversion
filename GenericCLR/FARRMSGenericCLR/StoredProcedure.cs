using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Schema;
using DocumentFormat.OpenXml.Spreadsheet;
using Ionic.Zip;
using Microsoft.SqlServer.Server;
using Microsoft.VisualBasic.FileIO;
using DocumentFormat.OpenXml.Packaging;
using WordDocumentGenerator.Library;
using FARRMS.WebServices;
using System.Net.Sockets;
using sql = FARRMS.WebServices.ReportService2005;
using Row = DocumentFormat.OpenXml.Spreadsheet.Row;
using FARRMSUtilities;
using System.Globalization;

namespace FARRMSGenericCLR
{
    /// <summary>
    /// This class contains miscellenaous CLR methods to be deployed in database
    /// </summary>
    public class StoredProcedure
    {
        public static List<string> stackProcess = new List<string>();
        private static string PlaceholderIgnoreA = "PlaceholderIgnoreA";
        private static string PlaceholderIgnoreB = "PlaceholderIgnoreB";

        private static string PlaceholderContainerA = "PlaceholderContainerA";
        public static bool ContextConnection = true;
        public const int DATA_NOT_AVAILABLE = 100;
        public const int SUCCESS = 0;
        public const int REQUEST_ERROR = 200;
        public const int POLL_INTERVAL = 5000;


        [SqlProcedure]
        
        
        /// <summary>
        /// Build Data table for Epex Market results
        /// </summary>
        /// <param name="processTableName">Process table name</param>
        /// <param name="area">Area market</param>
        /// <param name="rawData">Data to be processed</param>
        public static void BuildEpexDataTable(string processTableName, string area, string rawData)
        {
            try
            {
                string areaSet;
                string auctionName;
                string[] datarows;

                //Grab required information from the whole response
                int checkIndex = rawData.IndexOf(area);
                int len = rawData.LastIndexOf("Sum/Avg") - checkIndex;
                datarows = rawData.Split(new string[] { "<br>" }, StringSplitOptions.RemoveEmptyEntries);
                areaSet = datarows[0].Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries).ToArray().Last();
                auctionName = datarows[1].Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries).ToArray().Last();

                string reqdinfo = rawData.Substring(checkIndex, len);
                datarows = reqdinfo.Split(new string[] { "<br>" }, StringSplitOptions.RemoveEmptyEntries);
                string[] participants = datarows[0].Split(new string[] { ";" }, StringSplitOptions.RemoveEmptyEntries).Where(x => x != area).ToArray();

                List<string> dataSet = new List<string>();

                int dataOffset = 3;// skip first 3 columns in each row to build new row
                for (int i = 0; i < participants.Count(); i++)
                {
                    // Each participant contains 12 segment data, except first one contains 15
                    for (int j = 3; j < datarows.Count(); j++) //j = skip first 3 rows 
                    {
                        string[] dataarr = datarows[j].Split(';');
                        if (i == 0)
                            dataSet.Add(area + ";" + areaSet + ";" + auctionName + ";" + participants[i].Split(':')[1].Trim() + ";" + string.Join(";", datarows[j].Replace(",", ".").Split(';').Take(15)));
                        else
                            dataSet.Add(area + ";" + areaSet + ";" + auctionName + ";" + participants[i].Split(':')[1].Trim() + ";" + dataarr[0].Replace(",", ".") + ";" + dataarr[1].Replace(",", ".") + ";" + dataarr[2].Replace(",", ".") + ";" + string.Join(";", datarows[j].Replace(",", ".").Split(';').Skip(dataOffset).Take(12)));
                    }
                    dataOffset += 12;
                }

                //  Data table
                string[] columns = "Area,Area Set,Auction Name,Participant,Date,MCP (EUR/MWh),MCV (MW),Total Sched Net,Total Sched Purchase,Total Sched Sale,Linear Sched Net,Linear Sched Purchase,Linear Sched Sale,Block Sched Net,Block Sched Purchase,Block Sched Sale,Complex Sched Net,Complex Sched Purchase,Complex Sched Sale".Split(',');
                DataTable dt = new DataTable("dtTable");
                foreach (string col in columns)
                    dt.Columns.Add(new DataColumn(col));

                foreach (var row in dataSet)
                {
                    var itmArray = row.Split(';');
                    dt.Rows.Add(itmArray);
                }

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=DESKTOP-FV76GJT\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=sa;password=pioneer"))
                {
                    cn.Open();
                    using (SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM " + processTableName, cn))
                    {
                        using (SqlCommandBuilder builder = new SqlCommandBuilder(adapter))
                        {
                            builder.GetInsertCommand();
                            adapter.Update(dt);
                        }
                    }

                    cn.Close();
                }
            }
            catch (Exception ex)
            {
                ex.LogError("Build Epex Data Table ", processTableName + "|" + area + "|" + ex.Message, stackProcess);
                throw ex;
            }

        }


        #region Calculation Eigen Matrix

        /// <summary>
        /// Performs calculation of eigen vector matrix
        /// </summary>
        /// <param name="as_of_date">as of date</param>
        /// <param name="term_start">Term Start</param>
        /// <param name="term_end">Term End</param>
        /// <param name="purge">Purge, posible vaues y,n</param>
        /// <param name="dvalue_end_range">Max value range</param>
        /// <param name="user_name">runtime user</param>
        /// <param name="process_id">unique process id</param>
        /// <param name="criteria_id">Criteria</param>
        /// <param name="decompositionType">Decomposition type, e=> Eigen, s=> Singular value</param>
        public static void CalculateEigenValues(SqlString as_of_date, SqlString term_start, SqlString term_end,
            SqlString purge, SqlDouble dvalue_end_range, SqlString user_name, SqlString process_id, SqlInt32 criteria_id, string decompositionType)
        {
            int criteriaId = criteria_id.ToInt();
            string processId = process_id.ToString();
            DecompositionStatus calcStatus = new DecompositionStatus() { Type = decompositionType };
            double dValueEndRange = dvalue_end_range.ToDouble();
            using (SqlConnection sc = new SqlConnection("Context Connection=true"))
            //using (SqlConnection sc = new SqlConnection("Data Source=SG-D-SQL02.farrms.us,2033;Initial Catalog=TRMTracker_PNM_Live;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
            {
                sc.Open();
                try
                {
                    string userName = user_name.ToString();
                    string processTable = "adiha_process.dbo.Curve_Info_" + userName + "_" + processId.ToString();

                    //  List Of Curves exists in process table
                    Curve[] curvesInProcess = GetCurvesFromProcessTable("SELECT DISTINCT risk_bucket_id [CurveId] ",
                        processTable, sc);

                    //  Get most recent date from curve correaltion according asofdate supplied
                    string recentDate = GetMostRecentDate(as_of_date.ToString(), sc);

                    //  List of curve data
                    string query =
                        @"IF OBJECT_ID('tempdb..#tmp_curve_detail') IS NOT NULL DROP TABLE #tmp_curve_detail  " +
                        "SELECT DISTINCT f.risk_bucket_id     curve_id_from " +
                        ", cto.risk_bucket_id [curve_id_to] " +
                        ", f.volatility_source " +
                        " INTO                  #tmp_curve_detail " +
                        "FROM " + processTable + " f " +
                        "CROSS APPLY ( " +
                        "    SELECT DISTINCT risk_bucket_id " +
                        "    FROM " + processTable + " )cto " +
                        "SELECT cc.id [Id]" +
                        " , cc.curve_id_from [CurveIdFrom]" +
                        " , cc.curve_id_to [CurveIdTo]" +
                        " , cc.as_of_date [AsOfDate]" +
                        " , cc.curve_source_value_id [CurveSourceValueId]" +
                        " , cc.term1 [Term1]" +
                        " , cc.term2 [Term2]" +
                        " , cc.[value] [Value] " +
                        " FROM #tmp_curve_detail tcd " +
                        " INNER JOIN curve_correlation cc ON  cc.curve_id_from = tcd.curve_id_from  " +
                        "AND cc.curve_id_to = tcd.curve_id_to " +
                        "AND cc.curve_source_value_id = tcd.volatility_source " +
                        "AND cc.as_of_date ='" + as_of_date.ToString() + "'" +
                        "AND (cc.term1 BETWEEN '" + term_start.ToString() + "' AND '" + term_end.ToString() + "') " +
                        "AND (cc.term2 BETWEEN '" + term_start.ToString() + "' AND '" + term_end.ToString() + "') " +
                        "ORDER BY cc.curve_id_from, cc.term1, cc.term2";
                    //sp.Send(query);
                    SqlCommand cmd = new SqlCommand(query, sc);
                    SqlDataReader reader = cmd.ExecuteReader();
                    CurveData[] curveDatas =
                        new List<CurveData>().FromDataReader(reader)
                            .OrderBy(x => x.CurveIdFrom)
                            .ThenBy(x => x.Term1)
                            .ThenBy(x => x.Term2)
                            .ToArray();
                    reader.Close();
                    //  Validation for number either curves in process table has data from curve correlation 
                    if (CurveDataNotExists(curvesInProcess, curveDatas, processId, as_of_date.ToString(), sc, userName))
                        return;
                    //  List of From curves 
                    List<Curve> curves = new List<Curve>();
                    foreach (CurveData curveData in curveDatas)
                    {
                        Curve curve = new Curve { CurveId = curveData.CurveIdFrom, Term1 = curveData.Term1 };
                        Curve c = curves.FirstOrDefault(x => x.CurveId == curve.CurveId && x.Term1 == curve.Term1);
                        if (c == null)
                            curves.Add(curve);
                    }
                    Curve[] curvesFrom = curves.OrderBy(x => x.CurveId).ThenBy(y => y.Term1).ToArray();
                    //  List of To curves
                    curves = new List<Curve>();
                    foreach (CurveData curveData in curveDatas)
                    {
                        Curve curve = new Curve { CurveId = curveData.CurveIdTo, Term1 = curveData.Term2 };
                        Curve c = curves.FirstOrDefault(x => x.CurveId == curve.CurveId && x.Term1 == curve.Term1);
                        if (c == null)
                            curves.Add(curve);
                    }
                    Curve[] curvesTo = curves.OrderBy(x => x.CurveId).ThenBy(y => y.Term1).ToArray();
                    //double[][] pvals = { new double[] { 1.0, 1.0, 1.0 }, new double[] { 1.0, 2.0, 3.0 }, new double[] { 1.0, 3.0, 6.0 } };
                    //  Validation for curve matrix is not square
                    if (!CurveIsSquare(curvesFrom, curvesTo))
                    {
                        MessageLogs(processId, "The matrix is not square", string.Format("{0} Decomposition Values. (ERRORS found).", calcStatus.DecompositionType), false, sc, userName, "Error", null, true, string.Format("{0}_Matrix", calcStatus.DecompositionType));
                        return;
                    }

                    var pvals = new double[curvesFrom.Count()][];
                    //  we suppose square always
                    //  By default array length for square matrix is equal to from curves
                    int arrayLength = curvesFrom.Count();
                    int index = 0;
                    foreach (Curve curveFrom in curvesFrom)
                    {
                        pvals[index] = new double[arrayLength];
                        int innerIndex = 0;
                        foreach (Curve curveTo in curvesTo)
                        {
                            var firstOrDefault = curveDatas.FirstOrDefault(
                                x => x.CurveIdFrom == curveFrom.CurveId && x.Term1 == curveFrom.Term1 &&
                                     x.CurveIdTo == curveTo.CurveId && x.Term2 == curveTo.Term1);
                            if (firstOrDefault != null)
                                pvals[index][innerIndex] = firstOrDefault.Value;
                            innerIndex++;
                        }
                        index++;
                    }

                    //  For test
                    //  double[][] pvals1 = { new double[] { 1.0, 1.0, 1.0 }, new double[] { 1.0, 2.0, 3.0 }, new double[] { 1.0, 3.0, 6.0 } };

                    var matrices = new GeneralMatrix(pvals);

                    if (calcStatus.Type.ToLower() == "e" || calcStatus.Type.ToLower() == "s")
                    {
                        calcStatus = Decompose(matrices, dValueEndRange, decompositionType);

                        if (calcStatus.Error)
                        {
                            MessageLogs(processId, string.Format("The {0} value is less than the threshold defined.", calcStatus.DecompositionType), string.Format("{0} Values Decomposition. (ERRORS found).", calcStatus.DecompositionType), false, sc, userName, "Error", null, true, string.Format("{0}_Threshold", calcStatus.DecompositionType));
                            return;
                        }
                    }
                    else
                    {
                        calcStatus = Decompose(matrices, dValueEndRange, "e");
                        if (calcStatus.Error)
                        {
                            MessageLogs(processId, "The Eigen value is less than the threshold defined.", "[Warning] The Eigen value is less than the threshold defined.", false, sc, userName, "Warning", null, false);
                            calcStatus = Decompose(matrices, dValueEndRange, "s");
                            if (calcStatus.Error)
                            {
                                MessageLogs(processId, "The Singular value is less than the threshold defined.", "[Warning] The Singular value is less than the threshold defined.", false, sc, userName, "Warning", null, false, "Singular Values", "Singular Values");
                                return;
                            }
                        }
                    }
                    //  Assignment of (D & V) matrix array to curve data
                    index = 0;
                    foreach (Curve curveFrom in curvesFrom)
                    {
                        int innerIndex = 0;
                        foreach (Curve curveTo in curvesTo)
                        {
                            CurveData curveData =
                                curveDatas.FirstOrDefault(
                                    x => x.CurveIdFrom == curveFrom.CurveId && x.Term1 == curveFrom.Term1 &&
                                         x.CurveIdTo == curveTo.CurveId && x.Term2 == curveTo.Term1);
                            if (curveData != null) curveData.DValue = calcStatus.Values.Array[index][innerIndex];
                            if (curveData != null) curveData.VValue = calcStatus.Vectors.Array[index][innerIndex];
                            if (curveData != null) curveData.EigenFactor = calcStatus.Factors.Array[index][innerIndex];
                            if (calcStatus.Type.ToLower() == "s")
                            {
                                if (curveData != null)
                                    curveData.MatrixU = calcStatus.MatricesU.Array[index][innerIndex];
                            }
                            innerIndex++;
                        }
                        index++;
                    }
                    //  Purge
                    PurgeOperations(purge.ToString(), as_of_date.ToString(), processTable, term_start.ToString(), term_end.ToString(), sc, criteriaId);

                    //  Bulkcopy has been disabled due to Context connection which cannot be used in SqlBulkCopy
                    //  We can implement this if we build SSIS package in future
                    InsertResults(curveDatas, sc, userName, criteriaId, calcStatus.Type);

                    MessageLogs(processId, "", string.Format("{0} values decomposition completed successfully.", calcStatus.DecompositionType), false, sc, userName, "Success", null, false, string.Format("{0} Values", calcStatus.DecompositionType), string.Format("{0} Values", calcStatus.DecompositionType));
                    query = "EXEC spa_ErrorHandler 0, '{0} Decomposition Process', 	'{0} Decomposition', 'Success', '{0} Decomposition Process has been completed successfully.', '{0}_value_decomposition'";
                    query = string.Format(query, calcStatus.DecompositionType);
                    ExecuteReader(query, sc);
                }
                catch (Exception ex)
                {
                    string query = "EXEC spa_ErrorHandler -1, '{0} Decomposition Process', 	'{0} Decomposition', 'Error', '{0} Decomposition Process Failed.', ''";
                    query = string.Format(query, calcStatus.DecompositionType);
                    ExecuteReader(query, sc);
                    ex.LogError("CalculateEigenValues",
                        as_of_date.ToString() + "|" + term_start.ToString() + "|" + term_end.ToString() + "|" +
                        purge.ToString() + "|" + dvalue_end_range.ToString() + "|" + user_name.ToString() + "|" +
                        process_id.ToString() + "|" + criteria_id.ToString() + "|" + decompositionType + "|" + ex.Message);
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="matrices">GeneralMatrix</param>
        /// <param name="dValueEndRange">Max range, default is -2</param>
        /// <param name="decompositionType">Decomposition type, e=> Eigen, s=> Singular value</param>
        /// <returns>DecompositionStatus</returns>
        private static DecompositionStatus Decompose(GeneralMatrix matrices, double dValueEndRange, string decompositionType)
        {
            DecompositionStatus dStatus = new DecompositionStatus() { Type = decompositionType };
            if (decompositionType.ToLower() == "e")
            {
                EigenvalueDecomposition eig = matrices.Eigen();
                dStatus.Values = eig.D; //  These matrix will dump as it is in physical table
                //  If eigen values is between 0 to DValueEndRange (Default : -2) then make it 0
                //  Eigen values will used to calculate Eigen Factors
                GeneralMatrix eigenConvertedValues = eig.D; //  These matrix will use for calculation
                SetZeroForNegativeEigenValues(eigenConvertedValues, dValueEndRange);
                dStatus.Vectors = eig.GetV();
                dStatus.MatricesU = null;
                //  Error as output parameter, while getting square root
                bool error;
                dStatus.Factors = dStatus.Vectors.Multiply(Sqrt(eigenConvertedValues, out error));
                dStatus.Error = error;
                return dStatus;
            }
            else if (decompositionType.ToLower() == "s")
            {
                SingularValueDecomposition svd = matrices.SVD();
                //  Error as output parameter, while getting square root
                bool error;
                dStatus.Factors = svd.GetV().Multiply(Sqrt(svd.S, out error).Multiply(svd.GetU()));
                //  diagonal matrix of singular values
                dStatus.Values = svd.S;
                //SetZeroForNegativeEigenValues(eigenConvertedValues, dValueEndRange);
                dStatus.MatricesU = svd.GetU();
                dStatus.Vectors = svd.GetV();
                dStatus.Error = error;
                return dStatus;
            }
            return null;
        }

        /// <summary>
        /// Insert results to eigen_value_decomposition table, eigen_value_decomposition_whatif
        /// </summary>
        /// <param name="curveDatas">Array collection cyrve data definition</param>
        /// <param name="connection">Valid opened sql connection</param>
        /// <param name="userName">runtime user</param>
        /// <param name="criteriaId">Critreia numeric value</param>
        /// <param name="decompositionType">Decomposition type, e=> Eigen, s=> Singular value</param>
        private static void InsertResults(CurveData[] curveDatas, SqlConnection connection, string userName, int criteriaId, string decompositionType)
        {
            string query = "SELECT TOP 1 * FROM eigen_value_decomposition";
            if (criteriaId > 0)
                query = "SELECT TOP 1 * FROM eigen_value_decomposition_whatif";

            SqlDataAdapter adapter = new SqlDataAdapter(query, connection);
            SqlCommandBuilder builder = new SqlCommandBuilder(adapter);
            DataSet dataSet = new DataSet("dataset");
            adapter.Fill(dataSet);

            for (int i = 0; i < curveDatas.Count(); i++)
            {
                DataRow row = dataSet.Tables[0].NewRow();
                row["as_of_date"] = curveDatas[i].AsOfDate.ToString();
                row["curve_id_from"] = curveDatas[i].CurveIdFrom.ToString();
                row["curve_id_to"] = curveDatas[i].CurveIdTo.ToString();
                row["term1"] = curveDatas[i].Term1.ToString();
                row["term2"] = curveDatas[i].Term2.ToString();
                row["curve_source_value_id"] = curveDatas[i].CurveSourceValueId.ToString();
                row["eigen_values"] = curveDatas[i].DValue.ToString();
                row["eigen_vectors"] = curveDatas[i].VValue.ToString();
                row["eigen_factors"] = curveDatas[i].EigenFactor.ToString();
                row["create_user"] = userName;
                row["create_ts"] = DateTime.Now;

                if (decompositionType.ToLower() == "s")
                    row["matrix_u"] = curveDatas[i].MatrixU.ToString();
                else
                    row["matrix_u"] = "0";

                if (criteriaId > 0)
                    row["criteria_id"] = criteriaId.ToString();
                dataSet.Tables[0].Rows.Add(row);
            }
            ////adapter.UpdateBatchSize = 5000;
            adapter.Update(dataSet);
        }

        /// <summary>
        /// Performs sql bulk copy operation, CURRENTLY NOT USED BECAUSE BULK COPY DOESNT WORK ON CONTEXT CONNECTION
        /// </summary>
        /// <param name="curveDatas">Curve data array</param>
        /// <param name="connection">SqlConnection</param>
        private static void BulkCopy(CurveData[] curveDatas, SqlConnection connection)
        {

            //  Creating source table to perform sql bulk copy according to our destination table.
            //  These column name must be same according to our destination table because these column name is used in column mapping 
            DataTable sourceTable = new DataTable();
            sourceTable.Columns.Add("as_of_date");
            sourceTable.Columns.Add("curve_id_from");
            sourceTable.Columns.Add("curve_id_to");
            sourceTable.Columns.Add("term1");
            sourceTable.Columns.Add("term2");
            sourceTable.Columns.Add("curve_source_value_id");
            sourceTable.Columns.Add("eigen_values");
            sourceTable.Columns.Add("eigen_vectors");
            sourceTable.Columns.Add("eigen_factors");
            //  Insert build data rows in table 
            for (int i = 0; i < curveDatas.Count(); i++)
            {
                DataRow row = sourceTable.NewRow();
                row["as_of_date"] = curveDatas[i].AsOfDate.ToString();
                row["curve_id_from"] = curveDatas[i].CurveIdFrom.ToString();
                row["curve_id_to"] = curveDatas[i].CurveIdTo.ToString();
                row["term1"] = curveDatas[i].Term1.ToString();
                row["term2"] = curveDatas[i].Term2.ToString();
                row["curve_source_value_id"] = curveDatas[i].CurveSourceValueId.ToString();
                row["eigen_values"] = curveDatas[i].DValue.ToString();
                row["eigen_vectors"] = curveDatas[i].VValue.ToString();
                row["eigen_factors"] = curveDatas[i].EigenFactor.ToString();
                sourceTable.Rows.Add(row);
            }
            connection.Close();
            SqlConnection destinationConnection = new SqlConnection("Context Connection=true");

            //destinationConnection.ConnectionString = connection.ConnectionString;
            SqlPipe sp = SqlContext.Pipe;
            sp.Send(destinationConnection.ConnectionString);
            destinationConnection.Open();
            using (SqlBulkCopy bulkCopy =
                new SqlBulkCopy(destinationConnection.ConnectionString,
                    SqlBulkCopyOptions.TableLock))
            {
                bulkCopy.NotifyAfter = 100;
                bulkCopy.BatchSize = 500;
                ColumnMapping(bulkCopy, sourceTable);
                bulkCopy.DestinationTableName = "eigen_value_decomposition";
                bulkCopy.WriteToServer(sourceTable);
            }
            destinationConnection.Close();

        }
        /// <summary>
        /// Column mapping for sqlbulk copy
        /// </summary>
        /// <param name="bulkCopy">SqlBulkCopy</param>
        /// <param name="dataTable">DataTable</param>
        private static void ColumnMapping(SqlBulkCopy bulkCopy, DataTable dataTable)
        {
            foreach (DataColumn column in dataTable.Columns)
            {
                bulkCopy.ColumnMappings.Add(column.ColumnName, column.ColumnName);
            }
        }

        /// <summary>
        /// Square root of general matrix
        /// </summary>
        /// <param name="generalMatrix">GeneralMatrix</param>
        /// <param name="error">output error true or false</param>
        /// <returns></returns>
        private static GeneralMatrix Sqrt(GeneralMatrix generalMatrix, out bool error)
        {

            int colLength = generalMatrix.ColumnDimension;
            int rowLength = generalMatrix.RowDimension;
            GeneralMatrix R = new GeneralMatrix(rowLength, colLength);
            bool flag = false;
            for (int i = 0; i < rowLength; i++)
            {
                for (int j = 0; j < colLength; j++)
                {
                    double square = Math.Sqrt(generalMatrix.GetElement(i, j));
                    if (double.IsNaN(square))
                    {
                        flag = true;
                        break;
                    }
                    R.SetElement(i, j, square);
                }
                if (flag) break;
            }
            error = flag;
            return R;
        }

        /// <summary>
        /// Browse general matrix sets 0 to negative values
        /// </summary>
        /// <param name="generalMatrix">GeneralMatrix</param>
        /// <param name="endRange">Possible nagative values to set 0</param>
        /// <returns></returns>
        private static GeneralMatrix SetZeroForNegativeEigenValues(GeneralMatrix generalMatrix, double endRange = -2)
        {
            int colLength = generalMatrix.ColumnDimension;
            int rowLength = generalMatrix.RowDimension;
            GeneralMatrix R = generalMatrix;

            for (int i = 0; i < rowLength; i++)
            {
                for (int j = 0; j < colLength; j++)
                {
                    double d = R.GetElement(i, j);
                    if (d != null && (d < 0 && d >= endRange))
                    {
                        R.SetElement(i, j, 0);
                    }
                }

            }
            return R;
        }
        /// <summary>
        /// Get most recent max as of date based on suplied as of date from curve_colrelation table.
        /// </summary>
        /// <param name="asOfDate">As of date</param>
        /// <param name="sc">Valid SqlConnection</param>
        /// <returns>As of date value string</returns>
        private static string GetMostRecentDate(string asOfDate, SqlConnection sc)
        {
            string query =
                "SELECT ISNULL(MAX(as_of_date), '" + asOfDate + "') FROM curve_correlation WHERE as_of_date <='" +
                asOfDate + "'";
            SqlCommand cmd = new SqlCommand(query, sc);
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.HasRows)
                {
                    reader.Read();
                    return reader[0].ToString();
                }
            }
            return asOfDate;
        }

        /// <summary>
        /// Get arrays of curves definition from process table
        /// </summary>
        /// <param name="query">Valid sql query</param>
        /// <param name="processTable">Process table name</param>
        /// <param name="sqlConnection">Valid SqlConnection</param>
        /// <returns></returns>
        private static Curve[] GetCurvesFromProcessTable(string query, string processTable, SqlConnection sqlConnection)
        {
            SqlCommand cmd = new SqlCommand(query + " FROM " + processTable, sqlConnection);
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                Curve[] curves =
                    new List<Curve>().FromDataReader(reader).OrderBy(x => x.CurveId).ThenBy(x => x.Term1).ToArray();
                return curves;
            }
            return null;
        }
        
        /// <summary>
        /// Execute sql queries send result output to sql server 
        /// </summary>
        /// <param name="query"></param>
        /// <param name="sqlConnection"></param>
        private static void ExecuteReader(string query, SqlConnection sqlConnection)
        {
            SqlPipe sp = SqlContext.Pipe;
            SqlCommand cmd = new SqlCommand(query, sqlConnection);
            SqlDataReader reader = cmd.ExecuteReader();
            sp.Send(reader);
            reader.Close();
        }

        /// <summary>
        /// /Performs purge (delete) operation on eigen_value_decomposition table based on criteria or parameter
        /// </summary>
        /// <param name="purge">To purge => y, else n</param>
        /// <param name="asOfDate">asOfDate</param>
        /// <param name="processTable">processTable</param>
        /// <param name="termStart">termStart</param>
        /// <param name="termEnd">termEnd</param>
        /// <param name="sqlConnection">Valid SqlConnection</param>
        /// <param name="criteriaId">0=> delete based on as of date, if purge set to y deletes based on parameter</param>
        private static void PurgeOperations(string purge, string asOfDate, string processTable, string termStart,
            string termEnd, SqlConnection sqlConnection, int criteriaId)
        {

            string query;
            if (criteriaId == 0)
            {
                query = "DELETE FROM eigen_value_decomposition WHERE as_of_date <= '" + asOfDate.ToString() + "'";

                if (purge.ToUpper() != "Y")
                {
                    query = @"DELETE evd FROM eigen_value_decomposition evd " +
                            " CROSS APPLY ( " +
                            " SELECT f.risk_bucket_id     curve_id_from " +
                            " , cto.risk_bucket_id [curve_id_to] " +
                            " , f.volatility_source " +
                            " FROM " + processTable + " f " +
                            " CROSS APPLY ( " +
                            " SELECT risk_bucket_id " +
                            " FROM " + processTable + ") cto " +
                            " ) p " +
                            " WHERE  evd.curve_id_from = p.curve_id_from AND evd.curve_id_to = p.curve_id_to AND evd.curve_source_value_id = p.volatility_source AND  evd.as_of_date = '" +
                            asOfDate + "' AND evd.term1 BETWEEN  '" + termStart + "' AND '" + termEnd +
                            "' AND evd.term2 BETWEEN  '" + termStart + "' AND '" + termEnd + "'";
                }
                sqlConnection.ExecuteQuery(query);

                if (purge.ToUpper() != "Y" && criteriaId > 0)
                {
                    query = @"DELETE FROM eigen_value_decomposition_whatif WHERE criteria_id = " + criteriaId.ToString() + " AND as_of_date <= '" + asOfDate + "'";
                }
                sqlConnection.ExecuteQuery(query);

            }


            if (purge.ToLower() == "y")
            {
                if (criteriaId > 0)
                {
                    query = "DELETE mmvw FROM eigen_value_decomposition_whatif mmvw WHERE mmvw.as_of_date <'" + asOfDate + "'";
                    sqlConnection.ExecuteQuery(query);
                    query = "DELETE mmvw FROM eigen_value_decomposition_whatif mmvw WHERE mmvw.as_of_date ='" + asOfDate +
                            "' AND mmvw.criteria_id =" + criteriaId;
                    sqlConnection.ExecuteQuery(query);
                }
                //else
                //{
                //    query = "DELETE mmv FROM matrix_multiplication_value mmv WHERE run_date <='" + asOfDate + "'";
                //    ExecuteQuery(query, sqlConnection);
                //}
            }
            else
            {
                if (criteriaId > 0)
                {
                    query = "DELETE mmvw FROM eigen_value_decomposition_whatif mmvw WHERE mmvw.as_of_date ='" + asOfDate +
                            "' AND mmvw.criteria_id =" + criteriaId;
                    sqlConnection.ExecuteQuery(query);

                }

            }

        }

        /// <summary>
        /// Validates if curve data existence for curves
        /// </summary>
        /// <param name="curvesInProcess">Curve array</param>
        /// <param name="curveDatas">CurveData array of curve</param>
        /// <param name="processId">Process Id</param>
        /// <param name="asOfDate">As of date</param>
        /// <param name="sc">Valid SqlConnection</param>
        /// <param name="userName">Runtime user</param>
        /// <returns></returns>
        private static bool CurveDataNotExists(Curve[] curvesInProcess, CurveData[] curveDatas, string processId,
            string asOfDate, SqlConnection sc, string userName)
        {
            string query = "";
            bool dontExists = false;
            foreach (Curve curve in curvesInProcess)
            {
                CurveData curveData = curveDatas.FirstOrDefault(x => x.CurveIdFrom == curve.CurveId);
                //  data not found in correlatin according processed curve
                if (curveData == null)
                {
                    dontExists = true;
                    //  Message Log
                    MessageLogs(processId,
                        "Correlation value not found for : " + asOfDate.ToString() + ", curve Id :" +
                        curve.CurveId.ToString(), "", true, sc, userName, "Error", null, true, "Eigen_Correlation");
                }
            }
            if (dontExists)
            {
                //  Message board
                MessageLogs(processId, "Eigen Decomposition Values. (ERRORS found).", "", false, sc, userName, "Error",
                    null, true, "Eigen_Correlation");
            }
            return dontExists;
        }
        /// <summary>
        /// Validates coumt is same for two different curve
        /// </summary>
        /// <param name="curvesFrom">Curve Array</param>
        /// <param name="curvesTo">Curve Array</param>
        /// <returns>Returns true if count is equal for two supplied curves otherwise false</returns>
        private static bool CurveIsSquare(Curve[] curvesFrom, Curve[] curvesTo)
        {
            //  Curve matrices Square
            if (curvesFrom.Count() == curvesTo.Count())
                return true;
            return false;
        }
        /// <summary>
        /// Insert message lo to fas_eff_ass_test_run_log table
        /// </summary>
        /// <param name="processId">Process Id</param>
        /// <param name="messageLogDescription">Message log</param>
        /// <param name="messageBoarddescription">Message board description</param>
        /// <param name="excludeMessageboard">Insert hyperlink message to message board when set to true</param>
        /// <param name="connection">Valid SqlConnection</param>
        /// <param name="userName">Runtime user</param>
        /// <param name="error">Error or Success</param>
        /// <param name="curvesInProcess">Curves Array that has been processed</param>
        /// <param name="showLinkInMessageBoard">True for displaing hyperlink message in message board</param>
        /// <param name="messageType">Message type, possible values Eigen/Cholesky</param>
        /// <param name="module">possible Module name values </param>
        private static void MessageLogs(string processId, string messageLogDescription, string messageBoarddescription,
            bool excludeMessageboard, SqlConnection connection, string userName, string error = "Error",
            Curve[] curvesInProcess = null, bool showLinkInMessageBoard = true, string messageType = "Eigen Values", string module = "Eigen Values")
        {
            string query = "";
            if (messageLogDescription != "")
            {
                query =
                    "INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)";
                query += "SELECT  '" + processId + "', '" + error + "', '" + module + "' , '" + messageType + "', '" +
                         messageType + "', '" + messageLogDescription + "', 'Please check data.'";
                connection.ExecuteQuery(query);
            }
            //  Message Log
            //  Portion multiple log for curves in process
            if (curvesInProcess != null)
            {
                foreach (Curve curve in curvesInProcess)
                {
                    query =
                        "INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, DESCRIPTION, nextsteps)";
                    query += "SELECT  '" + processId + "', '" + error + "', '" + module + "' , '" + messageType + "', '" +
                             messageType + "', '" + messageLogDescription + " " + curve.CurveId.ToString() +
                             "', 'Please check data.'";
                    //  Message Log
                    connection.ExecuteQuery(query);
                }
            }

            //  Message board
            if (!excludeMessageboard)
            {
                string desc = messageBoarddescription;

                string url = "./dev/spa_html.php?__user_name__=" + userName +
                             "&spa=exec spa_fas_eff_ass_test_run_log ''" + processId + "'',''y'',''" + module + "''";
                desc = "'<a target=\"_blank\" href=\"" + url + "\">" + desc + ".</a>'";

                if (!showLinkInMessageBoard)
                    desc = "'" + messageBoarddescription + "'";
                query = "EXEC  spa_message_board 'i', '" + userName + "', NULL, '" + module + "'," + desc +
                        ", '', '', 'e', '" + module + "',NULL,'" + processId + "'";
                connection.ExecuteQuery(query);
            }

        }

        #region Class Declarations

        /// <summary>
        /// Decomposition status various general matrix, sets decomposition type either eigen or singlar. Decomposition status will be used through out eigen calculation process
        /// </summary>
        private class DecompositionStatus
        {
            private string myVar;

            public string Type
            {
                get { return myVar; }
                set
                {
                    myVar = value;
                    if (value.ToLower() == "e") DecompositionType = "Eigen";
                    if (value.ToLower() == "s") DecompositionType = "Singular";
                }
            }

            public string DecompositionType { get; set; }

            public GeneralMatrix Vectors { get; set; }
            public GeneralMatrix Factors { get; set; }
            public GeneralMatrix Values { get; set; }
            public GeneralMatrix MatricesU { get; set; }
            public bool Error { get; set; }
        }
        /// <summary>
        /// This class stores information of curve for specific term
        /// </summary>
        private class Curve
        {
            public DateTime Term1 { get; set; }
            public int CurveId { get; set; }
        }

        /// <summary>
        /// This class stores Curve data
        /// </summary>
        private class CurveData
        {
            public int Id { get; set; }
            public int CurveIdFrom { get; set; }
            public int CurveIdTo { get; set; }
            public DateTime AsOfDate { get; set; }
            public int CurveSourceValueId { get; set; }
            public DateTime Term1 { get; set; }
            public DateTime Term2 { get; set; }
            public double Value { get; set; }
            public virtual double EigenFactor { get; set; }
            public virtual double DValue { get; set; }
            public virtual double VValue { get; set; }
            public virtual double MatrixU { get; set; }
        }

        #endregion
        #endregion


        #region Excel Import
        /// <summary>
        /// Sends list of available worksheet specified excel file to sql server
        /// </summary>
        /// <param name="filename">Excel filename path.</param>
        public static void ExcelSheets(string filename)
        {
            Sheets sheets = null;

            using (SpreadsheetDocument document =
                SpreadsheetDocument.Open(filename, false))
            {
                WorkbookPart wbPart = document.WorkbookPart;
                sheets = wbPart.Workbook.Sheets;
            }
            // define table structure
            SqlDataRecord rec = new SqlDataRecord(new SqlMetaData[] { new SqlMetaData("Sheets", SqlDbType.NVarChar, 1000), });

            // start sending and tell the pipe to use the created record
            SqlContext.Pipe.SendResultsStart(rec);
            {
                // send items step by step
                foreach (Sheet sheet in sheets)
                {
                    rec.SetSqlString(0, sheet.Name.ToString());
                    // send new record/row
                    SqlContext.Pipe.SendResultsRow(rec);
                }
            }
            SqlContext.Pipe.SendResultsEnd();    // finish sending
        }

        /// <summary>
        /// Returns context connection user date format APPLICATION_USERS table
        /// </summary>
        /// <returns>user date format string. Eg. yyyy.mm.dd</returns>
        public static string GetUserDateFormat()
        {
            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=SG-D-SQL02.farrms.us,2033;Initial Catalog=TRMTracker_Release2;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    string sql = @"SELECT date_format
                                    FROM   APPLICATION_USERS AU
                                           INNER JOIN REGION r
                                                ON  r.region_id = AU.region_id
                                                AND AU.user_login_id = dbo.FNADBUser()
                                    ";

                    using (SqlCommand cmd = new SqlCommand(sql, cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            if (rd.HasRows)
                                rd.Read();
                            return rd[0].ToString().Replace("m", "M");
                        }

                    }
                }
                return "yyyy-MM-dd";
            }
            catch (Exception)
            {

                return "yyyy-MM-dd";
            }
        }

        /// <summary>
        /// Import excel worksheet rows to process table
        /// </summary>
        /// <param name="filename">Excel filename</param>
        /// <param name="sheetName">Sheetname</param>
        /// <param name="processTableName">Process table name</param>
        /// <param name="outputResult">Retirns output param message as sucesss or failure message</param>
        /// <param name="formatColumHeaderForXML">formatColumHeaderForXML, possible vaues y/n</param>
        /// <param name="hasColumnHeaders">hasColumnHeaders, possible vaues y/n, if n is set row scan operation will be performed to identify number of columns to create process table. Its better to avoid this feature because it will impact performance of excel import.</param>
        public static void ImportFromExcel(string filename, string sheetName, string processTableName, out string outputResult, string formatColumHeaderForXML = "n", string hasColumnHeaders = "y")
        {
            bool hasHeaders = hasColumnHeaders.ToString().Trim().ToLower() == "y";
            try
            {
                string dateFormat = GetUserDateFormat();
                DataTable dt = new DataTable();

                using (SpreadsheetDocument spreadSheetDocument = SpreadsheetDocument.Open(filename, false))
                {

                    WorkbookPart workbookPart = spreadSheetDocument.WorkbookPart;


                    IEnumerable<Sheet> sheets = spreadSheetDocument.WorkbookPart.Workbook.GetFirstChild<Sheets>().Elements<Sheet>();
                    if (sheetName != "")
                    {
                        if (sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == sheetName.ToLower()) == null)
                        {
                            outputResult = "Invalid Sheet Name";
                            return;
                        }
                    }

                    string relationshipId = sheets.First().Id.Value;
                    if (sheetName != "")
                        relationshipId = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == sheetName.ToLower()).Id.Value;
                    WorksheetPart worksheetPart = (WorksheetPart)spreadSheetDocument.WorkbookPart.GetPartById(relationshipId);
                    Worksheet workSheet = worksheetPart.Worksheet;
                    SheetData sheetData = workSheet.GetFirstChild<SheetData>();
                    IEnumerable<Row> rows = sheetData.Descendants<Row>();

                    string value = "";
                    string columnName = "";
                    int colIndex = 1;
                    if (hasHeaders)
                    {
                        foreach (Cell cell in rows.First().Descendants<Cell>())
                        {
                            columnName = GetCellValue(spreadSheetDocument, cell, false);
                            columnName = (formatColumHeaderForXML == "y" ? columnName.Replace(" ", "_") : columnName);
                            DataColumn datacolumn = new DataColumn(columnName);
                            dt.Columns.Add(datacolumn);
                            colIndex++;
                        }
                    }
                    else
                    {
                        //  determine number of maximum columns
                        int maxColumnIndex = rows.Select(x => x.Descendants<Cell>().Count()).Max();

                        //  Scan rows to identify max no column to populate
                        foreach (Row row in rows)
                        {
                            var cell = row.Descendants<Cell>().Last();
                            int tempMax = (int)GetColumnIndexFromName(GetColumnName(cell.CellReference));
                            if (tempMax > maxColumnIndex)
                                maxColumnIndex = tempMax;
                        }
                        //  Add columns
                        for (int i = 0; i < maxColumnIndex; i++)
                        {
                            columnName = "Column" + (i + 1);
                            DataColumn datacolumn = new DataColumn(columnName);
                            dt.Columns.Add(datacolumn);
                        }
                    }

                    foreach (Row row in rows) //this will also include your header row...
                    {
                        //  if file has header and its first header row skip it otherwise it will include in data row
                        if (hasHeaders && row.RowIndex == 1) continue;
                        //Add rows to DataTable.
                        dt.Rows.Add();
                        int i = 0;
                        int currentColIndex = 1;
                        foreach (Cell cell in row.Descendants<Cell>())
                        {
                            int cellColumnIndex = (int)GetColumnIndexFromName(GetColumnName(cell.CellReference));
                            while (currentColIndex < cellColumnIndex)
                            {
                                dt.Rows[dt.Rows.Count - 1][i] = DBNull.Value;
                                i++;
                                currentColIndex++;
                            }
                            //value = GetValue(spreadSheetDocument, cell, dateFormat);
                            value = GetCellValue(spreadSheetDocument, cell, true, dateFormat);
                            dt.Rows[dt.Rows.Count - 1][i] = value;
                            i++;
                            currentColIndex++;
                        }
                    }
                    string str = "";
                    //using (SqlConnection sqlConnection = new SqlConnection(@"Data Source=PSDL50\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                    using (SqlConnection sqlConnection = new SqlConnection("Context Connection=true"))
                    {
                        sqlConnection.Open();

                        //  Create process table

                        int index = 1;
                        string sql = "IF OBJECT_ID('" + processTableName + "') IS NOT NULL DROP TABLE " + processTableName;
                        sqlConnection.ExecuteQuery(sql);

                        sql = "CREATE TABLE " + processTableName + "(";

                        foreach (DataColumn dtColumn in dt.Columns)
                        {
                            sql += "[" + (formatColumHeaderForXML == "y" ? dtColumn.ColumnName.Replace(" ", "_") : dtColumn.ColumnName) + "] NVARCHAR(MAX)";
                            if (dt.Columns.Count != index)
                                sql += ",";
                            sql += "\r\n";
                            index++;
                        }
                        sql += ")";

                        sqlConnection.ExecuteQuery(sql);

                        using (var adapter = new SqlDataAdapter("SELECT * FROM " + processTableName, sqlConnection))
                        using (var builder = new SqlCommandBuilder(adapter))
                        {
                            adapter.InsertCommand = builder.GetInsertCommand();
                            adapter.Update(dt);
                        }
                        DeleteEmptyRowsOfTable(processTableName, sqlConnection);
                    }
                }
                outputResult = "success";
            }
            catch (Exception ex)
            {

                outputResult = ex.Message;
                ex.LogError("Import from Excel", filename + "|" + sheetName + "|" + processTableName + "|" + outputResult, stackProcess);
            }
        }

        /// <summary>
        /// Delete empty data rows of table
        /// </summary>
        /// <param name="tableName">table name</param>
        /// <param name="sqlConnection">valid SqlConnection</param>
        public static void DeleteEmptyRowsOfTable(string tableName, SqlConnection sqlConnection)
        {
            try
            {
                //  Just load the structure
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM " + tableName + " WHERE 1=2", sqlConnection))
                {
                    string sql = @"DELETE FROM " + tableName + " WHERE ";
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {

                        for (int i = 0; i < rd.FieldCount; i++)
                        {
                            sql += " ISNULL([" + rd.GetName(i) + "],'') = '' +";
                        }
                        rd.Close();
                    }
                    sql = sql.TrimEnd('+').Replace("+", "AND");
                    sqlConnection.ExecuteQuery(sql);
                }
            }
            catch (Exception)
            {

            }
        }
        /*
        private static string GetValue(SpreadsheetDocument document, WorkbookPart workbookPart, Cell cell)
        {
            if (cell.CellValue == null)
                return "";
            if (ExcelHelper.IsDateTimeCell(workbookPart, cell))
            {
                var date = DateTime.FromOADate(cell.CellValue.InnerText.ToDouble());
                return date.ToString("yyyy-MM-dd");
            }
            return GetCellValue(document, cell);
            return cell.CellValue.InnerText;
        }
        */

        /// <summary>
        /// Get cell value 
        /// </summary>
        /// <param name="document">OpenXml Spreadsheet document</param>
        /// <param name="cell">Cell</param>
        /// <param name="formatData">True for formating ole date value</param>
        /// <param name="userDateFormat">User date format</param>
        /// <returns></returns>
        private static string GetCellValue(SpreadsheetDocument document, Cell cell, bool formatData = true, string userDateFormat = null)
        {
            SharedStringTablePart stringTablePart = document.WorkbookPart.SharedStringTablePart;
            if (cell.CellValue == null)
                return "";

            if (cell.DataType != null && cell.DataType == "str")
                return cell.CellValue.InnerXml;

            string value = cell.CellValue.InnerXml;
            value = Convert.ToDouble(value).ToString();// Added to fix decimal value converting to scientific notation value 0.1222= 2.21E+ format

            int numberFormatId;
            if (cell.DataType != null && cell.DataType.Value == CellValues.SharedString)
            {
                return stringTablePart.SharedStringTable.ChildElements[Int32.Parse(value)].InnerText.Trim();
            }
            if (cell.DataType == null && CellWithDate(cell, out numberFormatId))
            {
                var date = DateTime.FromOADate(cell.CellValue.InnerText.ToDouble());
                string result = date.ToString(userDateFormat);
                if (numberFormatId == 20)
                    result = date.ToString("hh:mm");
                else if (numberFormatId == 18)
                    result = date.ToString("hh:mm tt");

                return result;
            }

            if (cell.StyleIndex != null)
            {
                int styleIndex = (int)cell.StyleIndex.Value;
                CellFormat cellFormat = (CellFormat)GetWorkbookPartFromCell(cell).WorkbookStylesPart.Stylesheet.CellFormats.ElementAt(styleIndex);

                if (cellFormat != null && formatData)
                {
                    try
                    {
                        string format =
                        GetWorkbookPartFromCell(cell)
                            .WorkbookStylesPart.Stylesheet.NumberingFormats.Elements<NumberingFormat>()
                            .First(i => i.NumberFormatId.Value == cellFormat.NumberFormatId.Value)
                            .FormatCode;

                        if (format.ToLower().Contains("d") || format.ToLower().Contains("m") || format.ToLower().Contains("y"))
                            return DateTime.FromOADate(cell.CellValue.InnerText.ToDouble()).ToString(format.Replace("m", "M"));
                        else
                        {
                            double number = double.Parse(cell.InnerText);
                            return number.ToString(format);
                        }
                    }
                    catch (Exception)
                    {
                        return value;
                    }
                }
            }
            return value.Trim();
        }
        /// <summary>
        /// Get workbookpart from cell reference
        /// </summary>
        /// <param name="cell">Cell</param>
        /// <returns></returns>
        private static WorkbookPart GetWorkbookPartFromCell(Cell cell)
        {
            Worksheet workSheet = cell.Ancestors<Worksheet>().FirstOrDefault();
            SpreadsheetDocument doc = workSheet.WorksheetPart.OpenXmlPackage as SpreadsheetDocument;
            return doc.WorkbookPart;
        }

        /// <summary>
        /// Determines if cell is part of built in dateformat number 
        /// </summary>
        /// <param name="cell">Cell</param>
        /// <param name="numberFormatId">output parameter number format id</param>
        /// <returns></returns>
        private static bool CellWithDate(Cell cell, out int numberFormatId)
        {
            numberFormatId = 0;
            uint[] builtInDateTimeNumberFormatIDs = new uint[] { 14, 15, 16, 17, 18, 19, 20, 21, 22, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 45, 46, 47, 50, 51, 52, 53, 54, 55, 56, 57, 58 };
            WorkbookPart workbookPart = GetWorkbookPartFromCell(cell);

            if (cell.StyleIndex == null)
                return false;

            int styleIndex = (int)cell.StyleIndex.Value;
            CellFormat cellFormat = (CellFormat)workbookPart.WorkbookStylesPart.Stylesheet.CellFormats.ElementAt(styleIndex);

            if (cellFormat != null)
            {
                numberFormatId = cellFormat.NumberFormatId.ToInt();
                if (builtInDateTimeNumberFormatIDs.Where(x => x.ToInt() == cellFormat.NumberFormatId).Any())
                    return true;
            }

            return false;
        }

        /// <summary>
        /// Get Value from cell
        /// </summary>
        /// <param name="document">SpreadsheetDocument</param>
        /// <param name="cell">Cell</param>
        /// <param name="userDateFormat">User date format eg. yyyy/mm/dd</param>
        /// <returns></returns>
        private static string GetValue(SpreadsheetDocument document, Cell cell, string userDateFormat)
        {
            int formatId = 0;
            if (cell.CellValue == null)
                return "";

            if (cell.DataType != null && cell.DataType.Value == CellValues.SharedString)
            {
                return GetCellValue(document, cell, false);
            }

            if (CellWithDate(cell, out formatId))
            {

                var date = DateTime.FromOADate(cell.CellValue.InnerText.ToDouble());
                string result = date.ToString(userDateFormat);
                if (formatId == 20)
                    result = date.ToString("hh:mm");
                else if (formatId == 18)
                    result = date.ToString("hh:mm tt");
                //else if (formatId == 168)
                //    result = date.ToString("dd-MM-yyyy");
                //else if (formatId == 165)
                //    result = date.ToString("dd.MM.yyyy");
                //else if (formatId == 164)
                //    result = date.ToString("MM-dd-yyyy");
                //else if (formatId == 166)
                //    result = date.ToString("MM/dd/yyyy");
                //else if (formatId == 14)
                //    result = date.ToString("dd/MM/yyyy");
                return result;
            }
            return GetCellValue(document, cell, false);
        }

        /// <summary>
        /// Given a cell name, parses the specified cell to get the column name.
        /// </summary>
        /// <param name="cellReference">Address of the cell (ie. B2)</param>
        /// <returns>Column Name (ie. B)</returns>
        public static string GetColumnName(string cellReference)
        {
            // Create a regular expression to match the column name portion of the cell name.
            Regex regex = new Regex("[A-Za-z]+");
            Match match = regex.Match(cellReference);
            return match.Value;
        }
        /// <summary>
        /// Given just the column name (no row index), it will return the zero based column index.
        /// Note: This method will only handle columns with a length of up to two (ie. A to Z and AA to ZZ). 
        /// A length of three can be implemented when needed.
        /// </summary>
        /// <param name="columnName">Column Name (ie. A or AB)</param>
        /// <returns>Zero based index if the conversion was successful; otherwise null</returns>
        public static int? GetColumnIndexFromName(string columnName)
        {

            //return columnIndex;
            string name = columnName;
            int number = 0;
            int pow = 1;
            for (int i = name.Length - 1; i >= 0; i--)
            {
                number += (name[i] - 'A' + 1) * pow;
                pow *= 26;
            }
            return number;
        }

        /// <summary>
        /// Generate import sample file
        /// </summary>
        /// <param name="sourceFolderName">Takes Single folder name or multiple comma separated file name</param> 
        public static void processImportSampleFile(string sourceFolderName)
        {
            string sourceFileDirectory = "";
            string filePath;
            string result;

            //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL50\INSTANCE2016;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
            using (SqlConnection cn = new SqlConnection("Context Connection=true"))
            {
                cn.Open();
                string sql = @"SELECT document_path FROM connection_string";

                using (SqlCommand cmd = new SqlCommand(sql, cn))
                {
                    using (SqlDataReader rd = cmd.ExecuteReader())
                    {
                        if (rd.HasRows)
                            rd.Read();
                        filePath = rd[0].ToString();
                    }
                }
                cn.Close();
            }

            string[] sourceFileNameArray = sourceFolderName.Split(',');
            string[] filesNotAvailableArray = new string[] { };
            string[] errorSampleFilesArray = new string[] { };

            List<string> listfilesNotAvailable = new List<string>();
            List<string> sourceFilesList = new List<string>(sourceFileNameArray);
            List<string> listErrorSampleFiles = new List<string>();

            string file_unique_dentifier = DateTime.Now.ToString("yyyy_MM_dd_hh_mm_ss");
            string zipFileName = "import_sample_files_" + file_unique_dentifier + ".zip";
            string destinationZipFilePath = filePath + @"\temp_note\" + zipFileName;
            string message = "";
            string generationErrorFiles = "";
            string processTableName = "";
            string fullFolderPathName = "";
            string fullFolderPathRuleName = "";
            string fullFilePathName = "";
            string jsoncontent;
            string sqlQuery;
            string xmlQuery;

            fullFolderPathName = filePath + @"\temp_note\Import_samples_" + file_unique_dentifier + @"\";

            //Create folder "Import_samples_*" inside temp_note to zip it after process completes
            CreateFolder(fullFolderPathName, out message);

            processTableName = "adiha_process.dbo.excel_file_data_" + Guid.NewGuid().ToString().ToUpper().Replace("-", "_");
            try
            {
                for (int i = 0; i < sourceFileNameArray.Length; i++)
                {
                    string fullSourceFileName = sourceFileNameArray[i] + ".xlsx";
                    sourceFileDirectory = filePath + @"\import_samples\" + fullSourceFileName;

                    if (File.Exists(sourceFileDirectory) == false)
                    {
                        listfilesNotAvailable.Add(sourceFileNameArray[i]);
                        sourceFilesList.Remove(sourceFileNameArray[i]);
                    }
                    else
                    {
                        //Create folder with Rule name inside temp_note\"Import_samples_*"  
                        fullFolderPathRuleName = fullFolderPathName + sourceFileNameArray[i];
                        CreateFolder(fullFolderPathRuleName, out message);
                        fullFilePathName = fullFolderPathName + sourceFileNameArray[i] + @"\" + sourceFileNameArray[i];
                        //SendMessage(sourceFileDirectory + "  " + processTableName, true);  

                        Exception exp = new Exception();

                        ImportFromExcel(sourceFileDirectory, "", processTableName, out message, "n");
                        if (message != "success")
                        {
                            exp = new Exception(message);
                            listErrorSampleFiles.Add(sourceFileNameArray[i]);
                            exp.LogError("Download sample file: Insert Excel Data to Process table", sourceFileDirectory + "|" + message);

                        }
                        else
                        {
                            CopyFile(sourceFileDirectory, fullFilePathName + ".xlsx", out message);

                            if (message != "1")
                            {
                                listErrorSampleFiles.Add(sourceFileNameArray[i] + ".xlsx");
                                exp = new Exception(message);
                                exp.LogError("Download sample file: Copy Source Excel file to final folder", message);
                            }

                            sqlQuery = "SELECT * FROM " + processTableName;
                            BuildJson(sqlQuery, "", out jsoncontent);
                            jsoncontent = "{\"import_data\" : " + jsoncontent + "}";
                            WriteToFile(jsoncontent, "", fullFilePathName + ".json", out message);

                            if (message != "1")
                            {
                                listErrorSampleFiles.Add(sourceFileNameArray[i] + ".json");
                                exp = new Exception(message);
                                exp.LogError("Download sample file: Error in creating JSON file", message);

                            }

                            ExportToCsv(processTableName, fullFilePathName + ".csv", "y", ",", "n", "n", "n", "n", out message);

                            if (message != "1")
                            {
                                listErrorSampleFiles.Add(sourceFileNameArray[i] + ".csv");
                                exp = new Exception(message);
                                exp.LogError("Download sample file: Error in creating CSV file", message);
                            }

                            // Replaced space in column name of process table by underscore to create XML file
                            xmlQuery = @"EXEC('
                                            DECLARE @sql_Statement VARCHAR(MAX) 
                                            SELECT @sql_Statement = COALESCE(@sql_Statement + '', '', '''') + ''['' + LOWER(c.name) + ''] AS ['' + REPLACE(LOWER(c.name), '' '', ''_'') + '']''
                                            FROM adiha_process.sys.columns c
                                            WHERE c.object_id = OBJECT_ID(''" + processTableName + "'') "
                                                + " SELECT @sql_Statement = ''SELECT '' + @sql_Statement + '' FROM " + processTableName + "'' "
                                                + " EXEC(@sql_Statement)')";

                            Utility.CreateXMLDocument(xmlQuery, "", "", "-100000", fullFilePathName + ".xml", "n", out message);

                            if (message != "true")
                            {
                                listErrorSampleFiles.Add(sourceFileNameArray[i] + ".xml");
                                exp = new Exception(message);
                                exp.LogError("Download sample file: Error in creating XML file", message);
                            }

                        }
                    }
                }

                using (ZipFile zip = new ZipFile(destinationZipFilePath))
                {
                    zip.AddDirectory(fullFolderPathName);
                    zip.Save();
                }

                result = destinationZipFilePath;

                //Delete the temp folder after compressing it
                if (System.IO.Directory.Exists(fullFolderPathName)) DeleteFolder(fullFolderPathName, out message);

                filesNotAvailableArray = listfilesNotAvailable.ToArray();
                sourceFileNameArray = sourceFilesList.ToArray();
                errorSampleFilesArray = listErrorSampleFiles.ToArray();
                //Console.WriteLine(string.Join(",", filesNotAvailableArray));
                //Console.WriteLine(string.Join(",", sourceFileNameArray));
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL50\INSTANCE2016;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();

                    for (int i = 0; i < filesNotAvailableArray.Length; i++)
                    {
                        message = message + "<li>" + filesNotAvailableArray[i] + "</li>";

                    }

                    for (int i = 0; i < errorSampleFilesArray.Length; i++)
                    {
                        generationErrorFiles = generationErrorFiles + "<li>" + errorSampleFilesArray[i] + "</li>";

                    }

                    if (errorSampleFilesArray.Length > 0)
                    {
                        // if (StoredProcedure.ContextConnection)
                        SqlContext.Pipe.ExecuteAndSend(new SqlCommand("SELECT 'few_file_missing' as result, 'Error occurred while generating import samples: " + generationErrorFiles + " Please consult tech team.' AS message, '" + result + "' AS destination, '" + zipFileName + "' AS output_file_name", cn));
                    }
                    else if (filesNotAvailableArray.Length > 0 && sourceFileNameArray.Length > 0)
                    {
                        // if (StoredProcedure.ContextConnection)
                        SqlContext.Pipe.ExecuteAndSend(new SqlCommand("SELECT 'few_file_missing' as result, 'Sample file(s) for following rule(s) do not exist: " + message + "' AS message, '" + result + "' AS destination, '" + zipFileName + "' AS output_file_name", cn));
                    }
                    else if (filesNotAvailableArray.Length > 0 && sourceFileNameArray.Length == 0)
                    {
                        // if (StoredProcedure.ContextConnection)
                        SqlContext.Pipe.ExecuteAndSend(new SqlCommand("SELECT 'file_missing' as result, 'Sample file(s) for following rule(s) do not exist: " + message + "' AS message, NULL AS destination ", cn));
                    }
                    else
                    {
                        //if (StoredProcedure.ContextConnection)
                        SqlContext.Pipe.ExecuteAndSend(new SqlCommand("SELECT 'success' as result, '" + result + "' AS destination, '" + zipFileName + "' AS output_file_name", cn));
                    }

                    cn.Close();
                }
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Download sample file ", sourceFileDirectory + "|" + result);

                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL50\INSTANCE2016;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    //if (StoredProcedure.ContextConnection)
                    SqlContext.Pipe.ExecuteAndSend(new SqlCommand("SELECT 'error' as result, '" + result + "' AS message, NULL AS destination", cn));
                    cn.Close();
                }
            }
        }

        #endregion

        #region Export / Import CSV

        /// <summary>
        /// Export process table or sql query output to csv file
        /// </summary>
        /// <param name="tableName">Table name / Sql query</param>
        /// <param name="exportFileName">CSV export file location</param>
        /// <param name="includeColumnHeaders">y-> include header, n-> discard header from csv file</param>
        /// <param name="delimiter">csv delimiter string</param>
        /// <param name="compressFile">Compress after csv export file. possible value y/n</param>
        /// <param name="useDateConversion">convert datetime column to user date format</param>
        /// <param name="stripHtml">Strip html content from data, possible value y/n</param>
        /// <param name="enclosedWithQuotes">Enclosed data with double quotes. possible value y/n</param>
        /// <param name="result">1 for success process otherwise failure exception message</param>
        /// <param name="decimalSeparator">Set decimal separator for decimal data type column, if left null or empty it will reterive from user profile, default . will be used</param>
        [SqlProcedure]
        public static void ExportToCsv(string tableName, string exportFileName, string includeColumnHeaders, string delimiter, string compressFile, string useDateConversion, string stripHtml, string enclosedWithQuotes, out string result, string decimalSeparator = null)
        {
            string query = "";
            //  check if sql query was supplied instead of table name
            if (tableName.ToLower().Contains("select") || tableName.ToLower().Contains("exec"))
                query = tableName;
            string enclosingChar = "";
            if (enclosedWithQuotes.Replace("1", "y").ToLower() == "y")
                enclosingChar = "\"";

            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=SG-D-SQL02.farrms.us,2034;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))

                {
                    cn.Open();
                    //  Get user decimal separator from profile, company info
                    if (string.IsNullOrEmpty(decimalSeparator))
                    {
                        string sqlQuery = @"SELECT COALESCE(au.decimal_separator, r.decimal_separator, '.') [decimal_separator]
                                    FROM application_users AU
                                         OUTER apply(SELECT ci.decimal_separator FROM   company_info ci) r
                                    WHERE  AU.user_login_id = dbo.Fnadbuser() ";
                        using (var cmd1 = new SqlCommand(sqlQuery, cn))
                        {
                            using (SqlDataReader rd = cmd1.ExecuteSessionReader())
                            {
                                if (rd.HasRows)
                                {
                                    while (rd.Read())
                                        decimalSeparator = rd["decimal_separator"].ToString();
                                }
                                else
                                    decimalSeparator = ".";
                            }
                        }
                    }
                    
                    NumberFormatInfo nfi = new NumberFormatInfo() { NumberDecimalSeparator = decimalSeparator, CurrencyDecimalSeparator = decimalSeparator, PercentDecimalSeparator = decimalSeparator };

                    //  Just to load the column shchema information to build select query 
                    SqlCommand cmd = new SqlCommand("select TOP 1 * from " + tableName, cn);
                    DataTable dt = new DataTable();

                    if (!tableName.ToLower().Contains("select") && !tableName.ToLower().Contains("exec"))
                    {
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            sda.Fill(dt);
                        }

                        //  cannot load schema information when custom select query is specified perform custom conversion within select query 
                        query = BuildSelect(dt, tableName, useDateConversion);

                    }

                    using (StreamWriter sw = new StreamWriter(exportFileName, false, Encoding.UTF8))
                    {
                        if (delimiter.ToLower() == "tab")
                            delimiter = "\t";
                        //  cannot load schema information when custom select query is specified perform custom conversion within select query 
                        if (!tableName.ToLower().Contains("select") && !tableName.ToLower().Contains("exec"))
                            query = BuildSelect(dt, tableName, useDateConversion);


                        cmd = new SqlCommand(query, cn);
                        dt = new DataTable();
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            sda.Fill(dt);
                        }

                        //  Column cofigurations
                        if (includeColumnHeaders.Replace("1", "y").ToLower() == "y")
                            sw.WriteLine(ColumnNames(dt, delimiter, enclosingChar));

                        foreach (DataRow row in dt.Rows)
                        {
                            string strRow = "";
                            for (int i = 0; i < dt.Columns.Count; i++)
                            {
                                string value = row[i].ToString();
                                if (dt.Columns[i].DataType == Type.GetType("System.Decimal") || dt.Columns[i].DataType == Type.GetType("System.Double"))
                                    value = Convert.ToString(row[i], nfi);

                                if (stripHtml.ToLower().Replace("1", "y") == "y")
                                    strRow += enclosingChar + StripHtml(value.Replace("\"", "\"\"")) + enclosingChar;
                                else
                                {
                                    strRow += enclosingChar + value.Replace("\"", "\"\"") + enclosingChar;
                                }
                                if (i < dt.Columns.Count - 1)
                                {
                                    strRow += delimiter.ToString();
                                }
                            }
                            sw.WriteLine(strRow);
                        }

                        sw.Close();
                        sw.Dispose();
                        cn.Close();
                    }
                    //  Compress File
                    if (compressFile.ToString().ToLower() == "y")
                    {
                        string extension = Path.GetExtension(exportFileName);
                        Utility.FileCompression(exportFileName, exportFileName.ToLower().Replace(extension, ".zip"));
                    }

                    result = "1";
                }

            }
            catch (Exception ex)
            {
                //SendResultRowMessage(ex.Message, cols);
                //  Raise error is used because this procedure is called from job to track error
                result = ex.Message;
                ex.LogError("Export to Csv", tableName + "|" + exportFileName + "|" + includeColumnHeaders + "|" + delimiter + "|" + compressFile + "|" + useDateConversion + "|" + stripHtml + "|" + enclosedWithQuotes + "|" + result);
                SqlPipe sp = SqlContext.Pipe;
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    sp.ExecuteAndSend(new SqlCommand("RAISEERROR ('" + ex.Message + "', 16, 1", cn));
                    cn.Close();
                }

            }

        }
        /// <summary>
        /// Build select statement from supplied databale
        /// </summary>
        /// <param name="dataTable">DataTable</param>
        /// <param name="tableName">Table name</param>
        /// <param name="useDateConversion">y-> Convert column to date format.</param>
        /// <returns></returns>
        private static string BuildSelect(DataTable dataTable, string tableName, string useDateConversion)
        {
            string strOut = "SELECT ";

            for (int i = 0; i < dataTable.Columns.Count; i++)
            {
                //  for dump csv 2
                if (useDateConversion.ToLower().Replace("1", "y") == "y")
                {
                    if (dataTable.Columns[i].DataType.Name == "DateTime")
                        strOut += "dbo.FNADateFormat([" + dataTable.Columns[i] + "]) [" + dataTable.Columns[i] + "]";
                    else
                        strOut += "[" + dataTable.Columns[i] + "]";
                }
                else
                {
                    strOut += "[" + dataTable.Columns[i] + "]";
                }

                if (i < dataTable.Columns.Count - 1)
                {
                    strOut += ",";
                }
            }
            return strOut + " FROM " + tableName;

        }

        /// <summary>
        /// Send message data output to sql server.
        /// </summary>
        /// <param name="message">Message to send</param>
        /// <param name="sqlMetaData">SqlMetaData</param>
        private static void SendResultRowMessage(string message, SqlMetaData[] sqlMetaData)
        {
            SqlPipe sp = SqlContext.Pipe;
            SqlDataRecord rec = new SqlDataRecord(sqlMetaData);
            rec.SetSqlString(0, message);
            sp.SendResultsStart(rec);
            sp.SendResultsRow(rec);
        }

        /// <summary>
        /// Returns data table column header name to be exported in csv header
        /// </summary>
        /// <param name="dataTable">Datatable</param>
        /// <param name="delimiter">csv delimiter</param>
        /// <param name="enclosingChar">Column name enclosing char. Eg double quote</param>
        /// <returns></returns>
        private static string ColumnNames(DataTable dataTable, string delimiter, string enclosingChar)
        {
            string strOut = "";
            if (delimiter.ToLower() == "tab")
            {
                delimiter = "\t";
            }

            for (int i = 0; i < dataTable.Columns.Count; i++)
            {
                strOut += enclosingChar + dataTable.Columns[i].ToString() + enclosingChar;
                if (i < dataTable.Columns.Count - 1)
                {
                    strOut += delimiter;
                }

            }
            return strOut;
        }

        /// <summary>
        /// Stripout html content from html string content
        /// </summary>
        /// <param name="htmlContent">Html Contents</param>
        /// <returns>Returns plain text with stripping html</returns>
        private static string StripHtml(string htmlContent)
        {
            char[] array = new char[htmlContent.Length];
            int arrayIndex = 0;
            bool inside = false;

            for (int i = 0; i < htmlContent.Length; i++)
            {
                char let = htmlContent[i];
                if (let == '<')
                {
                    inside = true;
                    continue;
                }
                if (let == '>')
                {
                    inside = false;
                    continue;
                }
                if (!inside)
                {
                    array[arrayIndex] = let;
                    arrayIndex++;
                }
            }
            return new string(array, 0, arrayIndex);
        }

        /// <summary>
        /// Import from csv file using sql bulk copy
        /// </summary>
        /// <param name="csvFilePath">CSV file path</param>
        /// <param name="processTableName">Process table name to dump the records of file</param>
        /// <param name="delimeter">csv dilimiter</param>
        /// <param name="rowTerminator">csv data terminator</param>
        /// <param name="hasColumnHeaders">y if csv file has column header otherwise n</param>
        /// <param name="hasFieldsEnclosedInQuotes">y if data is wraped with double quotes </param>
        /// <param name="includeFileName">y for Include file name column to process table after import is done </param>
        /// <param name="result">success or failure message</param>
        /// <param name="formatColumHeaderForXML">formatColumHeaderForXML</param>
        public static void ImportFromCSV(string csvFilePath, string processTableName, string delimeter,
            string rowTerminator, string hasColumnHeaders, string hasFieldsEnclosedInQuotes, string includeFileName, out string result, string formatColumHeaderForXML = "n")
        {


            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDD10\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    bool enclosedInQuotes = hasFieldsEnclosedInQuotes.ToString().Trim().ToLower() == "y";
                    bool hasHeaders = hasColumnHeaders.ToString().Trim().ToLower() == "y";
                    bool includeFilename = includeFileName.ToString().Trim().ToLower() == "y";


                    //SqlConnection cn = new SqlConnection(
                    //        @"Data Source=PSLDEV10\INSTANCE2012;Initial Catalog=TRMTracker_New_Framework_Branch;Persist Security Info=True;User ID=farrms_admin;password=Admin2929");
                    //cn.Open();

                    //  Column Configurations only 
                    string[] colFields = null;
                    using (TextFieldParser csvReader = new TextFieldParser(csvFilePath.ToString()))
                    {
                        csvReader.SetDelimiters(new string[] { delimeter.ToString() });
                        csvReader.HasFieldsEnclosedInQuotes = enclosedInQuotes;
                        colFields = csvReader.ReadFields();
                    }

                    for (int i = 0; i < colFields.Count(); i++)
                    {
                        colFields[i] = (formatColumHeaderForXML == "y" ? colFields[i].Replace(" ", "_") : colFields[i]);
                        colFields[i] = Regex.Replace(colFields[i], @"[^\x00-\x7F]+", ""); // replaced unicode characters like xa0 character - Unicode non-breaking space
                    }

                    //  Create process table 
                    string sql = "IF OBJECT_ID('" + processTableName + "') IS NOT NULL DROP TABLE " + processTableName;
                    cn.ExecuteQuery(sql);

                    int index = 1;
                    sql = "CREATE TABLE " + processTableName + "(";
                    for (int i = 0; i < colFields.Count(); i++)
                    {
                        if (hasHeaders)
                            sql += "[" + colFields[i] + "] NVARCHAR(MAX)";
                        else
                        {
                            sql += "column" + index.ToString() + " NVARCHAR(MAX)";
                        }

                        if (i != colFields.Count() - 1)
                            sql += ",";
                        sql += "\r\n";
                        index++;
                    }


                    sql += ")";
                    cn.ExecuteQuery(sql);

                    sql = "spa_bulk_insert '" + csvFilePath + "','" + @processTableName + "','" + delimeter + "','" +
                                 rowTerminator + "','" + hasColumnHeaders + "','" + hasFieldsEnclosedInQuotes + "'";

                    cn.ExecuteQuery(sql);
                    //  if csv file has column headers delete that row from data table
                    if (hasHeaders)
                    {
                        sql = "DELETE FROM " + @processTableName + " WHERE ";
                        for (int i = 0; i < colFields.Count(); i++)
                        {
                            sql += " [" + colFields[i] + "] LIKE '%" + colFields[i] + "%'";
                            if (i != colFields.Count() - 1)
                                sql += " AND";
                        }
                        cn.ExecuteQuery(sql);
                    }
                    //  if data is enclosed with quotes remove it
                    //  last column data terminator may contain carriage return , line feed
                    if (enclosedInQuotes)
                    {
                        sql = "UPDATE " + processTableName + " SET ";
                        for (int i = 0; i < colFields.Count(); i++)
                        {
                            sql += " [" + colFields[i] +
                                   "] = CASE WHEN RIGHT(REPLACE(REPLACE(CASE WHEN LEFT([" + colFields[i] + "], 1)='\"' THEN SUBSTRING([" + colFields[i] + "], 2, LEN([" + colFields[i] + "]))ELSE [" + colFields[i] + "] END,CHAR(10),''),CHAR(13),''),1)='\"' THEN SUBSTRING(REPLACE(REPLACE(CASE WHEN LEFT([" + colFields[i] + "], 1)='\"' THEN SUBSTRING([" + colFields[i] + "], 2, LEN([" + colFields[i] + "]))ELSE [" + colFields[i] + "] END,CHAR(10),''),CHAR(13),''),0,LEN(REPLACE(REPLACE(CASE WHEN LEFT([" + colFields[i] + "], 1)='\"' THEN SUBSTRING([" + colFields[i] + "], 2, LEN([" + colFields[i] + "]))ELSE [" + colFields[i] + "] END,CHAR(10),''),CHAR(13),'')))ELSE [" + colFields[i] + "] END";
                            if (i != colFields.Count() - 1)
                                sql += " ,";
                        }
                        cn.ExecuteQuery(sql);
                    }
                    DeleteEmptyRowsOfTable(processTableName, cn);
                    //  if filename column is included add one extra column
                    if (includeFilename)
                    {
                        sql = "IF COL_LENGTH('" + processTableName + "', 'import_file_name') IS NULL BEGIN ALTER TABLE " + processTableName + " ADD import_file_name NVARCHAR(2000) END";
                        cn.ExecuteQuery(sql);
                        sql = "UPDATE " + processTableName + " SET import_file_name='" + @csvFilePath + "'";
                        cn.ExecuteQuery(sql);
                    }
                    result = "success";
                }

            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Import From CSV", csvFilePath + "|" + processTableName + "|" + delimeter + "|" + rowTerminator + "|" + hasColumnHeaders + "|" + hasFieldsEnclosedInQuotes + "|" + includeFileName + "|" + ex.Message);
            }
        }

        #region lse Import

        /// <summary>
        /// Import LSE meter data files to process table
        /// </summary>
        /// <param name="filePath">LSE full file path</param>
        /// <param name="processTableName">Process table name</param>
        /// <param name="outputResult">Success or failure message</param>
        public static void ImportFromLSE(String filePath, string processTableName, out string outputResult)
        {
            string tableName = processTableName;
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //SqlConnection cn = new SqlConnection(
                //  @"Data Source=192.168.0.9,1444;Initial Catalog=TRMTRACKER_Trunk;Persist Security Info=True;User ID=farrms_admin;password=Admin2929");
                {
                    cn.Open();

                    List<DST> dstDates = new List<DST>();
                    int counter = 0;
                    int j = 0;
                    string line;
                    string[] line_data;
                    string recorder_id = "";
                    string channel = "";
                    string is_dst = "";
                    int current_year = 0;
                    int new_year = 0;
                    DateTime dst_date = Convert.ToDateTime("00:00:00");
                    DateTime date_from = Convert.ToDateTime("00:00:00");
                    DateTime date_to = Convert.ToDateTime("00:00:00");
                    string granularity = "";
                    SqlDataAdapter adapter = new SqlDataAdapter("SELECT * FROM " + tableName, cn);
                    SqlCommandBuilder builder = new SqlCommandBuilder(adapter);
                    DataSet dataSet = new DataSet("dataset");
                    adapter.Fill(dataSet);
                    System.IO.StreamReader file = new System.IO.StreamReader(filePath);

                    while ((line = file.ReadLine()) != null)
                    {
                        j = 1;
                        line = line.TrimEnd();
                        // line_data = line.Split(',').Where(x=> x.Trim() != "" ).ToArray();
                        line_data = line.Split(',');
                        line_data = line_data.Take(line_data.Count() - 1).ToArray();
                        if (line_data[0].ToInt() == 1)
                        {
                            recorder_id = line_data[1];
                            channel = line_data[2];
                            date_from = DateTime.ParseExact(line_data[3], "yyyyMMddHHmmss", null);
                            date_to = DateTime.ParseExact(line_data[4], "yyyyMMddHHmmss", null);
                            is_dst = line_data[5].ToString();
                        }
                        else if (line_data[0].ToInt() == 2)
                        {
                            granularity = line_data[7];
                            if (granularity.ToInt() == 3600)
                            {

                                date_to = date_to.AddHours(-1);
                            }
                            else if (granularity.ToInt() == 900)
                            {
                                date_to = date_to.AddMinutes(-5);
                            }
                            else
                            {
                                date_to = date_to.AddDays(-1);
                            }
                        }
                        else if (line_data[0].ToInt() >= 10000000)
                        {
                            for (int i = 1; i < line_data.Length; i = 3 * (j - 1) + 1)
                            {
                                if (date_from <= date_to)
                                {
                                    if (i == 1 && line_data[0].ToInt() == 10000000)
                                    {
                                        if (granularity.ToInt() == 3600)
                                        {

                                            date_from = date_from.AddHours(0);
                                        }
                                        else if (granularity.ToInt() == 900)
                                        {
                                            date_from = date_from.AddMinutes(0);
                                        }
                                        else
                                        {
                                            date_from = date_from.AddDays(0);
                                        }
                                    }
                                    else if (i >= 1)
                                    {
                                        if (granularity.ToInt() == 3600)
                                        {

                                            date_from = date_from.AddHours(1);
                                        }
                                        else if (granularity.ToInt() == 900)
                                        {
                                            date_from = date_from.AddMinutes(5);
                                        }
                                        else
                                        {
                                            date_from = date_from.AddDays(1);
                                        }
                                    }
                                    AddToDataset(adapter, dataSet, recorder_id, channel.ToInt().ToString(), date_from.ToString("yyyy-MM-dd HH:mm:ss.fff"), date_from.Hour.ToString(), date_from.Minute.ToString(), line_data[i].ToDecimal().ToString(), "0");
                                    current_year = date_from.Year;
                                    DST d = new DST();
                                    d = dstDates.Where(x => x.Year == current_year).FirstOrDefault();
                                    if (d != null)
                                        dst_date = d.EndDate;
                                    else
                                    {
                                        d = GetDSTDate(current_year, cn);
                                        if (d != null)
                                        {
                                            dst_date = d.EndDate;
                                            dstDates.Add(d);
                                            current_year = new_year;
                                        }
                                    }
                                    if (is_dst == "Y" && dst_date.Date == date_from.Date && date_from.Hour == 3)
                                    {
                                        AddToDataset(adapter, dataSet, recorder_id, channel.ToString(), date_from.ToString("yyyy-MM-dd HH:mm:ss.fff"), date_from.Hour.ToString(), date_from.Minute.ToString(), line_data[i].ToDecimal().ToString(), "1");
                                    }
                                }

                                j++;
                            }
                        }
                        else
                        {
                        }
                        counter++;
                    }
                    file.Close();
                    //adapter.UpdateBatchSize = 1000;
                    adapter.Update(dataSet);
                    outputResult = "Success";
                }
            }

            //SqlConnection cn = new SqlConnection(
            //      @"Data Source=192.168.0.9,1444;Initial Catalog=TRMTRACKER_Branch;Persist Security Info=True;User ID=farrms_admin;password=Admin2929");

            catch (Exception ex)
            {

                ex.LogError("Import LSE To Table", tableName.ToString() + "|" + filePath.ToString());
                outputResult = "Error";
            }
        }

        /// <summary>
        /// Add lse data sql dataset table
        /// </summary>
        /// <param name="adpater">SqlDataAdapter</param>
        /// <param name="ds">DataSet</param>
        /// <param name="meter_id"></param>
        /// <param name="channel"></param>
        /// <param name="date"></param>
        /// <param name="hour"></param>
        /// <param name="period"></param>
        /// <param name="Volume"></param>
        /// <param name="is_dst"></param>
        private static void AddToDataset(SqlDataAdapter adpater, DataSet ds, string meter_id, string channel, string date, string hour, string period, string Volume, string is_dst)
        {
            DataRow row = ds.Tables[0].NewRow();
            row["meter_id"] = meter_id;
            row["channel"] = channel;
            row["date"] = date;
            row["hour"] = hour;
            row["period"] = period;
            row["Volume"] = Volume;
            row["is_dst"] = is_dst;
            ds.Tables[0].Rows.Add(row);
        }
        /// <summary>
        /// Get DST date for supplied year
        /// </summary>
        /// <param name="current_year">Year string</param>
        /// <param name="cnn">Valid SqlConnection</param>
        /// <returns>DST</returns>
        public static DST GetDSTDate(int current_year, SqlConnection cnn)
        {
            DateTime dst_date = Convert.ToDateTime("00:00:00");
            DST d = new DST();
            string query = "EXEC spa_daylight_saving_time '" + current_year + "'";
            SqlCommand cmd = new SqlCommand(query, cnn);
            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.HasRows)
                {
                    reader.Read();
                    dst_date = Convert.ToDateTime(reader[3]);
                    d.Year = current_year;
                    d.EndDate = dst_date;
                    return d;
                }
            }

            return null;
        }

        #endregion
        /// <summary>
        /// Import csv file to table using csv reader
        /// </summary>
        /// <param name="userName">runtime user</param>
        /// <param name="csvFilePath">csv full file path</param>
        /// <param name="delimeter">delimiter</param>
        /// <param name="hasFieldsEnclosedInQuotes"> y if field is enclosed with double quotes</param>
        /// <param name="hasColumnHeaders">y if csv file has headers</param>
        public static void ImportCsvToTable(SqlString userName, SqlString csvFilePath, SqlString delimeter,
            SqlString hasFieldsEnclosedInQuotes, SqlString hasColumnHeaders)
        {
            SqlMetaData[] cols = new SqlMetaData[1];
            cols[0] = new SqlMetaData("result", SqlDbType.NVarChar, 2048);


            bool enclosedInQuotes = hasFieldsEnclosedInQuotes.ToString().Trim().ToLower() == "y";
            bool hasHeaders = hasColumnHeaders.ToString().Trim().ToLower() == "y";



            //string connectionString =
            //    @"user id=farrms_admin;password=Admin2929;initial catalog=adiha_process;data source=PSLDEV10\INSTANCE2012";
            //SqlConnection connection = new SqlConnection(connectionString);
            //connection.Open();
            DataTable csvData = new DataTable();
            try
            {
                using (SqlConnection connection = new SqlConnection("Context Connection=true"))
                {
                    connection.Open();
                    using (TextFieldParser csvReader = new TextFieldParser(csvFilePath.ToString()))
                    {
                        csvReader.SetDelimiters(new string[] { delimeter.ToString() });
                        csvReader.HasFieldsEnclosedInQuotes = enclosedInQuotes;
                        string[] colFields = csvReader.ReadFields();

                        int index = 1;
                        foreach (string column in colFields)
                        {
                            DataColumn datacolumn = new DataColumn(column);
                            if (!hasHeaders)
                                datacolumn.ColumnName = "column_" + index.ToString();
                            datacolumn.AllowDBNull = true;
                            csvData.Columns.Add(datacolumn);
                            index++;
                        }

                        while (!csvReader.EndOfData)
                        {
                            string[] fieldData = csvReader.ReadFields();
                            //Making empty value as null
                            for (long i = 0; i < fieldData.Length; i++)
                            {
                                if (fieldData[i] == "")
                                {
                                    fieldData[i] = null;
                                }
                            }
                            csvData.Rows.Add(fieldData);
                        }
                    }

                    //  Create Table in Database according to datacolumns
                    string tableName = "adiha_process.dbo.IMPORT_DATA_" + userName.ToString().ToUpper() + "_" + Guid.NewGuid().ToString().ToUpper().Replace("-", "_");
                    CreateSqlTableFromDataTable(csvData, tableName, connection);
                    SendResultRowMessage("success", cols);
                }

            }
            catch (Exception ex)
            {
                ex.LogError("Import CSV To Table", userName.ToString() + "|" + csvFilePath.ToString() + "|" + delimeter.ToString() + "|" + hasFieldsEnclosedInQuotes.ToString() + "|" + hasColumnHeaders.ToString());
                SendResultRowMessage(ex.Message, cols);
            }
        }
        /// <summary>
        /// create table from data table oject.
        /// </summary>
        /// <param name="dataTable">DataTable</param>
        /// <param name="tableName">sql table name</param>
        /// <param name="connection">valid SqlConnection</param>
        private static void CreateSqlTableFromDataTable(DataTable dataTable, string tableName, SqlConnection connection)
        {
            string ctStr = "CREATE TABLE " + tableName + "(\r\n";

            for (int i = 0; i < dataTable.Columns.Count; i++)
            {
                ctStr += "  [" + dataTable.Columns[i].ToString() + "][nvarchar](4000) NULL";
                if (i != dataTable.Columns.Count - 1)
                    ctStr += ",";
                ctStr += "\r\n";
            }
            ctStr += ")";

            SqlCommand command = new SqlCommand(ctStr, connection);
            command.ExecuteNonQuery();
            ImportToTable(dataTable, connection, tableName);
        }

        /// <summary>
        /// Performs bulkcopy operation
        /// </summary>
        /// <param name="csvFileData">Source data table</param>
        /// <param name="sqlConnection">Valid sqlconnection</param>
        /// <param name="tableName">destination table</param>
        private static void ImportToTable(DataTable csvFileData, SqlConnection sqlConnection, string tableName)
        {
            using (SqlBulkCopy bulkCopy = new SqlBulkCopy(sqlConnection))
            {
                bulkCopy.BatchSize = 1000;
                bulkCopy.DestinationTableName = tableName;
                foreach (var column in csvFileData.Columns)
                    bulkCopy.ColumnMappings.Add(column.ToString(), column.ToString());
                bulkCopy.WriteToServer(csvFileData);
            }
            sqlConnection.Close();
        }

        #endregion


        #region Miscellenous
        /// <summary>
        /// Generate XML file from table/sqlquery
        /// </summary>
        /// <param name="tableName">Table name</param>
        /// <param name="sqlQuery">Sql select Query</param>
        /// <param name="xml_path">XML filename</param>
        /// <param name="result">returns 1 for success or failure message</param>
        public static void GenerateXML(string tableName, string sqlQuery, string xml_path, out string result)
        {
            if (tableName != null)
                sqlQuery = "select * from " + tableName + " row for xml auto, root('rows'), elements";
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    SqlCommand cmd = new SqlCommand(sqlQuery, cn);
                    XmlReader reader = cmd.ExecuteXmlReader();
                    using (FileStream fs = System.IO.File.Create(xml_path))
                    {
                        using (StreamWriter streamWriter = new StreamWriter(fs))
                        {
                            while (reader.Read())
                            {
                                streamWriter.WriteLine(reader.ReadOuterXml());
                            }
                        }
                    }
                    result = "1";
                    cn.Close();
                    reader.Close();
                }
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("XML Generation", tableName + "|" + sqlQuery + "|" + xml_path + "|" + ex.Message);
            }
        }
        #endregion
        #region File Handling Storedprocedures
        /// <summary>
        /// Moves folder and its contents to destination path
        /// </summary>
        /// <param name="sourceFolder">Source Folder to move</param>
        /// <param name="destinationPath">Full destination path where source folder will be moved</param>
        /// <param name="result">returs 1 or failure message</param>
        public static void MoveFolder(string sourceFolder, string destinationPath, out string result)
        {
            Utility.MoveFolder(sourceFolder, destinationPath, out result);
        }
        /// <summary>
        /// Move file to destination
        /// </summary>
        /// <param name="sourceFile">Source filename to move</param>
        /// <param name="destinationFile">Destination filename</param>
        /// <param name="result">returs 1 or failure message</param>
        public static void MoveFile(string sourceFile, string destinationFile, out string result)
        {
            Utility.MoveFile(sourceFile, destinationFile, out result);
        }
        /// <summary>
        /// Copy source file to destination
        /// </summary>
        /// <param name="sourceFile">Source filename</param>
        /// <param name="destinationFile">Destination filename</param>
        /// <param name="result">returs 1 or failure message</param>
        public static void CopyFile(string sourceFile, string destinationFile, out string result)
        {
            Utility.CopyFile(sourceFile, destinationFile, out result);
        }
        /// <summary>
        /// Moves source file to folder
        /// </summary>
        /// <param name="sourceFile">Source filename to move</param>
        /// <param name="destinationFolderPath">Destination folder</param>
        /// <param name="result">returns -1 -> source file doesnt exist, -2 </param>
        public static void MoveFileToFolder(string sourceFile, string destinationFolderPath, out string result)
        {
            Utility.MoveFileToFolder(sourceFile, destinationFolderPath, out result);
        }

        /// <summary>
        /// Create new folder
        /// </summary>
        /// <param name="folderPath">Folder path where new folder will be created.</param>
        /// <param name="result">1 or failure message</param>
        public static void CreateFolder(string folderPath, out string result)
        {
            Utility.CreateFolder(folderPath, out result);

        }
        /// <summary>
        /// Create new file
        /// </summary>
        /// <param name="fileName">Filename to create</param>
        /// <param name="result">1 or failure message</param>
        public static void CreateFile(string fileName, out string result)
        {
            Utility.CreateFile(fileName, out result);
        }

        /// <summary>
        /// Write string contents to file
        /// </summary>
        /// <param name="content">Content to write</param>
        /// <param name="appendContent">y for appending content to file else write content omitting the old one</param>
        /// <param name="fileName">Full filename</param>
        /// <param name="result">returns 1 for success else failure </param>
        public static void WriteToFile(string content, string appendContent, string fileName, out string result)
        {
            Utility.WriteToFile(content, appendContent, fileName, out result);
        }

        /// <summary>
        /// Delete file
        /// </summary>
        /// <param name="fileName">Filename to delete</param>
        /// <param name="result">returns 1 for success, -1 if file doesnt exist else failure</param>
        public static void DeleteFile(string fileName, out string result)
        {
            Utility.DeleteFile(fileName, out result);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="folderPath"></param>
        /// <param name="result"></param>
        public static void DeleteFolder(string folderPath, out string result)
        {
            Utility.DeleteFolder(folderPath, out result);
        }
        #endregion

        #region Compression
        /// <summary>
        /// Compress folder 
        /// </summary>
        /// <param name="folderPath">Source flder to compress</param>
        /// <param name="zipFileName">Compressed filename</param>
        /// <param name="result">returns 1 for success else failure</param>
        public static void CompressFolder(string folderPath, string zipFileName, out string result)
        {
            Utility.CompressFolder(folderPath, zipFileName, out result);
        }

        /// <summary>
        /// Compress file
        /// </summary>
        /// <param name="filename">Source filename to compress</param>
        /// <param name="zipFileName">Compressed zip filename</param>
        /// <param name="result">returns 1 for success else failure</param>
        public static void CompressFile(string filename, string zipFileName, out string result)
        {
            Utility.CompressFile(filename, zipFileName, out result);
        }
        #endregion

        #region SSRS Funcationalities
        public static void DownloadRdl(string reportName)
        {
            SqlDataRecord rec;
            // define table structure
            rec =
                new SqlDataRecord(new SqlMetaData[]
                {
                    new SqlMetaData("status", SqlDbType.NVarChar, SqlMetaData.Max),
                    new SqlMetaData("rdl_filename", SqlDbType.Text, SqlMetaData.Max)

                });
            try
            {
                FARRMS.WebServices.SSRS ssrs = new SSRS();
                ssrs.DownloadRdl(reportName);
            }
            catch (Exception ex)
            {
                SqlContext.Pipe.SendResultsStart(rec);
                rec.SetSqlString(0, ex.Message);
                rec.SetSqlString(1, "");
                SqlContext.Pipe.SendResultsRow(rec);
                SqlContext.Pipe.SendResultsEnd();    // finish sending
                ex.LogError("DownloadRdl", reportName);
            }
        }

        /// <summary>
        /// Export SSRS report to html format
        /// </summary>
        /// <param name="serverUrl">SSRS url</param>
        /// <param name="userName">SSRS username</param>
        /// <param name="password">SSRS password</param>
        /// <param name="domain">SSRS domain, if domain doesnt exist left blank</param>
        /// <param name="reportName">ssrs report name to export</param>
        /// <param name="reportParameters">Additinal report parameters that are part of report rdl</param>
        /// <param name="deviceInfo">Device info for report rendering</param>
        /// <param name="sortXml">Sort xml</param>
        /// <param name="toggleItem">Toggle item</param>
        /// <param name="documentPath">Document path</param>
        /// <param name="executionId">report Execution id</param>
        /// <param name="export_type">Export type default html</param>
        public static void ExportRdlToHtml(string serverUrl, string userName, string password, string domain, string reportName, string reportParameters, string deviceInfo, string sortXml, string toggleItem, string documentPath, string executionId = "", string export_type = "HTML4.0")
        {
            SqlDataRecord rec;
            // define table structure
            rec = new SqlDataRecord(new SqlMetaData[] { new SqlMetaData("Html", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("TotalPages", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("Status", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("ExecutionID", SqlDbType.NVarChar, SqlMetaData.Max), new SqlMetaData("Message", SqlDbType.NVarChar, SqlMetaData.Max) });

            try
            {
                FARRMS.WebServices.SSRS ssrs = new SSRS();
                ssrs.ExportRdlToHtml(serverUrl, userName, password, domain, reportName, reportParameters, deviceInfo, sortXml, toggleItem, documentPath, executionId, export_type);
            }
            catch (Exception e)
            {

                SqlContext.Pipe.SendResultsStart(rec);
                rec.SetSqlString(0, e.Message);
                rec.SetSqlString(1, "");
                rec.SetSqlString(2, "Error");
                rec.SetSqlString(4, e.Message);
                SqlContext.Pipe.SendResultsRow(rec);
                SqlContext.Pipe.SendResultsEnd();    // finish sending

                e.LogError("Export RDL To HTML - ExportRdlToHtml", serverUrl + "|" + userName + "|" + password + "|" + domain + "|" + reportName + "|" + reportParameters);


            }
        }

        //// <summary>
        ///  This function Generates PDF document Reporting Services RDL.
        /// </summary>
        /// <param name="serverUrl"> URL of Report Server.</param>
        /// <param name="userName"> Report Server username.</param>
        /// <param name="password"> Report Server Password.</param>
        /// <param name="domain"> Report Server Domain.</param>
        /// <param name="reportName"> Report Name .</param>
        /// <param name="reportParameters"> Report Parameter string</param>
        ///  <param name="OutputFileName"> Output File Name.</param>
        public static void GenerateDocFromRDL(string serverUrl, string userName, string password, string domain, string reportName, string reportParameters, string OutputFileFormat, string OutputFileName, string process_id, out string resultOutput)
        {
            try
            {
                SSRS ssrs = new SSRS();
                ssrs.GenerateDocFromRDL(serverUrl, userName, password, domain, reportName, reportParameters, OutputFileFormat, OutputFileName, process_id, out resultOutput);
                resultOutput = "true";
            }
            catch (Exception e)
            {
                resultOutput = e.ToString();
                e.LogError("Generate Document From RDL - SoapException", serverUrl + "|" + userName + "|" + password + "|" + domain + "|" + reportName + "|" + reportParameters + "|" + OutputFileFormat + "|" + OutputFileName + "|" + process_id + e.Message);
            }

        }

        /// <summary>
        /// Deploy ssrs rdl
        /// </summary>
        /// <param name="userName">ssrs username</param>
        /// <param name="password">ssrs password</param>
        /// <param name="hostName">ssrs domain</param>
        /// <param name="serverURL">report service url</param>
        /// <param name="reportTempFolder">connection string document path temp note folder</param>
        /// <param name="reportTargetFolder">ssrs report folder where rdl will be deployed</param>
        /// <param name="dataSource">ssrs report data source</param>
        /// <param name="reportName">report name</param>
        /// <param name="reportDescription">report description</param>
        /// <param name="debugMode">y send print messages in sql server used for debugging purpose</param>
        /// <param name="output">1 for success else failure message</param>
        public static void DeployRDL(string userName, string password, string hostName, string serverURL, string reportTempFolder, string reportTargetFolder, string dataSource, string reportName, string reportDescription, string debugMode, out string output)
        {
            bool _debugMode = debugMode.ToLower() == "y";
            SendMessage("UserName:" + userName + "\r\nPassword:" + password + "\r\nHostName \\ Domain:" + hostName + "\r\nReport Server:" +
                        serverURL + "\r\nTemp Folder:" + reportTempFolder + "\r\nReport Target Folder:" + reportTargetFolder + "\r\nData Source:" + dataSource + "\r\nReport Name:" +
                        reportName + "\r\nReport Description:" + reportDescription, _debugMode);
            try
            {
                SSRS ssrs = new SSRS();
                ssrs.DeployRDL(userName, password, hostName, serverURL, reportTempFolder, reportTargetFolder, dataSource, reportName, reportDescription, debugMode, out output);
                SendMessage("Report deployed successfully.");
            }
            catch (Exception ex)
            {
                output = ex.Message;
                ex.LogError("Deploy RDL to Report Server", userName + "|" + password + "|" + hostName + "|" + serverURL + "|" + reportTempFolder + "|" + reportTargetFolder + "|" + dataSource + "|" + reportName + "|" + reportDescription + "|" + debugMode + "|" + ex.Message);
                SendMessage("ERROR :: Report Creation Failed:" + ex.Message, _debugMode);
                
            }

        }

        #endregion

        /// <summary>
        /// Replace openxml word document xml with custom xml
        /// </summary>
        /// <param name="fileName">Word document file name</param>
        /// <param name="customXML">Custom xml to be replaced</param>
        private static void ReplaceCustomXML(string fileName, string customXML)
        {
            using (WordprocessingDocument wordDoc = WordprocessingDocument.Open(fileName, true))
            {
                MainDocumentPart mainPart = wordDoc.MainDocumentPart;
                mainPart.DeleteParts<CustomXmlPart>(mainPart.CustomXmlParts);
                //Add a new customXML part and then add the content. 
                CustomXmlPart customXmlPart = mainPart.AddCustomXmlPart(CustomXmlPartType.CustomXml);
                //Copy the XML into the new part. 
                using (StreamWriter ts = new StreamWriter(customXmlPart.GetStream())) ts.Write(customXML);
            }
        }

        /// <summary>
        /// Generate open xml word document
        /// </summary>
        /// <param name="doc_location">Document filename</param>
        /// <param name="temp_location">Temp location</param>
        /// <param name="xml_location">XML file location</param>
        /// <param name="result">returns 1 for success else failure</param>
        public static void generatedocument(string doc_location, string temp_location, string xml_location, out string result)
        {
            try
            {
                File.Delete(doc_location);
                File.Copy(temp_location, doc_location);
                string customXml = File.ReadAllText(xml_location);
                ReplaceCustomXML(doc_location, customXml);
                String test = DateTime.Now.ToString("dd-MM-yyy");
                //String output = "C:\\Users\\prajwal-pc\\Desktop\\Research\\Confirmation Letter" + test + ".pdf";

                //System.Windows.Forms.MessageBox.Show(output);
                //ConverttoPDF(@"C:\Users\prajwal-pc\Desktop\Research\Confirmation Letter.docx", @output);
                result = "1";
            }
            catch (Exception ex)
            {
                result = ex.Message;
                ex.LogError("Generate Document", doc_location + "|" + temp_location + "|" + xml_location + "|" + ex.Message);
            }
        }

        

        /// <summary>
        /// Export report manager rfx query to csv format.
        /// </summary>
        /// <param name="rfxParameter">report spa_rfx_query</param>
        /// <param name="outputFormat">output format as csv</param>
        /// <param name="delimeter">csv delimiter</param>
        /// <param name="includeHeader">y for inluding csv header n to exclude</param>
        /// <param name="fileName">csv filename</param>
        /// <param name="process_id">Process id</param>
        /// <returns></returns>
        public static string RfxExport(string rfxParameter, string outputFormat, string delimeter, string includeHeader, string fileName, string process_id)
        {
            try
            {
                string[] arr = rfxParameter.Split(',');
                string dateFormat = null;
                var date = arr.FirstOrDefault(x => x.ToLower().Contains("global_date_format"));
                if (date != null)
                    dateFormat = date.Split(':')[1];

                string sql = UserDefinedFunction.BuildRfxQueryFromReportParameter(rfxParameter, process_id, "n");
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=DB02\INSTANCE2014;Initial Catalog=FASTracker_Master_RWE_DE_UPGRADE;Persist Security Info=True;User ID=sa;password=Pi0neer$123"))
                {
                    cn.Open();
                    if (outputFormat.ToLower() == "csv")
                    {
                        SqlCommand cmd1 = new SqlCommand(sql, cn);
                        SqlDataReader rd = cmd1.ExecuteReader();
                        if (delimeter.ToLower() == "tab")
                            delimeter = "\t";

                        StreamWriter sw = new StreamWriter(fileName, false, Encoding.UTF8);

                        if (includeHeader.Replace("1", "y").ToLower() == "y")
                        {
                            string header = ColumnNamesFromReader(rd, delimeter);
                            sw.WriteLine(header);
                        }


                        while (rd.Read())
                        {
                            string row = "";
                            for (int i = 0; i < rd.FieldCount; i++)
                            {
                                if (dateFormat != null)
                                {
                                    if (rd[i].GetType().Name == "DateTime")
                                    {
                                        row += FormatDate(rd[i].ToString(), dateFormat);
                                    }
                                    else
                                        row += StripHtml(rd[i].ToString());
                                }
                                else
                                {
                                    row += StripHtml(rd[i].ToString());
                                }


                                if (i < (rd.FieldCount - 1))
                                    row += delimeter;
                            }
                            sw.WriteLine(row);
                        }
                        sw.Close();
                        sw.Dispose();
                    }
                    cn.Close();
                }
                return "true";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        /// <summary>
        /// Format date value specified dateformat.
        /// </summary>
        /// <param name="value">Date value</param>
        /// <param name="dateformat">Date format</param>
        /// <returns></returns>
        private static string FormatDate(string value, string dateformat)
        {
            try
            {
                DateTime dt = Convert.ToDateTime(value);
                return dt.ToString(dateformat);
            }
            catch (Exception)
            {
                return value;
            }
        }

        /// <summary>
        /// Dump data to process table based report manager report parameter
        /// </summary>
        /// <param name="reportParameter">report filter</param>
        /// <param name="processId">Process id</param>
        /// <returns>True/False</returns>
        public static string RfxDumpToTable(string reportParameter, string processId)
        {
            try
            {
                string sql = UserDefinedFunction.BuildRfxQueryFromReportParameter(reportParameter, processId, "y");

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    SqlCommand cmd = new SqlCommand(sql, cn);
                    cmd.ExecuteNonQuery();
                }
                return "true";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }

        }

        /// <summary>
        /// Crete xml document table / select query / sp outpout
        /// </summary>
        /// <param name="tableName">Table name / Sql query</param>
        /// <param name="xmlNamespace">Xml namespace to  include in xml doc</param>
        /// <param name="reportName">report name included in xml doc</param>
        /// <param name="standardXml">-100000 for standard node based xml, -100001 for attribute baed xml</param>
        /// <param name="filename">xml file name</param>
        /// <param name="compressFile">y for compressing xml document else file wont be compressed</param>
        /// <param name="result">true for success else failur</param>
        public static void CreateXMLDocument(string tableOrSP, string xmlNamespace, string reportName, string standardXml, string filename, string compressFile, out string result)
        {
            Utility.CreateXMLDocument(tableOrSP, xmlNamespace, reportName, standardXml, filename, compressFile, out result);
        }

        /*
         * Transform XML according to the xslt supplied        
         * effFilePath = File Path of Source XML file
         * xsltPath = Path of XSL file
         * filePath = Destination of Final XML file
         * compressFile = Set y To compress file
         * removeEmptyNodes = Remove empty nodes if the value is set to y
         */
        public static void TransformXML(string effFilePath, string xsltPath, string filePath, string compressFile, string removeEmptyNodes, out string result)
        {
            Utility.TransformXML(effFilePath, xsltPath, filePath, compressFile, removeEmptyNodes, out result);
        }

        /// <summary>
        /// Reversse string
        /// </summary>
        /// <param name="s">string to reverse</param>
        /// <returns>returns reversed string</returns>
        public static string Reverse(string s)
        {
            char[] charArray = s.ToCharArray();
            Array.Reverse(charArray);
            return new string(charArray);
        }

        
        /// <summary>
        /// Get column names from data reader output .
        /// </summary>
        /// <param name="rd">SqlDataReader</param>
        /// <param name="delimiter">csv delimiter</param>
        /// <returns>Column names with delimited char</returns>
        private static string ColumnNamesFromReader(SqlDataReader rd, string delimiter)
        {

            string strOut = "";
            if (delimiter.ToLower() == "tab")
            {
                delimiter = "\t";
            }
            for (int i = 0; i < rd.FieldCount; i++)
            {
                strOut += rd.GetName(i);
                if (i < rd.FieldCount - 1)
                {
                    strOut += delimiter;
                }

            }
            return strOut;
        }

        
        /// <summary>
        /// genetrate document
        /// </summary>
        /// <param name="xmlfile">xml file</param>
        /// <param name="xsdfile">xsd file</param>
        /// <param name="template_name">template name</param>
        /// <param name="filename">output filenam</param>
        /// <param name="template_id">template id</param>
        public static void GenerateDocUsingXML(string xmlfile, string xsdfile, string template_name, string filename, int template_id)
        {
            string sqlquery;
            Dictionary<string, ContentControlXmlMetadata> placeHolderTagToContentControlXmlMetadataCollection = new Dictionary<string, ContentControlXmlMetadata>();

            placeHolderTagToContentControlXmlMetadataCollection.Add(PlaceholderIgnoreA, new ContentControlXmlMetadata() { PlaceHolderName = PlaceholderIgnoreA, Type = PlaceHolderType.Ignore });
            placeHolderTagToContentControlXmlMetadataCollection.Add(PlaceholderIgnoreB, new ContentControlXmlMetadata() { PlaceHolderName = PlaceholderIgnoreA, Type = PlaceHolderType.Ignore });

            // Handle container placeholders            
            placeHolderTagToContentControlXmlMetadataCollection.Add(PlaceholderContainerA, new ContentControlXmlMetadata() { PlaceHolderName = PlaceholderContainerA, Type = PlaceHolderType.Container, ControlTagXPath = "./ID[1]" });

            //SqlConnection sc = new SqlConnection("Context Connection=true");
            //SqlConnection sc = new SqlConnection(@"data source=10.90.124.138\CLR2012;initial catalog=TRMTracker_Trunk;user id=farrms_admin;password=Admin2929");
            //sc.Open();
            try
            {
                using (SqlConnection sc = new SqlConnection("Context Connection=true"))
                {
                    sc.Open();
                    sqlquery = @"SELECT dsc.name name,tvm.tag_name,tvm.recursive  recursive
                            FROM contract_report_template crt 
	                            INNER JOIN contract_report_template_views crtv ON crt.template_id = crtv.template_id
	                            INNER JOIN template_view_mapping tvm ON tvm.contract_template_views_id = crtv.contract_report_template_views_id
	                            INNER JOIN data_source ds ON ds.data_source_id =  crtv.data_source_id
                            	LEFT JOIN data_source_column dsc ON dsc.data_source_column_id = tvm.columns_id
                                WHERE crt.template_id  =" + template_id + @" 
                                UNION ALL                     
                            Select ds.name+'s',ds.name+'s', 1[recursive] FROM  contract_report_template crt 
	                            INNER JOIN contract_report_template_views crtv ON crt.template_id = crtv.template_id
	                            INNER JOIN data_source ds ON ds.data_source_id =  crtv.data_source_id  
                                WHERE crt.template_id  =" + template_id;
                    using (SqlCommand cmd = new SqlCommand(sqlquery, sc))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            List<PlaceHolder> placeHolders = new List<PlaceHolder>();

                            while (reader.Read())
                            {
                                placeHolders.Add(new PlaceHolder() { Name = reader[0].ToString(), TagName = reader[1].ToString(), Recursive = reader[2].ToString() });
                            }
                            foreach (PlaceHolder ph in placeHolders)
                            {
                                if (ph.Recursive == "1")
                                    placeHolderTagToContentControlXmlMetadataCollection.Add(ph.TagName, new ContentControlXmlMetadata() { PlaceHolderName = ph.Name, Type = PlaceHolderType.Recursive, ControlTagXPath = "./Id[1]", ControlValueXPath = "./" + ph.Name + "[1]" });
                                else
                                    placeHolderTagToContentControlXmlMetadataCollection.Add(ph.TagName, new ContentControlXmlMetadata() { PlaceHolderName = ph.TagName, Type = PlaceHolderType.NonRecursive, ControlTagXPath = "./Id[1]", ControlValueXPath = "./" + ph.Name + "[1]" });
                                //index++;
                                //placeHolderTagToContentControlXmlMetadataCollection.Add(PlaceholderNonRecursiveO, new ContentControlXmlMetadata() { PlaceHolderName = PlaceholderNonRecursiveO, Type = PlaceHolderType.NonRecursive, ControlTagXPath = "./Id[1]", ControlValueXPath = "./date[1]" });
                                XmlDocument xmlDoc = new XmlDocument();
                                xmlDoc.Load(xmlfile);
                                xmlDoc.Schemas.Add(null, xsdfile);
                                xmlDoc.Validate(ValidationCallBack, xmlDoc.DocumentElement);
                                DocumentGenerationInfo generationInfo = GetDocumentGenerationInfo("SampleDocumentGeneratorUsingXml", "1.0", xmlDoc.DocumentElement,
                                                                        template_name, false);
                                GenerateDocumentUsingXML GenerateDocumentUsingXML = new GenerateDocumentUsingXML(generationInfo, placeHolderTagToContentControlXmlMetadataCollection);
                                byte[] fileContents = GenerateDocumentUsingXML.GenerateDocument();
                                WriteOutputToFile(filename, template_name, fileContents);
                            }
                            reader.Close();
                        }

                    }
                    sc.Close();
                }
            }

            catch (Exception ex)
            {
                ex.LogError("Generate Document Using XML", xmlfile + "|" + xsdfile + "|" + template_name + "|" + filename + "|" + template_id);
                SqlContext.Pipe.Send(ex.Message);
            }

        }

        /// <summary>
        /// Document place holder
        /// </summary>
        public class PlaceHolder
        {
            public string Name { get; set; }
            public string TagName { get; set; }
            public string Recursive { get; set; }
        }

        /// <summary>
        /// Write byte array output to filename
        /// </summary>
        /// <param name="fileName">output filename</param>
        /// <param name="templateName">template name</param>
        /// <param name="fileContents">file content byte array</param>
        public static void WriteOutputToFile(string fileName, string templateName, byte[] fileContents)
        {

            if (fileContents != null)
            {
                // File.WriteAllBytes(Path.Combine(filePath, fileName), fileContents);
                File.WriteAllBytes(fileName, fileContents);
            }
        }

        private static void ValidationCallBack(object sender, ValidationEventArgs ex)
        {
            ex.Message.ToString();
        }

        /// <summary>
        /// Get document generation info
        /// </summary>
        /// <param name="docType"></param>
        /// <param name="docVersion"></param>
        /// <param name="dataContext"></param>
        /// <param name="fileName"></param>
        /// <param name="useDataBoundControls"></param>
        /// <returns></returns>
        private static DocumentGenerationInfo GetDocumentGenerationInfo(string docType, string docVersion, object dataContext, string fileName, bool useDataBoundControls)
        {
            DocumentGenerationInfo generationInfo = new DocumentGenerationInfo();
            generationInfo.Metadata = new DocumentMetadata() { DocumentType = docType, DocumentVersion = docVersion };
            generationInfo.DataContext = dataContext;
            generationInfo.TemplateData = File.ReadAllBytes(Path.Combine("Sample Templates", fileName));
            generationInfo.IsDataBoundControls = useDataBoundControls;

            return generationInfo;
        }


        #region TRM Push Notifications
        /// <summary>
        /// Post web request
        /// </summary>
        /// <param name="pushPhpUrl">Url to post</param>
        /// <param name="pushXML">Post parameters for web request</param>
        /// <param name="debugMode">y for debugging print message</param>
        /// <param name="result">returns success or failure message</param>
        /// <param name="httpWebResponse">return web response message</param>
        public static void PushNotification(string pushPhpUrl, string pushXML, string debugMode, out string result, out string httpWebResponse, string authorizationType = "noAuth", string accessToken = "")
        {
            bool DebugMode = debugMode.Replace("1", "y") == "y";

            try
            {
                string url = pushPhpUrl;
                //Proper Secure Sockets Layer (SSL) or Transport Layer Security (TLS) protocol to use for new connections 
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);//SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;

                var request = (HttpWebRequest)WebRequest.Create(url);

                request.UseDefaultCredentials = true;
                request.PreAuthenticate = true;
                request.Credentials = CredentialCache.DefaultCredentials;

                // Send authentication token in the header along with the web request if access token is sent in the parameters
                if (authorizationType.ToUpper() == "BEARERTOKEN" && accessToken != "")
                {
                    request.Headers.Add("Authorization", "Bearer " + accessToken);
                }

                //var postData = "push_xml=" + pushXML;
                var postData = pushXML;

                var data = Encoding.ASCII.GetBytes(postData);

                request.Method = "POST";
                request.ContentType = "application/x-www-form-urlencoded";
                request.ContentLength = data.Length;

                using (var stream = request.GetRequestStream())
                {
                    stream.Write(data, 0, data.Length);
                }

                var response = (HttpWebResponse)request.GetResponse();

                string responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();
                SendMessage(responseString, DebugMode);
                result = "success";
                httpWebResponse = responseString;
            }
            catch (Exception ex)
            {
                httpWebResponse = "Http Response Failed.";
                result = ex.Message;
                ex.LogError("Push Notification", pushPhpUrl + "|" + pushXML + "|" + debugMode + "|" + ex.Message);
            }
        }
        #endregion
        #region SSIS Package

        /// <summary>
        /// Send print message to sql server
        /// </summary>
        /// <param name="message">Message to send</param>
        /// <param name="debugMode">y=> print mode on</param>
        public static void SendMessage(string message, bool debugMode = true)
        {
            //  CLR print doesnt support more than 4000
            int lengthToTake = 1000;
            if (debugMode)
            {
                for (int i = 0; i < message.Length; i += lengthToTake)
                {
                    int len = 0;
                    if ((message.Length - i) > lengthToTake)
                        len = lengthToTake;
                    else
                        len = message.Length - i;

                    SqlContext.Pipe.Send(message.Substring(i, len));
                }
            }

        }

        /// <summary>
        /// Executes ssis package using DTEXEC command line arguments
        /// </summary>
        /// <param name="dtsxFileName">SSIS package filename</param>
        /// <param name="packageVairablesValues">Package variables with values</param>
        /// <param name="ssisSystemVariables">Package system variable</param>
        /// <param name="sqlVersion">Sql version eg 2012, 2016 to determine valid dtexec</param>
        /// <param name="bitVersion">Sql bit version</param>
        /// <param name="debugMode">Debug mode</param>
        /// <param name="outputResult">Success or failure message</param>
        public static void ExecuteSSISPackage(string dtsxFileName, string packageVairablesValues, string ssisSystemVariables, string sqlVersion, int bitVersion, string debugMode, out string outputResult)
        {
            bool debug_Mode = debugMode.ToLower() == "y";
            try
            {

                string environment_pats = Environment.GetEnvironmentVariable("path");
                string[] paths = environment_pats.Split(';');
                string[] dtsPath = paths.Where(x => x.ToLower().Contains("dts")).ToArray();

                if (dtsPath.Count() == 0)
                    SendMessage("DTEXEC path configuration missing in path environment variable", debug_Mode);

                DTExec[] dtExecs = new DTExec[dtsPath.Count()];
                int index;

                for (int i = 0; i < dtsPath.Count(); i++)
                {
                    dtExecs[i] = new DTExec() { Path = dtsPath[i], Bit = 0, SQLVersion = "" };
                    if (dtExecs[i].Path.Contains("100") && dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 32;
                        dtExecs[i].SQLVersion = "2008R2";
                    }
                    else if (dtExecs[i].Path.Contains("100") && !dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 64;
                        dtExecs[i].SQLVersion = "2008R2";
                    }
                    else if (dtExecs[i].Path.Contains("120") && !dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 64;
                        dtExecs[i].SQLVersion = "2014";
                    }
                    else if (dtExecs[i].Path.Contains("120") && dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 32;
                        dtExecs[i].SQLVersion = "2014";
                    }
                    else if (dtExecs[i].Path.Contains("110") && !dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 64;
                        dtExecs[i].SQLVersion = "2012";
                    }
                    else if (dtExecs[i].Path.Contains("110") && dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 32;
                        dtExecs[i].SQLVersion = "2012";
                    }
                    else if (dtExecs[i].Path.Contains("130") && !dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 64;
                        dtExecs[i].SQLVersion = "2016";
                    }
                    else if (dtExecs[i].Path.Contains("130") && dtExecs[i].Path.Contains("x86"))
                    {
                        dtExecs[i].Bit = 32;
                        dtExecs[i].SQLVersion = "2016";
                    }
                }

                //  List of DT EXECS
                if (debug_Mode)
                {
                    string dtpaths = "";
                    foreach (DTExec dtExec in dtExecs)
                    {
                        dtpaths += "SQL Version : " + dtExec.SQLVersion + " " + dtExec.Bit.ToString() + " BIT" + dtExec.Path + Environment.NewLine;
                    }
                    if (dtExecs.Count() > 0)
                        SendMessage("List of DTEXEC path configured" + Environment.NewLine + dtpaths, debug_Mode);
                    else
                        SendMessage("There are no any DTEXEC path setup.", debug_Mode);
                }

                DTExec dt = new DTExec();
                //  we have some path
                if (dtExecs.Count() > 0)
                {
                    dt = dtExecs.Where(x => x.Bit == bitVersion && x.SQLVersion == sqlVersion).FirstOrDefault();
                }

                if (dt == null)
                {
                    SendMessage("DTEXEC file not found for " + bitVersion.ToString() + " BIT " + sqlVersion + " Version", debug_Mode);
                    DTExec d = dtExecs.FirstOrDefault();
                    //  none of the supported SQL Server version is found, Instead run the package with available DTExec.exe
                    SendMessage("Using available DTExec: First available in Environment Variable - System Variable Path", debug_Mode);
                    dt = new DTExec() { Bit = bitVersion, Path = d.Path, SQLVersion = sqlVersion };
                }



                string cmd = @" /FILE """ + dtsxFileName + @""" /MAXCONCURRENT "" -1 "" /CHECKPOINTING OFF /REPORTING E";
                string[] sssisParameters = packageVairablesValues.TrimStart(',').Split(',');
                foreach (string sp in sssisParameters)
                {
                    if (sp.Contains("="))
                    {
                        string variable = sp.Substring(0, sp.IndexOf('=')).Trim();
                        string varValue = sp.Substring(sp.IndexOf('=') + 1);
                        cmd += @" /SET ""\Package.Variables[User::" + variable + @"].Properties[Value]"";""" + varValue.Trim() + @"""";
                    }
                    else
                    {
                        cmd = cmd.TrimEnd('"');
                        StringBuilder sb = new StringBuilder(cmd);
                        cmd = sb.Append("," + sp + "\"").ToString();
                    }
                }
                if (ssisSystemVariables != "")
                {
                    cmd += " " + ssisSystemVariables;
                }
                SendMessage("DTEXEC : SQL Version " + dt.SQLVersion + " " + dt.Bit.ToString() + " BIT Path :" + dt.Path + Environment.NewLine + "Command :" + cmd, debug_Mode);

                //  Start Process
                ProcessStartInfo info = new ProcessStartInfo(dt.Path + @"\DTEXEC.exe");
                info.UseShellExecute = false;
                info.RedirectStandardInput = true;
                info.RedirectStandardOutput = true;
                info.RedirectStandardError = true;
                info.Arguments = cmd;
                var process = Process.Start(info);
                string dtexecOutput = process.StandardOutput.ReadToEnd();
                process.WaitForExit();
                if (dtexecOutput.ToUpper().Contains("DTSER_SUCCESS"))
                {
                    outputResult = "Success";
                }
                else
                {
                    outputResult = "Failed";
                }
                SendMessage("\r\n-------------------Package Execution Progress Status Results-------------------\r\n" + dtexecOutput, debug_Mode);




            }
            catch (Exception ex)
            {
                ex.LogError("Execute SSIS Package", dtsxFileName + "|" + packageVairablesValues + "|" + ssisSystemVariables + "|" + sqlVersion + "|" + bitVersion.ToString() + "|" + debugMode + "|" + ex.Message);
                string err = ex.Message;
                if (err.Length > 3000)
                    err = err.Substring(0, 3000) + "...";
                SendMessage("Error Message:" + err, debug_Mode);
                outputResult = "failed";
            }
        }

        /// <summary>
        /// This class holds Dtexec information
        /// </summary>
        private class DTExec
        {
            public string Path { get; set; }
            public int Bit { get; set; }
            public string SQLVersion { get; set; }

        }

        #endregion

        #region Excel Add-in requirements
        /// <summary>
        /// This class contains info about excel addin excel file worksheet
        /// </summary>
        class AddinSheet
        {
            public string ReportName { get; set; }
            public string ReportSheet { get; set; }
            public string SpaRfxParameter { get; set; }
            public string ParameterSheet { get; set; }
            public string ParamsetHash { get; set; }
            public int DocoumentType { get; set; }
        }

        /// <summary>
        /// Get list of excel addin sheets
        /// </summary>
        /// <param name="filename">Excel add-in file</param>
        /// <param name="output">return 1 for success else failure message</param>
        public static void ExcelAddinSheets(string filename, out string output)
        {
            if (UserDefinedFunction.IsFileLocked(filename))
            {
                output = "The file is unavailable or used by another process.";
                return;
            }

            try
            {
                List<string> sheetsList = new List<string>();
                List<AddinSheet> addinSheets = new List<AddinSheet>();
                using (SpreadsheetDocument spreadSheetDocument = SpreadsheetDocument.Open(filename, false))
                {
                    IEnumerable<Sheet> sheets =
                        spreadSheetDocument.WorkbookPart.Workbook.GetFirstChild<Sheets>().Elements<Sheet>();

                    //  list of sheets
                    foreach (Sheet sheet in sheets)
                    {
                        sheetsList.Add(sheet.Name);
                    }

                    //  configuration sheet
                    Sheet sheetConfiguration = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == "configurations");

                    string relationshipId =
                        sheets.FirstOrDefault(
                            x => x.Name.ToString().ToLower() == sheetConfiguration.Name.ToString().ToLower()).Id.Value;
                    WorksheetPart worksheetPart =
                        (WorksheetPart)spreadSheetDocument.WorkbookPart.GetPartById(relationshipId);
                    Worksheet workSheet = worksheetPart.Worksheet;
                    SheetData sheetData = workSheet.GetFirstChild<SheetData>();
                    IEnumerable<Row> rows = sheetData.Descendants<Row>();

                    foreach (Row row in rows)
                    {
                        if (row.RowIndex == 1) continue;

                        AddinSheet addinSheet = new AddinSheet();
                        int i = 1;
                        foreach (Cell cell in row.Descendants<Cell>())
                        {
                            string value = GetCellValue(spreadSheetDocument, cell);
                            switch (i)
                            {
                                case 1:
                                    addinSheet.ReportName = value;
                                    break;
                                case 2:
                                    addinSheet.ReportSheet = value;
                                    break;
                                case 3:
                                    addinSheet.SpaRfxParameter = value;
                                    break;
                                case 4:
                                    addinSheet.ParameterSheet = value;
                                    break;
                                case 7:
                                    addinSheet.ParamsetHash = value;
                                    break;
                                default:
                                    break;
                            }
                            i++;
                        }
                        addinSheet.DocoumentType = 106700; ;
                        addinSheets.Add(addinSheet);
                    }

                    // Invoice configuration sheet
                    sheetConfiguration = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == "invoice configuration");
                    if (sheetConfiguration != null)
                    {
                        relationshipId = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == sheetConfiguration.Name.ToString().ToLower()).Id.Value;
                        worksheetPart =
                            (WorksheetPart)spreadSheetDocument.WorkbookPart.GetPartById(relationshipId);
                        workSheet = worksheetPart.Worksheet;
                        sheetData = workSheet.GetFirstChild<SheetData>();
                        rows = sheetData.Descendants<Row>();

                        foreach (Row row in rows)
                        {
                            if (row.RowIndex == 1) continue;

                            AddinSheet addinSheet = new AddinSheet();
                            int i = 1;
                            foreach (Cell cell in row.Descendants<Cell>())
                            {
                                string value = GetCellValue(spreadSheetDocument, cell);
                                switch (i)
                                {
                                    case 1:
                                        addinSheet.ReportName = value;
                                        addinSheet.ReportSheet = value;
                                        break;
                                    case 2:
                                        addinSheet.SpaRfxParameter = "";
                                        //  2nd data set column can be null
                                        addinSheet.ParameterSheet = value + "_template";
                                        break;
                                    case 3:
                                        addinSheet.ParameterSheet = value + "_template";
                                        break;
                                    default:
                                        break;
                                }
                                i++;
                            }
                            addinSheet.DocoumentType = 106701;
                            addinSheets.Add(addinSheet);
                        }
                    }

                    // Invoice configuration sheet
                    sheetConfiguration = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == "import settings");
                    if (sheetConfiguration != null)
                    {
                        relationshipId = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == sheetConfiguration.Name.ToString().ToLower()).Id.Value;
                        worksheetPart =
                            (WorksheetPart)spreadSheetDocument.WorkbookPart.GetPartById(relationshipId);
                        workSheet = worksheetPart.Worksheet;
                        sheetData = workSheet.GetFirstChild<SheetData>();
                        rows = sheetData.Descendants<Row>();

                        foreach (Row row in rows)
                        {
                            if (row.RowIndex == 1) continue;

                            AddinSheet addinSheet = new AddinSheet();
                            int i = 1;
                            foreach (Cell cell in row.Descendants<Cell>())
                            {
                                string value = GetCellValue(spreadSheetDocument, cell);
                                switch (i)
                                {
                                    case 1:
                                        addinSheet.ReportName = "";
                                        break;
                                    case 2:
                                        addinSheet.ReportSheet = "";
                                        break;
                                    case 3:
                                        addinSheet.SpaRfxParameter = "";
                                        break;
                                    case 4:
                                        addinSheet.ParameterSheet = "";
                                        break;
                                    case 5:
                                        addinSheet.ReportSheet = value;
                                        break;
                                    default:
                                        break;
                                }
                                i++;
                            }
                            addinSheet.DocoumentType = 106702;
                            addinSheets.Add(addinSheet);
                        }
                    }
                }
                // define table structure
                SqlDataRecord rec =
                    new SqlDataRecord(new SqlMetaData[]
                    {
                        new SqlMetaData("excel_sheet_name", SqlDbType.NVarChar, 1000),
                        new SqlMetaData("report_name", SqlDbType.NVarChar, 1000),
                        new SqlMetaData("spa_rfx_query", SqlDbType.NVarChar, 4000),
                        new SqlMetaData("parameter_sheet", SqlDbType.NVarChar, 1000),
                        new SqlMetaData("sheet_type", SqlDbType.Int),
                        new SqlMetaData("paramset_hash", SqlDbType.NVarChar, 1000),
                        new SqlMetaData("document_type", SqlDbType.Int)
                    });

                // start sending and tell the pipe to use the created record
                SqlContext.Pipe.SendResultsStart(rec);
                {
                    foreach (string s in sheetsList)
                    {
                        AddinSheet ads = addinSheets.FirstOrDefault(x => x.ReportSheet == s);
                        if (ads != null)
                        {
                            rec.SetSqlString(0, ads.ReportSheet);
                            rec.SetSqlString(1, ads.ReportName);
                            rec.SetSqlString(2, ads.SpaRfxParameter);
                            rec.SetSqlString(3, ads.ParameterSheet);
                            if (ads.ParameterSheet.ToLower().Contains("_template"))
                                rec.SetSqlInt32(4, 0);
                            else
                                rec.SetSqlInt32(4, 3);

                            rec.SetSqlString(5, ads.ParamsetHash);
                            rec.SetSqlInt32(6, ads.DocoumentType);
                        }
                        else
                        {
                            rec.SetSqlString(0, s);
                            rec.SetSqlString(1, null);
                            rec.SetSqlString(2, null);
                            rec.SetSqlString(3, null);
                            rec.SetSqlInt32(4, 0);

                            if (s.ToLower().Contains("_param") || s.ToLower().Contains("_template") || s.ToLower().Contains("globalfilter") || s.ToLower().Contains("import settings"))
                                rec.SetSqlInt32(4, 1);

                            if (s.ToLower().Contains("configuration"))
                                rec.SetSqlInt32(4, 2);

                            rec.SetSqlString(5, null);
                            rec.SetSqlInt32(6, 106700);
                        }
                        SqlContext.Pipe.SendResultsRow(rec);
                    }
                    SqlContext.Pipe.SendResultsEnd();    // finish sending
                }
                output = "1";
            }
            catch (Exception ex)
            {
                output = ex.Message;
                //ex.LogError("List Excel Add-in  Sheets", filename + "|" + ex.Message);
            }
        }

        /// <summary>
        /// get parameter collection from excel add-in _param worksheet
        /// </summary>
        /// <param name="fileName">ecel add-in filename</param>
        /// <param name="listAll">y=> List all parameter including date time</param>
        /// <param name="output">1 for success else failure message</param>
        public static void ExcelAddInParameters(string fileName, string listAll, out string output)
        {
            if (UserDefinedFunction.IsFileLocked(fileName))
            {
                output = "The file is unavailable or used by another process.";
                return;
            }


            bool listAllParam = false;

            try
            {
                if (listAll.Replace("1", "y").ToLower() == "y")
                    listAllParam = true;


                List<Param> parameters = new List<Param>();

                using (SpreadsheetDocument spreadSheetDocument = SpreadsheetDocument.Open(fileName, false))
                {
                    IEnumerable<Sheet> sheets =
                        spreadSheetDocument.WorkbookPart.Workbook.GetFirstChild<Sheets>().Elements<Sheet>();

                    //  browse only _param sheets which has parameter information for raw sheet
                    foreach (Sheet sheet in sheets.Where(x => x.Name.ToString().ToLower().Contains("_param")))
                    {
                        string relationshipId = sheets.FirstOrDefault(x => x.Name.ToString().ToLower() == sheet.Name.ToString().ToLower()).Id.Value;
                        WorksheetPart worksheetPart = (WorksheetPart)spreadSheetDocument.WorkbookPart.GetPartById(relationshipId);
                        Worksheet workSheet = worksheetPart.Worksheet;
                        SheetData sheetData = workSheet.GetFirstChild<SheetData>();
                        IEnumerable<Row> rows = sheetData.Descendants<Row>();

                        foreach (Row row in rows)
                        {
                            if (row.RowIndex <= 2) continue;
                            int i = 1;
                            Param p = new Param();
                            foreach (Cell cell in row.Descendants<Cell>())
                            {
                                string value = GetCellValue(spreadSheetDocument, cell);

                                switch (i)
                                {
                                    case 2:
                                        p.Name = value;
                                        break;
                                    case 3:
                                        p.Values = value;
                                        break;
                                    case 4:
                                        p.Label = value;
                                        break;
                                    case 5:
                                        if (value.ToLower() == "true")
                                            p.Optional = true;
                                        else
                                            p.Optional = false;
                                        break;
                                    case 6:
                                        p.DataType = Convert.ToInt32(value);
                                        break;
                                    case 7:
                                        if (value == "DATETIME")
                                            p.DataType = 2;
                                        break;
                                    default:
                                        break;
                                }
                                i++;

                            }
                            if (!listAllParam)
                            {
                                if (p.DataType == 2)
                                    parameters.Add(p);
                            }
                            else
                                parameters.Add(p);

                        }
                    }
                    parameters = parameters.Distinct().ToList();
                }
                SqlDataRecord rec =
                    new SqlDataRecord(new SqlMetaData[]
                {
                    new SqlMetaData("parameter_name", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("parameter_label", SqlDbType.NVarChar, 1000),
                    new SqlMetaData("data_type", SqlDbType.Int),
                    new SqlMetaData("values", SqlDbType.NVarChar,5000),
                    new SqlMetaData("optional", SqlDbType.Bit)
                });

                SqlContext.Pipe.SendResultsStart(rec);
                {
                    foreach (Param p in parameters)
                    {
                        rec.SetSqlString(0, p.Name);
                        rec.SetSqlString(1, p.Label);
                        rec.SetSqlInt32(2, p.DataType);
                        rec.SetSqlString(3, p.Values);
                        rec.SetSqlBoolean(4, p.Optional);
                        SqlContext.Pipe.SendResultsRow(rec);
                    }
                    SqlContext.Pipe.SendResultsEnd();    // finish sending
                }
                output = "1";
            }
            catch (Exception ex)
            {
                //ex.LogError("List Excel Add-in  Sheets", fileName + "|" + listAll + "|" + ex.Message);
                output = ex.Message;

            }
        }

        /// <summary>
        /// Excel addin parameter struct
        /// </summary>
        struct Param
        {
            public string Name { get; set; }
            public string Label { get; set; }
            public int DataType { get; set; }
            public string Values { get; set; }
            public bool Optional { get; set; }
        }

        #endregion

        

        #region socketClient
        /// <summary>
        /// Send remote command text remote host/port using TCP protocol
        /// </summary>
        /// <param name="ip">Remote IP Address</param>
        /// <param name="portNo">Remote Port</param>
        /// <param name="remoteCmdParameters">Text to send</param>
        /// <param name="outputResult"></param>
        public static void SendRemoteCommand(string ip, int portNo, string remoteCmdParameters, out string outputResult)
        {
            try
            {
                byte[] byteData = Encoding.Unicode.GetBytes(remoteCmdParameters);

                IPAddress ipAddress = IPAddress.Parse(ip);

                IPEndPoint endPoint = new IPEndPoint(ipAddress, portNo);
                Socket scSender = new Socket(ipAddress.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
                scSender.Connect(endPoint);
                scSender.Send(byteData);
                outputResult = "true";
            }
            catch (Exception ex)
            {
                outputResult = ex.Message;
                ex.LogError("Remote Cmd To Ps Socket Server", ip + "|" + portNo.ToString() + "|" + remoteCmdParameters + "|" + outputResult);
            }

        }

        #endregion
        #region Email Fetch
        /// <summary>
        /// Read email
        /// </summary>
        /// <param name="emailAddress"></param>
        /// <param name="emailPassword"></param>
        /// <param name="emailHost"></param>
        /// <param name="emailServerPort"></param>
        /// <param name="emailRequireSslInt"></param>
        /// <param name="DocumentPath"></param>
        /// <param name="messageId"></param>
        /// <param name="flag"></param>
        /// <param name="processId"></param>
        /// <param name="result"></param>
        public static void DumpIncomingEmail(string emailAddress, string emailPassword, string emailHost, int emailServerPort, int emailRequireSslInt, string DocumentPath, string messageId, char flag, string processId, out string result)
        {
            try
            {
                bool emailRequireSsl = (emailRequireSslInt == 1 ? true : false);

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL13\instance2016;Initial Catalog=TRMTracker_Branch;Persist Security Info=True;User id= farrms_admin;password=Admin2929"))
                {
                    cn.Open();
                    MailTaskOutlook mto = new MailTaskOutlook(new MailSetting(emailAddress, emailPassword, emailHost, emailServerPort, emailRequireSsl, cn, processId));
                    result = "";
                    if (flag == 'i')
                    {
                        Exception ex = mto.GetExchangeMail(DocumentPath);
                        if (ex != null)
                        {
                            cn.Close();
                            ex.LogError("GetExchangeMail", emailAddress + "|" + "******" + "|" + emailHost + "|" + emailServerPort + "|" + emailRequireSslInt + "|" + DocumentPath + "|" + ex.Message);
                            result = ex.Message;
                            return;
                        }
                    }
                    else if (flag == 'd')
                    {
                        Exception ex = mto.DeleteExchangeMail(DocumentPath, messageId);
                        if (ex != null)
                        {
                            cn.Close();
                            ex.LogError("DeleteExchangeMail", emailAddress + "|" + "******" + "|" + emailHost + "|" + emailServerPort + "|" + emailRequireSslInt + "|" + DocumentPath + "|" + ex.Message);
                            result = ex.Message;
                            return;
                        }
                    }
                }
                result = "success";
            }
            catch (Exception ex)
            {
                SendMessage(ex.Message);
                result = ex.Message;
                ex.LogError("DumpIncomingEmail", emailAddress + "|" + "******" + "|" + emailHost + "|" + emailServerPort + "|" + emailRequireSslInt + "|" + DocumentPath + "|" + ex.Message);
            }


        }
        #endregion

        #region ExcelAddIn API Integrations Changes
        #region JSON Builder

        /// <summary>
        /// Build json string from sql query output
        /// </summary>
        /// <param name="sqlQuery">Sql query</param>
        /// <param name="jsonFieldList">field list include in json output</param>
        /// <param name="jsoncontent">json output result</param>
        public static void BuildJson(string sqlQuery, string jsonFieldList, out string jsoncontent)
        {
            if (String.IsNullOrEmpty(jsonFieldList))
                jsonFieldList = null;

            string json = "";

            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))

                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    using (SqlCommand cmd = new SqlCommand(sqlQuery, cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteSessionReader())
                        {
                            //StoredProcedure.SendMessage(cmd.CommandText);
                            json = new PsJson(rd, jsonFieldList).ConvertToJson();
                            rd.Close();
                        }
                    }
                    cn.Close();
                }
                jsoncontent = json;
            }
            catch (Exception ex)
            {
                jsoncontent = "";
                ex.LogError("BuildJson", sqlQuery + "|" + jsonFieldList);
            }
        }

        /// <summary>
        /// Generate raw xml from table
        /// </summary>
        /// <param name="tableName">table name</param>
        /// <param name="xmlOutPut">xml output string</param>
        public static void RawXml(string tableName, out string xmlOutPut)
        {
            string sql = @"DECLARE @report_output XML
                            SET @report_output = (
                                    SELECT *
                                    FROM   " + tableName;
            sql += @" FOR XML RAW,
                                           ELEMENTS XSINIL ,
                                           ROOT('Report')
                                )

                            SELECT @report_output";

            string xmlContent = "<Report><Row><Error>Error while retreiveing report.</Error></Row></Report>";
            try
            {
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL18\INSTANCE2012;Initial Catalog=TRMTracker_Trunk;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                {
                    cn.Open();
                    //using (SqlCommand cmd = new SqlCommand("SELECT TOP 10000 * FROM adiha_process.dbo.report_output_results FOR XML AUTO, ELEMENTS", cn))
                    using (SqlCommand cmd = new SqlCommand(sql, cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteReader())
                        {
                            cmd.CommandTimeout = 7200;
                            if (rd.HasRows)
                            {
                                while (rd.Read())
                                {
                                    xmlOutPut = rd[0].ToString();//.Replace("_x0020_", "");
                                    //xmlOutPut = rd[0].ToString();
                                    return;
                                }
                            }
                        }
                    }
                    cn.Close();
                }
                xmlOutPut = "<Report><Row><Error>Error while retreiveing report.</Error></Row></Report>";
            }
            catch (Exception ex)
            {
                xmlOutPut = "<Report><Row><Error>Error while retreiveing report." + ex.Message + "</Error></Row></Report>";
                ex.LogError("Raw XML", tableName + "|" + xmlOutPut);
            }
        }

        /// <summary>
        /// Import json data to sql table
        /// </summary>
        /// <param name="jsonContent">JSON Data</param>
        /// <param name="tableName"></param>
        /// <param name="status">returns Success or failure message</param>
        public static void ImportFromJSON(string jsonContent, string tableName, out string status)
        {
            jsonContent = System.Net.WebUtility.HtmlDecode(jsonContent);
            System.Data.DataTable dt = new System.Data.DataTable("ImportTable");
            string[] jsonParts = Regex.Split(jsonContent.Replace("[", "").Replace("]", ""), "},{");
            try
            {
                //string[] arr = jsonContent.Substring(0, jsonContent.IndexOf('}')).Split(",");
                string[] arr = Regex.Split(jsonContent.Substring(0, jsonContent.IndexOf('}')), ",\"");
                int i = 1;
                foreach (string s1 in arr)
                {
                    if (!s1.Contains("\":\"")) continue;
                    string column = s1.Replace("[{", "").Replace("\"", "").Split(':')[0];
                    if (column == "")
                        column = "Column" + i.ToString();
                    i++;
                    dt.Columns.Add(column);
                }

                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL18\INSTANCE2012;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    //  Create process table
                    string sql = "IF OBJECT_ID('" + tableName + "') IS NOT NULL 	DROP TABLE " + tableName + Environment.NewLine;
                    sql += "CREATE TABLE " + tableName + " (";

                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        sql += "[" + dt.Columns[j].ColumnName + "] NVARCHAR(1024),";
                    }
                    sql = sql.TrimEnd(',') + ")";
                    cn.ExecuteQuery(sql);

                    foreach (string jp in jsonParts)
                    {
                        string[] propData = Regex.Split(jp.Replace("{", "").Replace("}", ""), ",\"");
                        DataRow nr = dt.NewRow();
                        i = 0;
                        foreach (string rowData in propData)
                        {
                            try
                            {
                                int idx = rowData.IndexOf(":");
                                string n = rowData.Substring(0, idx - 1).Replace("\"", "");
                                string v = FormatJson(rowData.Substring(idx + 1).Replace("\"", ""));
                                nr[i] = v;
                                i++;
                            }
                            catch (Exception ex)
                            {
                                i++;
                                continue;
                            }

                        }
                        dt.Rows.Add(nr);
                    }

                    //  Just load structure of table
                    using (SqlDataAdapter sqlDataAdapter = new SqlDataAdapter("SELECT * FROM " + tableName + " WHERE 0=1", cn))
                    {
                        SqlCommandBuilder builder = new SqlCommandBuilder(sqlDataAdapter);
                        sqlDataAdapter.Fill(dt);
                        sqlDataAdapter.Update(dt);
                    }
                    cn.Close();
                }
                status = "success";
            }
            catch (Exception ex)
            {
                status = ex.Message;
                ex.LogError("ImportFromJSON", jsonContent + "|" + tableName + "|" + status);
            }
        }

        /// <summary>
        /// Format json string invalid characters
        /// </summary>
        /// <param name="rawJsonContent">Json data</param>
        /// <returns></returns>
        public static string FormatJson(string rawJsonContent)
        {
            return rawJsonContent.Replace(@"\\", @"\").Replace(@"\/", @"/").Replace("\\n", Environment.NewLine).Replace("\\r", "\n").Replace("\\t", "\t").Replace(@"\", @"\\");
        }

        #endregion
        #endregion


        #region XML Import

        /// <summary>
        /// Import XML Content to Table
        /// </summary>
        /// <param name="xmlContent">XML Content</param>
        /// <param name="xmlFileName">XML Filename</param>
        /// <param name="processTableName">Table Name</param>
        /// <param name="suppressResult">Suppress output, Added to support nested insert when required</param>
        public static void ImportFromXml(string xmlContent, string xmlFileName, string processTableName, string suppressResult, out string status)
        {
            try
            {
                if (string.IsNullOrEmpty(processTableName))
                    processTableName = "adiha_process.dbo.xml_data_table_" + Guid.NewGuid().ToString().ToUpper().Replace("-", "_");

                if (string.IsNullOrEmpty(suppressResult)) suppressResult = "n";

                using (var importXml = new ImportXml(xmlContent, xmlFileName, processTableName))
                {
                    importXml.Import();
                    //  send result if suppress is off
                    if (suppressResult == "n")
                    {
                        //  Send process table as output
                        SqlDataRecord rec = new SqlDataRecord(new SqlMetaData[] { new SqlMetaData("process_table", SqlDbType.NVarChar, 1000) });
                        SqlContext.Pipe.SendResultsStart(rec);
                        {
                            rec.SetSqlString(0, processTableName);
                            SqlContext.Pipe.SendResultsRow(rec);
                            SqlContext.Pipe.SendResultsEnd();    // finish sending
                        }
                    }
                }
                status = "Success";
            }
            catch (Exception ex)
            {
                status = "failed";
                ex.LogError("ImportFromXml", xmlContent + "|" + xmlFileName + "|" + processTableName + "|" + "|" + ex.Message);
            }
        }

        #endregion

        

        #region Created method for regisTR message Log

        /// <summary>
        /// Method to capture and record response for submitted report
        /// </summary>
        /// <param name="ProcessTable">Table to collect response data</param>
        /// <param name="xmlFileList">Request xml to capture file list</param>
        /// <param name="recoverXml">Request XML to capture status of each file</param>
        /// <param name="requestUrl">SOAP URL</param>
        /// <param name="hostUrl">Web service URL</param>
        /// <param name="soapAction">Soap action</param>
        /// <param name="outmsg">Success/Failure status of the request</param>
        /// <param name="responseFileXML">Captured File XML</param>
        /// <param name="responseRecoverXML">Capture Response XML</param>
        public static void RegisTRMessageLog(string ProcessTable, string xmlFileList, string recoverXml, string requestUrl, string hostUrl, string soapAction, out string outmsg, out string responseFileXML, out string responseRecoverXML)
        {
            string errorNo = "";
            ExportStatus exportStatus = new ExportStatus();
            //String ProcessTable = "adiha_process.dbo.temp_registr_message_log";
            string[] tag_names_header = new string[] { "messageId", "inReplyTo", "tradeType", "sentBy", "sentTo", "creationTimestamp" };
            string[] tag_names_reason = new string[] { "reasonCode", "errorDescription" };
            string[] additionalColumns = new string[] { "fileName" };
            string[] column_headers = tag_names_header.Concat(tag_names_reason).Concat(additionalColumns).ToArray();
            string soapActionUrlXmlList = soapAction + "get_xml_list";
            string soapActionUrlRecover = soapAction + "recover_xmls";
            //string responseFileXML = null;
            //string responseRecoverXML = null;
            responseFileXML = "";
            responseRecoverXML = "";
            outmsg = ",:";
            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=sg-d-sql01,2033;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    DataTable dt = new DataTable("regisRespose");
                    foreach (string column_header in column_headers)
                    {
                        dt.Columns.Add(new DataColumn(column_header));
                    }
                    string createTableSql = "IF OBJECT_ID('" + ProcessTable + "') IS NOT NULL DROP TABLE " +
                                            ProcessTable;
                    cn.ExecuteQuery(createTableSql);
                    createTableSql = "CREATE TABLE " + ProcessTable + "(";
                    for (int i = 0; i < dt.Columns.Count; i++)
                    {
                        createTableSql += "[" + dt.Columns[i].ColumnName + "] NVARCHAR(1024),";
                    }
                    createTableSql = createTableSql.TrimEnd(',') + ")";
                    cn.ExecuteQuery(createTableSql);


                    ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);//SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                    HttpWebRequest requestFileList = (HttpWebRequest)WebRequest.Create(requestUrl);
                    requestFileList.Headers.Add("SOAPAction", soapActionUrlXmlList);
                    requestFileList.ContentType = "text/xml;charset=\"utf-8\"";
                    requestFileList.Accept = "text/xml";
                    requestFileList.Method = "POST";
                    requestFileList.KeepAlive = true;
                    requestFileList.Host = hostUrl;


                    using (Stream stream = requestFileList.GetRequestStream())
                    {
                        using (StreamWriter stmw = new StreamWriter(stream))
                        {
                            stmw.Write(xmlFileList);
                        }
                    }

                    using (WebResponse webResponse = requestFileList.GetResponse())
                    {
                        using (StreamReader streamReader = new StreamReader(webResponse.GetResponseStream()))
                        {
                            responseFileXML = streamReader.ReadToEnd();
                        }
                    }

                    //responseFileXML = "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><get_xml_listResponse xmlns=\"http://regis_tr_xml_load\"><get_xml_listResult xmlns=\"\">4</get_xml_listResult><xml_list xmlns=\"\" xmlns:a=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"><a:string>RP6650_I401_20190912_105844_0_WS_0.xml</a:string><a:string>RP6650_I401_20190912_110305_0_WS_0.xml</a:string><a:string>RP6650_I401_20190912_110324_0_WS_0.xml</a:string><a:string>RP6650_I401_20190912_110851_0_WS_0.xml</a:string></xml_list></get_xml_listResponse></s:Body></s:Envelope>";
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml(responseFileXML);
                    var listResult = xmlDoc.SelectSingleNode("//get_xml_listResult");
                    int fileNumber = 0;
                    if (Int32.TryParse(listResult.InnerText, out fileNumber))
                    {
                        if (fileNumber <= 0)
                        {
                            errorNo = listResult.InnerText;
                            outmsg = "Failed" + "," + errorNo + ":1";
                            cn.Close();
                            return;
                        }
                    }
                    else
                    {
                        errorNo = listResult.InnerText;
                        outmsg = "Failed" + "," + errorNo + ":1";
                        cn.Close();
                        return;
                    }

                    List<string> fileNames = new List<string>();
                    foreach (XmlNode node in xmlDoc.SelectNodes("//xml_list"))
                    {
                        foreach (XmlNode childNode in node.ChildNodes)
                        {
                            fileNames.Add(childNode.InnerText);
                        }
                    }
                    string[] fileName = fileNames.ToArray();

                    System.Threading.Thread.Sleep(500);
                    ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | (SecurityProtocolType)(0xc0 | 0x300 | 0xc00);//SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                    HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestUrl);
                    request.Headers.Add("SOAPAction", soapActionUrlRecover);
                    request.ContentType = "text/xml;charset=\"utf-8\"";
                    request.Accept = "text/xml";
                    request.Method = "POST";
                    request.KeepAlive = true;
                    request.Host = hostUrl;


                    using (Stream stream = request.GetRequestStream())
                    {
                        using (StreamWriter stmw = new StreamWriter(stream))
                        {
                            stmw.Write(recoverXml);
                        }
                    }

                    using (WebResponse webResponse = request.GetResponse())
                    {
                        using (StreamReader streamReader = new StreamReader(webResponse.GetResponseStream()))
                        {
                            responseRecoverXML = streamReader.ReadToEnd();
                        }
                    }

                    //responseRecoverXML = "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><recover_xmlsResponse xmlns=\"http://regis_tr_xml_load\"><recover_xmlsResult xmlns=\"\">5</recover_xmlsResult><xmls xmlns=\"\" xmlns:a=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\"><a:string><![CDATA[<?xml version=\"1.0\" encoding=\"utf-8\"?><reportingOperations xmlns=\"http://regis-tr.com/schema/2012/1.1/ReportingOutbound\"><reportingMessageRejected><header><messageId>A72C80778CF5E000</messageId><inReplyTo>ADE78FBD_77F4_41DF_A25A_D6E54C2BF15E</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:01:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected><reportingMessageRejected><header><messageId>A72C80778CF5F000</messageId><inReplyTo>C1080818_9EE7_405A_911A_4228AB29C4BB</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:01:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected></reportingOperations>]]></a:string><a:string><![CDATA[<?xml version=\"1.0\" encoding=\"utf-8\"?><reportingOperations xmlns=\"http://regis-tr.com/schema/2012/1.1/ReportingOutbound\"><reportingMessageRejected><header><messageId>A72C8077961FD200</messageId><inReplyTo>E75A541D_5104_42EF_8230_C3DACEA0CBD9</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:07:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected><reportingMessageRejected><header><messageId>A72C8077961FD202</messageId><inReplyTo>473C4CEB_7274_43FC_8E4E_A0FAD6E24811</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:07:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected></reportingOperations>]]></a:string><a:string><![CDATA[<?xml version=\"1.0\" encoding=\"utf-8\"?><reportingOperations xmlns=\"http://regis-tr.com/schema/2012/1.1/ReportingOutbound\"><reportingMessageRejected><header><messageId>A72C807796200100</messageId><inReplyTo>FDF06ABD_C658_4749_87F4_A2FF4119C632</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:07:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected><reportingMessageRejected><header><messageId>A72C807796200102</messageId><inReplyTo>E3D74D56_A92F_41D4_920C_2039A83737A2</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:07:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected></reportingOperations>]]></a:string><a:string><![CDATA[<?xml version=\"1.0\" encoding=\"utf-8\"?><reportingOperations xmlns=\"http://regis-tr.com/schema/2012/1.1/ReportingOutbound\"><reportingMessageRejected><header><messageId>A72C80779AB1A200</messageId><inReplyTo>E9DE2243_E6C3_4812_8AF6_F8DC59D63023</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:10:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected><reportingMessageRejected><header><messageId>A72C80779AB1A202</messageId><inReplyTo>52AA8696_E9A8_45E7_AEB0_1B9263D4291D</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:10:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected></reportingOperations>]]></a:string><a:string><![CDATA[<?xml version=\"1.0\" encoding=\"utf-8\"?><reportingOperations xmlns=\"http://regis-tr.com/schema/2012/1.1/ReportingOutbound\"><reportingMessageRejected><header><messageId>A72C80779F47D200</messageId><inReplyTo>02614FDD_A8FC_4478_A252_74B1CCEDC72B</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:13:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected><reportingMessageRejected><header><messageId>A72C80779F47D204</messageId><inReplyTo>85053F3E_D717_434B_AAD2_9ED36EB196F8</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-12T09:13:37Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected></reportingOperations>]]></a:string></xmls></recover_xmlsResponse></s:Body></s:Envelope>";
                    XmlDocument xmlDoc1 = new XmlDocument();
                    xmlDoc1.LoadXml(responseRecoverXML);
                    var xmlsResult = xmlDoc1.SelectSingleNode("//recover_xmlsResult");
                    if (Int32.TryParse(xmlsResult.InnerText, out fileNumber))
                    {
                        if (fileNumber <= 0)
                        {
                            errorNo = xmlsResult.InnerText;
                            outmsg = "Failed" + "," + errorNo + ":2";
                            cn.Close();
                            return;
                        }
                    }
                    else
                    {
                        errorNo = xmlsResult.InnerText;
                        outmsg = "Failed" + "," + errorNo + ":2";
                        cn.Close();
                        return;
                    }

                    int counter = 0;
                    foreach (XmlNode node_parent in xmlDoc1.SelectNodes("//xmls"))
                    {
                        foreach (XmlNode childNode_parent in node_parent.ChildNodes)
                        {
                            string test_xml3 = childNode_parent.InnerText;
                            XmlDocument xmlDoc2 = new XmlDocument();
                            xmlDoc2.LoadXml(test_xml3);
                            List<string> RowData = new List<string>();
                            foreach (XmlNode node in xmlDoc2.ChildNodes)
                            {
                                foreach (XmlNode childNode in node.ChildNodes)
                                {
                                    if (childNode.Name == "reportingMessageRejected")
                                    {
                                        foreach (string tag_name in tag_names_header)
                                        {
                                            if (childNode["header"][tag_name] != null)
                                            {
                                                RowData.Add(childNode["header"][tag_name].InnerText);
                                            }
                                            else
                                            {
                                                RowData.Add("");
                                            }

                                        }

                                        foreach (string tag_name in tag_names_reason)
                                        {
                                            if (childNode["reason"][tag_name] != null)
                                            {
                                                RowData.Add(childNode["reason"][tag_name].InnerText);
                                            }
                                            else
                                            {
                                                RowData.Add("");
                                            }

                                        }
                                        if (counter < fileName.Length)
                                        {
                                            RowData.Add(fileName[counter]);
                                        }
                                        else
                                        {
                                            RowData.Add("");
                                        }

                                    }
                                    string[] RowDataArray = RowData.ToArray();
                                    dt.Rows.Add(RowDataArray);
                                    RowData.Clear();
                                }

                            }
                            counter++;
                        }

                    }
                    //string responseMsg = "<?xml version=\"1.0\" encoding=\"utf-8\"?><reportingOperations xmlns=\"http://regis-tr.com/schema/2012/1.1/ReportingOutbound\"><reportingMessageRejected><header><messageId>A72C7F157FAE4900</messageId><inReplyTo>5C4F76C0_A0E5_4227_A7F0_FED82D8299EE</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-06T15:01:32Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected><reportingMessageRejected><header><messageId>A72C7F157FAE6800</messageId><inReplyTo>0A9D88A1_F0C1_4234_A740_61E18A0F83F4</inReplyTo><tradeType>MessageRejected</tradeType><sentBy>RGTRESMMXXX</sentBy><sentTo>743700F2CDGSIF0Z9036</sentTo><creationTimestamp>2019-09-06T15:01:32Z</creationTimestamp></header><reason><reasonCode>7</reasonCode><errorDescription>Incorrect Identification[SentBy]</errorDescription></reason></reportingMessageRejected></reportingOperations>";

                    using (SqlDataAdapter adapter = new SqlDataAdapter("SELECT TOP 1 * FROM " + ProcessTable, cn))
                    {
                        using (SqlCommandBuilder builder = new SqlCommandBuilder(adapter))
                        {
                            DataSet dataSet = new DataSet("dataset");
                            dataSet.Tables.Add(dt);
                            adapter.Fill(dt);
                            adapter.Update(dt);
                        }

                    }
                    outmsg = "Success" + "," + "" + ":0";
                    cn.Close();
                }
            }
            catch (Exception ex)
            {
                outmsg = "Failed" + "," + "" + ":-1";
                exportStatus.Exception.LogError("IWebServiceDataDispatcher", exportStatus.ResponseMessage);
                ex.LogError("regisTR Request Log", ex.Message);
            }
        }
        #endregion

        /// <summary>
        /// Returns Schema information of sql query or sp output
        /// </summary>
        /// <param name="sqlQuery">Storedprocedure query or SQL Adhoc query</param>
        /// <param name="processTableName">process table name</param>
        /// <param name="dataOutputColCount">Return number of columns output by query</param>
        /// <param name="flag">string possible value data=> dumps data to process table, schema => dumps schema information to process table</param>
        public static void GetSchemaOrData(string sqlQuery, string processTableName, out int dataOutputColCount, string flag)
        {
            try
            {



                DataTable schemaDataTable;
                DataTable dataTable = new DataTable(processTableName);
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL20\INSTANCE2016;Initial Catalog=TRMTracker_Release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    //  if process table is part of adiha process drop thi will be created
                    if (processTableName.ToLower().Contains("adiha_process"))
                        cn.ExecuteQuery("IF OBJECT_ID('" + processTableName + "') IS NOT NULL DROP TABLE " + processTableName);

                    string sql = "";
                    var alreadyAddedColumns = new List<string>();
                    //  Collect dummy columns if present in temp table, this will be dropped after completion of process
                    if (processTableName.ToLower().Contains("#"))
                    {
                        using (var cmd = new SqlCommand("Select * from " + processTableName, cn))
                        {
                            using (var rd1 = cmd.ExecuteReader())
                            {
                                for (int i = 0; i < rd1.FieldCount; i++)
                                    alreadyAddedColumns.Add(rd1.GetName(i));
                            }
                        }
                    }
                    //  Load schema / Data
                    using (SqlCommand cmd = new SqlCommand(sqlQuery, cn))
                    {
                        using (SqlDataReader rd = cmd.ExecuteSessionReader())
                        {
                            //  Schema information
                            schemaDataTable = rd.GetSchemaTable();
                            if (flag.ToLower() == "data")   //  if data retrival needs to be done, load data to datatable later dumped in table
                                dataTable.Load(rd);
                        }
                    }

                    if (string.IsNullOrEmpty(processTableName))
                    {
                        dataOutputColCount = schemaDataTable.Rows.Count;
                    }
                    else
                    {
                        //  Data
                        var schemaColumns = new List<SchemaColumn>();
                        if (flag.ToLower() == "data")
                        {
                            foreach (DataRow row in schemaDataTable.Rows)
                            {
                                schemaColumns.Add(new SchemaColumn()
                                {
                                    Name = row.ItemArray[0].ToString(),
                                    Ordinal = row.ItemArray[1].ToInt(),
                                    ColumnSize = row.ItemArray[2].ToInt(),
                                    NumericPrecision = row.ItemArray[3].ToInt(),
                                    NumericScale = row.ItemArray[4].ToInt(),
                                    SqlDataType = row.ItemArray[24].ToString()
                                });
                            }

                            if (processTableName.ToLower().Contains("adiha_process"))
                            {
                                sql = "CREATE TABLE " + processTableName + "(";
                                sql = schemaColumns.OrderBy(x => x.Ordinal).Aggregate(sql, (current, column) => current + ("[" + column.Name + "] " + column.DataType + ",")).TrimEnd(',') + ")";
                                cn.ExecuteQuery(sql);
                            }
                            else if (processTableName.ToLower().Contains("#"))
                            {
                                //  Temp table
                                sql = "ALTER TABLE " + processTableName + " ADD ";
                                sql = schemaColumns.Aggregate(sql, (current, column) => current + ("[" + column.Name + "] " + column.DataType + ",")).TrimEnd(',');
                                cn.ExecuteQuery(sql);
                            }
                            //  Dump datatable to process table, process table schema should be exact according to datatable columns colllection
                            string columns = schemaColumns.Aggregate("", (current, column) => current + ("[" + column.Name + "],")).TrimEnd(',');

                            dataTable.DumpDataTableToProcessTable(processTableName, cn, columns);
                        }
                        else if (flag.ToLower() == "schema")
                        {
                            if (processTableName.ToLower().Contains("adiha_process"))
                            {
                                sql = "CREATE TABLE " + processTableName + "(";
                                sql = schemaDataTable.Columns.Cast<DataColumn>().Aggregate(sql, (current, column) => current + ("[" + column.ColumnName + "] NVARCHAR(1024) COLLATE DATABASE_DEFAULT,")).TrimEnd(',') + ")";
                                cn.ExecuteQuery(sql);
                            }
                            else if (processTableName.ToLower().Contains("#"))
                            {
                                //  Temp table
                                sql = "ALTER TABLE " + processTableName + " ADD ";
                                sql = schemaDataTable.Columns.Cast<DataColumn>().Aggregate(sql, (current, column) => current + ("[" + column.ColumnName + "] NVARCHAR(1024) COLLATE DATABASE_DEFAULT,")).TrimEnd(',');
                                cn.ExecuteQuery(sql);
                            }
                            string columns = schemaDataTable.Columns.Cast<DataColumn>().OrderBy(x => x.Ordinal).Aggregate("", (current, dc) => current + ("[" + dc.ColumnName + "],")).TrimEnd(',');
                            columns = columns.TrimEnd(',');

                            //  data table dump doesnt support data conversion, manual insert query is build to insert
                            foreach (DataRow row in schemaDataTable.Rows)
                            {
                                string insertQuery = "INSERT INTO " + processTableName + "(" + columns + ") VALUES(";
                                insertQuery = row.ItemArray.Aggregate(insertQuery, (current, o) => current + ("'" + o.ToString() + "',")).TrimEnd(',') + ")";
                                cn.ExecuteQuery(insertQuery);
                            }
                        }
                        //  Drop dummy columns from temp table, This case is not valid for process table, process table are dropped each time
                        if (processTableName.Contains("#"))
                        {
                            foreach (string col in alreadyAddedColumns)
                            {
                                sql = "ALTER TABLE " + processTableName + " DROP COLUMN [" + col + "]";
                                cn.ExecuteQuery(sql);
                            }
                        }
                    }
                    dataOutputColCount = schemaDataTable.Rows.Count;
                }
            }
            catch (Exception ex)
            {
                dataOutputColCount = 0;
                ex.LogError("GetSchemaOrData", sqlQuery + "|" + processTableName + "|" + dataOutputColCount + "|" + flag);
            }
        }

        #region Created method for Nordpool Feedback Capture
        public static void NordpoolFeedbackCapture(string ReportIDCSV, string ProcessTable, out string outmsg)
        {
            string clientId = null;
            string clientSecret = null;
            string grantType = null;
            string scope = null;
            string urlToken = null;
            string url = null;
            string secretKey = null;
            string authorization = null;
            string schema = null;
            string companyId = null;
            string FilePath = null;
            string jsonStatusResponse = null;
            string uploadStatus = null;
            string urlStatusURLOrg = null;
            string ReceiptURLOrg = null;
            outmsg = "";
            //string Query = null;
            string ReceiptURL = null;
            try
            {
                //using (SqlConnection cn = new SqlConnection(@"Data Source=PSDL21\INSTANCE2016;Initial Catalog=TRMTracker_release;Persist Security Info=True;User ID=farrms_admin;password=Admin2929"))
                using (SqlConnection cn = new SqlConnection("Context Connection=true"))
                {
                    cn.Open();
                    string[] ReportIDs = ReportIDCSV.Split(',');
                    string[] tableColumns = new string[] { "reportID", "logicalRecordIdentifier", "logicalRecordType", "status", "errorCode", "errorDescription", "errorDetails", "requestURL", "responseXML", "uploadStatus" };
                    DataTable dt = new DataTable("NordpoolRespose");
                    foreach (string columnHeader in tableColumns)
                    {
                        dt.Columns.Add(new DataColumn(columnHeader));
                    }
                    string createTableSql = "IF OBJECT_ID('" + ProcessTable + "') IS NOT NULL DROP TABLE " +
                                            ProcessTable;
                    cn.ExecuteQuery(createTableSql);
                    createTableSql = "CREATE TABLE " + ProcessTable + "(";
                    for (int i = 0; i < dt.Columns.Count; i++)
                    {
                        createTableSql += "[" + dt.Columns[i].ColumnName + "] NVARCHAR(MAX),";
                    }
                    createTableSql = createTableSql.TrimEnd(',') + ")";
                    cn.ExecuteQuery(createTableSql);

                    SqlCommand cmd_param = new SqlCommand("spa_generic_mapping_header", cn);
                    cmd_param.CommandType = CommandType.StoredProcedure;
                    cmd_param.Parameters.Add(new SqlParameter("@flag", "a"));
                    cmd_param.Parameters.Add(new SqlParameter("@mapping_name", "Web Service"));
                    cmd_param.Parameters.Add(new SqlParameter("@primary_column_value", "NordpoolExporter"));
                    using (SqlDataReader reader_param = cmd_param.ExecuteReader())
                    {
                        if (reader_param.HasRows)
                        {
                            reader_param.Read();
                            urlToken = reader_param["Web Service Token URL"].ToString();
                            url = reader_param["Web Service URL"].ToString();
                            clientId = reader_param["Client ID"].ToString();
                            clientSecret = reader_param["Client Secret"].ToString();
                            grantType = reader_param["Grant Type"].ToString();
                            scope = reader_param["Scope"].ToString();
                            authorization = reader_param["Authorization"].ToString();
                            secretKey = reader_param["Secret Key"].ToString();
                            schema = reader_param["Schema"].ToString();
                            companyId = reader_param["Company"].ToString();
                            urlStatusURLOrg = reader_param["Param1"].ToString();
                            ReceiptURLOrg = reader_param["Param2"].ToString();
                        }
                    }

                    using (var cmd2 = new SqlCommand("SELECT document_path FROM connection_string", cn))
                    {
                        using (SqlDataReader reader2 = cmd2.ExecuteReader())
                        {
                            while (reader2.Read())
                            {
                                FilePath = reader2["document_path"].ToString();
                            }
                            reader2.Close();
                        }
                    }

                    string accessToken = "";
                    var request = (HttpWebRequest)WebRequest.Create(urlToken);
                    request.Timeout = 30000;
                    request.UseDefaultCredentials = true;
                    request.PreAuthenticate = true;
                    request.Credentials = CredentialCache.DefaultCredentials;
                    string postData = "username=" + clientId + "&password=" + clientSecret + "&grant_type=" + grantType + "&scope=" + scope;

                    var data = Encoding.ASCII.GetBytes(postData);
                    request.Method = "POST";
                    request.ContentType = "application/x-www-form-urlencoded";
                    request.ContentLength = data.Length;
                    request.Headers.Add("Authorization", "Basic " + authorization);


                    using (var stream = request.GetRequestStream())
                    {
                        stream.Write(data, 0, data.Length);
                        stream.Close();
                    }

                    var httpResponse = (HttpWebResponse)request.GetResponse();

                    var responseString = new StreamReader(httpResponse.GetResponseStream()).ReadToEnd();
                    string refineData = responseString.Replace(":", ",").Replace("{", "").Replace("}", "");
                    string[] arrayData = refineData.Split(',').Select(sValue => sValue.Trim()).ToArray();
                    accessToken = arrayData[1].Replace(@"""", "");


                    List<string> RowData = new List<string>();
                    if (accessToken != "")
                    {
                        foreach (string ReportID in ReportIDs)
                        {
                            try
                            {
                                string urlStatusURL = urlStatusURLOrg + "?reportId=" + ReportID; //Needs to be changed
                                urlStatusURL = urlStatusURL.Replace(":companyId", companyId);
                                WebRequest request_reportID = WebRequest.Create(urlStatusURL);
                                request_reportID.Method = "GET";
                                request_reportID.Timeout = 30000;
                                request_reportID.UseDefaultCredentials = true;
                                request_reportID.PreAuthenticate = true;
                                request_reportID.Credentials = CredentialCache.DefaultCredentials;
                                //request_reportID.ContentLength = data.Length;
                                request_reportID.Headers.Add("Authorization", "Bearer " + accessToken);

                                using (HttpWebResponse httpResponse2 = (HttpWebResponse)request_reportID.GetResponse())
                                {
                                    using (Stream stream = httpResponse2.GetResponseStream())
                                    {
                                        using (StreamReader reader = new StreamReader(stream))
                                        {
                                            jsonStatusResponse = reader.ReadToEnd();
                                        }
                                    }
                                }

                                jsonStatusResponse = System.Net.WebUtility.HtmlDecode(jsonStatusResponse);

                                string[] jsonParts = jsonStatusResponse.Replace("[", "").Replace("]", "").Split("\": \"".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
                                //  Check if status  is present or not  based on report id 
                                if (!string.IsNullOrEmpty(jsonParts.Where(x => x.Contains(ReportID)).FirstOrDefault()))
                                {
                                    for (int i = 0; i < jsonParts.Count(); i++)
                                    {
                                        if (jsonParts[i] == "Status")
                                        {
                                            //  Next offset is  status message
                                            uploadStatus = jsonParts[i + 1];
                                            break;
                                        }
                                    }
                                }

                                if (uploadStatus == "ProcessingByAcerCompleted" || uploadStatus == "ProcessingByAcerFailed")
                                {
                                    ReceiptURL = ReceiptURLOrg + "?reportId=" + ReportID; //Needs to be changed
                                    ReceiptURL = ReceiptURL.Replace(":companyId", companyId);
                                    HttpWebRequest requestReceipt = (HttpWebRequest)HttpWebRequest.Create(ReceiptURL);
                                    requestReceipt.Method = WebRequestMethods.Http.Get;
                                    requestReceipt.Timeout = 30000;
                                    requestReceipt.UseDefaultCredentials = true;
                                    requestReceipt.PreAuthenticate = true;
                                    requestReceipt.Credentials = CredentialCache.DefaultCredentials;
                                    //requestReceipt.ContentLength = data.Length;
                                    requestReceipt.Headers.Add("Authorization", "Bearer " + accessToken);
                                    requestReceipt.ContentType = "application/octet-stream";
                                    string FileName = "Nordpool" + DateTime.Now.ToString("yyyyddM_HHmmss") + ".xml.zip";
                                    string FilePathZip = System.IO.Path.Combine(FilePath, "temp_Note", FileName);
                                    using (HttpWebResponse httpResponseReceipt = (HttpWebResponse)requestReceipt.GetResponse())
                                    {
                                        BinaryReader bin = new BinaryReader(httpResponseReceipt.GetResponseStream());

                                        byte[] buffer = bin.ReadBytes((Int32)httpResponseReceipt.ContentLength);

                                        using (Stream writer = File.Create(FilePathZip))
                                        {
                                            writer.Write(buffer, 0, buffer.Length);
                                            writer.Flush();
                                        }

                                    }

                                    FileInfo fi = new FileInfo(FilePathZip);
                                    string extractDir = fi.Directory.FullName;
                                    string ReceiptFileName = null;
                                    using (ZipFile zip = ZipFile.Read(FilePathZip))
                                    {
                                        foreach (ZipEntry e in zip)
                                        {
                                            e.Extract(extractDir, ExtractExistingFileAction.OverwriteSilently);
                                            ReceiptFileName = e.FileName;
                                        }
                                    }

                                    string XMLFilePath = System.IO.Path.Combine(FilePath, "temp_Note", ReceiptFileName);
                                    string xmlContent = "";

                                    using (StreamReader streamReader = new StreamReader(XMLFilePath, Encoding.UTF8))
                                    {
                                        string inputLine = "";
                                        while ((inputLine = streamReader.ReadLine()) != null)
                                        {
                                            if (inputLine.Trim().StartsWith("<") && inputLine.Trim().EndsWith(">"))
                                            {
                                                xmlContent += inputLine + " ";
                                            }
                                        }
                                    }

                                    /*Query = "INSERT INTO remote_service_response_log (response_status,process_id,request_identifier,request_msg_detail,response_msg_detail,export_web_service_id) ";
                                    Query += "SELECT  'Success', '" + ProcessID + "', '" + ReportID + "' , '" + ReceiptURL + "', '" +
                                             xmlContent + "', '" + WebServiceID + "'";
                                    ExecuteQuery(Query, cn);*/

                                    if (xmlContent != "")
                                    {
                                        XmlDocument xmlDoc = new XmlDocument();
                                        xmlDoc.LoadXml(xmlContent);
                                        XmlNodeList nodeList;
                                        if (xmlDoc.DocumentElement.Attributes["xmlns"] != null)
                                        {
                                            string xmlns = xmlDoc.DocumentElement.Attributes["xmlns"].Value;
                                            XmlNamespaceManager nsmgr = new XmlNamespaceManager(xmlDoc.NameTable);

                                            nsmgr.AddNamespace("a", xmlns);

                                            nodeList = xmlDoc.SelectNodes("/a:REMITReceipt/a:validationReceipt/a:globalReceiptItem", nsmgr);
                                        }
                                        else
                                        {
                                            nodeList = xmlDoc.SelectNodes("/REMITReceipt/validationReceipt/globalReceiptItem");
                                        }


                                        foreach (XmlNode node in nodeList)
                                        {
                                            RowData.Add(ReportID);
                                            foreach (string tableColumn in tableColumns)
                                            {
                                                if (tableColumn == "requestURL")
                                                {
                                                    RowData.Add(ReceiptURL);
                                                }
                                                else if (tableColumn == "responseXML")
                                                {
                                                    RowData.Add(xmlContent);
                                                }
                                                else if (tableColumn == "uploadStatus")
                                                {
                                                    RowData.Add(uploadStatus);
                                                }
                                                else if (tableColumn != "reportID")
                                                {
                                                    if (node[tableColumn] != null)
                                                    {
                                                        RowData.Add(node[tableColumn].InnerXml);
                                                    }
                                                    else
                                                    {
                                                        RowData.Add("");
                                                    }

                                                }
                                            }
                                            string[] RowDataArray = RowData.ToArray();
                                            dt.Rows.Add(RowDataArray);
                                            RowData.Clear();
                                        }
                                    }
                                }
                            }
                            catch (WebException webEx)
                            {
                                RowData.Add(ReportID);
                                foreach (string tableColumn in tableColumns)
                                {
                                    if (tableColumn == "requestURL")
                                    {
                                        RowData.Add(ReceiptURL);
                                    }
                                    else if (tableColumn == "responseXML")
                                    {
                                        RowData.Add(((HttpWebResponse)webEx.Response).StatusDescription);
                                    }
                                    else if (tableColumn == "uploadStatus")
                                    {
                                        RowData.Add("");
                                    }
                                    else if (tableColumn != "reportID")
                                    {
                                        RowData.Add("");
                                    }
                                }
                                string[] RowDataArray = RowData.ToArray();
                                dt.Rows.Add(RowDataArray);
                                RowData.Clear();
                            }
                            catch (Exception ex)
                            {
                                RowData.Add(ReportID);
                                foreach (string tableColumn in tableColumns)
                                {
                                    if (tableColumn == "requestURL")
                                    {
                                        RowData.Add(ReceiptURL);
                                    }
                                    else if (tableColumn == "responseXML")
                                    {
                                        RowData.Add(ex.Message);
                                    }
                                    else if (tableColumn == "uploadStatus")
                                    {
                                        RowData.Add("");
                                    }
                                    else if (tableColumn != "reportID")
                                    {
                                        RowData.Add("");
                                    }
                                }
                                string[] RowDataArray = RowData.ToArray();
                                dt.Rows.Add(RowDataArray);
                                RowData.Clear();
                            }

                        }

                        using (SqlDataAdapter adapter = new SqlDataAdapter("SELECT TOP 1 * FROM " + ProcessTable, cn))
                        {
                            using (SqlCommandBuilder builder = new SqlCommandBuilder(adapter))
                            {
                                DataSet dataSet = new DataSet("dataset");
                                dataSet.Tables.Add(dt);
                                adapter.Fill(dt);
                                adapter.Update(dt);
                            }

                        }
                    }
                    cn.Close();
                }
                outmsg = "Success";
            }
            catch (Exception ex)
            {
                outmsg = "Failed";
                ex.LogError("Norpool Error Log", ex.Message);
            }
        }
        #endregion

    };

    #region Extensions

    class SchemaColumn
    {
        public string Name { get; set; }
        public int Ordinal { get; set; }
        public string DataType { get; set; }
        public int NumericPrecision { get; set; }
        public int NumericScale { get; set; }
        public int ColumnSize { get; set; }

        private string myVar;
        /// <summary>
        /// DST class
        /// </summary>
        public string SqlDataType
        {
            get { return myVar; }
            set
            {
                myVar = value;
                switch (value)
                {
                    case "varchar":
                        if (this.ColumnSize >= 8000)
                            this.DataType = "VARCHAR(MAX) COLLATE DATABASE_DEFAULT";
                        else
                            this.DataType = "VARCHAR(" + this.ColumnSize + ") COLLATE DATABASE_DEFAULT";
                        break;
                    case "char":
                        this.DataType = "CHAR(" + this.ColumnSize + ") COLLATE DATABASE_DEFAULT";
                        break;
                    case "nchar":
                        this.DataType = "NCHAR(" + this.ColumnSize + ") COLLATE DATABASE_DEFAULT";
                        break;
                    case "nvarchar":
                        if (this.ColumnSize >= 4000)
                            this.DataType = "NVARCHAR(MAX) COLLATE DATABASE_DEFAULT";
                        else
                            this.DataType = "NVARCHAR(" + this.ColumnSize + ") COLLATE DATABASE_DEFAULT";
                        break;
                    case "decimal":
                        this.DataType = "NUMERIC(" + this.NumericPrecision + "," + this.NumericScale + ")";
                        break;
                    default:
                        this.DataType = value;
                        break;
                }
            }
        }

    }

    public class DST
    {
        public int Year { get; set; }
        public DateTime EndDate { get; set; }

    }
}

#endregion
