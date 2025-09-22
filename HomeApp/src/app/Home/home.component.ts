import { Component, OnInit } from '@angular/core';
import { ObservationService } from '../Shared/Services/observation.service';
import { CumulativeChartComponent } from '../Shared/cumulative-chart/cumulative-chart.component';
import { MatProgressSpinner } from '@angular/material/progress-spinner';

@Component({
  selector: 'app-home',
  imports: [
    CumulativeChartComponent,
    MatProgressSpinner
  ],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss'
})
export class HomeComponent implements OnInit {
  ytdPrecipitation: number[] = [];
  ytdCumulativePrecipitation: number[] = [];
  ytdSnow: number[] = [];
  ytdCumulativeSnow: number[] = [];
  ytdLabels: string[] = [];
  ytdLoading: boolean = true;

  monthPrecipitation: number[] = [];
  monthCumulativePrecipitation: number[] = [];
  monthSnow: number[] = [];
  monthCumulativeSnow: number[] = [];
  monthLabels: string[] = [];
  monthLoading: boolean = true;

  constructor(private observationService: ObservationService) { }

  ngOnInit() {
    this.observationService.getYtdSummary().subscribe(response => {
      this.ytdPrecipitation = response.map(o => o.precipitation);
      this.ytdCumulativePrecipitation = response.map(o => o.cumulativePrecipitation);
      this.ytdSnow = response.map(o => o.snow);
      this.ytdCumulativeSnow = response.map(o => o.cumulativeSnow);
      this.ytdLabels = response.map(o => new Date(o.date).toLocaleDateString());
      this.ytdLoading = false;
    });

    this.observationService.getMonthSummary().subscribe(response => {
      this.monthPrecipitation = response.map(o => o.precipitation);
      this.monthCumulativePrecipitation = response.map(o => o.cumulativePrecipitation);
      this.monthSnow = response.map(o => o.snow);
      this.monthCumulativeSnow = response.map(o => o.cumulativeSnow);
      this.monthLabels = response.map(o => new Date(o.date).toLocaleDateString());
      this.monthLoading = false;
    });}
}
