public class EinsteinApexClassesForBot {
    @InvocableMethod(label='Get Person Credentials')
    public static List<ID> getPerson(List<String> pesel) {
        List<Id> personIds = new List<Id>();
        
        Person__c person = [select Id from Person__c where Personal_ID_Number__c =: pesel[0]];
        
        personIds.add(person.Id);
        return personIds;
    }
}

