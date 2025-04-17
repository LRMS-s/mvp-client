import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType, User } from '../../../core/models/user.model';
import { ClientService } from '../../clients/services/client.service';
import { StaffService } from '../../staff/services/staff.service';
import { Client } from '../../../core/models/client.model';
import { Staff } from '../../../core/models/staff.model';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss'],
})
export class ProfileComponent implements OnInit {
  userForm: FormGroup;
  profileForm: FormGroup;
  passwordForm: FormGroup;

  currentUser: User | null = null;
  clientProfile: Client | null = null;
  staffProfile: Staff | null = null;

  isClient = false;
  isStaff = false;
  isAdmin = false;

  isLoading = true;
  isSaving = false;
  isChangingPassword = false;
  generalError = '';
  passwordError = '';
  successMessage = '';
  passwordSuccessMessage = '';

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private clientService: ClientService,
    private staffService: StaffService
  ) {
    this.userForm = this.createUserForm();
    this.profileForm = this.createProfileForm();
    this.passwordForm = this.createPasswordForm();
  }

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    if (this.currentUser) {
      this.isClient = this.currentUser.userType === UserType.CLIENT;
      this.isStaff = this.currentUser.userType === UserType.STAFF;
      this.isAdmin = this.currentUser.userType === UserType.ADMIN;

      this.patchUserForm(this.currentUser);
      this.loadAdditionalProfile();
    } else {
      this.isLoading = false;
      this.generalError = 'User not authenticated';
    }
  }

  createUserForm(): FormGroup {
    return this.fb.group({
      firstName: ['', [Validators.required]],
      lastName: ['', [Validators.required]],
      email: [{ value: '', disabled: true }],
      phone: [''],
      address: [''],
      city: [''],
      state: [''],
      country: [''],
      postalCode: [''],
    });
  }

  createProfileForm(): FormGroup {
    return this.fb.group({
      // Client specific fields
      companyName: [''],
      nationality: [''],
      taxId: [''],
      clientSource: [''],
      clientNotes: [''],

      // Staff specific fields
      emergencyContact: [''],
      qualification: [''],
    });
  }

  createPasswordForm(): FormGroup {
    return this.fb.group({
      currentPassword: ['', [Validators.required]],
      newPassword: ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword: ['', [Validators.required]],
    });
  }

  patchUserForm(user: User): void {
    this.userForm.patchValue({
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      address: user.address,
      city: user.city,
      state: user.state,
      country: user.country,
      postalCode: user.postalCode,
    });
  }

  loadAdditionalProfile(): void {
    if (!this.currentUser) return;

    if (this.isClient) {
      this.clientService.getClientByUserId(this.currentUser.id).subscribe({
        next: (client) => {
          this.clientProfile = client;
          this.patchClientProfile(client);
          this.isLoading = false;
        },
        error: (err) => {
          console.error('Error loading client profile', err);
          this.generalError = 'Failed to load client profile details';
          this.isLoading = false;
        },
      });
    } else if (this.isStaff || this.isAdmin) {
      this.staffService.getStaffMemberByUserId(this.currentUser.id).subscribe({
        next: (staff) => {
          this.staffProfile = staff;
          this.patchStaffProfile(staff);
          this.isLoading = false;
        },
        error: (err) => {
          console.error('Error loading staff profile', err);
          this.generalError = 'Failed to load staff profile details';
          this.isLoading = false;
        },
      });
    } else {
      this.isLoading = false;
    }
  }

  patchClientProfile(client: Client): void {
    this.profileForm.patchValue({
      companyName: client.companyName,
      nationality: client.nationality,
      taxId: client.taxId,
      clientSource: client.clientSource,
      clientNotes: client.notes,
    });
  }

  patchStaffProfile(staff: Staff): void {
    this.profileForm.patchValue({
      emergencyContact: staff.emergencyContact,
      qualification: staff.qualification,
    });
  }

  // onUserSubmit(): void {
  //   if (this.userForm.invalid) {
  //     this.markFormGroupTouched(this.userForm);
  //     return;
  //   }

  //   this.isSaving = true;
  //   this.generalError = '';
  //   this.successMessage = '';

  //   const userData = this.userForm.getRawValue();

  //   // Updating user profile
  //   this.authService.updateProfile(userData).subscribe({
  //     next: (user) => {
  //       // Update the current user object
  //       if (this.currentUser) {
  //         Object.assign(this.currentUser, user);
  //       }

  //       this.successMessage = 'Profile updated successfully';
  //       this.isSaving = false;
  //     },
  //     error: (err) => {
  //       console.error('Error updating profile', err);
  //       this.generalError = 'Failed to update profile';
  //       this.isSaving = false;
  //     }
  //   });
  // }

  onProfileSubmit(): void {
    if (this.profileForm.invalid) {
      this.markFormGroupTouched(this.profileForm);
      return;
    }

    this.isSaving = true;
    this.generalError = '';
    this.successMessage = '';

    if (this.isClient && this.clientProfile) {
      const clientData = {
        companyName: this.profileForm.value.companyName,
        nationality: this.profileForm.value.nationality,
        taxId: this.profileForm.value.taxId,
        clientSource: this.profileForm.value.clientSource,
        notes: this.profileForm.value.clientNotes,
      };

      this.clientService
        .updateClient(this.clientProfile.id, clientData)
        .subscribe({
          next: () => {
            this.successMessage = 'Client profile updated successfully';
            this.isSaving = false;
          },
          error: (err) => {
            console.error('Error updating client profile', err);
            this.generalError = 'Failed to update client profile';
            this.isSaving = false;
          },
        });
    } else if ((this.isStaff || this.isAdmin) && this.staffProfile) {
      const staffData = {
        emergencyContact: this.profileForm.value.emergencyContact,
        qualification: this.profileForm.value.qualification,
      };

      this.staffService
        .updateStaffByUserId(this.currentUser!.id, staffData)
        .subscribe({
          next: () => {
            this.successMessage = 'Staff profile updated successfully';
            this.isSaving = false;
          },
          error: (err) => {
            console.error('Error updating staff profile', err);
            this.generalError = 'Failed to update staff profile';
            this.isSaving = false;
          },
        });
    } else {
      this.isSaving = false;
    }
  }

  onPasswordSubmit(): void {
    if (this.passwordForm.invalid) {
      this.markFormGroupTouched(this.passwordForm);
      return;
    }

    if (
      this.passwordForm.value.newPassword !==
      this.passwordForm.value.confirmPassword
    ) {
      this.passwordError = 'New passwords do not match';
      return;
    }

    this.isChangingPassword = true;
    this.passwordError = '';
    this.passwordSuccessMessage = '';

    this.authService
      .resetPassword(
        this.passwordForm.value.currentPassword,
        this.passwordForm.value.newPassword
      )
      .subscribe({
        next: () => {
          this.passwordSuccessMessage = 'Password changed successfully';
          this.passwordForm.reset();
          this.isChangingPassword = false;
        },
        error: (err) => {
          console.error('Error changing password', err);
          this.passwordError =
            err.error?.message || 'Failed to change password';
          this.isChangingPassword = false;
        },
      });
  }

  markFormGroupTouched(formGroup: FormGroup): void {
    Object.values(formGroup.controls).forEach((control) => {
      control.markAsTouched();

      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  getFieldError(formGroup: FormGroup, fieldName: string): string {
    const field = formGroup.get(fieldName);
    if (!field || !field.errors || !field.touched) return '';

    if (field.errors['required']) return 'This field is required';
    if (field.errors['email']) return 'Please enter a valid email address';
    if (field.errors['minlength']) {
      return `Minimum length is ${field.errors['minlength'].requiredLength} characters`;
    }

    return 'Invalid input';
  }
}
