import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { DepartmentService } from '../services/department.service';
import { Department } from '../../../core/models/department.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-department-form',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './department-form.component.html',
})
export class DepartmentFormComponent implements OnInit {
  departmentForm: FormGroup;
  isEditMode = false;
  departmentId: number | null = null;
  loading = false;
  submitting = false;
  error = '';

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private departmentService: DepartmentService,
    private authService: AuthService,
    private notificationService: NotificationService
  ) {
    this.departmentForm = this.createForm();
    this.checkUserPermissions();
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.departmentId = +id;
      this.loadDepartment(this.departmentId);
    }
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    if (currentUser?.userType !== UserType.ADMIN) {
      this.notificationService.error(
        'You do not have permission to manage departments'
      );
      this.router.navigate(['/']);
    }
  }

  createForm(): FormGroup {
    return this.fb.group({
      name: [
        '',
        [
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(100),
        ],
      ],
      description: ['', [Validators.maxLength(500)]],
    });
  }

  loadDepartment(id: number): void {
    this.loading = true;
    this.departmentService.getDepartment(id).subscribe({
      next: (department) => {
        this.departmentForm.patchValue({
          name: department.name,
          description: department.description || '',
        });
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading department', err);
        this.error = 'Failed to load department data';
        this.notificationService.error(this.error);
        this.loading = false;
      },
    });
  }

  onSubmit(): void {
    if (this.departmentForm.invalid) {
      this.markFormGroupTouched(this.departmentForm);
      return;
    }

    this.submitting = true;

    const departmentData = this.departmentForm.value;

    if (this.isEditMode && this.departmentId) {
      // Update existing department
      this.departmentService
        .updateDepartment(this.departmentId, departmentData)
        .subscribe({
          next: (updatedDepartment) => {
            this.notificationService.success('Department updated successfully');
            this.router.navigate(['/staff/departments']);
          },
          error: (err) => {
            console.error('Error updating department', err);
            this.error = 'Failed to update department';
            this.notificationService.error(this.error);
            this.submitting = false;
          },
        });
    } else {
      // Create new department
      this.departmentService.createDepartment(departmentData).subscribe({
        next: (newDepartment) => {
          this.notificationService.success('Department created successfully');
          this.router.navigate(['/staff/departments']);
        },
        error: (err) => {
          console.error('Error creating department', err);
          this.error = 'Failed to create department';
          this.notificationService.error(this.error);
          this.submitting = false;
        },
      });
    }
  }

  markFormGroupTouched(formGroup: FormGroup): void {
    Object.values(formGroup.controls).forEach((control) => {
      control.markAsTouched();

      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  getFieldError(fieldName: string): string {
    const field = this.departmentForm.get(fieldName);
    if (!field || !field.errors || !field.touched) return '';

    if (field.errors['required']) return 'This field is required';
    if (field.errors['minlength']) {
      return `Minimum length is ${field.errors['minlength'].requiredLength} characters`;
    }
    if (field.errors['maxlength']) {
      return `Maximum length is ${field.errors['maxlength'].requiredLength} characters`;
    }

    return 'Invalid input';
  }
}
