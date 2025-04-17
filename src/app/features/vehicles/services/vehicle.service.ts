import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import {
  Vehicle,
  CreateVehicleRequest,
} from '../../../core/models/vehicle.model';
import { AdditionalService } from '../../../core/models/additional-service';

@Injectable({
  providedIn: 'root',
})
export class VehicleService {
  private readonly endpoint = 'vehicles';

  constructor(private apiService: ApiService) {}

  getVehicles(params: any = {}): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(this.endpoint, params);
  }

  getVehicle(id: number): Observable<Vehicle> {
    return this.apiService.get<Vehicle>(`${this.endpoint}/${id}`);
  }

  createVehicle(vehicle: CreateVehicleRequest): Observable<Vehicle> {
    return this.apiService.post<Vehicle>(this.endpoint, vehicle);
  }

  updateVehicle(
    id: number,
    vehicle: Partial<CreateVehicleRequest>
  ): Observable<Vehicle> {
    return this.apiService.patch<Vehicle>(`${this.endpoint}/${id}`, vehicle);
  }

  deleteVehicle(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getVehicleTypes(): Observable<string[]> {
    return this.apiService.get<string[]>(`${this.endpoint}/types`);
  }

  searchVehicles(query: string): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/search`, {
      q: query,
    });
  }

  getVehiclesByType(type: string): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/type/${type}`);
  }

  getVehiclesByMakeModel(make: string, model?: string): Observable<Vehicle[]> {
    const params: any = { make };
    if (model) {
      params.model = model;
    }
    return this.apiService.get<Vehicle[]>(
      `${this.endpoint}/make-model`,
      params
    );
  }

  getVehiclesByYearRange(
    minYear: number,
    maxYear: number
  ): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/year-range`, {
      minYear,
      maxYear,
    });
  }

  getAvailableVehicles(
    startDate: string,
    endDate: string,
    params: any = {}
  ): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`rental-items/available`, {
      itemType: 'vehicle',
      startDate,
      endDate,
      ...params,
    });
  }

  getVehicleAdditionalServices(
    vehicleId: number
  ): Observable<AdditionalService[]> {
    return this.apiService.get<AdditionalService[]>(
      `${this.endpoint}/${vehicleId}/additional-services`
    );
  }
}
