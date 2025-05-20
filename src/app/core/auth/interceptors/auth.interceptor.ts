import {
  HttpErrorResponse,
  HttpInterceptorFn,
  HttpStatusCode,
} from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';
import { catchError } from 'rxjs';
import { NotificationService } from '../../services/notification.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const notificationService = inject(NotificationService);
  const token = authService.getToken();

  if (token) {
    const authReq = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` },
    });
    return next(authReq).pipe(
      catchError((err) => {
        if ([HttpStatusCode.Forbidden].includes(err.status)) {
          authService.logout();
        }
        if ([HttpStatusCode.Unauthorized].includes(err.status)) {
          console.log(err, 'error');

          notificationService.error('Unauthorized');
        }
        throw err;
      })
    );
  }

  return next(req);
};
