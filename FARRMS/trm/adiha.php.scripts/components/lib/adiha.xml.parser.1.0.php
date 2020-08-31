<?php

class ADIHAXMLParser {
    private $recordset;
    private $rows;
    private $clms;
    
    //Constructor
    function __construct() {
        $this->recordset = array();
        $this->rows = -1;
        $this->clms = -1;
    }

    // Open and read xml file. You can replace this with your xml data.
    // default is it returns array
    function readXML($xmlFile, $rCount = 0, $stripSlashes = 1, $param_values = array()) {
        global $DEBUG_MODE, $db_servername, $connection_info, $SQLSRV_QUERY_TIME_OUT;
        $sql = '';
        if (stripos(trim($xmlFile), 'EXEC') === 0 || stripos(trim($xmlFile), 'SELECT') === 0) {
            //direct query is passed instead of a php page
            $sql = $xmlFile;
        }
        
        $sql = $this->add_session_context($sql);

        if (!$DEBUG_MODE)
            error_reporting(0);

        $db_server_name = $db_servername;
        $link = sqlsrv_connect($db_server_name, $connection_info);
        $result = sqlsrv_query($link, $sql, $param_values, $SQLSRV_QUERY_TIME_OUT);
        if (!$result) {
            sqlsrv_errors();
        }

        $y_index = 0;
        while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_NUMERIC)) {
            $count = count($row);
            for ($y = 0; $y < $count; $y++) {
                $this->recordset[$y_index][$y] = $row[$y];
            }
            $y_index++;
            $this->clms = $y;
        }

        sqlsrv_free_stmt($result);
        sqlsrv_close($link);
        $this->rows = $y_index;
        
        return $this->recordset;
    }

    function rows_count() {
        return $this->rows;
    }

    function clms_count() {
        return $this->clms;
    }

    // 1 is array
    // 2 is dropdown
    // 3 is grid
    function return_value($return_type) {
        // check here for $ret_type and call appropriate functions
        // if $return_type = 1 return $recordset;
        // if $return_type = 2 return build_combo();
        // if $return_tyep = 3 return build_listbox()

        if ($return_type == 1)
            return $this->recordset;

        if ($return_type == 2)
            return $this->build_combo();
    }

    function build_combo() {
        
    }

    function build_grid() {
        
    }

    function GetElementByName($xml, $start, $end, &$pos) {
        $startpos = strpos($xml, $start);

        if ($startpos === false) {
            return false;
        }

        $endpos = strpos($xml, $end);
        $endpos = $endpos + strlen($end);
        $pos = $endpos;
        $endpos = $endpos - $startpos;
        $endpos = $endpos - strlen($end);
        $tag = substr($xml, $startpos, $endpos);
        $tag = substr($tag, strlen($start));

        return $tag;
    }

    // Trim trailing zeroes after a decimal (used for parsing of numeric data type here)
    function rtrimZero($number) {
        $x = explode('.', $number);
        $left = $x[0];
        $right = '';

        if (count($x) > 1) {
            $right = rtrim($x[1], '0.');
            if (strlen($right) > 0) {
                $right = '.' . $right;
            }
        }

        if (strlen($left) == 0) {
            $left = '0';
        }

        return $left . $right;
    }

    function readXMLFunction($xmlFile, $preserve_col_name = false, $param_values = array()) {
        global $DEBUG_MODE, $db_servername, $connection_info, $SQLSRV_QUERY_TIME_OUT;
        $sql = '';
        if (stripos(trim($xmlFile), 'EXEC') === 0 || stripos(trim($xmlFile), 'SELECT') === 0) {
            $sql = $xmlFile;
        }
        
        $sql = $this->add_session_context($sql);
        
        if (!$DEBUG_MODE)
            error_reporting(0);

        $db_server_name = $db_servername;
        $link = sqlsrv_connect($db_server_name, $connection_info);
        
        $result = sqlsrv_query($link, $sql, $param_values, $SQLSRV_QUERY_TIME_OUT);

        if (!$result) {
            sqlsrv_errors();
        }

        $z = 0;
        foreach (sqlsrv_field_metadata($result) as $fieldMetadata) {
            $value = $fieldMetadata['Name'];
            if (!$preserve_col_name) {
                $field_name = str_replace(" ", "_", strtolower($value));
            } else {
                $field_name = $value;
            }
            $this->clmTypes[$z] = $field_name;
            $z++;
        }

        $y_index = 0;
        while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_NUMERIC)) {
            $count = count($row);
            for ($y = 0; $y < $count; $y++) {
                $column_name = $this->clmTypes[$y];
                $this->recordset[$y_index][$column_name] = $row[$y];
            }
            $y_index++;
            $this->clms = $y;
        }
        sqlsrv_free_stmt($result);
        sqlsrv_close($link);
        $this->rows = $y_index;
        return $this->recordset;
    }

    function readXMLFunctionCached($xmlFile, $preserve_col_name = false, $key_prefix='', $key_suffix='', $append_user_name=true, $key_expiry_time=0, $data_source='general', $param_values = array()) { 
        global $DEBUG_MODE, $db_servername, $connection_info, $SQLSRV_QUERY_TIME_OUT, $ENABLE_DATA_CACHING;
        
        if ($ENABLE_DATA_CACHING) {
            $cache_data = ($key_prefix != '' && $key_prefix != 'null') ? true : false;

            if (!$DEBUG_MODE)
                error_reporting(0);

            $fetch_data = 1;
            $data_cache = new DataCache(); 
            if (!$data_cache->is_cache_server_exists()) {
                $cache_data = false;
            }

            if ($cache_data == true) {
               $k = $data_cache->get_key($key_prefix, $key_suffix, false, $append_user_name);
               $cached_data = $data_cache->get_data($k);

               if (!empty($cached_data)) {
                   $this->recordset = $cached_data;
                   $fetch_data = 0;                   
               } else {
                   $fetch_data = 1;
               }
            }
            
            if ($fetch_data == 1) {
                if (stripos(trim($xmlFile), 'EXEC') === 0 || stripos(trim($xmlFile), 'SELECT') === 0) {
                    $sql = $xmlFile;
                }
                $sql = $this->add_session_context($sql);

                $db_server_name = $db_servername;
                $link = sqlsrv_connect($db_server_name, $connection_info);

                $result = sqlsrv_query($link, $sql, $param_values, $SQLSRV_QUERY_TIME_OUT);
                if (!$result) {
                    sqlsrv_errors();
                }

                $z = 0;
                foreach (sqlsrv_field_metadata($result) as $fieldMetadata) {
                    $value = $fieldMetadata['Name'];
                    if (!$preserve_col_name) {
                        $field_name = str_replace(" ", "_", strtolower($value));
                    } else {
                        $field_name = $value;
                    }
                    $this->clmTypes[$z] = $field_name;
                    $z++;
                }

                $y_index = 0;
                while ($row = sqlsrv_fetch_array($result, SQLSRV_FETCH_NUMERIC)) {
                    $count = count($row);
                    for ($y = 0; $y < $count; $y++) {
                        $column_name = ($data_source == 'general') ? $this->clmTypes[$y] : $y;
                        $this->recordset[$y_index][$column_name] = $row[$y];
                    }
                    $y_index++;
                    $this->clms = $y;
                }

                sqlsrv_free_stmt($result);
                sqlsrv_close($link);

                $this->rows = $y_index;

                if ($cache_data == true) {
                    $data_cache->set_data($k, $this->recordset,$key_expiry_time);
                }
            }
            if ($cache_data == true) {
                $data_cache->close_conn();
            }   
            return $this->recordset;
        } else {
            if ($data_source == 'general')
                $this->recordset = $this->readXMLFunction($xmlFile, $preserve_col_name, $param_values);
            else
                $this->recordset = $this->readXML($xmlFile, 0, 1, $param_values);
        }
        return $this->recordset;
    }

    /**
     * Adds Session Context to SQL Query
     * @param String $sql SQL Query
     * @return String     SQL Query with added session context
     */
    private function add_session_context($sql) {
        global $app_user_name;
        return "EXEC sys.sp_set_session_context @key = N'DB_USER', @value = '" . $app_user_name . "';" . $sql;
    }
}
?>