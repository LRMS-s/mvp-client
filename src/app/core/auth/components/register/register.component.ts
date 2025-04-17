import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Router, RouterModule } from '@angular/router';

import { HttpErrorResponse } from '@angular/common/http';
import { AuthService } from '../../services/auth.service';
import { NotificationService } from '../../../services/notification.service';
import {
  passwordMatchValidator,
  passwordValidator,
} from '../../../../shared/validators/password.validator';
import { UserType } from '../../../models/user.model';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
})
export class RegisterComponent implements OnInit {
  registerForm: FormGroup;
  loading = false;
  submitted = false;
  error = '';

  constructor(
    private formBuilder: FormBuilder,
    private router: Router,
    private authService: AuthService,
    private notificationService: NotificationService
  ) {
    this.registerForm = this.createForm();

    // Redirect to home if already logged in
    if (this.authService.isLoggedIn()) {
      this.router.navigate(['/']);
    }
  }

  ngOnInit(): void {
    // Setup password confirmation validator
    const passwordControl = this.registerForm.get('password');
    if (passwordControl) {
      this.registerForm
        .get('confirmPassword')
        ?.setValidators([
          Validators.required,
          passwordMatchValidator(passwordControl),
        ]);
      this.registerForm.get('confirmPassword')?.updateValueAndValidity();
    }
  }

  createForm(): FormGroup {
    return this.formBuilder.group({
      firstName: ['', [Validators.required, Validators.maxLength(50)]],
      lastName: ['', [Validators.required, Validators.maxLength(50)]],
      username: [
        '',
        [
          Validators.required,
          Validators.minLength(3),
          Validators.maxLength(20),
        ],
      ],
      email: ['', [Validators.required, Validators.email]],
      password: [
        '',
        [
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
      confirmPassword: ['', Validators.required],
      userType: [UserType.CLIENT],
    });
  }

  // Convenience getter for easy access to form fields
  get f() {
    return this.registerForm.controls;
  }

  onSubmit(): void {
    this.submitted = true;

    // stop here if form is invalid
    if (this.registerForm.invalid) {
      return;
    }

    this.loading = true;

    const registerData = {
      username: this.f['username'].value,
      email: this.f['email'].value,
      password: this.f['password'].value,
      firstName: this.f['firstName'].value,
      lastName: this.f['lastName'].value,
      userType: this.f['userType'].value,
    };

    this.authService.register(registerData).subscribe({
      next: () => {
        this.notificationService.success(
          'Registration successful, you can now log in'
        );
        this.router.navigate(['/auth/login']);
      },
      error: (error: HttpErrorResponse) => {
        this.error = error?.error?.message || 'Registration failed';
        this.notificationService.error(this.error);
        this.loading = false;
      },
    });
  }
}
