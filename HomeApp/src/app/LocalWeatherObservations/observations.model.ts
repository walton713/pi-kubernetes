export interface IAddLocalWeatherObservation {
  date?: string | null;
  precipitation?: number | null;
  snow?: number | null;
  tracePrecipitation?: boolean | null;
  traceSnow?: boolean | null;
}

export interface IAddEditLocalWeatherObservationDialogData {
  id?: string | null;
  date?: Date | null;
  precipitation?: number | null;
  snow?: number | null;
  tracePrecipitation?: boolean | null;
  traceSnow?: boolean | null;
}

export interface IAddEditLocalWeatherObservation {
  id?: string | null;
  date?: string | null;
  precipitation?: number | null;
  snow?: number | null;
  tracePrecipitation?: boolean | null;
  traceSnow?: boolean | null;
}

export interface ILocalWeatherObservation {
  id: string;
  date: string;
  precipitation: number;
  tracePrecipitation: boolean;
  precipitationString: string;
  snow: number;
  traceSnow: boolean;
  snowString: string;
}

export interface ILocalWeatherObservationSummary {
  id: string;
  date: string;
  precipitation: number;
  cumulativePrecipitation: number;
  snow: number;
  cumulativeSnow: number;
}
