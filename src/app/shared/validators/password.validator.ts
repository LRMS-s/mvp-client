import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function passwordValidator(options: {
  minLength?: number;
  requireUppercase?: boolean;
  requireLowercase?: boolean;
  requireDigit?: boolean;
  requireSpecialChar?: boolean;
} = {}): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value;

    if (!value) {
      return null;
    }

    const minLength = options.minLength ?? 8;
    const requireUppercase = options.requireUppercase ?? true;
    const requireLowercase = options.requireLowercase ?? true;
    const requireDigit = options.requireDigit ?? true;
    const requireSpecialChar = options.requireSpecialChar ?? true;

    const errors: ValidationErrors = {};

    if (value.length < minLength) {
      errors['minLength'] = {
        required: minLength,
        actual: value.length
      };
    }

    if (requireUppercase && !/[A-Z]/.test(value)) {
      errors['requireUppercase'] = true;
    }

    if (requireLowercase && !/[a-z]/.test(value)) {
      errors['requireLowercase'] = true;
    }

    if (requireDigit && !/[0-9]/.test(value)) {
      errors['requireDigit'] = true;
    }

    if (requireSpecialChar && !/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(value)) {
      errors['requireSpecialChar'] = true;
    }

    return Object.keys(errors).length > 0 ? errors : null;
  };
}

export function passwordMatchValidator(passwordControl: AbstractControl): ValidatorFn {
  return (confirmPasswordControl: AbstractControl): ValidationErrors | null => {
    if (!passwordControl || !confirmPasswordControl) {
      return null;
    }

    const password = passwordControl.value;
    const confirmPassword = confirmPasswordControl.value;

    if (password !== confirmPassword) {
      return { passwordMismatch: true };
    }

    return null;
  };
}
