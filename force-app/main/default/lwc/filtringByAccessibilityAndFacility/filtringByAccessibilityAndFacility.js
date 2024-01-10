import { api, LightningElement, wire, track } from 'lwc';
import getDoctors from '@salesforce/apex/AppointmentController.getAllDoctors';

export default class FiltringByAccessibilityAndFacility extends LightningElement {
    @track doctors = [];
    @track selectedDoctorId;

    @wire(getDoctors)
    wiredDoctors({ error, data }) {
        if (data) {
            this.doctors = data.map(doctor => ({
                label: doctor.Name,
                value: doctor.Id
            }));
        } else if (error) {
            console.error('Błąd pobierania danych lekarzy', error);
        }
    }

    get doctorOptions() {
        return this.doctors;
    }

    handleDoctorChange(event) {
        this.selectedDoctorId = event.detail.value;
        console.log('Wybrano lekarza:', this.selectedDoctorId);
    }
}