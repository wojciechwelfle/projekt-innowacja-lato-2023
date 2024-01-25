import { api, LightningElement, wire, track } from 'lwc';
import getPatients from '@salesforce/apex/AppointmentController.getAllPatients';
import getDoctors from '@salesforce/apex/AppointmentController.getAllDoctorsWorkingInCurrentFacility';
import getSpecialization from '@salesforce/apex/AppointmentController.getAllSpecializationsFromDoctorsWorkingInAFacility';
import getFacilities from '@salesforce/apex/AppointmentController.getAllFacilities';
import bookAppointment from '@salesforce/apex/AppointmentController.saveAppointment';
import getVisitTIme from '@salesforce/apex/AppointmentController.returnAllAvailableHoursForSingleDoctor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class FiltringByAccessibilityAndFacility extends NavigationMixin(LightningElement) {
    @api recordId;

    @track patients = [];
    @track doctors = [];
    @track facilities = [];
    @track specializations = [];
    @track times = []
    picklistOptions = [
        { label: "Online", value: "Online" },
        { label: "On Site", value: "On Site" }
    ];

    @track selectedDoctorId;
    @track patientId = null;
    @track selectedFacilityId = null;
    @track selectedSpecializationId = null;
    @track selectedSpecializationLabel = null;
    @track selectedPicklistValue = null;
    @track dateString = null;
    @track selectedTime = null;


    @wire(getPatients)
    wiredPatients({ error, data }) {
        if (data) {
            this.patients = data.map(patient => ({
                label: patient.Name,
                value: patient.Id
            }));
        } else if (error) {
            console.error('Błąd pobierania danych o pacjentach', error);
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
            console.log(data)
            this.times = data.map(visit => ({
                label: visit,
                value: visit
            }));
        } else if (error) {
            console.log(this.dateString)
            console.error('Błąd pobierania godzin', error);
        }
    }

    handlePatientChange(event) {
        console.log('recordID: ' + this.recordId)
        this.patientId = event.detail.value;
        this.selectedFacilityId = null;
        this.selectedSpecializationId = null;
        this.selectedDoctorId = null;
        this.doctors = [];
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

    handleTimeChange(event) {
        this.selectedTime = event.detail.value;
    }

    handleAppointmentBooking() {
        console.log('Booking appointment with the following data:');
        console.log(
            'facility: ' + this.selectedFacilityId +
            ',\ndoctor: ' + this.selectedDoctorId +
            ',\npatient: ' + this.patientId +
            ',\nisOnline: ' + this.selectedPicklistValue +
            ',\ndateTime: ' + this.dateString +
            ',\nvisitTime: ' + this.selectedTime
        );
        bookAppointment({
            facilityId: this.selectedFacilityId,
            doctorId: this.selectedDoctorId,
            patientId: this.patientId,
            isOnline: this.selectedPicklistValue,
            dateTimeString: this.dateString,
            visitTime: this.selectedTime,
            appointmentId: null,
            appointmentStatus: null
        })
        .then(() => {
            this.selectedFacilityId = null;
            this.selectedDoctorId = null;
            this.selectedPicklistValue = null;
            this.visitTime = null;
            this.dateString = null;
            this.patientId = null;
            

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Appointment booked successfully!',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            const errorMessage = error.body.pageErrors ? error.body.pageErrors[0].message : 'Unknown error';

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        });
}


    get facilitiesOptions() {
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

    get patientsOptions() {
        return this.patients;
    }

    get isBookDisabled() {
        return  !this.selectedFacilityId ||
                !this.selectedSpecializationId ||
                !this.selectedDoctorId ||
                !this.dateString ||
                !this.selectedTime ||
                !this.patientId ||
                !this.selectedPicklistValue;
    }    

    get isDateDisabled() {
        return !this.selectedDoctorId;
    }

    get isTimeDisabled() {
        return !this.dateString;
    }
}