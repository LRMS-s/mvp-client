import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const RESERVATIONS_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./components/reservation-list.component').then(
        (c) => c.ReservationListComponent
      ),
    canActivate: [authGuard],
  },
  // {
  //   path: 'new',
  //   loadComponent: () =>
  //     import('./components/reservation-form.component').then(
  //       (c) => c.ReservationFormComponent
  //     ),
  //   canActivate: [authGuard],
  // },
  {
    path: 'calendar',
    loadComponent: () =>
      import('./components/calendar-view.component').then(
        (c) => c.CalendarViewComponent
      ),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] },
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./components/reservation-detail.component').then(
        (c) => c.ReservationDetailComponent
      ),
    canActivate: [authGuard],
  },
  // {
  //   path: ':id/edit',
  //   loadComponent: () => import('./components/reservation-form.component')
  //     .then(c => c.ReservationFormComponent),
  //   canActivate: [authGuard],
  //   data: { roles: [UserType.ADMIN, UserType.STAFF] }
  // }
];
