import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import {Observable, shareReplay} from 'rxjs';
import {IAddLocalWeatherObservation, ILocalWeatherObservation} from './observations.model';

@Injectable({
  providedIn: 'root'
})
export class ObservationsService {
  private url = `${environment.apiUrl}/localweatherobservations`;
  private friendlyHeaders = new HttpHeaders({'Accept': 'application/vnd.friendly+json'})

  constructor(private http: HttpClient) { }

  getObservations(): Observable<ILocalWeatherObservation[]> {
    return this.http.get<ILocalWeatherObservation[]>(this.url, {headers: this.friendlyHeaders});
  }

  addObservation(observation: IAddLocalWeatherObservation) {
    return this.http.post<ILocalWeatherObservation>(this.url, observation, {headers: this.friendlyHeaders})
      .pipe(shareReplay());
  }
}
