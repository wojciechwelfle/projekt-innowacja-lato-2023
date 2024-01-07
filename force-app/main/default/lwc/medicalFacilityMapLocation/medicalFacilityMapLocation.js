import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import NAME from "@salesforce/schema/Medical_Facility__c.Name";
import CITY from "@salesforce/schema/Medical_Facility__c.City__c";
import STREET from "@salesforce/schema/Medical_Facility__c.Street__c";
import POSTAL_CODE from "@salesforce/schema/Medical_Facility__c.zip_code__c";
import BUILDING_NUMBER from "@salesforce/schema/Medical_Facility__c.Building_number__c";
import COUNTRY from "@salesforce/schema/Medical_Facility__c.Country__c";

const FIELDS = [NAME, CITY, STREET, POSTAL_CODE, BUILDING_NUMBER, COUNTRY];

export default class LightningMapExample extends LightningElement {
  @api recordId;
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS }) facility;

  getFacilityField(field) {
    return getFieldValue(this.facility.data, field);
  }
  get street() {
    return (
      this.getFacilityField(STREET) +
      " " +
      this.getFacilityField(BUILDING_NUMBER)
    );
  }
  get mapMarkers() {
    if (this.facility.data) {
      const city = this.getFacilityField(CITY);
      const street = this.street;
      const postalCode = this.getFacilityField(POSTAL_CODE);
      const country = this.getFacilityField(COUNTRY);
      const name = this.getFacilityField(NAME);
      return [
        {
          location: {
            Street: street,
            City: city,
            Country: country,
            PostalCode: postalCode
          },
          title: name,
          description:
            street + ", " + postalCode + ", " + city + ", " + country,
          icon: "standard:account"
        }
      ];
    }
    return [];
  }
  mapOptions = {
    draggable: true,
    disableDefaultUI: false
  };
  zoomLevel = 17;
  listView = "visible";
}
