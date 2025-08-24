import { Component } from '@angular/core';
import { ILocalWeatherObservationFriendly } from '../observations.model';
import { ObservationsService } from '../observations.service';
import { MatTableModule } from '@angular/material/table';
import { DatePipe } from '@angular/common';
import { Observable } from 'rxjs';
import {ObservationsStore} from '../observations.store';

@Component({
  selector: 'app-observations-list',
  imports: [
    MatTableModule,
    DatePipe
  ],
  templateUrl: './observations-list.component.html',
  styleUrl: './observations-list.component.scss'
})
export class ObservationsListComponent {
  observations$: Observable<ILocalWeatherObservationFriendly[]>;
  columnsToDisplay: string[] = ['Date', 'Precipitation', 'Snow'];

  constructor(private observationsStore: ObservationsStore) {
    this.observations$ = observationsStore.observations$;
  }
}
