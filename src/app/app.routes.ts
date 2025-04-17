import { Routes } from '@angular/router';
import { authGuard } from './core/auth/guards/auth.guard';
import { UserType } from './core/models/user.model';
import { MainLayoutComponent } from './layout/layouts/main-layout.component';

export const routes: Routes = [
  {
    path: '',
    component: MainLayoutComponent,
    children: [
      {
        path: '',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then(
            (c) => c.DashboardComponent
          ),
        canActivate: [authGuard],
      },
      {
        path: 'properties',
        loadChildren: () =>
          import('./features/properties/properties.routes').then(
            (r) => r.PROPERTIES_ROUTES
          ),
        canActivate: [authGuard],
      },
      {
        path: 'vehicles',
        loadChildren: () =>
          import('./features/vehicles/vehicles.routes').then(
            (r) => r.VEHICLES_ROUTES
          ),
        canActivate: [authGuard],
      },
      {
        path: 'reservations',
        loadChildren: () =>
          import('./features/reservations/reservations.routes').then(
            (r) => r.RESERVATIONS_ROUTES
          ),
        canActivate: [authGuard],
      },
      {
        path: 'clients',
        loadChildren: () =>
          import('./features/clients/clients.routes').then(
            (r) => r.CLIENTS_ROUTES
          ),
        canActivate: [authGuard],
      },
      {
        path: 'staff',
        loadChildren: () =>
          import('./features/staff/staff.routes').then((r) => r.STAFF_ROUTES),
        canActivate: [authGuard],
      },
      {
        path: 'settings',
        loadChildren: () =>
          import('./features/settings/settings.routes').then(
            (r) => r.SETTINGS_ROUTES
          ),
        canActivate: [authGuard],
      },
    ],
  },
  {
    path: 'auth',
    loadChildren: () =>
      import('./core/auth/auth.routes').then((r) => r.AUTH_ROUTES),
  },
  // {
  //   path: '**',
  //   redirectTo: '',
  // },
];
