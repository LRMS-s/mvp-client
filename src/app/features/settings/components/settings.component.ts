import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { SettingsService } from '../services/settings.service';
import { NotificationService } from '../../../core/services/notification.service';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './settings.component.html',
  styleUrl: './settings.component.scss',
})
export class SettingsComponent implements OnInit {
  settingsForm: FormGroup;
  loading = true;
  isSaving = false;
  error = '';

  constructor(
    private fb: FormBuilder,
    private settingsService: SettingsService,
    private notificationService: NotificationService,
    private authService: AuthService
  ) {
    this.settingsForm = this.createForm();
  }

  ngOnInit(): void {
    this.loadSettings();
  }

  createForm(): FormGroup {
    return this.fb.group({
      companyName: ['', [Validators.required, Validators.maxLength(100)]],
      supportEmail: ['', [Validators.required, Validators.email]],
      phoneNumber: ['', [Validators.pattern(/^\+?[0-9\s()-]{10,}$/)]],
      enableNotifications: [true],
      language: ['en'],
      requireTwoFactor: [false],
      sessionTimeout: [30, [Validators.min(5), Validators.max(1440)]],
    });
  }

  loadSettings(): void {
    this.loading = true;
    this.error = '';

    this.settingsService.getSystemSettings().subscribe({
      next: (settings) => {
        this.settingsForm.patchValue(settings);
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading settings', err);
        this.error = 'Failed to load system settings';
        this.loading = false;
        this.notificationService.error(this.error);
      },
    });
  }

  onSubmit(): void {
    if (this.settingsForm.invalid) {
      this.markFormGroupTouched(this.settingsForm);
      return;
    }

    this.isSaving = true;
    const currentUser = this.authService.getCurrentUser();

    // Only allow admin to modify system settings
    if (currentUser?.userType !== UserType.ADMIN) {
      this.notificationService.error(
        'Only administrators can modify system settings'
      );
      this.isSaving = false;
      return;
    }

    this.settingsService
      .updateSystemSettings(this.settingsForm.value)
      .subscribe({
        next: (updatedSettings) => {
          this.settingsForm.patchValue(updatedSettings);
          this.notificationService.success(
            'System settings updated successfully'
          );
          this.isSaving = false;
        },
        error: (err) => {
          console.error('Error updating settings', err);
          this.notificationService.error('Failed to update system settings');
          this.isSaving = false;
        },
      });
  }

  resetForm(): void {
    // Confirm before resetting to defaults
    if (
      confirm(
        'Are you sure you want to reset all settings to their default values?'
      )
    ) {
      // Create a new form with default values
      this.settingsForm = this.createForm();
      this.notificationService.warning('Settings reset to default values');
    }
  }

  private markFormGroupTouched(formGroup: FormGroup): void {
    Object.values(formGroup.controls).forEach((control) => {
      control.markAsTouched();

      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }
}
