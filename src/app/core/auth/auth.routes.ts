import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';

export const AUTH_ROUTES: Routes = [
  {
    path: 'login',
    component: LoginComponent,
  },
  {
    path: 'register',
    loadChildren: () =>
      import('./components/register/register.component').then(
        (m) => m.RegisterComponent
      ),
  },
];
