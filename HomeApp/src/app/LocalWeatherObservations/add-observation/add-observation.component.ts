import { Component } from '@angular/core';
import {
  AbstractControl,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators
} from '@angular/forms';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDatepicker, MatDatepickerInput, MatDatepickerToggle } from '@angular/material/datepicker';
import { MatSlideToggle } from '@angular/material/slide-toggle';
import { MatButton } from '@angular/material/button';
import { ObservationsStore } from '../observations.store';
import { formatDate } from '@angular/common';

@Component({
  selector: 'app-add-observation',
  imports: [
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatDatepickerInput,
    MatDatepickerToggle,
    MatDatepicker,
    MatSlideToggle,
    MatButton
  ],
  templateUrl: './add-observation.component.html',
  styleUrl: './add-observation.component.scss'
})
export class AddObservationComponent {
  observationForm = new FormGroup({
    date: new FormControl(new Date(), [
      Validators.required
    ]),
    precipitation: new FormControl(0, [
      Validators.required,
      this.positiveValidator()
    ]),
    snow: new FormControl(0, [
      Validators.required,
      this.positiveValidator()
    ]),
    tracePrecipitation: new FormControl(false, [
      Validators.required
    ]),
    traceSnow: new FormControl(false, [
      Validators.required
    ])
  }, {
    validators: [
      this.snowZeroValidator(),
      this.tracePrecipitationValidator(),
      this.traceSnowValidator()
    ]
  });

  constructor(private observationsStore: ObservationsStore) { }

  onSubmit() {
    const observation = {
      date: formatDate(this.observationForm.controls['date'].value ?? new Date(), 'yyyy-MM-dd', 'en-US'),
      precipitation: this.observationForm.controls['precipitation']?.value,
      snow: this.observationForm.controls['snow']?.value,
      tracePrecipitation: this.observationForm.controls['tracePrecipitation']?.value,
      traceSnow: this.observationForm.controls['traceSnow']?.value
    }
    console.warn(observation);
    this.observationsStore.addObservation(observation);
  }

  positiveValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      return control.value >= 0 ? {positive: {value: control.value}} : null;
    }
  }

  snowZeroValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const precipitation = control.get('precipitation');
      const tracePrecipitation = control.get('tracePrecipitation');
      const snow = control.get('snow');
      return precipitation && tracePrecipitation && snow &&
        precipitation.value == 0 && !tracePrecipitation.value && snow.value != 0 ? {snowZero: {value: control.value}} : null;
    }
  }

  tracePrecipitationValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const precipitation = control.get('precipitation');
      const tracePrecipitation = control.get('tracePrecipitation');
      return precipitation && tracePrecipitation &&
        precipitation.value != 0 && tracePrecipitation.value ? {tracePrecipitation: {value: control.value}} : null;
    }
  }

  traceSnowValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const precipitation = control.get('precipitation');
      const tracePrecipitation = control.get('tracePrecipitation');
      const snow = control.get('snow');
      const traceSnow = control.get('traceSnow');
      return precipitation && tracePrecipitation && snow && traceSnow &&
        ((precipitation.value == 0 && !tracePrecipitation.value) || snow.value != 0) && traceSnow.value ? {traceSnow: {value: control.value}} : null;
    }
  }
}
