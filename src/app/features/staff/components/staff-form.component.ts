import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { StaffService } from '../services/staff.service';
import { DepartmentService } from '../services/department.service';
import {
  Staff,
  EmploymentType,
  CreateStaffRequest,
} from '../../../core/models/staff.model';
import { Department } from '../../../core/models/department.model';
import { UserType } from '../../../core/models/user.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { NotificationService } from '../../../core/services/notification.service';
import { passwordValidator } from '../../../shared/validators/password.validator';
import { ReplacePipe } from '../../../shared/pipes/replace.pipe';

@Component({
  selector: 'app-staff-form',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule, ReplacePipe],
  templateUrl: './staff-form.component.html',
})
export class StaffFormComponent implements OnInit {
  staffForm: FormGroup;
  isEditMode = false;
  staffId: number | null = null;
  loading = false;
  submitting = false;
  error = '';

  departments: Department[] = [];
  employmentTypes = Object.values(EmploymentType);

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private staffService: StaffService,
    private departmentService: DepartmentService,
    private authService: AuthService,
    private notificationService: NotificationService
  ) {
    this.staffForm = this.createForm();
    this.checkUserPermissions();
  }

  ngOnInit(): void {
    this.loadDepartments();

    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.staffId = +id;
      this.loadStaff(this.staffId);
    }
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    if (currentUser?.userType !== UserType.ADMIN) {
      this.notificationService.error(
        'You do not have permission to manage staff'
      );
      this.router.navigate(['/']);
    }
  }

  loadDepartments(): void {
    this.departmentService.getDepartments().subscribe({
      next: (departments) => {
        this.departments = departments;
      },
      error: (err) => {
        console.error('Error loading departments', err);
        this.notificationService.error('Failed to load departments');
      },
    });
  }

  createForm(): FormGroup {
    return this.fb.group({
      // User information
      user: this.fb.group({
        firstName: ['', [Validators.required, Validators.maxLength(50)]],
        lastName: ['', [Validators.required, Validators.maxLength(50)]],
        email: ['', [Validators.required, Validators.email]],
        phone: ['', [Validators.pattern(/^\+?[0-9\s()-]{10,}$/)]],
        address: [''],
        city: [''],
        state: [''],
        country: [''],
        postalCode: [''],
        // Conditional password validation
        password: [
          '',
          this.isEditMode
            ? []
            : [
                Validators.required,
                passwordValidator({
                  minLength: 8,
                  requireUppercase: true,
                  requireLowercase: true,
                  requireDigit: true,
                  requireSpecialChar: true,
                }),
              ],
        ],
        userType: [UserType.STAFF],
      }),

      // Staff-specific information
      staff: this.fb.group({
        departmentId: ['', [Validators.required]],
        position: ['', [Validators.required, Validators.maxLength(100)]],
        employmentType: ['', [Validators.required]],
        hireDate: ['', [Validators.required]],
        qualification: [''],
        emergencyContact: [''],
        salary: ['', [Validators.min(0)]],
        isActive: [true],
      }),
    });
  }

  loadStaff(id: number): void {
    this.loading = true;
    this.staffService.getStaffMember(id).subscribe({
      next: (staff) => {
        this.patchForm(staff);
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading staff', err);
        this.error = 'Failed to load staff data';
        this.notificationService.error(this.error);
        this.loading = false;
      },
    });
  }

  patchForm(staff: Staff): void {
    // Remove password validator in edit mode
    const userGroup = this.staffForm.get('user') as FormGroup;
    userGroup.get('password')?.clearValidators();
    userGroup.get('password')?.updateValueAndValidity();

    this.staffForm.patchValue({
      user: {
        firstName: staff.user.firstName,
        lastName: staff.user.lastName,
        email: staff.user.email,
        phone: staff.user.phone,
        address: staff.user.address,
        city: staff.user.city,
        state: staff.user.state,
        country: staff.user.country,
        postalCode: staff.user.postalCode,
      },
      staff: {
        departmentId: staff.department.id,
        position: staff.position,
        employmentType: staff.employmentType,
        hireDate: staff.hireDate,
        qualification: staff.qualification,
        emergencyContact: staff.emergencyContact,
        salary: staff.salary,
        isActive: staff.isActive,
      },
    });
  }

  onSubmit(): void {
    if (this.staffForm.invalid) {
      this.markFormGroupTouched(this.staffForm);
      return;
    }

    this.submitting = true;

    const formValue = this.staffForm.value;

    if (this.isEditMode && this.staffId) {
      // In edit mode, update staff details
      const updateData = {
        staff: {
          departmentId: formValue.staff.departmentId,
          position: formValue.staff.position,
          employmentType: formValue.staff.employmentType,
          hireDate: formValue.staff.hireDate,
          qualification: formValue.staff.qualification,
          emergencyContact: formValue.staff.emergencyContact,
          salary: formValue.staff.salary,
          isActive: formValue.staff.isActive,
        },
        user: {
          firstName: formValue.user.firstName,
          lastName: formValue.user.lastName,
          phone: formValue.user.phone,
          address: formValue.user.address,
          city: formValue.user.city,
          state: formValue.user.state,
          country: formValue.user.country,
          postalCode: formValue.user.postalCode,
        },
      };

      this.staffService.updateStaff(this.staffId, updateData.staff).subscribe({
        next: () => {
          this.notificationService.success('Staff member updated successfully');
          this.router.navigate(['/staff', this.staffId]);
        },
        error: (err) => {
          console.error('Error updating staff', err);
          this.error = 'Failed to update staff member';
          this.notificationService.error(this.error);
          this.submitting = false;
        },
      });
    } else {
      // In create mode, send full staff and user data
      const createData: CreateStaffRequest = {
        staff: {
          departmentId: formValue.staff.departmentId,
          position: formValue.staff.position,
          employmentType: formValue.staff.employmentType,
          hireDate: formValue.staff.hireDate,
          qualification: formValue.staff.qualification,
          emergencyContact: formValue.staff.emergencyContact,
          salary: formValue.staff.salary,
        },
        user: {
          ...formValue.user,
          userType: UserType.STAFF,
        },
      };

      this.staffService.createStaff(createData).subscribe({
        next: () => {
          this.notificationService.success('Staff member created successfully');
          this.router.navigate(['/staff']);
        },
        error: (err) => {
          console.error('Error creating staff', err);
          this.error = 'Failed to create staff member';
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

  getFieldError(formGroup: string, fieldName: string): string {
    const field = this.staffForm.get(`${formGroup}.${fieldName}`);
    if (!field || !field.errors || !field.touched) return '';

    if (field.errors['required']) return 'This field is required';
    if (field.errors['email']) return 'Please enter a valid email address';
    if (field.errors['minlength']) {
      return `Minimum length is ${field.errors['minlength'].requiredLength} characters`;
    }
    if (field.errors['pattern']) return 'Invalid format';

    return 'Invalid input';
  }
}
