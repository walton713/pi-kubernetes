import { Routes } from '@angular/router';
import {ObservationsListComponent} from './LocalWeatherObservations/observations-list/observations-list.component';

export const routes: Routes = [
  {
    path: '',
    component: ObservationsListComponent,
    title: "Observations"
  }
];
