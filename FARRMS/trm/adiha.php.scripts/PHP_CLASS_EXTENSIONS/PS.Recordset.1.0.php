<?php
include '../components/include.file.v3.php';

/**
 *  @brief PSRecordset
 *  
 *  @par Description
 *  This class is used to query database
 *  
 *  @copyright Pioneer Solutions
 */
class PSRecordset {

    var $database;
    var $user;
    var $pass;
    var $show_label;
    var $strip_hyperlink;
    var $recrodsetResource;
    var $dbConnection;
    var $clms;
    var $rows;
    var $recordsets;
    var $recordsetsMDArray;
    var $recordsetXML;
    var $startTimer;
    var $endTimer;
    var $clmNames;
    var $clmTypes;
    var $sql_arr_list;

    /**
     * PSRecordset constructor - accepts boolean value for label
     * @param   Boolean  $label  Show label
     */
    function _construct($label) {
        $this->setShowLable($label);
        $this->strip_hyperlink = false;
    }

    /**
     * Set Strip Hyperlink
     * @param   Boolean  $strip_flag  Strip Hyperlink
     */
    function setStripHyperlink($strip_flag) {
        $this->strip_hyperlink = $strip_flag;
    }

    /**
     * Get connection
     */
    function getConnection() {
        return $this->dbConnection;
    }

    /**
     * Connects database
     * @param   String  $database  Database name
     * @param   String  $user      User name
     * @param   String  $pass      Password
     */
    function connectToDatabase($database, $user, $pass) {
        $this->database = $database;
        $this->user = $user;
        $this->pass = $pass;
        
        global $use_grid_labels, $DEBUG_MODE, $db_servername, $connection_info;
        //Open connection to the database
        //  $this->dbConnection = odbc_connect($this->database, $this->user, $this->pass) or die("could not connect");
        $error_msg = 'Could not connect to database';
        
       $db_server_name = $db_servername;
       // $link = sqlsrv_connect($db_server_name, $connection_info);
        $this->dbConnection = sqlsrv_connect($db_server_name, $connection_info) or die($this->buildErrorXML($error_msg));
        //check to see if connection failed rather than dieing here... should return  with error message
        }
    
    /**
     * Builds error xml
     * @param   String  $error_msg  Error message
     * @return  String              Error XML
     */
    function buildErrorXML($error_msg) {

        $errorXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<PSRecordSet records='" . 1 . "' columns='" . 2 . "'>\n";
        $errorXML .= $this->buildBeginRecordXML(0);
        $errorXML .= $this->buildClmXML(0, 'Error');
        $errorXML .= $this->buildClmXML(1, $error_msg);
        $errorXML .= $this->buildEndRecordXML(0);
        $errorXML .= "</PSRecordSet>\n";

        return $errorXML;
    }

    /**
     * Sets to show label
     * @param   Boolean  $label  Show label
     */
    function setShowLable($label) {
        if ($label == 'NULL' || $label == null || $label == 'null' || $label == '' || $label == 'false' || $label == 'FALSE')
            $this->show_label = false;
        else
            $this->show_label = $label;
    }

    /**
     * Builds XML begin record
     * @return  String XML
     */
    function buildBeginRecordXML($itemNo) {
        $tmpStr = "   <record>\n";
        return $tmpStr;
    }

    /**
     * Function to create XML child node based on the column name and it's value
     * @param   String  $colName  Column Name
     * @param   String  $value    Value
     * @return  String            XML
     */
    function buildClmXML($colName, $value) {
        //replace backslash in column name with the underscore character
        $colName = trim($colName);
        $colName = str_replace('/', '_', ($colName));

        // Replace number's tag in php to non number tag****************/
        /* $pattern="/^[0-9]+$/";
          if(preg_match($pattern,$colName))
          {
          $colName="X".$colName;
          } */
        /*         * ************************************** */
        //replace space in column name with the underscore character
        $value = preg_replace('/[^A-Za-z0-9+\.\-:_;><\/()&]+/i', ' ', $value);
        $colName = preg_replace('/[^A-Za-z0-9+\.><\/]+/i', ' ', $colName);

        if (preg_match('/^[[:alpha:]]+/', $colName)) {
            $colName = $colName;
        } else {
            $colName = chr(32) . $colName;
        }
        if (isset($_POST['call_from']) && $_POST['call_from'] = 'mobile') {
            $tmpStr = "      <" . str_replace(" ", "_", $colName) . ">" . $value . "</" . str_replace(" ", "_", $colName) . ">\n";            
        } else {            
            $tmpStr = "      <" . str_replace(" ", "_", get_locale_value($colName, false)) . ">" . $value . "</" . str_replace(" ", "_", get_locale_value($colName, false)) . ">\n";
            
        }
                
        return $tmpStr;
    }

    /**
     * Build XML end record
     * @return  String XML
     */
    function buildEndRecordXML($itemNo) {
        $tmpStr = "   </record>\n";
        return $tmpStr;
    }

    /**
     * Show label
     * @param   Boolean  $label  Show label
     */
    function showLabel($label) {
        $this->show_label = $label;
    }

    /**
     * Run SQL Query
     *
     * @param   String  $sql        SQL Query
     * @param   String  $flag       Flag
     * @param   String  $call_from  Call from
     * @return  Mixed               Data XML or Error
     */
    function runSQLStmt($sql, $flag = '', $call_from = '') {
        global $SQLSRV_QUERY_TIME_OUT;
        
        $this->sql_arr_list = decode_param_sql($sql);
         //error_reporting(0);

         $sql = $this->add_session_context($sql);
         
         $params = array();
         $this->recrodsetResource = sqlsrv_query($this->getConnection(), $sql, $params, $SQLSRV_QUERY_TIME_OUT);
         
         if (!$this->recrodsetResource) {
            error_reporting(2047);
        }
        /*
        if( ($errors = sqlsrv_errors()) != null)
            foreach( $errors as $error ) {
            //echo "message: ".$error[ 'message']."<br />";                        
            //$this->recrodsetResource = odbc_exec($this, $sql);
            // if (!$this->recrodsetResource) {
            error_reporting(2047);
        }
        */

        //check for error here....
        $this->clmTypes = array();
        $this->clmNames = array();
        $this->recordsets = array();
        $this->recordsetsMDArray = array();
        $this->rows = 0;
        $this->clms = 0;

        if ($this->show_label == true)
            $record_start_at = 1;
        else
            $record_start_at = 0;
       

        if (gettype($this->recrodsetResource) != 'resource')
            if(($errors = sqlsrv_errors() ) != null)
               
                    die($this->buildErrorXML('No Data Were Returned'));

        //get all lables first
   
        $this->clms = sqlsrv_num_fields($this->recrodsetResource);
       
        
              
         //Save clm names and add to multi-dimensional array
        if ($this->show_label == true)
            $this->recordsetsMDArray[0] = array();
        
        $z = 0;
        $n = 0;
        foreach (sqlsrv_field_metadata($this->recrodsetResource) as $fieldMetadata) {
            foreach ($fieldMetadata as $name => $value) {
                if ($name == 'Name') {
                    $this->clmNames[$n] = $value;
                }

                if ($name == 'Type') {
                    $this->clmTypes[$n] = $value;
                    $n++;
                }
                
                if ($this->show_label == true)
                    $this->recordsetsMDArray[0][$n] = $this->clmNames[$n];
                }
            }
     
     
        /*
       for ($n = 0; $n < $this->clms; $n++) {

            $this->clmNames[$n] = odbc_field_name($this->recrodsetResource, $n + 1);
            $this->clmTypes[$n] = odbc_field_type($this->recrodsetResource, $n + 1);

            if ($this->show_label == true)
                $this->recordsetsMDArray[0][$n] = $this->clmNames[$n];
        }
        */

        $total_rows = 0;
        $rows_count = 0;

        //Save each record and add to multi-dimensional array
        while ($recs = sqlsrv_fetch_array($this->recrodsetResource,SQLSRV_FETCH_NUMERIC)) {
            //rows_count checked here inside loop since odbc_num_rows workaround cost even more.
            
            if ($rows_count > 8000) //8000 row data
                die("Error: Data size is too large. Please select 'Apply Paging' to view the report in HTML and export to the required format.");

            $rowNo = $rows_count + $record_start_at;
            $this->recordsetsMDArray[$rowNo] = array();

            for ($n = 0; $n < $this->clms; $n++) {
                $data_value = stripslashes($recs[$n]);                
                

                if ($call_from == 'AJAX') {
                    $data_value = str_replace("=", 'equal', $data_value);
                    $data_value = str_replace(',', 'comma', $data_value);
                    $data_value = str_replace('?', 'question', $data_value);
                    $data_value = str_replace('%', 'percentage', $data_value);
                }

                if ($flag == 'xml') {
                    $data_value = strip_tags($data_value, '<s><a>');
                    // to convert -,<>' ' character to html entity****************************/
                    $data_value = htmlentities($data_value);
                }

                //strip hyperlink if it is set to do so
                if ($this->strip_hyperlink == true && strpos($data_value, 'openHyperLink') !== false) {
                    //echo $data_value; echo '\n';
                    $start_at = strpos($data_value, '<u>') + 3;
                    //echo $start_at; echo '\n';
                    $data_value = str_replace('&nbsp;', '', substr($data_value, $start_at, strpos($data_value, '</u>') - $start_at));
                    //echo strpos($data_value, '</u>') - $start_at; echo '\n';
                    //die();
                }
                //strip tool tips
                else
                if ($this->strip_hyperlink == true && strpos($data_value, '<span title=') !== false) {
                    $start_at = strpos($data_value, '<0>') + 3;
                    $data_value = substr($data_value, $start_at, strpos($data_value, '<0>', $start_at) - $start_at);
                } else
                if ($this->strip_hyperlink == true) {
                    $data_value = str_replace('&nbsp;', '', $data_value);
                }

                if ($this->clmTypes[$n] == 'float') {
                    if ($data_value == null || $data_value == '')
                        $this->recordsetsMDArray[$rowNo][$n] = $data_value;
                    else
                        $this->recordsetsMDArray[$rowNo][$n] = floatval($data_value);
                } else {
                    $this->recordsetsMDArray[$rowNo][$n] = $data_value;
                }
                $this->recordsets[$total_rows] = $this->recordsetsMDArray[$rowNo][$n];
                $total_rows++;
            }
            $rows_count++;
        }

        // change this also..
        if ($this->clms == 0)
            die($this->buildErrorXML('No Fields Were Returned'));

        $this->rows = ($total_rows / $this->clms) + $record_start_at;
        sqlsrv_cancel($this->recrodsetResource);
        //default return is XML
        if ($this->sql_arr_list[1] == 'spa_create_rec_transaction_report' || $this->sql_arr_list[1] == 'spa_allowance_transfer')
            return $this->recordsetXMLNewFormat();
        else
            return $this->recordsetXML();
    }

    /**
     * Generates XML
     * @return  String  Data XML
     */
    function recordsetXML() {
        $this->recordsetXML = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        $this->recordsetXML .= "<PSRecordSet records='" . $this->rows . "' columns='" . $this->clms . "'>\n";

        $tmpXMLStr = "";

        for ($m = 0; $m < $this->rows; $m++) {
            $tmpXMLStr .= $this->buildBeginRecordXML($m);

            for ($n = 0; $n < $this->clms; $n++) //$tmpXMLStr .= $this->buildClmXML($n, $this->recordsetsMDArray[$m][$n]);
                $tmpXMLStr .= $this->buildClmXML($this->clmNames[$n], $this->recordsetsMDArray[$m][$n]);
            $tmpXMLStr = str_replace('#', '', $tmpXMLStr);
            $tmpXMLStr = str_replace('(%)', '__', $tmpXMLStr);
            $tmpXMLStr = str_replace('__', '_', $tmpXMLStr);
            $tmpXMLStr = str_replace('%', ' ', $tmpXMLStr);
            $tmpXMLStr .= $this->buildEndRecordXML($m);
        }

        $this->recordsetXML .= $tmpXMLStr . "</PSRecordSet>\n";
        return $this->recordsetXML;
    }

    /**
     * Recordset MD
     * @return  Array  Recordest MD
     */
    function recordsetsMDArray() {
       return $this->recordsetsMDArray;
    }

    /**
     * Recordsets
     * @return  Array  Recordsets
     */
    function recordsets() {
       return $this->recordsets;
    }

    /**
     * Run COM Object
     * @param   Object  $comOBJ  COM Object
     * @return  String           XML
     */
    function runCOMObject($comOBJ) {
        $this->clmNames = array();
        $this->recordsets = array();
        $this->recordsetsMDArray = array();
        $this->rows = 0;
        $this->clms = 0;

        if ($this->show_label == true)
            $record_start_at = 1;
        else
            $record_start_at = 0;

        $this->clms = $comOBJ->columnsCount();

        if ($this->show_label == true)
            $this->recordsetsMDArray[0] = array();

        //get column names
        for ($i = 0; $i < $this->clms; $i++) {
            $this->clmNames[$i] = $comOBJ->columnName($i);
            $this->recordsetsMDArray[0][$i] = $this->clmNames[$i];
        }

        $counter = 0;
        $rows_count = 0;

        //populate single dimensional recordset array
        for ($r = 0; $r < $comOBJ->rowsCount(); $r++) {
            $rowNo = $rows_count + $record_start_at;
            $this->recordsetsMDArray[$rowNo] = array();
            for ($c = 0; $c < $this->clms; $c++) {
                $this->recordsets[$counter] = $comOBJ->columnValue($r, $c);
                $this->recordsetsMDArray[$rowNo][$c] = $this->recordsets[$counter];
                $counter++;
            }
            $rows_count++;
        }
        $this->rows = ($counter / $this->clms) + $record_start_at;

        //default return is XML
        return $this->recordsetXML();
    }
    
    /**
     * Recordset in newly formatted XML
     * New function for allowance trnsfer is added  works when [SellAcct],[BuyAcct],[AllwYear] is order by in sql
     * Column order is also [SellAcct],[BuyAcct] is hard code here is 0,1 so it is necessary to keep order in sql
     * in 0,1 order and first 5 order in cloumn is also necessary
     * @return  String  XML
     */
    function recordsetXMLNewFormat() {
        $this->recordsetXML = "<?xml version=\"1.0\" ?>\n";
        $this->recordsetXML .=
                "<Transaction xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:noNamespaceSchemaLocation='allowancetransfer.xsd'>\n";

        $tmpXMLStr = '';
        $clmNamesSellAcctTmp = '';
        $clmNamesBuyAcctTmp = '';
        $isNewAllowance = false;
        $tagOpened = false;

        if (count($this->recordsetsMDArray) > 0) {
            for ($m = 0; $m < $this->rows; $m++) {
                $isNewAllowance = ($clmNamesSellAcctTmp != $this->recordsetsMDArray[$m][0] || $clmNamesBuyAcctTmp != $this->
                        recordsetsMDArray[$m][1]);

                if ($tagOpened && $isNewAllowance) {
                    $tmpXMLStr .= '</SerialBlocks>';
                    $tmpXMLStr .= '</Allowance>';
                    $tagOpened = false;
                }

                if ($isNewAllowance) {
                    $tagOpened = true;
                    $tmpXMLStr .= '<Allowance>';

                    for ($n = 0; $n < 5; $n++)
                        $tmpXMLStr .= $this->buildClmXML($this->clmNames[$n], $this->recordsetsMDArray[$m][$n]);

                    $tmpXMLStr .= '<SerialBlocks>';
                }

                $tmpXMLStr .= '<SerialBlock>';
                for ($n = 5; $n < $this->clms; $n++)
                    $tmpXMLStr .= $this->buildClmXML($this->clmNames[$n], $this->recordsetsMDArray[$m][$n]);
                $tmpXMLStr .= '</SerialBlock>';

                $clmNamesSellAcctTmp = $this->recordsetsMDArray[$m][0];
                $clmNamesBuyAcctTmp = $this->recordsetsMDArray[$m][1];
            }
            $tmpXMLStr .= '</SerialBlocks>';
            $tmpXMLStr .= '</Allowance>';
        }

        $tmpXMLStr = str_replace('#', '', $tmpXMLStr);
        $tmpXMLStr = str_replace('(%)', '__', $tmpXMLStr);
        $tmpXMLStr = str_replace('__', '_', $tmpXMLStr);
        $this->recordsetXML .= $tmpXMLStr . "</Transaction>\n";
        return $this->recordsetXML;
    }

    /**
     * Adds Session Context to SQL Query
     * @param   String  $sql    SQL Query
     * @return  String          SQL Query with added session context
     */
    private function add_session_context($sql) {
        global $app_user_name;
        return "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '" . $app_user_name . "';" . $sql;
    }

}

/**
 * Decodes SQL Query params
 * @param   String  $o_str  SQL Query
 * @return  Array           Decoded SQL Query
 */
function decode_param_sql($o_str) {
    $sql_stmt_name = trim(strtolower($o_str));
    $arrayR = array();

    if (substr($sql_stmt_name, 0, 4) != 'exec') {
        $arrayR[0] = 'Error';
        $arrayR[1] = "<font color=\"red\" font=\"tahoma\" size=3><b>ERROR - Could not locate report name (1).</b></font>";
        return $arrayR;
    }

    //gives the str after EXE
    $sql_stmt_name = trim(substr($sql_stmt_name, 4));

    $pointLoc = strpos($sql_stmt_name, ' ');

    $arrayR[0] = 'Success';
    if ($pointLoc < 1 && $sql_stmt_name != '') {
        $arrayR[1] = $sql_stmt_name;
        $sql_stmt_name = '';
    } else
    if ($pointLoc > 1)
        $arrayR[1] = trim(substr($sql_stmt_name, 0, $pointLoc));
    else {
        $arrayR[0] = 'Error';
        $arrayR[1] = '';
    }

    if ($arrayR[0] == 'Error') {
        $arrayR[0] = 'Error';
        $arrayR[1] = 'ERROR - Could not locate report name (2)';
        return $arrayR;
    }

    //gives the parameters after the sp name
    $sql_stmt_name = trim(substr($sql_stmt_name, $pointLoc));

    $arrayP = explode(',', $sql_stmt_name);
    $count = count($arrayP);

    $nextIndex = 0;
    $tmp_str = '';

    for ($i = 0; $i < $count; $i++) {
        $tmp_str = '';
        if (substr_count($arrayP[$i], "'") == 1) { // split varchar found with "," seperated
            $tmp_str = $arrayP[$i];
            for ($k = $i + 1; $k < $count; $k++) {
                $tmp_str = $tmp_str . ', ' . trim($arrayP[$k]);
                if (substr_count($arrayP[$k], "'") != 0) {
                    $arrayR[2 + $nextIndex] = $tmp_str;
                    $nextIndex = $nextIndex + 1;
                    $i = $k;
                    break;
                }
            }
        } else { // number found or a varchar with '' found
            $arrayR[2 + $nextIndex] = trim($arrayP[$i]);
            $nextIndex = $nextIndex + 1;
        }
    }
    return $arrayR;
}

?>