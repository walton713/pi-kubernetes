import { Component, input, OnInit } from '@angular/core';
import { BaseChartDirective } from 'ng2-charts';

@Component({
  selector: 'app-chart',
  imports: [
    BaseChartDirective
  ],
  templateUrl: './chart.component.html',
  styleUrl: './chart.component.scss'
})
export class ChartComponent implements OnInit {
  data = input.required<number[]>();
  labels = input.required<string[]>();
  dataLabel = input.required<string>();

  chartData: any;
  chartOptions: any;

  ngOnInit() {
    this.chartData = {
      labels: this.labels(),
      datasets: [
        {
          data: this.data(),
          label: this.dataLabel(),
          backgroundColor: '#5F8BA2',
          borderColor: '#5F8BA2',
        }
      ]
    }

    this.chartOptions = {
      elements: {
        line: {
          tension: 0.5
        }
      },
      scales: {
        y: {
          title: {
            display: true,
            text: 'Inches'
          }
        }
      }
    }
  }
}
