public with sharing class Obj1Controller 
{
    public List<contact> contacts {get;set;}
    public Obj1Controller()
    {
    contacts = [select accountId, Name, mobilephone, Email from contact limit 10];
    }

}