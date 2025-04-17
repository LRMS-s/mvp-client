import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const VEHICLES_ROUTES: Routes = [
  // {
  //   path: '',
  //   loadComponent: () => import('./components/vehicle-list.component')
  //     .then(c => c.VehicleListComponent)
  // },
  // {
  //   path: 'new',
  //   loadComponent: () => import('./components/vehicle-form.component')
  //     .then(c => c.VehicleFormComponent),
  //   canActivate: [authGuard],
  //   data: { roles: [UserType.ADMIN, UserType.STAFF] }
  // },
  // {
  //   path: ':id',
  //   loadComponent: () => import('./components/vehicle-detail.component')
  //     .then(c => c.VehicleDetailComponent)
  // },
  // {
  //   path: ':id/edit',
  //   loadComponent: () => import('./components/vehicle-form.component')
  //     .then(c => c.VehicleFormComponent),
  //   canActivate: [authGuard],
  //   data: { roles: [UserType.ADMIN, UserType.STAFF] }
  // }
];
