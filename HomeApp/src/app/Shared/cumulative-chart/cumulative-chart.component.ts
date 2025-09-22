import { Component, input, OnInit } from '@angular/core';
import { BaseChartDirective } from 'ng2-charts';

@Component({
  selector: 'app-cumulative-chart',
  imports: [
    BaseChartDirective
  ],
  templateUrl: './cumulative-chart.component.html',
  styleUrl: './cumulative-chart.component.scss'
})
export class CumulativeChartComponent implements OnInit {
  data = input.required<number[]>();
  cumulativeData = input.required<number[]>();
  labels = input.required<string[]>();
  dataLabel = input.required<string>();
  cumulativeDataLabel = input.required<string>();

  chartData: any;
  chartOptions: any;

  ngOnInit() {
    this.chartData = {
      labels: this.labels(),
      datasets: [
        {
          data: this.cumulativeData(),
          label: this.cumulativeDataLabel(),
          order: 1,
          backgroundColor: '#5F8BA2',
          borderColor: '#5F8BA2',
          yAxisID: 'y2'
        },
        {
          data: this.data(),
          label: this.dataLabel(),
          type: 'bar',
          order: 0,
          backgroundColor: 'rgba(100, 225, 100, 0.8)',
          yAxisID: 'y1'
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
        y1: {
          position: 'left',
          title: {
            display: true,
            text: 'Inches'
          }
        },
        y2: {
          position: 'right',
        }
      }
    }}
}
