import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const SETTINGS_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/settings.component')
      .then(c => c.SettingsComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  },
  {
    path: 'profile',
    loadComponent: () => import('./components/profile.component')
      .then(c => c.ProfileComponent),
    canActivate: [authGuard]
  }
];
