import { Injectable } from '@angular/core';
import {BehaviorSubject, subscribeOn, tap} from 'rxjs';
import {IAddLocalWeatherObservation, ILocalWeatherObservation} from './observations.model';
import {ObservationsService} from './observations.service';

@Injectable({
  providedIn: 'root'
})
export class ObservationsStore {
  private _observations = new BehaviorSubject<ILocalWeatherObservation[]>([]);
  readonly observations$ = this._observations.asObservable();

  constructor(private service: ObservationsService) {
    this.loadObservations();
  }

  loadObservations() {
    this.service.getObservations().pipe(
      tap(observations => this._observations.next(observations))
    ).subscribe();
  }

  addObservation(observation: IAddLocalWeatherObservation) {
    this.service.addObservation(observation).pipe(
      tap(observation => {
        const currentObs = this._observations.getValue();
        this._observations.next([...currentObs, observation]);
      })
    ).subscribe();
  }
}
