/**
    Trigger Name:   DMLQueueable
    Description:    Generic apex for handling DML asynchronously using Queueable
    Created By:     Frederick Valle
    Created Date:   4/29/2020
    Test Class:     DMLQueueableTest
    
    Modification History:
    Author      Date        Description
    FVALLE      11/24/2020  Added chainable DML chunking 
    FVALLE      01/26/2021  Added check for asyncSkipMap. This can be used to skip certain parts of the Trigger logic from asynchronous process

    TODO: Add Limits.getQueueableJobs() == 0 check, if FALSE process synchronously
*/


public without sharing class DMLQueueable  {

    public enum OPERATION {FOR_INSERT, FOR_UPDATE, FOR_DELETE, FOR_UPSERT, CHUNK_INSERT, CHUNK_UPDATE, CHUNK_DELETE, CHUNK_UPSERT}
    
    @TestVisible OPERATION oper;
    @TestVisible List <sObject> dmlObjectLst;
   
    public static Map <String, Boolean> asyncSkipMap = new Map <String, Boolean> ();
    
    // Inner class that implements Queueable 
    public class ExecuteQueueable implements Queueable, Database.AllowsCallouts {
        @TestVisible List <sObject> objLst; 
        @TestVisible DMLQueueable.OPERATION oper;
        @TestVisible String objType;
        @TestVisible Map <String, Boolean> asyncSkipMap = new Map <String, Boolean> ();

        @TestVisible Inputs input;
        
        // Non Chunked DML Constructor
        public ExecuteQueueable (List <sObject> objLst, DMLQueueable.OPERATION oper, Map <String, Boolean> asyncSkipMap) {
            this.objLst = objLst;
            // Assumption: dmlObjectLst collection contains only one sObjectType 
            this.objType = DMLQueueable.isNotEmpty (objLst)? String.valueOf (objLst[0].getsObjectType()): ''; 
            this.oper = oper;
            this.asyncSkipMap = asyncSkipMap;
        }

        // Chunked DML Constructor
        public ExecuteQueueable (Inputs input) {
            this.input  = input;
            this.oper   = input.oper;
            this.asyncSkipMap = input.asyncSkipMap;
        }

        // Execute implementation
        public void execute (QueueableContext context) {
            
            system.debug ('DLMQueueable Processing operation for ' + this.oper.name() + '.');

            if (this.asyncSkipMap.size () > 0) { DMLQueueable.asyncSkipMap = this.asyncSkipMap; }

            switch on this.oper {
                when FOR_INSERT {
                    ErrorLogHelper.logDMLResult (Database.insert (objLst, false), 'DMLQueueable', this.oper.name(), objType);
                }	
                when FOR_UPDATE {		
                    ErrorLogHelper.logDMLResult (Database.update (objLst, false), 'DMLQueueable', this.oper.name(), objType);
                }
                when FOR_DELETE {		
                    ErrorLogHelper.logDMLResult (Database.delete (objLst, false), 'DMLQueueable', this.oper.name(), objType);
                }
                when CHUNK_INSERT {
                    if (this.input.hasMoreChunk()) {
                        this.objLst = input.getChunk(); // Gets the chunk and removes the processed key from input.chunkMap

                        if (DMLQueueable.isNotEmpty (objLst)) {
                            this.objType = DMLQueueable.isNotEmpty (this.objLst)? String.valueOf (objLst[0].getsObjectType()): ''; 

                            // Insert sObject List associated to current chunk
                            ErrorLogHelper.logDMLResult (Database.insert (objLst, false), 'DMLQueueable', this.oper.name(), objType);
                        }
                        
                        // Check if there's more Chunk to chain for processing
                        if (this.input.hasMoreChunk() && !Test.isRunningTest()) { System.enqueueJob (new ExecuteQueueable (input)); }
                    }
                }
                when CHUNK_UPDATE {
                    if (this.input.hasMoreChunk()) {
                        this.objLst = input.getChunk(); // Gets the chunk and removes the processed key from input.chunkMap
                        
                        if (DMLQueueable.isNotEmpty (objLst)) {
                            this.objType = DMLQueueable.isNotEmpty (this.objLst)? String.valueOf (objLst[0].getsObjectType()): ''; 

                            // Insert sObject List associated to current chunk
                            ErrorLogHelper.logDMLResult (Database.update (objLst, false), 'DMLQueueable', this.oper.name(), objType);
                        }

                        // Check if there's more Chunk to chain for processing
                        if (this.input.hasMoreChunk() && !Test.isRunningTest()) { System.enqueueJob (new ExecuteQueueable (input)); }
                    }
                }
                when CHUNK_DELETE {
                    if (this.input.hasMoreChunk()) {
                        this.objLst = input.getChunk(); // Gets the chunk and removes the processed key from input.chunkMap

                        if (DMLQueueable.isNotEmpty (objLst)) {
                            this.objType = DMLQueueable.isNotEmpty (this.objLst)? String.valueOf (objLst[0].getsObjectType()): ''; 

                            // Insert sObject List associated to current chunk
                            ErrorLogHelper.logDMLResult (Database.delete (objLst, false), 'DMLQueueable', this.oper.name(), objType);
                        }

                        // Check if there's more Chunk to chain for processing
                        if (this.input.hasMoreChunk() && !Test.isRunningTest()) { System.enqueueJob (new ExecuteQueueable (input)); }
                    }
                }
            }
        }
    }

    // Insert sObject List 
    public static void asyncInsert (List <sObject> dmlObjectLst) {
        if (DMLQueueable.isNotEmpty (dmlObjectLst)) {
            System.enqueueJob (new ExecuteQueueable (dmlObjectLst, OPERATION.FOR_INSERT, asyncSkipMap));
        }
    }

    // Chunk Insert 
    public static void asyncInsert (List <SObject> dmlObjectLst, Integer chunkSize) {
        processChunk (dmlObjectLst, chunkSize, new OperationInputs (OPERATION.CHUNK_INSERT, OPERATION.FOR_INSERT));
    }

    // Insert single sObject
    public static void asyncInsert (sObject sObj) {
        if (sObj != null) {
            System.enqueueJob (new ExecuteQueueable (new List <sObject> {sObj}, OPERATION.FOR_INSERT, asyncSkipMap));
        }
    }
    
    // Update sObject List 
    public static void asyncUpdate (List <sObject> dmlObjectLst) {
        if (DMLQueueable.isNotEmpty (dmlObjectLst)) {
            System.enqueueJob (new ExecuteQueueable (dmlObjectLst, OPERATION.FOR_UPDATE, asyncSkipMap));
        }
    }

    // Chunk Update
    public static void asyncUpdate (List <SObject> dmlObjectLst, Integer chunkSize) {
        processChunk (dmlObjectLst, chunkSize, new OperationInputs (OPERATION.CHUNK_UPDATE, OPERATION.FOR_UPDATE));
    }

    // Update single sObject
    public static void asyncUpdate (sObject sObj) {
        if (sObj != null) {
            System.enqueueJob (new ExecuteQueueable (new List <sObject> {sObj}, OPERATION.FOR_UPDATE, asyncSkipMap));
        }
    }

    // Delete sObject List 
    public static void asyncDelete (List <sObject> dmlObjectLst) {
        if (DMLQueueable.isNotEmpty (dmlObjectLst)) {
            System.enqueueJob (new ExecuteQueueable (dmlObjectLst, OPERATION.FOR_DELETE, asyncSkipMap));
        }
    }

    // Chunk Delete 
    public static void asyncDelete (List <SObject> dmlObjectLst, Integer chunkSize) {
        processChunk (dmlObjectLst, chunkSize, new OperationInputs (OPERATION.CHUNK_DELETE, OPERATION.FOR_DELETE));
    }

    // Delete single sObject
    public static void asyncDelete (sObject sObj) {
        if (sObj != null) {
            System.enqueueJob (new ExecuteQueueable (new List <sObject> {sObj}, OPERATION.FOR_DELETE, asyncSkipMap));
        }
    }

    // Generic helper
    // Check if object collection is not empty
    @TestVisible static Boolean isNotEmpty (List <sObject> objLst) {
        return (objLst != null && objLst.size () > 0);
    }

    // Process Chunking and enqueue appropriate queueable job
    @TestVisible static void processChunk (List <SObject> dmlObjectLst, Integer chunkSize, OperationInputs operationInput) {
        if (DMLQueueable.isNotEmpty (dmlObjectLst)) {
            if (dmlObjectLst.size() > chunkSize) {
                
                Map <Integer, List <sObject>> chunkMap = new ObjectParser ().chunk (dmlObjectLst, chunkSize);
                if (chunkMap.size () > 0) {
                    Inputs input = new Inputs (chunkMap, operationInput.forChunkOperation, asyncSkipMap);
                    System.enqueueJob (new ExecuteQueueable (input));
                }
            }
            else {
                System.enqueueJob (new ExecuteQueueable (dmlObjectLst, operationInput.forNonChunkOperation, asyncSkipMap));
            }
        }
    }

    // Chunk/Non Chunk Operation key pairing
    public class OperationInputs {
        // Attributes 
        public OPERATION forChunkOperation { get; set; }
        public OPERATION forNonChunkOperation { get; set; }

        // Constructor 
        public OperationInputs (OPERATION chunkOperation, OPERATION nonChunkOperation) {
            this.forChunkOperation    = chunkOperation;
            this.forNonChunkOperation = nonChunkOperation;
        }
    }

    // Input Wrapper
    public class Inputs {
        // Attributes
        @TestVisible Map <Integer, List <sObject>> chunkMap;
        @TestVisible OPERATION oper;
        @TestVisible Map <String, Boolean> asyncSkipMap;
        
        // Constructor 
        public Inputs (Map <Integer, List <sObject>> chunkMap, OPERATION oper, Map <String, Boolean> asyncSkipMap ) {
            this.chunkMap = chunkMap;
            this.oper = oper;
            this.asyncSkipMap = asyncSkipMap;
        }

        // Verify if there's more chunk to process
        public Boolean hasMoreChunk () { return this.chunkMap != null && this.chunkMap.size () > 0; }

        // Get an element from keySet
        public List <sObject> getChunk () { 
            List <sObject> objLst = new List <sObject> ();
            
            if (hasMoreChunk ()) {
                // Get chunk key to process 
                Integer keyToProcess = keyPop();

                // Get chunk value to Process
                objLst = new List <sObject> (this.chunkMap.get (keyToProcess));

                // Remove returned key from chunkMap
                this.chunkMap.remove (keyToProcess);
            }
            
            return objLst;
        }

        // Get an element from keySet
        @TestVisible Integer keyPop () { return new List <Integer> (this.chunkMap.keySet())[0]; }
    }
}