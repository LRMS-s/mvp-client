import { Injectable } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { NotificationService } from './notification.service';

@Injectable({
  providedIn: 'root'
})
export class ErrorHandlerService {
  constructor(private notificationService: NotificationService) { }

  handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An error occurred';

    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Error: ${error.error.message}`;
    } else {
      // Server-side error
      if (error.status === 401) {
        errorMessage = 'You are not authorized to perform this action';
      } else if (error.status === 403) {
        errorMessage = 'You do not have permission to access this resource';
      } else if (error.status === 404) {
        errorMessage = 'The requested resource was not found';
      } else if (error.status === 500) {
        errorMessage = 'Internal server error occurred';
      } else {
        errorMessage = error.error?.message || `Error Code: ${error.status}, Message: ${error.message}`;
      }
    }

    this.notificationService.error(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}
