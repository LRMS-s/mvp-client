import { Injectable } from '@angular/core';
import { Subject, Observable } from 'rxjs';

export enum NotificationType {
  SUCCESS = 'success',
  ERROR = 'error',
  INFO = 'info',
  WARNING = 'warning'
}

export interface Notification {
  id: string;
  type: NotificationType;
  message: string;
  timeout?: number;
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private notificationSubject: Subject<Notification> = new Subject<Notification>();
  public notifications$: Observable<Notification> = this.notificationSubject.asObservable();

  success(message: string, timeout: number = 5000): void {
    this.show(NotificationType.SUCCESS, message, timeout);
  }

  error(message: string, timeout: number = 5000): void {
    this.show(NotificationType.ERROR, message, timeout);
  }

  info(message: string, timeout: number = 5000): void {
    this.show(NotificationType.INFO, message, timeout);
  }

  warning(message: string, timeout: number = 5000): void {
    this.show(NotificationType.WARNING, message, timeout);
  }

  private show(type: NotificationType, message: string, timeout?: number): void {
    const id = this.generateId();
    this.notificationSubject.next({ id, type, message, timeout });
  }

  private generateId(): string {
    return '_' + Math.random().toString(36).substr(2, 9);
  }
}
