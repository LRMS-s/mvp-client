import { Injectable } from '@angular/core';
import { forkJoin, Observable, of } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiService } from '../../../core/services/api.service';

@Injectable({
  providedIn: 'root'
})
export class DashboardService {
  constructor(private apiService: ApiService) { }

  getDashboardStats(): Observable<any> {
    // Create a combined request for all dashboard data
    return forkJoin({
      propertyStats: this.getPropertyStats(),
      vehicleStats: this.getVehicleStats(),
      reservationStats: this.getReservationStats(),
      clientStats: this.getClientStats(),
      recentReservations: this.getRecentReservations(),
      upcomingMaintenance: this.getUpcomingMaintenance()
    });
  }

  private getPropertyStats(): Observable<any> {
    return this.apiService.get('properties/statistics');
  }

  private getVehicleStats(): Observable<any> {
    return this.apiService.get('vehicles/statistics');
  }

  private getReservationStats(): Observable<any> {
    return this.apiService.get('reservations/statistics');
  }

  private getClientStats(): Observable<any> {
    return this.apiService.get('clients/statistics');
  }

  private getRecentReservations(): Observable<any> {
    return this.apiService.get('reservations', { limit: 5, sort: 'createdAt,desc' });
  }

  private getUpcomingMaintenance(): Observable<any> {
    // This might need to be adjusted based on your API
    return this.apiService.get('maintenance/upcoming');
  }
}
