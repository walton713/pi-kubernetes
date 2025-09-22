import { Component } from '@angular/core';
import { MatButton } from '@angular/material/button';
import { ILocalWeatherObservation } from './observations.model';
import { ObservationService } from '../Shared/Services/observation.service';
import { MatTableModule } from '@angular/material/table';
import { DatePipe, formatDate } from '@angular/common';
import { ChartComponent } from '../Shared/chart/chart.component';
import { MatProgressSpinner } from '@angular/material/progress-spinner';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { AddEditObservationComponent } from './add-edit-observation/add-edit-observation.component';

@Component({
  selector: 'app-local-weather-observations-page',
  imports: [
    MatDialogModule,
    MatButton,
    MatTableModule,
    DatePipe,
    ChartComponent,
    MatProgressSpinner
  ],
  templateUrl: './local-weather-observations-page.component.html',
  styleUrl: './local-weather-observations-page.component.scss'
})
export class LocalWeatherObservationsPageComponent {
  precipitation: number[] = [];
  snow: number[] = [];
  labels: string[] = [];
  observations: ILocalWeatherObservation[] = [];
  loading: boolean = true;

  columns: string[] = ['Date', 'Precipitation', 'Snow'];

  constructor(private observationService: ObservationService, public dialog: MatDialog) {
    this.getObservations();
  }

  openAddEditObservationDialog(): void {
    const dialogRef = this.dialog.open(AddEditObservationComponent, {
      width: '400px',
      data: {
        id: null,
        date: new Date(),
        precipitation: 0,
        snow: 0,
        tracePrecipitation: false,
        traceSnow: false
      }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.observationService.addEditObservation(result).subscribe(_ => {
          this.loading = true;
          this.getObservations();
        });
      }
    });
  }

  getObservations(): void {
    this.observationService.getObservations().subscribe(response => {
      this.observations = response;
      this.labels = response.slice().reverse().map(o => new Date(o.date).toLocaleDateString());
      this.precipitation = response.slice().reverse().map(o => o.precipitation);
      this.snow = response.slice().reverse().map(o => o.snow);
      this.loading = false;
    });
  }
}
