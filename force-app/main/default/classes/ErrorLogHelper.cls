/**
    Trigger Name:   ErrorLogHelper
    Description:    Generic Helper for inserting records into the Error Log object
    Created By:     Frederick Valle
    Created Date:   4/29/2020
    Test Class:     ErrorLogHelperTest

    Modification History:
    Author      Date            Description
    FVALLE      9/14/2020       Add DMLResultCounter
*/

public with sharing class ErrorLogHelper {
    
    // Update / Insert DML
    public static void logDMLResult (List <Database.SaveResult> srLst, 
                                        String apexObj, 
                                        String apexMethod,
                                        String objName) {
        List <Error_Log__c> errLst = new List <Error_Log__c> ();
        for (Database.SaveResult sr: srLst) {
            if (!sr.isSuccess()) {
                errLst.add (
                    createErrorLog (sr.getErrors(), apexObj, apexMethod, objName)
                );
            }
        }

        createLog (errLst);
    }

    // Delete DML
    public static void logDMLResult (List <Database.DeleteResult> srLst, 
                                        String apexObj, 
                                        String apexMethod,
                                        String objName) {
        List <Error_Log__c> errLst = new List <Error_Log__c> ();
        for (Database.DeleteResult sr: srLst) {
            if (!sr.isSuccess()) {
                errLst.add (
                    createErrorLog (sr.getErrors(), apexObj, apexMethod, objName)
                );
            }
        }

        createLog (errLst);
    }

    @TestVisible 
    static void createLog (List <Error_Log__c> errLst) {
        if (errLst.size () > 0) { 
            database.insert (errLst, false); 
        }
    }

    // Get all errors 
    @TestVisible
    static String getAllErrors (List <Database.Error> errLst) {
        String errStr = '';
        for (Database.Error err: errLst) {
            errStr = errStr + 'StatusCode: ' + err.getStatusCode() + '\n' +
                              'Message: ' + err.getMessage() + '\n' +
                              'Fields: ' + err.getFields();
        }
        return errStr;
    }

    // Create an instance of the Error_Log__c object
    @TestVisible
    static Error_Log__c createErrorLog (List <Database.Error> errLst, 
                                        String apexObj, 
                                        String apexMethod,
                                        String objName) {
        return new Error_Log__c (
            Object_Name__c          = objName,
            Apex_Class_Trigger__c   = apexObj,
            Method_Name__c          = apexMethod,
            Description__c          = getAllErrors (errLst).left (32700),
            Severity__c             = 'ERROR',
            Type__c                 = 'Error'
        );
    }

    // FVALLE 9/14/2020 DML Result Counters
    public class DMLResultCounter {
        @TestVisible Integer failCtr     = 0;
        @TestVisible Integer successCtr  = 0;

        public DMLResultCounter (List <Database.SaveResult> srLst) {
            for (Database.SaveResult sr: srLst) {
                if (sr.isSuccess()) { this.successCtr ++; }
                else {
                    this.failCtr ++;
                    system.debug ('ERRORS: ' + getAllErrors (sr.getErrors()));
                }
            }
        }
        public Integer getSuccess () { return this.successCtr;}
        public Integer getFail () { return this.failCtr;}
    }
}