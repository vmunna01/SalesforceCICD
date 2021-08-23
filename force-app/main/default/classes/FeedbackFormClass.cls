public with sharing class FeedbackFormClass 
{
public Comment__c comment{get;set;}
public FeedbackFormClass()
{
comment = new comment__c();
}
    public PageReference saverecords()
     {
        try{
        insert comment;
        } catch (Exception e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'Phone Number must be 10 digits');
        ApexPages.addMessage(myMsg);
}
        PageReference pr = new PageReference('/apex/ThankYouForm');
        return pr;
    }
    public PageReference cancelrecords() 
    {
        PageReference pr1 = new PageReference('/apex/CancelForm');
        return pr1;
    }

}