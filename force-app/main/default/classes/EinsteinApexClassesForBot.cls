public class EinsteinApexClassesForBot {
    @InvocableMethod(label='Get Person Credentials')
    public static List<ID> getPerson(List<String> pesel) {
        List<Id> personIds = new List<Id>();
        
        Person__c person = [select Id from Person__c where Personal_ID_Number__c =: pesel[0]];
        
        personIds.add(person.Id);
        return personIds;
    }

    @InvocableMethod(label='Get Person Credentials')
    public static List<Medical_Facility__c> getAllFacilities() {
        return 
            [
                select Id, Name from Medical_Facility__c
            ];
    }
}