import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import {AddObservationComponent} from './LocalWeatherObservations/add-observation/add-observation.component';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, AddObservationComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  protected readonly title = signal('HomeApp');
}
