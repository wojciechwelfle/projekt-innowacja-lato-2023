import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import MONDAY from "@salesforce/schema/Medical_Facility__c.Monday__c";
import TUESDAY from "@salesforce/schema/Medical_Facility__c.Tuesday__c";
import WEDNESDAY from "@salesforce/schema/Medical_Facility__c.Wednesday__c";
import THURSDAY from "@salesforce/schema/Medical_Facility__c.Thursday__c";
import FRIDAY from "@salesforce/schema/Medical_Facility__c.Friday__c";
import SATURDAY from "@salesforce/schema/Medical_Facility__c.Saturday__c";
import SUNDAY from "@salesforce/schema/Medical_Facility__c.Sunday__c";

const FIELDS = [MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY];

export default class MedicalFacilityOpeningHours extends LightningElement {
  @api recordId;
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS }) facility;

  get monday() {
    return getFieldValue(this.facility.data, MONDAY);
  }
  get tuesday() {
    return getFieldValue(this.facility.data, TUESDAY);
  }
  get wednesday() {
    return getFieldValue(this.facility.data, WEDNESDAY);
  }
  get thursday() {
    return getFieldValue(this.facility.data, THURSDAY);
  }
  get friday() {
    return getFieldValue(this.facility.data, FRIDAY);
  }
  get saturday() {
    return getFieldValue(this.facility.data, SATURDAY);
  }
  get sunday() {
    return getFieldValue(this.facility.data, SUNDAY);
  }
}
