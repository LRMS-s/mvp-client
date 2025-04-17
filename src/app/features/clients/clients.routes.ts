import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const CLIENTS_ROUTES: Routes = [
  {
    path: ':id',
    loadComponent: () =>
      import('./components/client-detail.component').then(
        (c) => c.ClientDetailComponent
      ),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] },
  },
  {
    path: ':id/edit',
    loadComponent: () =>
      import('./components/client-form.component').then(
        (c) => c.ClientFormComponent
      ),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] },
  },
];
