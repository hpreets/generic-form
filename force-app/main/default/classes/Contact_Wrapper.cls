public class Contact_Wrapper {
    private Contact contact;
    private Contact_Email__c contactEmail;
    private Contact_Phone__c contactPhone;
   // private CV__Related_Address_Detail__c contactAddress;
    @auraenabled public String FirstName;
    @auraenabled public String LastName;
    @auraenabled public String Email;
    @auraenabled public String Phone;
    @auraenabled public String MailingStreet;
    @auraenabled public String StreetAddressLine2;
    @auraenabled public String MailingCity;
    @auraenabled public String MailingState;
    @auraenabled public String MailingStateDropdown; // Added by Harpreet (OSI) 
    @auraenabled public String MailingCountry;
    @auraenabled public String MailingPostalCode;
    @auraenabled public String Id;
    @auraenabled public String AccountId;
    @auraenabled public String RecordTypeId;
    
    public Contact_Wrapper() {
        contact = new Contact();
        contactEmail = new Contact_Email__c();
        contactPhone = new Contact_Phone__c();
       // contactAddress = new  cv__Related_Address_Detail__c();

    }
    
    public Contact_Wrapper(Contact con) {
        setContactValues(con);
    }
    public void setContactValues(Contact con) {
        System.debug('Contact_Wrapper setContactValues con :::' + con);
        contact = con;
        list<contact_phone__c> conPhoneList = con.contact_phones__r;
        list<contact_email__c> conEmailList = con.contact_emails__r;
       // list<cv__Related_Address_Detail__c> conAddressList = con.Cv__Related_Addresses__r;

        if(conPhoneList.size()>0) {
            contactPhone = conPhoneList[0];
        }
        else contactPhone = new Contact_Phone__c();

        if(conEmailList.size()>0) {
            contactEmail = conEmailList[0];
        }
        else contactEmail = new Contact_Email__c();
        
       /* if(conAddressList.size()>0) {
            contactAddress = conAddressList[0];
        }
        else contactAddress = new  cv__Related_Address_Detail__c();*/
        
        FirstName = contact.FirstName;
        LastName = contact.LastName;
        Email = contact.email;
        Phone = contact.Phone;
        MailingStreet = contact.MailingStreet;
        MailingCity = contact.MailingCity;
        MailingState = contact.MailingState;
        MailingCountry = contact.MailingCountry;
        MailingPostalCode = contact.MailingPostalCode;
        Id = contact.Id;
        AccountId = contact.AccountId;
        //RecordTypeId = contact.RecordTypeId;
    }

    public Contact_Wrapper(Contact con,Contact_email__c conEmail,Contact_phone__c conPhone/*,Cv__Related_Address_Detail__c conAddress*/) {
        contact = con;
        contactEmail = conEmail == null ? new Contact_Email__c() : conEmail;
        contactPhone = conPhone == null ? new Contact_Phone__c() : conPhone;
       // contactAddress = conAddress == null ? new cv__Related_Address_Detail__c() : conAddress;
        
        FirstName = contact.FirstName;
        LastName = contact.LastName;
        Email = conEmail.Email__c;
        Phone = conPhone.Phone__c;
        /*MailingStreet = conAddress.cv__Mailing_Street__c;
        if(contactAddress.cv__Mailing_Street__c!=null && contactAddress.cv__Mailing_Street__c.split('\n').size()>0) 
            MailingStreet = contactAddress.cv__Mailing_Street__c.split('\n')[0]; 
        else 
            MailingStreet = '';
        if(contactAddress.cv__Mailing_Street__c!=null && contactAddress.cv__Mailing_Street__c.split('\n').size()>1) 
            StreetAddressLine2 = contactAddress.cv__Mailing_Street__c.split('\n')[1]; 
        else 
            StreetAddressLine2 = '';
        MailingCity = conAddress.cv__Mailing_City__c;
        MailingState = conAddress.cv__Mailing_State__c;
        MailingCountry = conAddress.cv__Mailing_Country__c;
        MailingPostalCode = conAddress.cv__Mailing_Zip__c;
        Id = contact.Id;
        AccountId = contact.AccountId;
        RecordTypeId = contact.RecordTypeId;*/
    }
    
    public Contact_Wrapper(String contactId) {
//      List<Contact> contList = [select Id, AccountId, FirstName, LastName, Email, Phone, RecordTypeId, MailingStreet, Street_Address_Line_2__c, MailingCity, MailingState, MailingCountry, MailingPostalCode from Contact where Id = :contactId];

        System.debug('Contact_Wrapper constructor contactId :::' + contactId);
        List<Contact> contList 
            = [Select Id, FirstName, LastName, Email, Phone, AccountId, /*RecordTypeId,*/ 
                    Constituency__c, Sub_Constituency__c, 
                    (Select id,name,Donor__c,Email__c,Primary__c 
                        from Contact_Emails__r 
                        where Created_from_Fellow_App__c = true
                            and Donor__c = :contactId)/*,
                    (Select id,name,cv__Address_Type__c, Created_from_Fellow_App__c,cv__Mailing_City__c,
                            cv__Mailing_Country__c,cv__Mailing_State__c,cv__Mailing_Street__c,
                            cv__Mailing_Zip__c, cv__Primary__c,cv__Start_Date__c,Source__c,cv__Contact__c 
                        from Cv__Related_Addresses__r 
                        where Created_from_Fellow_App__c = true
                            and cv__Contact__c = :contactId)*/,
                    (Select id,name,Donor__c,Phone__c,Created_from_Fellow_App__c, Primary__c 
                        from Contact_Phones__r 
                        where Created_from_Fellow_App__c =true
                            and Donor__c = :contactId),
                    MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode, OwnerId 
                From Contact 
                Where Id = :contactId];

        System.debug('Contact_Wrapper constructor contList :::' + contList);
        if (contList != null  &&  contList.size() > 0) {
            System.debug('Contact_Wrapper constructor contList.get(0) :::' + contList.get(0));
            setContactValues(contList.get(0));
/*          contact = contList.get(0);
            list<contact_phone__c> conPhoneList = contact.contact_phones__r;
            list<contact_email__c> conEmailList = contact.contact_emails__r;
            list<cv__Related_Address_Detail__c> conAddressList = contact.Cv__Related_Addresses__r;
            if(conPhoneList.size()>0) {
                    contactPhone = conPhoneList[0];
            }
            else
                contactPhone = new contact_phone__c();  
            if(conEmailList.size()>0) {
                    contactEmail = conEmailList[0];
            }
            else
                contactEmail = new contact_email__c();  
            if(conAddressList.size()>0) {
                    contactAddress =  conAddressList[0];
            }
            else
                contactAddress = new cv__Related_Address_Detail__c();
            FirstName = contact.FirstName;
            LastName = contact.LastName;
            Email = contact.email;
            Phone = contact.Phone;
            MailingStreet = contact.MailingStreet;
            StreetAddressLine2= contact.Street_Address_Line_2__c;
            MailingCity = contact.MailingCity;
            MailingState = contact.MailingState;
            MailingCountry = contact.MailingCountry;
            MailingPostalCode = contact.MailingPostalCode;
            Id = contact.Id;
            AccountId = contact.AccountId;
            RecordTypeId = contact.RecordTypeId;
*/      }
    }

    

    
    public Contact getContact()             {   return contact;                     }
    public String getFirstName()            {   return contact.FirstName;           }
    public String getLastName()             {   return contact.LastName;            }
    public String getEmail()                {   return /*   contact.Email;              }*/contactEmail.Email__c;       }
    public String getPhone()                {   return /*   contact.Phone;              }*/contactPhone.Phone__c;       }
///    public contact_Email__c getContactEmail(){   return contactEmail;                }
    public contact_Phone__c getContactPhone(){  return contactPhone;                }
    //public CV__Related_Address_Detail__c getContactAddress(){   return contactAddress; }
    public String getMailingStreet()        { 
        String street;
       /* if (contactAddress != null  
                &&  contactAddress.cv__Mailing_Street__c!=null 
                && contactAddress.cv__Mailing_Street__c.split('\n').size()>0) {
            street = contactAddress.cv__Mailing_Street__c.split('\n')[0]; 
        }
        else street = '';  return street; */
        return street;
    }
    public String getStreetAddressLine2() {
        String street; 
        /*if (contactAddress != null  
                &&  contactAddress.cv__Mailing_Street__c!=null 
                && contactAddress.cv__Mailing_Street__c.split('\n').size()>1) {
            street = contactAddress.cv__Mailing_Street__c.split('\n')[1];
        }
        else street = '';*/  return street; 
    }
    public String getStreetAddress() {
       // return contactAddress == null ? null : contactAddress.cv__Mailing_Street__c;
       return 'StreetAddress';
    }
    //public String getMailingCity()          {   return /*contact.MailingCity;           }*/ contactAddress.cv__Mailing_City__c;         }
    //public String getMailingState()         {   return /*contact.MailingState;      }*/contactAddress.cv__Mailing_State__c;     }

    // Fellow App 2021-22 - Added by Harpreet (OSI)
    //public String getMailingStateDropdown() {   return contactAddress.cv__Mailing_State__c;     }
    
   // public String getMailingCountry()       {   return /*contact.MailingCountry;        }*/contactAddress.cv__Mailing_Country__c;       }
    //public String getMailingPostalCode()    {   return /*contact.MailingPostalCode; }*/contactAddress.cv__Mailing_Zip__c;   }
    public String getId()                   {   return contact.Id;                  }
    public String getAccountId()            {   return contact.AccountId;           }
    //public String getRecordTypeId()         {   return contact.RecordTypeId;        }

    public void setFirstName(String fn)                     {   contact.FirstName = fn;             }
    public void setLastName(String ln)                      {   contact.LastName = ln;              }
    public void setEmail(String email)                      {   contact.Email = email; contactEmail.Email__c = email;       }
    public void setPhone(String phone)                      {   contact.Phone = phone; contactPhone.Phone__c = phone;       }
/*  public void setMailingStreet(String street)             {   contact.MailingStreet = street;     }
    public void setStreetAddressLine2(String street2Line)   {contact.Street_Address_Line_2__c = street2Line; }
    public void setMailingCity(String city)                 {   contact.MailingCity = city;         }
    public void setMailingState(String state)               {   contact.MailingState = state;       }
    public void setMailingCountry(String country)           {   contact.MailingCountry = country;   }
    public void setMailingPostalCode(String zip)            {   contact.MailingPostalCode = zip;    }
*/
    public void setMailingStreet(String street)             {   
        /*if (street!='') contactAddress.cv__Mailing_Street__c = street +'\n'; 
        else contactAddress.cv__Mailing_Street__c = street; 
        
        contact.MailingStreet = contactAddress.cv__Mailing_Street__c;*/
    }
    public void setStreetAddressLine2(String street2Line)   {   
      /*  if (contactAddress.cv__Mailing_Street__c !='') {
            contactAddress.cv__Mailing_Street__c = contactAddress.cv__Mailing_Street__c + street2Line; 
        }
        contact.MailingStreet = contactAddress.cv__Mailing_Street__c; */
    }
    public void setMailingCity(String city)                 {   
       /* contactAddress.cv__Mailing_City__c = city; contact.MailingCity = city;   */       
    }
    public void setMailingState(String state)               {   
       /*  contactAddress.cv__Mailing_State__c = state; contact.MailingState = state;      */
    }

    // Fellow App 2021-22 - Added by Harpreet (OSI)
    public void setMailingStateDropdown(String state)       {   
        /*contactAddress.cv__Mailing_State__c = state; contact.MailingState = state;*/
    }

    public void setMailingCountry(String country)           {   
       /* contactAddress.cv__Mailing_Country__c = country; contact.MailingCountry = country; */ 
    }
    public void setMailingPostalCode(String zip)            {
       /* contactAddress.cv__Mailing_Zip__c = zip; contact.MailingPostalCode = zip;*/
    }
    public void setAccountId(String aId)                    {   contact.AccountId = aId;            }
  //  public void setRecordTypeId(String recTypeId)           {   contact.RecordTypeId = recTypeId;   }

}