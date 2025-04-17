import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { ReservationService } from '../services/reservation.service';
import { Reservation } from '../../../core/models/reservation.model';
import { NotificationService } from '../../../core/services/notification.service';

interface CalendarDay {
  date: Date;
  reservations: Reservation[];
  isOtherMonth: boolean;
}

@Component({
  selector: 'app-calendar-view',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe],
  templateUrl: './calendar-view.component.html',
  styleUrl: './calendar-view.component.scss',
})
export class CalendarViewComponent implements OnInit {
  currentMonth: Date = new Date();
  calendarDays: CalendarDay[] = [];
  weekdays: string[] = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  currentView: 'month' | 'week' | 'day' = 'month';
  selectedReservation: Reservation | null = null;
  loading = true;
  error = false;

  constructor(
    private reservationService: ReservationService,
    private notificationService: NotificationService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.generateCalendarDays();
    this.loadReservations();
  }

  generateCalendarDays(): void {
    const firstDayOfMonth = new Date(
      this.currentMonth.getFullYear(),
      this.currentMonth.getMonth(),
      1
    );
    const lastDayOfMonth = new Date(
      this.currentMonth.getFullYear(),
      this.currentMonth.getMonth() + 1,
      0
    );

    // Calculate days to show from previous and next months
    const startDate = new Date(firstDayOfMonth);
    startDate.setDate(startDate.getDate() - startDate.getDay());

    const endDate = new Date(lastDayOfMonth);
    endDate.setDate(endDate.getDate() + (6 - endDate.getDay()));

    this.calendarDays = [];
    const currentDate = new Date(startDate);

    while (currentDate <= endDate) {
      this.calendarDays.push({
        date: new Date(currentDate),
        reservations: [],
        isOtherMonth: currentDate.getMonth() !== this.currentMonth.getMonth(),
      });

      currentDate.setDate(currentDate.getDate() + 1);
    }
  }

  loadReservations(): void {
    this.loading = true;
    const firstDay = this.calendarDays[0].date;
    const lastDay = this.calendarDays[this.calendarDays.length - 1].date;

    this.reservationService
      .getReservationsInDateRange(firstDay.toISOString(), lastDay.toISOString())
      .subscribe({
        next: (reservations) => {
          this.mapReservationsToCalendar(reservations);
          this.loading = false;
        },
        error: (err) => {
          console.error('Error loading reservations', err);
          this.notificationService.error('Failed to load reservations');
          this.error = true;
          this.loading = false;
        },
      });
  }

  mapReservationsToCalendar(reservations: Reservation[]): void {
    // Reset existing reservations
    this.calendarDays.forEach((day) => (day.reservations = []));

    reservations.forEach((reservation) => {
      const startDate = new Date(reservation.startDate);
      const endDate = new Date(reservation.endDate);

      this.calendarDays.forEach((day) => {
        if (day.date >= startDate && day.date <= endDate) {
          day.reservations.push(reservation);
        }
      });
    });
  }

  goToPreviousMonth(): void {
    this.currentMonth.setMonth(this.currentMonth.getMonth() - 1);
    this.generateCalendarDays();
    this.loadReservations();
  }

  goToNextMonth(): void {
    this.currentMonth.setMonth(this.currentMonth.getMonth() + 1);
    this.generateCalendarDays();
    this.loadReservations();
  }

  switchView(view: 'month' | 'week' | 'day'): void {
    this.currentView = view;
    // Additional view-specific logic can be added here
  }

  openReservationDetails(reservation: Reservation): void {
    this.selectedReservation = reservation;
  }

  closeReservationDetails(): void {
    this.selectedReservation = null;
  }

  viewFullReservationDetails(): void {
    if (this.selectedReservation) {
      this.router.navigate(['/reservations', this.selectedReservation.id]);
    }
  }
}
