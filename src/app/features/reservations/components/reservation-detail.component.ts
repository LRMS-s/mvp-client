import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { ReservationService } from '../services/reservation.service';
import { Reservation } from '../../../core/models/reservation.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-reservation-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe],
  templateUrl: './reservation-detail.component.html',
  styleUrl: './reservation-detail.component.scss',
})
export class ReservationDetailComponent implements OnInit {
  reservation: Reservation | null = null;
  loading = true;
  error = false;
  isAdmin = false;
  isStaff = false;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private reservationService: ReservationService,
    private authService: AuthService,
    private notificationService: NotificationService
  ) {}

  ngOnInit(): void {
    this.checkUserPermissions();
    this.loadReservation();
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    if (currentUser) {
      this.isAdmin = currentUser.userType === UserType.ADMIN;
      this.isStaff = currentUser.userType === UserType.STAFF;
    }
  }

  loadReservation(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.error = true;
      this.loading = false;
      return;
    }

    this.reservationService.getReservation(+id).subscribe({
      next: (data) => {
        this.reservation = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading reservation', err);
        this.error = true;
        this.loading = false;
        this.notificationService.error('Failed to load reservation details');
      },
    });
  }

  cancelReservation(): void {
    if (
      !this.reservation ||
      !confirm('Are you sure you want to cancel this reservation?')
    ) {
      return;
    }

    this.reservationService.cancelReservation(this.reservation.id).subscribe({
      next: () => {
        this.notificationService.success('Reservation cancelled successfully');
        this.router.navigate(['/reservations']);
      },
      error: (err) => {
        console.error('Error cancelling reservation', err);
        this.notificationService.error('Failed to cancel reservation');
      },
    });
  }

  checkInReservation(): void {
    if (!this.reservation) return;

    this.reservationService.checkInReservation(this.reservation.id).subscribe({
      next: (updatedReservation) => {
        this.reservation = updatedReservation;
        this.notificationService.success('Reservation checked in successfully');
      },
      error: (err) => {
        console.error('Error checking in reservation', err);
        this.notificationService.error('Failed to check in reservation');
      },
    });
  }

  checkOutReservation(): void {
    if (!this.reservation) return;

    this.reservationService.checkOutReservation(this.reservation.id).subscribe({
      next: (updatedReservation) => {
        this.reservation = updatedReservation;
        this.notificationService.success(
          'Reservation checked out successfully'
        );
      },
      error: (err) => {
        console.error('Error checking out reservation', err);
        this.notificationService.error('Failed to check out reservation');
      },
    });
  }
}
