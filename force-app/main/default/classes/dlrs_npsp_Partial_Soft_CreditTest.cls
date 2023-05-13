/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_npsp_Partial_Soft_CreditTest
{
    @IsTest
    private static void testTrigger()
    {
Account Acct = new Account(Name='Test'); 
insert Acct; 

Contact Con= new Contact(LastName='Test'); 
insert Con; 

Opportunity Opp = new Opportunity(Name = 'Test', AccountId = Acct.Id, StageName='Received', CloseDate=System.Today(),Entity__c='C3'); 
insert Opp; 

npsp__Partial_Soft_Credit__c SC= new npsp__Partial_Soft_Credit__c(npsp__Contact__c= Con.Id, npsp__Opportunity__c = Opp.Id); 
insert SC;
    }
}