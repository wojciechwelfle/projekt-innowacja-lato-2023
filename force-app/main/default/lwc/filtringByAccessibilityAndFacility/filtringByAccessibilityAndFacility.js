import { api, LightningElement, wire, track } from 'lwc';
import getDoctors from '@salesforce/apex/AppointmentController.getAllDoctorsWorkingInCurrentFacility';
import getSpecialization from '@salesforce/apex/AppointmentController.getAllSpecializationsFromDoctorsWorkingInAFacility';
import getFacilities from '@salesforce/apex/AppointmentController.getAllFacilities';
import bookAppointment from '@salesforce/apex/AppointmentController.saveAppointment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FiltringByAccessibilityAndFacility extends LightningElement {
    @api recordId;
    
    @track doctors = [];
    @track facilities = [];
    @track specializations = [];
    picklistOptions = [
        { label: "Online", value: "Online" },
        { label: "On-Site", value: "On-Site" }
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
        this.dateTimeString = event.target.value;
    }

    handleAppointmentBooking() {
        bookAppointment({
            facilityId: this.selectedFacilityId,
            doctorId: this.selectedDoctorId,
            patientId: this.recordId,
            isOnline: this.selectedPicklistValue,
            dateTimeString: this.dateTimeString
        }).then(() => {
                this.selectedFacilityId = null
                this.selectedDoctorId = null
                this.selectedPicklistValue = null

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Appointment booked successfully!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                const errorMessage = error.body.pageErrors[0].message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
            })
    }

    get facilitisOptions() {
        return this.facilities;
    }

    get specializationOptions() {
        return this.specializations;
    }

    get doctorOptions() {
        return this.doctors.sort((a, b) => a.label.localeCompare(b.label));
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
                !this.dateTimeString;
    }    
}