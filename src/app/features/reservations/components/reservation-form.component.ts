import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ReservationService } from '../services/reservation.service';
import { PropertyService } from '../../properties/services/property.service';
import { VehicleService } from '../../vehicles/services/vehicle.service';
import { ClientService } from '../../clients/services/client.service';
import { NotificationService } from '../../../core/services/notification.service';
import { Property } from '../../../core/models/property.model';
import { Vehicle } from '../../../core/models/vehicle.model';
import { Client } from '../../../core/models/client.model';
import { HttpErrorResponse } from '@angular/common/http';

@Component({
  selector: 'app-reservation-form',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './reservation-form.component.html',
  styleUrl: './reservation-form.component.scss',
})
export class ReservationFormComponent implements OnInit {
  reservationForm: FormGroup;
  properties: Property[] = [];
  vehicles: Vehicle[] = [];
  clients: Client[] = [];
  selectedItemType: 'property' | 'vehicle' = 'property';
  isLoading = false;
  isSubmitting = false;

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private reservationService: ReservationService,
    private propertyService: PropertyService,
    private vehicleService: VehicleService,
    private clientService: ClientService,
    private notificationService: NotificationService
  ) {
    this.reservationForm = this.fb.group({
      itemType: ['property', Validators.required],
      propertyId: [null],
      vehicleId: [null],
      clientId: [null, Validators.required],
      startDate: [null, Validators.required],
      endDate: [null, Validators.required],
      additionalServices: this.fb.group({}),
      notes: [''],
    });
  }

  ngOnInit(): void {
    this.isLoading = true;

    // Load clients
    this.clientService.getClients().subscribe({
      next: (clients) => {
        this.clients = clients;
      },
      error: (err: HttpErrorResponse) => {
        console.error('Error loading clients', err);
        this.notificationService.error('Failed to load clients');
      },
    });

    // Load properties
    this.propertyService.getProperties().subscribe({
      next: (properties) => {
        this.properties = properties;
      },
      error: (err: HttpErrorResponse) => {
        console.error('Error loading properties', err);
        this.notificationService.error('Failed to load properties');
      },
    });

    // Load vehicles
    this.vehicleService.getVehicles().subscribe({
      next: (vehicles) => {
        this.vehicles = vehicles;
        this.isLoading = false;
      },
      error: (err: HttpErrorResponse) => {
        console.error('Error loading vehicles', err);
        this.notificationService.error('Failed to load vehicles');
        this.isLoading = false;
      },
    });

    // Update validators when item type changes
    this.reservationForm.get('itemType')?.valueChanges.subscribe((value) => {
      this.selectedItemType = value;
      this.updateItemValidators();
    });
  }

  updateItemValidators(): void {
    const propertyControl = this.reservationForm.get('propertyId');
    const vehicleControl = this.reservationForm.get('vehicleId');

    if (this.selectedItemType === 'property') {
      propertyControl?.setValidators(Validators.required);
      vehicleControl?.clearValidators();
    } else {
      vehicleControl?.setValidators(Validators.required);
      propertyControl?.clearValidators();
    }

    propertyControl?.updateValueAndValidity();
    vehicleControl?.updateValueAndValidity();
  }

  onItemTypeChange(itemType: 'property' | 'vehicle'): void {
    this.reservationForm.patchValue({ itemType });
    // Reset the previously selected item
    if (itemType === 'property') {
      this.reservationForm.patchValue({ vehicleId: null });
    } else {
      this.reservationForm.patchValue({ propertyId: null });
    }
  }

  onSelectedItemChange(event: Event, controlName: string): void {
    const value = (event.target as HTMLSelectElement).value;
    this.reservationForm.patchValue({ [controlName]: value ? +value : null });

    // If it's property or vehicle, load available additional services
    if (controlName === 'propertyId' || controlName === 'vehicleId') {
      this.loadAdditionalServices(controlName, value ? +value : null);
    }
  }

  loadAdditionalServices(type: string, id: number | null): void {
    if (!id) return;

    const service =
      type === 'propertyId'
        ? this.propertyService.getPropertyAdditionalServices(id)
        : this.vehicleService.getVehicleAdditionalServices(id);

    service.subscribe({
      next: (services) => {
        // Reset additional services form group
        this.reservationForm.setControl(
          'additionalServices',
          this.fb.group({})
        );

        // Create form controls for each service
        const servicesGroup = this.reservationForm.get(
          'additionalServices'
        ) as FormGroup;
        services.forEach((service) => {
          servicesGroup.addControl(service.name, this.fb.control(false));
        });
      },
      error: (err: HttpErrorResponse) => {
        console.error('Error loading additional services', err);
        this.notificationService.error('Failed to load additional services');
      },
    });
  }

  validateDates(): boolean {
    const startDate = this.reservationForm.get('startDate')?.value;
    const endDate = this.reservationForm.get('endDate')?.value;

    if (!startDate || !endDate) return false;

    const start = new Date(startDate);
    const end = new Date(endDate);

    // Check if end date is after start date
    return end > start;
  }

  checkAvailability(): void {
    if (!this.validateDates()) {
      this.notificationService.error(
        'Invalid date range. End date must be after start date.'
      );
      return;
    }

    const formValue = this.reservationForm.value;
    const itemId =
      this.selectedItemType === 'property'
        ? formValue.propertyId
        : formValue.vehicleId;

    if (!itemId) {
      this.notificationService.error('Please select a property or vehicle.');
      return;
    }

    this.isLoading = true;
    this.reservationService
      .checkAvailability({
        itemType: this.selectedItemType,
        itemId,
        startDate: formValue.startDate,
        endDate: formValue.endDate,
      })
      .subscribe({
        next: (available: boolean) => {
          this.isLoading = false;
          if (available) {
            this.notificationService.success(
              'The selected item is available for these dates!'
            );
          } else {
            this.notificationService.error(
              'The selected item is not available for these dates. Please choose different dates.'
            );
          }
        },
        error: (err: HttpErrorResponse) => {
          this.isLoading = false;
          console.error('Error checking availability', err);
          this.notificationService.error('Failed to check availability');
        },
      });
  }

  onSubmit(): void {
    if (this.reservationForm.invalid) {
      this.markFormGroupTouched(this.reservationForm);
      this.notificationService.error(
        'Please fill in all required fields correctly.'
      );
      return;
    }

    if (!this.validateDates()) {
      this.notificationService.error(
        'Invalid date range. End date must be after start date.'
      );
      return;
    }

    const formValue = this.reservationForm.value;

    // Format additional services into expected format
    const additionalServicesObj = formValue.additionalServices || {};
    const additionalServices = Object.keys(additionalServicesObj)
      .filter((key) => additionalServicesObj[key])
      .reduce((obj, key) => {
        obj[key] = true;
        return obj;
      }, {} as Record<string, boolean>);

    const reservationData = {
      itemType: formValue.itemType,
      ...(formValue.itemType === 'property'
        ? { propertyId: formValue.propertyId }
        : { vehicleId: formValue.vehicleId }),
      clientId: formValue.clientId,
      startDate: formValue.startDate,
      endDate: formValue.endDate,
      additionalServices,
      notes: formValue.notes,
    };

    this.isSubmitting = true;
    this.reservationService.createReservation(reservationData).subscribe({
      next: (reservation) => {
        this.isSubmitting = false;
        this.notificationService.success('Reservation created successfully');
        this.router.navigate(['/reservations', reservation.id]);
      },
      error: (err: HttpErrorResponse) => {
        this.isSubmitting = false;
        console.error('Error creating reservation', err);
        this.notificationService.error('Failed to create reservation');
      },
    });
  }

  // Helper method to mark all controls in a form group as touched
  markFormGroupTouched(formGroup: FormGroup): void {
    Object.keys(formGroup.controls).forEach((key) => {
      const control = formGroup.get(key);
      control?.markAsTouched();

      // Check if control is a FormGroup itself
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  // Cancel and go back
  cancel(): void {
    this.router.navigate(['/reservations']);
  }
}
