import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import MONDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Monday_Open_Hours__c";
import MONDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Monday_Close_Hours__c";
import TUESDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Tuesday_Open_Hours__c";
import TUESDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Tuesday_Close_Hours__c";
import WEDNESDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Wednesday_Open_Hours__c";
import WEDNESDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Wednesday_Close_Hours__c";
import THURSDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Thursday_Open_Hours__c";
import THURSDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Thursday_Close_Hours__c";
import FRIDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Friday_Open_Hours__c";
import FRIDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Friday_Close_Hours__c";
import SATURDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Saturday_Open_Hours__c";
import SATURDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Saturday_Close_Hours__c";
import SUNDAY_OPEN from "@salesforce/schema/Medical_Facility__c.Sunday_Open_Hours__c";
import SUNDAY_CLOSE from "@salesforce/schema/Medical_Facility__c.Sunday_Close_Hours__c";

const FIELDS = [
  MONDAY_OPEN,
  MONDAY_CLOSE,
  TUESDAY_OPEN,
  TUESDAY_CLOSE,
  WEDNESDAY_OPEN,
  WEDNESDAY_CLOSE,
  THURSDAY_OPEN,
  THURSDAY_CLOSE,
  FRIDAY_OPEN,
  FRIDAY_CLOSE,
  SATURDAY_OPEN,
  SATURDAY_CLOSE,
  SUNDAY_OPEN,
  SUNDAY_CLOSE
];

export default class MedicalFacilityOpeningHours extends LightningElement {
  @api recordId;
  @wire(getRecord, { recordId: "$recordId", fields: FIELDS }) facility;

  parseTime(time) {
    return time.substring(0, 5);
  }

  createTime(open, close) {
    return (
      this.parseTime(getFieldValue(this.facility.data, open)) +
      "-" +
      this.parseTime(getFieldValue(this.facility.data, close))
    );
  }

  get monday() {
    return this.createTime(MONDAY_OPEN, MONDAY_CLOSE);
  }
  get tuesday() {
    return this.createTime(TUESDAY_OPEN, TUESDAY_CLOSE);
  }
  get wednesday() {
    return this.createTime(WEDNESDAY_OPEN, WEDNESDAY_CLOSE);
  }
  get thursday() {
    return this.createTime(THURSDAY_OPEN, THURSDAY_CLOSE);
  }
  get friday() {
    return this.createTime(FRIDAY_OPEN, FRIDAY_CLOSE);
  }
  get saturday() {
    return this.createTime(SATURDAY_OPEN, SATURDAY_CLOSE);
  }
  get sunday() {
    return this.createTime(SUNDAY_OPEN, SUNDAY_CLOSE);
  }
}
