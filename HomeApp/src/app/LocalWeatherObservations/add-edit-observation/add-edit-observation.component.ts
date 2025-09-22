import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import {
  AbstractControl,
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  ValidationErrors,
  ValidatorFn,
  Validators
} from '@angular/forms';
import { IAddEditLocalWeatherObservationDialogData } from '../observations.model';
import { formatDate } from '@angular/common';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatDatepicker, MatDatepickerInput, MatDatepickerToggle } from '@angular/material/datepicker';
import { MatSlideToggle } from '@angular/material/slide-toggle';
import { MatButton } from '@angular/material/button';

@Component({
  selector: 'app-add-edit-observation',
  imports: [
    MatDialogModule,
    ReactiveFormsModule,
    MatInputModule,
    MatFormFieldModule,
    MatDatepickerInput,
    MatDatepickerToggle,
    MatDatepicker,
    MatSlideToggle,
    MatButton
  ],
  templateUrl: './add-edit-observation.component.html',
  styleUrl: './add-edit-observation.component.scss'
})
export class AddEditObservationComponent {
  observationForm: FormGroup;

  constructor(private fb: FormBuilder,
              public dialogRef: MatDialogRef<AddEditObservationComponent>,
              @Inject(MAT_DIALOG_DATA) public data: IAddEditLocalWeatherObservationDialogData) {
    this.observationForm = fb.group({
      id: this.data.id,
      date: [this.data.date, [Validators.required]],
      precipitation: [this.data.precipitation, [Validators.required, this.positiveValidator()]],
      snow: [this.data.snow, [Validators.required, this.positiveValidator()]],
      tracePrecipitation: [this.data.tracePrecipitation, [Validators.required]],
      traceSnow: [this.data.traceSnow, [Validators.required]]
    }, {
      validators: [
        this.snowZeroValidator(),
        this.tracePrecipitationValidator(),
        this.traceSnowValidator()
      ]
    });
  }

  onClose(): void {
    this.dialogRef.close();
  }

  onSubmit(): void {
    this.dialogRef.close({
      id: this.observationForm.controls['id']?.value,
      date: formatDate(this.observationForm.controls['date'].value ?? new Date(), 'yyyy-MM-dd', 'en-US'),
      precipitation: this.observationForm.controls['precipitation']?.value,
      snow: this.observationForm.controls['snow']?.value,
      tracePrecipitation: this.observationForm.controls['tracePrecipitation']?.value,
      traceSnow: this.observationForm.controls['traceSnow']?.value
    });
  }

  positiveValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      return control.value >= 0 ? { positive: { value: control.value } } : null;
    }
  }

  snowZeroValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const precipitation = control.get('precipitation');
      const tracePrecipitation = control.get('tracePrecipitation');
      const snow = control.get('snow');
      return precipitation && tracePrecipitation && snow &&
        precipitation.value == 0 && !tracePrecipitation.value && snow.value != 0 ? { snowZero: { value: control.value } } : null;
    }
  }

  tracePrecipitationValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const precipitation = control.get('precipitation');
      const tracePrecipitation = control.get('tracePrecipitation');
      return precipitation && tracePrecipitation &&
        precipitation.value != 0 && tracePrecipitation.value ? { tracePrecipitation: { value: control.value } } : null;
    }
  }

  traceSnowValidator(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const precipitation = control.get('precipitation');
      const tracePrecipitation = control.get('tracePrecipitation');
      const snow = control.get('snow');
      const traceSnow = control.get('traceSnow');
      return precipitation && tracePrecipitation && snow && traceSnow &&
        ((precipitation.value == 0 && !tracePrecipitation.value) || snow.value != 0) && traceSnow.value ? { traceSnow: { value: control.value } } : null;
    }
  }
}
