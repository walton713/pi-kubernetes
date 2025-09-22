import { Routes } from '@angular/router';
import {ObservationsListComponent} from './LocalWeatherObservations/observations-list/observations-list.component';
import {HomeComponent} from './Home/home.component';
import {
  LocalWeatherObservationsPageComponent
} from './LocalWeatherObservations/local-weather-observations-page.component';

export const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
    title: "Walton Farm"
  },
  {
    path: 'observations',
    component: LocalWeatherObservationsPageComponent,
    title: 'Observations'
  }
];
