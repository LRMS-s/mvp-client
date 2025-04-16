import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Staff, CreateStaffRequest } from '../../../core/models/staff.model';

@Injectable({
  providedIn: 'root'
})
export class StaffService {
  private readonly endpoint = 'staff';

  constructor(private apiService: ApiService) { }

  getStaffMembers(params: any = {}): Observable<Staff[]> {
    return this.apiService.get<Staff[]>(this.endpoint, params);
  }

  getStaffMember(id: number): Observable<Staff> {
    return this.apiService.get<Staff>(`${this.endpoint}/${id}`);
  }

  getStaffMemberByUserId(userId: number): Observable<Staff> {
    return this.apiService.get<Staff>(`${this.endpoint}/users/${userId}`);
  }

  getStaffByDepartment(departmentId: number): Observable<Staff[]> {
    return this.apiService.get<Staff[]>(`${this.endpoint}/departments/${departmentId}`);
  }

  createStaff(staff: CreateStaffRequest): Observable<Staff> {
    return this.apiService.post<Staff>(this.endpoint, staff);
  }

  updateStaff(id: number, staff: Partial<Staff>): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/${id}`, staff);
  }

  updateStaffByUserId(userId: number, staff: Partial<Staff>): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/users/${userId}`, staff);
  }

  activateStaff(id: number): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/${id}/activate`, {});
  }

  deactivateStaff(id: number): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/${id}/deactivate`, {});
  }

  deleteStaff(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getStaffStatistics(): Observable<any> {
    return this.apiService.get<any>(`${this.endpoint}/statistics`);
  }
}
