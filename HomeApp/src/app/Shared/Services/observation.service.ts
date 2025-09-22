import { Injectable } from '@angular/core';
import {
  IAddEditLocalWeatherObservation,
  ILocalWeatherObservation,
  ILocalWeatherObservationSummary
} from '../../LocalWeatherObservations/observations.model';
import { Observable } from 'rxjs';
import {HttpClient, HttpParams} from '@angular/common/http';
import {environment} from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ObservationService {
  private url = `${environment.apiUrl}/localweatherobservations`;

  constructor(private http: HttpClient) { }

  addEditObservation(observation: IAddEditLocalWeatherObservation) {
    return this.http.post(this.url, observation);
  }

  getMonthSummary(): Observable<ILocalWeatherObservationSummary[]> {
    return this.http.get<ILocalWeatherObservationSummary[]>(`${this.url}/summaries`, {params: new HttpParams().append('days', '30')});
  }

  getYtdSummary(): Observable<ILocalWeatherObservationSummary[]> {
    return this.http.get<ILocalWeatherObservationSummary[]>(`${this.url}/summaries`, {params: new HttpParams().append('yearToDate', 'true')});
  }

  getObservations(): Observable<ILocalWeatherObservation[]> {
    return this.http.get<ILocalWeatherObservation[]>(this.url);
  }
}
