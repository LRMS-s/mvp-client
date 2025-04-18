import { Injectable } from '@angular/core';
import { Observable, map } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import {
  Reservation,
  CreateReservationRequest,
  ReservationStatus,
  PaymentStatus,
} from '../../../core/models/reservation.model';
import { RentalItem } from '../../../core/models/rental-item.model';

@Injectable({
  providedIn: 'root',
})
export class ReservationService {
  private readonly endpoint = 'reservations';
  private readonly availabilityEndpoint = 'availability';
  constructor(private apiService: ApiService) {}

  getReservations(params: any = {}): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(this.endpoint, params);
  }

  getReservation(id: number): Observable<Reservation> {
    return this.apiService.get<Reservation>(`${this.endpoint}/${id}`);
  }

  getReservationByNumber(reservationNumber: string): Observable<Reservation> {
    return this.apiService.get<Reservation>(
      `${this.endpoint}/number/${reservationNumber}`
    );
  }

  createReservation(
    reservation: CreateReservationRequest
  ): Observable<Reservation> {
    return this.apiService.post<Reservation>(this.endpoint, reservation);
  }

  updateReservation(
    id: number,
    reservation: Partial<CreateReservationRequest>
  ): Observable<Reservation> {
    return this.apiService.patch<Reservation>(
      `${this.endpoint}/${id}`,
      reservation
    );
  }

  updateReservationStatus(
    id: number,
    status: ReservationStatus
  ): Observable<Reservation> {
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}/status`, {
      status,
    });
  }

  updatePaymentStatus(
    id: number,
    paymentStatus: PaymentStatus,
    paidAmount?: number
  ): Observable<Reservation> {
    const data: any = { paymentStatus };
    if (paidAmount !== undefined) {
      data.paidAmount = paidAmount;
    }
    return this.apiService.patch<Reservation>(
      `${this.endpoint}/${id}/payment`,
      data
    );
  }

  cancelReservation(id: number): Observable<Reservation> {
    return this.apiService.patch<Reservation>(
      `${this.endpoint}/${id}/cancel`,
      {}
    );
  }

  checkInReservation(id: number): Observable<Reservation> {
    return this.apiService.patch<Reservation>(
      `${this.endpoint}/${id}/check-in`,
      {}
    );
  }

  checkOutReservation(id: number): Observable<Reservation> {
    return this.apiService.patch<Reservation>(
      `${this.endpoint}/${id}/check-out`,
      {}
    );
  }

  markAsPaid(id: number): Observable<Reservation> {
    return this.apiService.post<Reservation>(
      `${this.endpoint}/${id}/pay-full`,
      {}
    );
  }

  refundReservation(id: number): Observable<Reservation> {
    return this.apiService.post<Reservation>(
      `${this.endpoint}/${id}/refund`,
      {}
    );
  }

  deleteReservation(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getClientReservations(clientId: number): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(
      `${this.endpoint}/client/${clientId}`
    );
  }

  getPropertyReservations(propertyId: number): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(
      `${this.endpoint}/property/${propertyId}`
    );
  }

  getVehicleReservations(vehicleId: number): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(
      `${this.endpoint}/vehicle/${vehicleId}`
    );
  }
  getReservationsInDateRange(
    startDate: string,
    endDate: string
  ): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/date-range`, {
      startDate,
      endDate,
    });
  }
  getAvailableItems(
    startDate: string,
    endDate: string,
    itemType?: string,
    itemId?: number
  ): Observable<any[]> {
    const params: any = {
      startDate: startDate,
      endDate: endDate,
    };

    if (itemType) {
      params.itemType = itemType;
    }

    if (itemId) {
      params.itemId = itemId;
    }

    return this.apiService
      .get<any[]>(`${this.availabilityEndpoint}/items`, params)
      .pipe(
        map((items: any[]) => {
          console.log(items);

          return items;
        })
      );
  }

  getUpcomingReservations(days: number = 7): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/upcoming`, {
      days,
    });
  }

  getCurrentReservations(): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/current`);
  }

  getReservationStatistics(): Observable<any> {
    return this.apiService.get<any>(`${this.endpoint}/statistics`);
  }
}
