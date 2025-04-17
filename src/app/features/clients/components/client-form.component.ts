import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ClientService } from '../services/client.service';
import { Client } from '../../../core/models/client.model';
import { UserType } from '../../../core/models/user.model';

@Component({
  selector: 'app-client-form',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './client-form.component.html',
  styleUrls: ['./client-form.component.scss'],
})
export class ClientFormComponent implements OnInit {
  clientForm: FormGroup;
  isEditMode = false;
  clientId: number | null = null;
  isLoading = false;
  isSaving = false;
  error = '';

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    private clientService: ClientService
  ) {
    this.clientForm = this.createForm();
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    console.log(id);

    if (id) {
      this.isEditMode = true;
      this.clientId = +id;
      this.loadClient(this.clientId);
    }
  }

  createForm(): FormGroup {
    return this.fb.group({
      // User information
      firstName: ['', [Validators.required]],
      lastName: ['', [Validators.required]],
      username: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      phone: [''],
      address: [''],
      city: [''],
      state: [''],
      country: [''],
      postalCode: [''],
      // In edit mode, we don't update password
      password: [
        '',
        this.isEditMode ? [] : [Validators.required, Validators.minLength(8)],
      ],
      userType: [UserType.CLIENT],
      // Client specific information
      companyName: [''],
      nationality: [''],
      taxId: [''],
      clientSource: [''],
      notes: [''],
    });
  }

  loadClient(id: number): void {
    this.isLoading = true;
    this.clientService.getClient(id).subscribe({
      next: (client) => {
        this.patchForm(client);
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Error loading client', err);
        this.error = 'Failed to load client data';
        this.isLoading = false;
      },
    });
  }

  patchForm(client: Client): void {
    // Remove password validator in edit mode
    const userGroup = this.clientForm.get('user') as FormGroup;
    userGroup.get('password')?.clearValidators();
    userGroup.get('password')?.updateValueAndValidity();

    // Patch form with client data
    this.clientForm.patchValue({
      user: {
        firstName: client.firstName,
        lastName: client.lastName,
        email: client.email,
        phone: client.phone,
        address: client.address,
        city: client.city,
        state: client.state,
        country: client.country,
        postalCode: client.postalCode,
        userType: client.userType,
      },
      companyName: client.companyName,
      nationality: client.nationality,
      taxId: client.taxId,
      clientSource: client.clientSource,
      notes: client.notes,
    });
  }

  onSubmit(): void {
    if (this.clientForm.invalid) {
      // Mark all fields as touched to trigger validation messages
      this.markFormGroupTouched(this.clientForm);
      return;
    }

    this.isSaving = true;

    if (this.isEditMode && this.clientId) {
      // In edit mode, we only update client-specific fields, not user auth data
      const clientData = {
        companyName: this.clientForm.value.companyName,
        nationality: this.clientForm.value.nationality,
        taxId: this.clientForm.value.taxId,
        clientSource: this.clientForm.value.clientSource,
        notes: this.clientForm.value.notes,
      };

      this.clientService.updateClient(this.clientId, clientData).subscribe({
        next: (updatedClient) => {
          this.router.navigate(['/clients', updatedClient.id]);
        },
        error: (err) => {
          console.error('Error updating client', err);
          this.error =
            'Failed to update client. Please check your input and try again.';
          this.isSaving = false;
        },
      });
    } else {
      // In create mode, we need both user and client data
      this.clientService.createClient(this.clientForm.value).subscribe({
        next: (newClient) => {
          this.router.navigate(['/clients', newClient.id]);
        },
        error: (err) => {
          console.error('Error creating client', err);
          this.error =
            'Failed to create client. Please check your input and try again.';
          this.isSaving = false;
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

  // Helper getters for form validation
  get userForm(): FormGroup {
    return this.clientForm.get('user') as FormGroup;
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
