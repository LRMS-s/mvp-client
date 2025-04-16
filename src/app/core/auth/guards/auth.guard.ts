import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';
import { UserType } from '../../models/user.model';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (!authService.isLoggedIn()) {
    router.navigate(['/auth/login'], { queryParams: { returnUrl: state.url } });
    return false;
  }

  // Role-based authorization check
  const requiredRoles = route.data?.['roles'] as UserType[];
  if (requiredRoles) {
    const currentUser = authService.getCurrentUser();
    if (!currentUser || !requiredRoles.includes(currentUser.userType)) {
      router.navigate(['/']);
      return false;
    }
  }

  return true;
};
