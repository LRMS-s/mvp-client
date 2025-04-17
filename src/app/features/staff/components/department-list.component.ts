import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { DepartmentService } from '../services/department.service';
import { Department } from '../../../core/models/department.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-department-list',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './department-list.component.html',
})
export class DepartmentListComponent implements OnInit {
  departments: Department[] = [];
  filteredDepartments: Department[] = [];
  loading = true;
  isAdmin = false;

  // Form for creating/editing departments
  departmentForm: FormGroup;
  selectedDepartment: Department | null = null;
  formMode: 'create' | 'edit' = 'create';

  constructor(
    private departmentService: DepartmentService,
    private authService: AuthService,
    private notificationService: NotificationService,
    private fb: FormBuilder
  ) {
    this.departmentForm = this.createDepartmentForm();
    this.checkUserPermissions();
  }

  ngOnInit(): void {
    this.loadDepartments();
  }

  createDepartmentForm(): FormGroup {
    return this.fb.group({
      name: [''],
      description: [''],
    });
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    this.isAdmin = currentUser?.userType === UserType.ADMIN;
  }

  loadDepartments(): void {
    this.loading = true;
    this.departmentService.getDepartments().subscribe({
      next: (departments) => {
        this.departments = departments;
        this.filteredDepartments = [...departments];
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading departments', error);
        this.notificationService.error('Failed to load departments');
        this.loading = false;
      },
    });
  }

  onSubmit(): void {
    if (this.departmentForm.invalid) return;

    const departmentData = this.departmentForm.value;

    if (this.formMode === 'create') {
      this.createDepartment(departmentData);
    } else {
      this.updateDepartment(departmentData);
    }
  }

  createDepartment(departmentData: Partial<Department>): void {
    this.departmentService.createDepartment(departmentData).subscribe({
      next: (newDepartment) => {
        this.departments.push(newDepartment);
        this.filteredDepartments = [...this.departments];
        this.notificationService.success('Department created successfully');
        this.resetForm();
      },
      error: (error) => {
        console.error('Error creating department', error);
        this.notificationService.error('Failed to create department');
      },
    });
  }

  updateDepartment(departmentData: Partial<Department>): void {
    if (!this.selectedDepartment) return;

    this.departmentService
      .updateDepartment(this.selectedDepartment.id, departmentData)
      .subscribe({
        next: (updatedDepartment) => {
          const index = this.departments.findIndex(
            (d) => d.id === updatedDepartment.id
          );
          if (index !== -1) {
            this.departments[index] = updatedDepartment;
            this.filteredDepartments = [...this.departments];
          }
          this.notificationService.success('Department updated successfully');
          this.resetForm();
        },
        error: (error) => {
          console.error('Error updating department', error);
          this.notificationService.error('Failed to update department');
        },
      });
  }

  deleteDepartment(department: Department): void {
    if (
      !confirm(
        `Are you sure you want to delete the department "${department.name}"?`
      )
    )
      return;

    this.departmentService.deleteDepartment(department.id).subscribe({
      next: () => {
        this.departments = this.departments.filter(
          (d) => d.id !== department.id
        );
        this.filteredDepartments = [...this.departments];
        this.notificationService.success('Department deleted successfully');
      },
      error: (error) => {
        console.error('Error deleting department', error);
        this.notificationService.error('Failed to delete department');
      },
    });
  }

  editDepartment(department: Department): void {
    this.selectedDepartment = department;
    this.formMode = 'edit';
    this.departmentForm.patchValue({
      name: department.name,
      description: department.description,
    });
  }

  resetForm(): void {
    this.departmentForm.reset();
    this.selectedDepartment = null;
    this.formMode = 'create';
  }

  filterDepartments(searchTerm: string = ''): void {
    const term = searchTerm.toLowerCase().trim();
    this.filteredDepartments = this.departments.filter(
      (dept) =>
        dept.name.toLowerCase().includes(term) ||
        (dept.description && dept.description.toLowerCase().includes(term))
    );
  }
}
