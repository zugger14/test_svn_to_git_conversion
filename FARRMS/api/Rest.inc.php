<?php
	/**
	*  @brief REST Rest API Class
	*
	*  @par Description
	*  This class is used to handle all REST API functionalities.	
	*  @copyright Pioneer Solutions.
	*/
	class REST {

		public $_allow = array();
		public $_content_type = "application/json";
		public $_request = array();

		private $_method = "";
		private $_code = 200;

		/**
		 * Constructor
		 */
		public function __construct(){
			$this->inputs();
		}

		/**
		 * Get HTTP Referer
		 *
		 * @return  String  HTTP Referer value
		 */
		public function get_referer(){
			return $_SERVER['HTTP_REFERER'];
		}

		/**
		 * Set Request Response
		 *
		 * @param   Array  $data    Data
		 * @param   Integer  $status  	Response Status
		 */
		public function response($data,$status=''){
          
            if ($status <> '') {
                $this->_code = $status;
            } else {
                if(count(json_decode($data)) > 0 && $data <> '[]') {
                    $this->_code = 200;
                } else {
                    $this->_code = 400;
                    $data = $this->json(array('message' => 'Bad Request.'));
                }
            }
          
			//$this->_code = ($status)?$status:200;
			$this->set_headers();
			echo $data;
			exit;
		}

		/**
		 * Returns status message based on code
		 *
		 * @return  String  Status Message
		 */
		private function get_status_message(){
			$status = array(
						100 => 'Continue',
						101 => 'Switching Protocols',
						200 => 'OK',
						201 => 'Created',
						202 => 'Accepted',
						203 => 'Non-Authoritative Information',
						204 => 'No Content',
						205 => 'Reset Content',
						206 => 'Partial Content',
						300 => 'Multiple Choices',
						301 => 'Moved Permanently',
						302 => 'Found',
						303 => 'See Other',
						304 => 'Not Modified',
						305 => 'Use Proxy',
						306 => '(Unused)',
						307 => 'Temporary Redirect',
						400 => 'Bad Request',
						401 => 'Unauthorized',
						402 => 'Payment Required',
						403 => 'Forbidden',
						404 => 'Not Found',
						405 => 'Method Not Allowed',
						406 => 'Not Acceptable',
						407 => 'Proxy Authentication Required',
						408 => 'Request Timeout',
						409 => 'Conflict',
						410 => 'Gone',
						411 => 'Length Required',
						412 => 'Precondition Failed',
						413 => 'Request Entity Too Large',
						414 => 'Request-URI Too Long',
						415 => 'Unsupported Media Type',
						416 => 'Requested Range Not Satisfiable',
						417 => 'Expectation Failed',
						500 => 'Internal Server Error',
						501 => 'Not Implemented',
						502 => 'Bad Gateway',
						503 => 'Service Unavailable',
						504 => 'Gateway Timeout',
						505 => 'HTTP Version Not Supported');
			return ($status[$this->_code])?$status[$this->_code]:$status[500];
		}
		
		/**
		 * Get Request Method 
		 *
		 * @return  String  E.g. GET, POST
		 */
		public function get_request_method(){
			return $_SERVER['REQUEST_METHOD'];
		}

		/**
		 * Get Inputs that Keep in Inputs on buffer
		 */
		private function inputs(){
			switch($this->get_request_method()){
				case "POST":
					$this->_request = $this->cleanInputs($_POST);
                    if (isset($_GET['deal_id'])) {
                        $this->_request['deal_id'] = $_GET['deal_id'];
                    }
					break;
				case "GET":
				case "DELETE":
					$this->_request = $this->cleanInputs($_GET);
					break;
				case "PUT":
					parse_str(file_get_contents("php://input"),$this->_request);
					$this->_request = $this->cleanInputs($this->_request);
					break;
				default:
					$this->response('',406);
					break;
			}
		}
		
		/**
		 * Cleanup Inputs
		 *
		 * @param   Array  $data  Data to be trimmed
		 *
		 * @return  Array         Inputs
		 */
		private function cleanInputs($data){
			$clean_input = array();
			if(is_array($data)){
				foreach($data as $k => $v){
					$clean_input[$k] = $this->cleanInputs($v);
				}
			}else{
				if(get_magic_quotes_gpc()){
					$data = trim(stripslashes($data));
				}
				$data = strip_tags($data);
				$clean_input = trim($data);
			}
			return $clean_input;
		}

		/**
		 * Set Header
		 */
		private function set_headers(){
			header("HTTP/1.1 ".$this->_code." ".$this->get_status_message());
			header("Content-Type:".$this->_content_type);
		}

		/**
		 * Get Input Body
		 *
		 * @return  Array  Inputs
		 */
        public function getContent() {
            $inputJSON = file_get_contents('php://input', 'r');
            $inputs = json_decode( $inputJSON, TRUE ); //convert JSON into array
            return $inputs;
        }

		/**
		 * Set Header
		 *
		 * @return  Array  Header Data
		 */
        private function getHeaders(){
            $headers = array();
            foreach ($_SERVER as $name => $value) {
                $headers[$name] = $value;
            }
            return $headers;
        }

		/**
		 * Get Header based On provided Code
		 *
		 * @param   String  $header_code  Code
		 *
		 * @return  Array                Header data of provided Code
		 */
        public function getHeader($header_code) {
            $header = $this->getHeaders();
            return $header[$header_code];
        }

		/**
		 * Add Quotes
		 *
		 * @param   String  $str  String to be quoted
		 *
		 * @return  String        Quoted String
		 */
        public function addQuotes($str){
            return "'$str'";
        }

		/**
		 * Format Date String
		 *
		 * @param   String  $date  Date String
		 *
		 * @return  [type]         Formatted Date String
		 */
        public function formatDate($date){
            //return "'" . date('Y-m-d', $date) . "'";
            return substr($date, 0, 10);
        }

		/**
		 * Return ]SON encoded Data
		 *
		 * @param   Array  $data  Data
		 *
		 * @return  JSON         JSON Object
		 */
        public function json($data) {
            if (is_array($data)) {
                return json_encode($data);
            }
        }

		/**
		 * Send Error
		 *
		 * @param   Integer  $code    	Error Code
		 * @param   String  $message  Error Message
		 *
		 * @return  JSON            Message as JSON Object
		 */
        public function sendError($code, $message) {
            $json = array(
                'message' => $message
            );
            $this->response($this->json($json), $code);
        }
		
		/**
		 * Write API Request Log in File
		 *
		 * @param   String  $app_user_name  Application User name
		 * @param   String  $currentRoute   Route
		 * @param   String  $method         Method Type GET, POST
		 * @param   Array  $body           Request Body
		 */
        public function writeLogFile($app_user_name, $currentRoute, $method, $body) {
            if ($method == 'POST' || $method == 'PUT' || $method == 'DELETE') {
                $body = json_encode($body);
                $log = 'User : "' . $app_user_name . '" ' . date('H:i:s') . ' || Route: ' . $currentRoute . ' || Body:' . $body ."\r\n";
                file_put_contents('./log/log_'.date("j.n.Y").'.txt', $log, FILE_APPEND);
            } else {
                $log = 'User : "' . $app_user_name . '" ' . date('H:i:s') . ' || Route: ' . $currentRoute . ' || Token:' . $body ."\r\n";
                file_put_contents('./log/log_'.date("j.n.Y").'.txt', $log, FILE_APPEND);   
            }
            
			## Delete log files prior to 7 days
            $folder_name = './log';
            if (file_exists($folder_name)) {
                $time = time();
                $ctime = 7*24*60*60;
                foreach (new DirectoryIterator($folder_name) as $fileInfo) {
                    if ($fileInfo->isDot()) {
                    continue;
                    }
                    if ($time - $fileInfo->getCTime() >= $ctime) {
                        ## Unlink error is suppressed because we cannot handle the error caused while deleting old log files due to file owner change.
						## Owner change normally happens in development server when user opens the log file and saves unintentionally.
						## In production server display errors will be off so will not generate error anyway.
						@unlink($fileInfo->getRealPath());
                    }
                }
            }
        }

	}
?>
