import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';

@Injectable({
  providedIn: 'root'
})
export class SettingsService {
  private readonly endpoint = 'settings';

  constructor(private apiService: ApiService) { }

  getSystemSettings(): Observable<any> {
    return this.apiService.get<any>(this.endpoint);
  }

  updateSystemSettings(settings: any): Observable<any> {
    return this.apiService.patch<any>(this.endpoint, settings);
  }

  getUserPreferences(userId: number, category?: string): Observable<any> {
    const params: any = {};
    if (category) {
      params.category = category;
    }
    return this.apiService.get<any>(`users/${userId}/preferences`, params);
  }

  setUserPreference(userId: number, category: string, key: string, value: string): Observable<any> {
    return this.apiService.post<any>(`users/${userId}/preferences`, { category, key, value });
  }

  deleteUserPreference(userId: number, category: string, key: string): Observable<void> {
    return this.apiService.delete<void>(`users/${userId}/preferences/${category}/${key}`);
  }
}
