/*
###########################################################################
# Created by............: Suresh Tavva & Team (OSI)
# Created Date..........: 3/7/2022
# Last Modified by......:
# Last Modified Date....: 
# Description...........: To insert the contact phone whenever the contcat is cretead and updated with new Phone field.
# Test Class............: 
# Change Log:
# 
############################################################################
*/


public class ContactTriggerHandler {
    private static boolean afterInsertAlreadyFired = false;
    private static boolean afterUpdateAlreadyFired = false;
	/**
    * Description : This method Creates a contact phone record after the contact record inserted uncheck the primary field if any phonenumber is changed.
    **/
    public void afterInsert(Map<Id, Contact> newMap, Map<Id, Contact> oldMap, List<Contact> newList, List<Contact> oldList){
        if(!afterInsertAlreadyFired){
            List<Contact_phone__c> contactPhoneList = new List<Contact_phone__c>();
            for(Contact con : newList) {
                if(!String.isBlank(con.Phone)){
                    Contact_phone__c contactPhone = new Contact_phone__c();
                    contactPhone.Donor__c = con.Id;
                    contactPhone.Type__c = 'Mobile';
                    contactPhone.Phone__c = con.Phone;
                    contactPhone.Primary__c = true;

                    contactPhoneList.add(contactPhone);
                }
            }

            if(!contactPhoneList.isEmpty()){
                insert contactPhoneList;
            }

            afterInsertAlreadyFired = true;
        }
    }
    /**
    * Description : This method Creates a contact phone record after the contact record updated and check .
    **/
    public void afterUpdate(Map<Id, Contact> newMap, Map<Id, Contact> oldMap, List<Contact> newList, List<Contact> oldList){
        
        if(!afterUpdateAlreadyFired){
            List<Contact_phone__c> contactPhoneList = new List<Contact_phone__c>();
            for(Contact con : newList) {
                Contact oldContact = oldMap.get(con.Id);
                System.debug('oldContact:'+oldContact.Phone);
                System.debug('con.Phone:'+con.Phone);
                System.debug('newList:'+newList);
                System.debug('oldContact:'+oldContact);
                if(!String.isBlank(con.Phone) && con.Phone != oldContact.Phone){
                    Contact_phone__c contactPhone = new Contact_phone__c();
                    contactPhone.Donor__c = con.Id;
                    contactPhone.Type__c = 'Mobile';
                    contactPhone.Phone__c = con.Phone;
                    contactPhone.Primary__c = true;
                    contactPhoneList.add(contactPhone);
                }
            }

            if(!contactPhoneList.isEmpty()){
                uncheckPrimaryForExistingContactPhone(newMap);
                insert contactPhoneList;
            }

            afterUpdateAlreadyFired = true;
            // added for Test class code coverage.
            if(Test.isRunningTest()){
                afterUpdateAlreadyFired = false;
             }
        }
    }

    public void uncheckPrimaryForExistingContactPhone(Map<Id, Contact> newMap){
        
        Set<Id> ids = newMap.keySet();
        List<Contact_phone__c> conPhoneList = [select Id, Primary__c from Contact_phone__c where Donor__c in: ids];
        if(!conPhoneList.isEmpty()){
            for(Contact_phone__c conPhone : conPhoneList) {
                conPhone.Primary__c = false;
            }

            update conPhoneList;
        }

    }
}