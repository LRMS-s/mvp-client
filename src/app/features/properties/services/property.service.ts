import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import {
  Property,
  CreatePropertyRequest,
} from '../../../core/models/property.model';
import { AdditionalService } from '../../../core/models/additional-service';

@Injectable({
  providedIn: 'root',
})
export class PropertyService {
  private readonly endpoint = 'properties';

  constructor(private apiService: ApiService) {}

  getProperties(params: any = {}): Observable<Property[]> {
    return this.apiService.get<Property[]>(this.endpoint, params);
  }

  getProperty(id: number): Observable<Property> {
    return this.apiService.get<Property>(`${this.endpoint}/${id}`);
  }

  createProperty(property: CreatePropertyRequest): Observable<Property> {
    return this.apiService.post<Property>(this.endpoint, property);
  }

  updateProperty(
    id: number,
    property: Partial<CreatePropertyRequest>
  ): Observable<Property> {
    return this.apiService.patch<Property>(`${this.endpoint}/${id}`, property);
  }

  deleteProperty(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getPropertyTypes(): Observable<string[]> {
    return this.apiService.get<string[]>(`${this.endpoint}/types`);
  }

  getLocationTypes(): Observable<string[]> {
    return this.apiService.get<string[]>(`${this.endpoint}/location-types`);
  }

  searchProperties(query: string): Observable<Property[]> {
    return this.apiService.get<Property[]>(`${this.endpoint}/search`, {
      q: query,
    });
  }

  getPropertiesByType(type: string): Observable<Property[]> {
    return this.apiService.get<Property[]>(`${this.endpoint}/type/${type}`);
  }

  getPropertiesByLocation(location: string): Observable<Property[]> {
    return this.apiService.get<Property[]>(
      `${this.endpoint}/location/${location}`
    );
  }

  getPropertyAdditionalServices(
    propertyId: number
  ): Observable<AdditionalService[]> {
    return this.apiService.get<AdditionalService[]>(
      `${this.endpoint}/${propertyId}/additional-services`
    );
  }
  getAvailableProperties(
    startDate: string,
    endDate: string,
    params: any = {}
  ): Observable<Property[]> {
    return this.apiService.get<Property[]>(`rental-items/available`, {
      itemType: 'property',
      startDate,
      endDate,
      ...params,
    });
  }
}
