import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const STAFF_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/staff-list.component')
      .then(c => c.StaffListComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: 'new',
    loadComponent: () => import('./components/staff-form.component')
      .then(c => c.StaffFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  },
  {
    path: 'profile',
    loadComponent: () => import('./components/staff-profile.component')
      .then(c => c.StaffProfileComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: 'departments',
    loadComponent: () => import('./components/department-list.component')
      .then(c => c.DepartmentListComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  },
  {
    path: ':id',
    loadComponent: () => import('./components/staff-detail.component')
      .then(c => c.StaffDetailComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/staff-form.component')
      .then(c => c.StaffFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  }
];
