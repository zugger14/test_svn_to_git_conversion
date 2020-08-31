<?php

class WorkflowController extends REST {
    public function index() {
        $results = Workflow::find();
        $this->response($this->json($results), 200);
    }

    public function get($messageId) {
        $results = Workflow::findOne($messageId);
        $this->response($this->json($results[0]), 200);
    }
    
    /*
    public function delete($messageId) {
        $results = Workflow::deleteOne($messageId);
        $this->response($this->json($results[0]));
    }
    */
    
     public function delete($body) {
        $activity_ids = $body->ids;
        
        $results = Workflow::delete($activity_ids);
        
        if (isset($results[0]['ErrorCode']) && $results[0]['ErrorCode'] = 'Success') {
            /*$json = array(
                'message' => $results[0]['Message'],
                "ids" => $activity_ids
            );
            $this->response($this->json($json));
            */
            $this->index();
        } else {
            $this->sendError(400, $results[0]['Message']);
        }
    }
    
    public function action($body) {
        $workflow_action = $body->action;
        $activity_ids = $body->ids;
        
        $results = Workflow::action($workflow_action, $activity_ids);
        
        if (isset($results[0]['ErrorCode']) && $results[0]['ErrorCode'] = 'Success') {
            /*
            $json = array(
                'message' => $results[0]['Message'],
                "ids" => $activity_ids
            );
            $this->response($this->json($json));
            */
            $this->index();
        } else {
            $this->sendError(400, $results[0]['Message']);
        }
    }
    
    /*
    public function action($activity_id, $body) {
        $workflow_method = $body->method;
        $workflow_action = $body->action;
        if ($workflow_method == 'put' || $workflow_method == 'PUT') {
            $results = Workflow::action($activity_id, $workflow_action);
            $this->response($this->json($results[0]));    
        }
        
    }
    */
}
