global class EinsteinApexClassesGettingAllNames {
    @InvocableMethod(label='Get All Cities')
    global static List<List<String>> getAllFacilities() {
        List<AggregateResult> citiesNames = [select City__c from Medical_Facility__c group by City__c];
        List<String> cities = new List<String>();
        List<List<String>> result = new List<List<String>>();

        for (AggregateResult city : citiesNames) {
            cities.add(String.valueOf(city.get('City__c')));
        }

        result.add(cities);

        return result;
    }
}