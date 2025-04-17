import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (token) {
    const authReq = req.clone({
      setHeaders: {
        Authorization: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEsInVzZXJuYW1lIjoiYWRtaW4iLCJlbWFpbCI6ImFkbWluQGFkbWluLmNvbSIsInVzZXJUeXBlIjoiYWRtaW4iLCJpYXQiOjE3NDQ4MzgwNDIsImV4cCI6MTc0NDkyNDQ0Mn0.k7JRxknrkzK07MCOx_AoRNA7rwwNkV9ZzwhHdiLgzcs`,
      },
    });
    return next(authReq);
  }

  return next(req);
};
