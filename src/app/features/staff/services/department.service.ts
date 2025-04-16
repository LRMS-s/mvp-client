import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Department } from '../../../core/models/department.model';

@Injectable({
  providedIn: 'root'
})
export class DepartmentService {
  private readonly endpoint = 'departments';

  constructor(private apiService: ApiService) { }

  getDepartments(): Observable<Department[]> {
    return this.apiService.get<Department[]>(this.endpoint);
  }

  getDepartment(id: number): Observable<Department> {
    return this.apiService.get<Department>(`${this.endpoint}/${id}`);
  }

  createDepartment(department: Partial<Department>): Observable<Department> {
    return this.apiService.post<Department>(this.endpoint, department);
  }

  updateDepartment(id: number, department: Partial<Department>): Observable<Department> {
    return this.apiService.patch<Department>(`${this.endpoint}/${id}`, department);
  }

  deleteDepartment(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getDepartmentWithStaff(id: number): Observable<Department> {
    return this.apiService.get<Department>(`${this.endpoint}/${id}/staff`);
  }
}
