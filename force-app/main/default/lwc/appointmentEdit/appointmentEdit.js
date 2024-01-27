import { api, LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import getDoctors from '@salesforce/apex/AppointmentController.getAllDoctorsWorkingInCurrentFacility';
import getSpecialization from '@salesforce/apex/AppointmentController.getAllSpecializationsFromDoctorsWorkingInAFacility';
import getFacilities from '@salesforce/apex/AppointmentController.getAllFacilities';
import editAppointment from '@salesforce/apex/AppointmentController.saveAppointment';
import getAppointmentStatusPicklistValues from '@salesforce/apex/AppointmentController.getAppointmentStatusPicklistValues';
import getVisitTIme from '@salesforce/apex/AppointmentController.returnAllAvailableHoursForSingleDoctor';

import FACILITY from '@salesforce/schema/Medical_Appointment__c.Medical_Facility__c';
import DOCTOR from '@salesforce/schema/Medical_Appointment__c.Doctor__c';
import SPECIALIZATION from '@salesforce/schema/Person__c.Specialization__c';
import STATUS from '@salesforce/schema/Medical_Appointment__c.Appointment_Status__c';
import APPOINTMENT_DATE from '@salesforce/schema/Medical_Appointment__c.Appointment_Date__c';
import PATIENT from '@salesforce/schema/Medical_Appointment__c.Patient__c';


export default class AppointmentEdit extends NavigationMixin(LightningElement) {
    @api recordId;

    @track doctors = [];
    @track times = []
    @track facilities = [];
    @track specializations = [];
    @track appointmentStatusOptions = [];
    picklistOptions = [
        { label: "Online", value: "Online" },
        { label: "On Site", value: "On Site" }
    ];

    @track selectedTime = null;
    @track selectedDoctorId = null;
    @track selectedFacilityId = null;
    @track selectedSpecializationId = null;
    @track selectedSpecializationLabel = null;
    @track selectedPicklistValue = null;
    @track selectedAppointmentStatus = null;
    @track dateString = null;

    
    @wire(getRecord, { recordId: "$recordId", fields: [FACILITY, DOCTOR, STATUS, APPOINTMENT_DATE, PATIENT] })
    wireCurrentAppointment({ data,error}) {
       if(data){
            this.selectedFacilityId = getFieldValue(data, FACILITY);
            this.selectedDoctorId = getFieldValue(data, DOCTOR);
            this.selectedAppointmentStatus = getFieldValue(data, STATUS);
            this.dateString = getFieldValue(data, APPOINTMENT_DATE);
            this.selectedPicklistValue = data.recordTypeInfo.name;
            this.patientId = getFieldValue(data, PATIENT);
            this.selectedTime = this.dateString.substring(11, 16);
       }
       else if(error){

       }
    }

    @wire(getRecord, { recordId: "$selectedDoctorId", fields: [SPECIALIZATION] })
    wireToGetSpecialization({ data,error }) {
       if(data){
            this.selectedSpecializationId = getFieldValue(data, SPECIALIZATION);
       }
       else if(error){
       }
    }

    
    @wire(getAppointmentStatusPicklistValues)
    wiredAppointmentStatusOptions({ error, data }) {
        if (data) {
            this.appointmentStatusOptions = data.map(value => ({
                label: value,
                value: value
            }));
        } else if (error) {
            console.error('Error fetching appointment status picklist values', error);
        }
    }


    @wire(getFacilities)
    wiredFacilities({ error, data }) {
        if (data) {
            this.facilities = data.map(facilitiy => ({
                label: facilitiy.Name,
                value: facilitiy.Id
            }));
        } else if (error) {
            console.error('Błąd pobierania danych o placówkach', error);
        }
    }

    @wire(getSpecialization, { facilityId: "$selectedFacilityId" })
    wiredSpecialization({ error, data }) {
        if (data) {

            this.specializations = data.map(specialization => ({
                label: specialization.Specialization__c,
                value: specialization.Specialization__c
            }));

            
        } else if (error) {
            console.error('Błąd pobierania specjalizacji', error);
        }
    }
    
    @wire(getDoctors, { facilityId: "$selectedFacilityId", specialization: "$selectedSpecializationId" })
    wiredDoctors({ error, data }) {
        if (data) {
            this.doctors = data.map(doctor => ({
                label: doctor.Last_Name__c + " " + doctor.Name,
                value: doctor.Id
            }));
        } else if (error) {
            console.error('Błąd pobierania danych lekarzy', error);
        }
    }

    @wire(getVisitTIme, { 
        dateTimeString: "$dateString", 
        medicalId: "$selectedFacilityId", 
        doctorId: "$selectedDoctorId" 
    })
    wiredVisits({ error, data }) {
        if (data) {
            this.times = data.map(visit => ({
                label: visit,
                value: visit
            }));
        } else if (error) {
        }
    }

    handleFacilityChange(event) {
        this.selectedFacilityId = event.detail.value;
        this.selectedSpecializationId = null;
        this.selectedDoctorId = null;
        this.doctors = [];
    }

    handleSpecializationChange(event) {
        this.selectedSpecializationId = event.detail.value;
    }

    handleDoctorChange(event) {
        this.selectedDoctorId = event.detail.value;
    }

    handlePicklistChange(event) {
        this.selectedPicklistValue = event.detail.value;
    }

    handleDateTimeChange(event) {
        this.dateString = event.target.value;
    }

    handleAppointmentStatusChange(event) {
        this.selectedAppointmentStatus = event.detail.value;
    }

    handleTimeChange(event) {
        this.selectedTime = event.detail.value;
    }

    handleAppointmentBooking() {

        editAppointment({
            facilityId: this.selectedFacilityId,
            doctorId: this.selectedDoctorId,
            patientId: this.patientId,
            isOnline: this.selectedPicklistValue,
            dateTimeString: this.dateString,
            visitTime: this.selectedTime,
            appointmentId: this.recordId,
            appointmentStatus: this.selectedAppointmentStatus
        }).then(() => {
                this.selectedFacilityId = null
                this.selectedDoctorId = null
                this.selectedPicklistValue = null

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Appointment edited successfully!',
                        variant: 'success'
                    })
                );

                const editRecordPageUrl = `/lightning/r/Medical_Appointment__c/${this.recordId}/view`;

                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: editRecordPageUrl
                    }
                });
            })
            .catch(error => {
                if (error.body.pageErrors === undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Record has not been updated',
                            variant: 'error'
                        })
                    );
                } else {
                    const errorMessage = error.body.pageErrors[0].message
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
                }
                
            })
    }

    get isSpecializationDisabled() {
        return !this.selectedFacilityId;
    }

    get isDoctorDisabled() {
        return !this.selectedSpecializationId || !this.selectedFacilityId;
    }

    get isBookDisabled() {
        return (
            this.selectedFacilityId === null &&
            this.selectedSpecializationId === null &&
            this.selectedDoctorId === null &&
            this.selectedAppointmentStatus === null &&
            this.dateString === null
        );
    }   

    
}