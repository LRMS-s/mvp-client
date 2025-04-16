import { RentalItemType } from './rental-item.model';
import { Client } from './client.model';
import { Property } from './property.model';
import { Vehicle } from './vehicle.model';

export enum ReservationStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  CHECKED_IN = 'checked_in',
  CHECKED_OUT = 'checked_out',
  CANCELLED = 'cancelled',
  NO_SHOW = 'no_show'
}

export enum PaymentStatus {
  PENDING = 'pending',
  PARTIALLY_PAID = 'partially_paid',
  PAID = 'paid',
  REFUNDED = 'refunded',
  FAILED = 'failed'
}

export interface Reservation {
  id: number;
  reservationNumber: string;
  status: ReservationStatus;
  paymentStatus: PaymentStatus;
  startDate: Date;
  endDate: Date;
  totalAmount: number;
  paidAmount: number;
  notes?: string;
  itemType: RentalItemType;
  propertyId?: number;
  vehicleId?: number;
  property?: Property;
  vehicle?: Vehicle;
  clientId: number;
  client: Client;
  additionalServices?: Record<string, any>;
  guestInformation?: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateReservationRequest {
  itemType: RentalItemType;
  propertyId?: number;
  vehicleId?: number;
  clientId: number;
  startDate: Date;
  endDate: Date;
  totalAmount?: number;
  paidAmount?: number;
  notes?: string;
  additionalServices?: Record<string, any>;
  guestInformation?: Record<string, any>;
}
