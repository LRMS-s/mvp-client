import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const PROPERTIES_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/property-list.component')
      .then(c => c.PropertyListComponent)
  },
  {
    path: 'new',
    loadComponent: () => import('./components/property-form.component')
      .then(c => c.PropertyFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id',
    loadComponent: () => import('./components/property-detail.component')
      .then(c => c.PropertyDetailComponent)
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/property-form.component')
      .then(c => c.PropertyFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  }
];
