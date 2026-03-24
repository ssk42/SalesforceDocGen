/**
 * Invocable action for starting bulk document generation from a Flow.
 */
public with sharing class DocGenBulkFlowAction {

    /**
     * Input parameters for the bulk document generation Flow action.
     */
    public class Request {
        @InvocableVariable(label='Template ID' required=true)
        public Id templateId;

        @InvocableVariable(label='Query Condition' description='Optional SOQL WHERE clause (e.g. Type = \'Customer\')')
        public String queryCondition;
    }

    /**
     * Output results from the bulk document generation Flow action.
     */
    public class Response {
        @InvocableVariable(label='Job ID')
        public Id jobId;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    /**
     * Starts a bulk document generation batch job for each request.
     * @param requests List of Request objects containing templateId and optional queryCondition
     * @return List of Response objects containing jobId or errorMessage
     */
    @InvocableMethod(label='Generate Bulk Documents' description='Starts a batch job to generate documents for multiple records based on a template and condition.')
    public static List<Response> generateBulkDocuments(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            try {
                // Leverage existing Bulk Controller logic
                Id jobId = DocGenBulkController.submitJob(req.templateId, req.queryCondition, null, false, 1, false);
                res.jobId = jobId;
            } catch (Exception e) {
                res.errorMessage = e.getMessage();
            }
            responses.add(res);
        }

        return responses;
    }
}