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

      // Staff-specific information
      departmentId: ['', [Validators.required]],
      position: ['', [Validators.required, Validators.maxLength(100)]],
      employmentType: ['', [Validators.required]],
      hireDate: ['', [Validators.required]],
      qualification: [''],
      emergencyContact: [''],
      salary: ['', [Validators.min(0)]],
      isActive: [true],
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
    this.staffForm.get('password')?.clearValidators();
    this.staffForm.get('password')?.updateValueAndValidity();

    this.staffForm.patchValue({
      firstName: staff.firstName,
      lastName: staff.lastName,
      email: staff.email,
      phone: staff.phone,
      address: staff.address,
      city: staff.city,
      state: staff.state,
      country: staff.country,
      postalCode: staff.postalCode,
      departmentId: staff.department.id,
      position: staff.position,
      employmentType: staff.employmentType,
      hireDate: staff.hireDate,
      qualification: staff.qualification,
      emergencyContact: staff.emergencyContact,
      salary: staff.salary,
      isActive: staff.isActive,
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
        departmentId: formValue.departmentId,
        position: formValue.position,
        employmentType: formValue.employmentType,
        hireDate: formValue.hireDate,
        qualification: formValue.qualification,
        emergencyContact: formValue.emergencyContact,
        salary: formValue.salary,
        isActive: formValue.isActive,
        firstName: formValue.firstName,
        lastName: formValue.lastName,
        phone: formValue.phone,
        address: formValue.address,
        city: formValue.city,
        state: formValue.state,
        country: formValue.country,
        postalCode: formValue.postalCode,
      };

      this.staffService.updateStaff(this.staffId, updateData).subscribe({
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
        ...formValue,
        departmentId: +formValue.departmentId,
        username: formValue.name + '_' + formValue.lastName,
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
