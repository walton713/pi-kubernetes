export interface IAddLocalWeatherObservation {
  date?: string | null;
  precipitation?: number | null;
  snow?: number | null;
  tracePrecipitation?: boolean | null;
  traceSnow?: boolean | null;
}

export interface ILocalWeatherObservationFriendly {
  id: string;
  date: Date;
  precipitation: string;
  snow: string;
}
