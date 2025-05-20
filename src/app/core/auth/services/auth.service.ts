import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, tap } from 'rxjs';
import { Router } from '@angular/router';
import {
  AuthRequest,
  AuthResponse,
  RegisterRequest,
} from '../models/auth.model';
import { User } from '../../models/user.model';
import { environment } from '../../../../environments/environment';
import { ApiService } from '../../services/api.service';
import { Client } from '../../models/client.model';
import { Staff } from '../../models/staff.model';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly API_URL = `${environment.apiUrl}/auth`;
  private readonly TOKEN_KEY = 'auth_token';
  private readonly USER_KEY = 'current_user';

  private currentUserSubject = new BehaviorSubject<User | null>(
    this.getUserFromStorage()
  );
  public currentUser$ = this.currentUserSubject.asObservable();

  constructor(
    private http: HttpClient,
    private router: Router,
    private apiService: ApiService
  ) {}

  login(authRequest: AuthRequest): Observable<AuthResponse> {
    return this.http
      .post<AuthResponse>(`${this.API_URL}/login`, authRequest)
      .pipe(
        tap((response) => {
          this.setSession(response);
          this.currentUserSubject.next(response.user);
        })
      );
  }

  register(registerRequest: RegisterRequest): Observable<User> {
    return this.http.post<User>(`${this.API_URL}/register`, registerRequest);
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.USER_KEY);
    this.currentUserSubject.next(null);
    this.router.navigate(['/auth/login']);
  }

  forgotPassword(email: string): Observable<{ message: string }> {
    return this.http.post<{ message: string }>(
      `${this.API_URL}/password/forgot`,
      { email }
    );
  }

  resetPassword(
    token: string,
    newPassword: string
  ): Observable<{ message: string }> {
    return this.http.post<{ message: string }>(
      `${this.API_URL}/password/reset`,
      { token, newPassword }
    );
  }

  validateToken(): Observable<User> {
    return this.http.post<User>(`${this.API_URL}/validate-token`, {
      token: this.getToken(),
    });
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }

  private setSession(authResult: AuthResponse): void {
    localStorage.setItem(this.TOKEN_KEY, authResult.access_token);
    localStorage.setItem(this.USER_KEY, JSON.stringify(authResult.user));
  }

  private getUserFromStorage(): User | null {
    const userStr = localStorage.getItem(this.USER_KEY);
    if (userStr) {
      try {
        return JSON.parse(userStr) as User;
      } catch {
        return null;
      }
    }
    return null;
  }
  getUserProfile(): Observable<User | Client | Staff> {
    return this.http.get<User | Client | Staff>(`${this.API_URL}/profile`);
  }
}
