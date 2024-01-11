import { api, LightningElement, wire, track } from 'lwc';
import getDoctors from '@salesforce/apex/AppointmentController.getAllDoctorsWorkingInCurrentFacility';
import getSpecialization from '@salesforce/apex/AppointmentController.getAllSpecializationsFromDoctorsWorkingInAFacility';
import getFacilities from '@salesforce/apex/AppointmentController.getAllFacilities';

export default class FiltringByAccessibilityAndFacility extends LightningElement {
    @api patientId;
    
    @track doctors = [];
    @track facilities = [];
    @track specializations = [];
    picklistOptions = [
        { label: "Online", value: "online" },
        { label: "On-Site", value: "onSite" }
    ];

    @track selectedDoctorId;
    @track selectedFacilityId = null;
    @track selectedSpecializationId = null;
    @track selectedSpecializationLabel = null;
    @track selectedPicklistValue;


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
            // let labels = data.map(specialization => specialization.Specialization__c);
            // this.specializations = data.filter((specialization, index) => labels.indexOf(specialization.Specialization__c) === index).map(specialization => ({
            //     label: specialization.Specialization__c,
            //     value: specialization.Specialization__c
            // }));
            this.specializations = data.map(specialization => ({
                label: specialization.Specialization__c,
                value: specialization.Specialization__c
            }));
        } else if (error) {
            console.error('Błąd pobierania specjalizacji', error);
        }
    }
    
    @wire(getDoctors, { facilityId: "$selectedFacilityId", specialization: "$selectedSpecializationLabel" })
    wiredDoctors({ error, data }) {
        if (data) {
            this.doctors = data.map(doctor => ({
                label: doctor.Name + " " + doctor.Last_Name__c,
                value: doctor.Id
            }));
        } else if (error) {
            console.error('Błąd pobierania danych lekarzy', error);
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
        this.selectedDateTime = event.target.value;
    }

    handleAppointmentBooking() {

    }

    get facilitisOptions() {
        return this.facilities;
    }

    get specializationOptions() {
        return this.specializations;
    }

    get doctorOptions() {
        return this.doctors;
    }

    get isSpecializationDisabled() {
        return !this.selectedFacilityId;
    }

    get isDoctorDisabled() {
        return !this.selectedSpecializationId || !this.selectedFacilityId;
    }

    get isBookDisabled() {
        return  !this.selectedFacilityId ||
                !this.selectedSpecializationId ||
                !this.selectedDoctorId ||
                !this.selectedDateTime;
    }    
}