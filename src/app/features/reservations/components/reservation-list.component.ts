import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { ReservationService } from '../services/reservation.service';
import {
  Reservation,
  ReservationStatus,
  PaymentStatus,
} from '../../../core/models/reservation.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';

@Component({
  selector: 'app-reservation-list',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule, DatePipe],
  templateUrl: './reservation-list.component.html',
  styleUrl: './reservation-list.component.scss',
})
export class ReservationListComponent implements OnInit {
  reservations: Reservation[] = [];
  filteredReservations: Reservation[] = [];
  loading = true;
  filterForm: FormGroup;

  // Enum values for filters
  reservationStatuses = Object.values(ReservationStatus);
  paymentStatuses = Object.values(PaymentStatus);

  // Pagination
  currentPage = 1;
  itemsPerPage = 10;

  // User permissions
  isAdmin = false;
  isStaff = false;

  Math = Math;
  constructor(
    private formBuilder: FormBuilder,
    private reservationService: ReservationService,
    private authService: AuthService
  ) {
    this.filterForm = this.createFilterForm();
    this.checkUserPermissions();
  }

  ngOnInit(): void {
    this.loadReservations();

    // Apply filters when form values change
    this.filterForm.valueChanges.subscribe(() => {
      this.applyFilters();
    });
  }

  createFilterForm(): FormGroup {
    return this.formBuilder.group({
      searchTerm: [''],
      status: [''],
      paymentStatus: [''],
      startDateFrom: [''],
      startDateTo: [''],
      minAmount: [''],
      maxAmount: [''],
    });
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    if (currentUser) {
      this.isAdmin = currentUser.userType === UserType.ADMIN;
      this.isStaff = currentUser.userType === UserType.STAFF;
    }
  }

  loadReservations(): void {
    this.loading = true;
    this.reservationService.getReservations().subscribe({
      next: (data) => {
        this.reservations = data;
        this.applyFilters();
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading reservations', error);
        this.loading = false;
      },
    });
  }

  applyFilters(): void {
    const filters = this.filterForm.value;

    this.filteredReservations = this.reservations.filter((reservation) => {
      // Search term filter
      if (filters.searchTerm) {
        const searchTerm = filters.searchTerm.toLowerCase();
        const matchesSearch =
          reservation.reservationNumber.toLowerCase().includes(searchTerm) ||
          reservation.client.user.firstName
            .toLowerCase()
            .includes(searchTerm) ||
          reservation.client.user.lastName.toLowerCase().includes(searchTerm);

        if (!matchesSearch) return false;
      }

      // Status filter
      if (filters.status && reservation.status !== filters.status) {
        return false;
      }

      // Payment status filter
      if (
        filters.paymentStatus &&
        reservation.paymentStatus !== filters.paymentStatus
      ) {
        return false;
      }

      // Start date from filter
      if (filters.startDateFrom) {
        const startDateFrom = new Date(filters.startDateFrom);
        if (new Date(reservation.startDate) < startDateFrom) return false;
      }

      // Start date to filter
      if (filters.startDateTo) {
        const startDateTo = new Date(filters.startDateTo);
        if (new Date(reservation.startDate) > startDateTo) return false;
      }

      // Minimum amount filter
      if (
        filters.minAmount &&
        reservation.totalAmount < parseFloat(filters.minAmount)
      ) {
        return false;
      }

      // Maximum amount filter
      if (
        filters.maxAmount &&
        reservation.totalAmount > parseFloat(filters.maxAmount)
      ) {
        return false;
      }

      return true;
    });

    // Reset pagination when filters change
    this.currentPage = 1;
  }

  resetFilters(): void {
    this.filterForm.reset();
    this.applyFilters();
  }

  get paginatedReservations(): Reservation[] {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    return this.filteredReservations.slice(
      startIndex,
      startIndex + this.itemsPerPage
    );
  }

  get totalPages(): number {
    return Math.ceil(this.filteredReservations.length / this.itemsPerPage);
  }

  changePage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }
}
