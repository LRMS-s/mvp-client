import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import {
  FormBuilder,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VehicleService } from '../services/vehicle.service';
import {
  Vehicle,
  VehicleType,
  TransmissionType,
  FuelType,
  DrivetrainType,
  CreateVehicleRequest,
} from '../../../core/models/vehicle.model';
import { RentalItemStatus } from '../../../core/models/rental-item.model';
import { ReplacePipe } from '../../../shared/pipes/replace.pipe';
import { NotificationService } from '../../../core/services/notification.service';

@Component({
  selector: 'app-vehicle-form',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule, ReplacePipe],
  templateUrl: './vehicle-form.component.html',
  styleUrl: './vehicle-form.component.scss',
})
export class VehicleFormComponent implements OnInit {
  vehicleForm: FormGroup;
  isEditMode = false;
  vehicleId: number | null = null;
  loading = false;
  submitting = false;
  error = '';

  // Enum values for dropdowns
  vehicleTypes = Object.values(VehicleType);
  transmissionTypes = Object.values(TransmissionType);
  fuelTypes = Object.values(FuelType);
  drivetrainTypes = Object.values(DrivetrainType);
  statuses = Object.values(RentalItemStatus);

  constructor(
    private fb: FormBuilder,
    private vehicleService: VehicleService,
    private route: ActivatedRoute,
    private router: Router,
    private notificationService: NotificationService
  ) {
    this.vehicleForm = this.createForm();
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.vehicleId = +id;
      this.loadVehicle(this.vehicleId);
    }
  }
  keyValueCompareFn(
    a: { key: string; value: any },
    b: { key: string; value: any }
  ): number {
    return 0; // keeps the order, or you can implement custom sorting
  }
  createForm(): FormGroup {
    const currentYear = new Date().getFullYear();

    return this.fb.group({
      // Basic Information
      name: ['', []],
      description: [''],
      status: [RentalItemStatus.AVAILABLE],
      baseRate: [0, []],
      securityDeposit: [0, []],
      location: [''],
      mainImageUrl: [''],
      imageUrls: [[]],
      maximumCapacity: [1, []],

      // Vehicle Specific Information
      make: [''],
      model: [''],
      year: [
        currentYear,
        // [Validators.min(1900), Validators.max(currentYear + 1)],
      ],
      vehicleType: [VehicleType.SEDAN],
      vin: [''],
      licensePlate: [''],
      exteriorColor: [''],
      interiorColor: [''],
      mileage: [0, []],
      transmissionType: [TransmissionType.AUTOMATIC],
      fuelType: [FuelType.GASOLINE],
      fuelEconomy: [''],
      drivetrain: [DrivetrainType.AWD],
      seatingCapacity: [
        5,
        // [Validators.min(1)]
      ],
      trunkCapacity: [''],
      engineType: [''],
      engineSpecs: [''],
      performanceStats: [''],
      currentLocation: [''],
      fuelLevel: [
        100,
        //  [, Validators.max(100)]
      ],
      isLimitedEdition: [false],

      // Feature Maps
      luxuryFeatures: this.fb.group({
        leather_seats: [false],
        sunroof: [false],
        heated_seats: [false],
        premium_audio: [false],
        navigation_system: [false],
      }),
      safetyFeatures: this.fb.group({
        abs: [false],
        airbags: [false],
        traction_control: [false],
        blind_spot_monitoring: [false],
        lane_departure_warning: [false],
        parking_sensors: [false],
      }),
      technologyFeatures: this.fb.group({
        bluetooth: [false],
        usb_ports: [false],
        wireless_charging: [false],
        android_auto: [false],
        apple_carplay: [false],
        touch_screen: [false],
      }),
    });
  }

  loadVehicle(id: number): void {
    this.loading = true;
    this.vehicleService.getVehicle(id).subscribe({
      next: (vehicle) => {
        this.updateForm(vehicle);
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading vehicle', err);
        this.error = 'Failed to load vehicle details. Please try again.';
        this.notificationService.error(this.error);
        this.loading = false;
      },
    });
  }

  updateForm(vehicle: Vehicle): void {
    // Update basic fields
    this.vehicleForm.patchValue({
      name: vehicle.name,
      description: vehicle.description,
      status: vehicle.status,
      baseRate: vehicle.baseRate,
      securityDeposit: vehicle.securityDeposit,
      location: vehicle.location,
      mainImageUrl: vehicle.mainImageUrl,
      imageUrls: vehicle.imageUrls,
      maximumCapacity: vehicle.maximumCapacity,

      // Vehicle Specific Information
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year,
      vehicleType: vehicle.vehicleType,
      vin: vehicle.vin,
      licensePlate: vehicle.licensePlate,
      exteriorColor: vehicle.exteriorColor,
      interiorColor: vehicle.interiorColor,
      mileage: vehicle.mileage,
      transmissionType: vehicle.transmissionType,
      fuelType: vehicle.fuelType,
      fuelEconomy: vehicle.fuelEconomy,
      drivetrain: vehicle.drivetrain,
      seatingCapacity: vehicle.seatingCapacity,
      trunkCapacity: vehicle.trunkCapacity,
      engineType: vehicle.engineType,
      engineSpecs: vehicle.engineSpecs,
      performanceStats: vehicle.performanceStats,
      currentLocation: vehicle.currentLocation,
      fuelLevel: vehicle.fuelLevel,
      isLimitedEdition: vehicle.isLimitedEdition,
    });

    // Update feature maps
    if (vehicle.luxuryFeatures) {
      const luxuryFeaturesGroup = this.vehicleForm.get(
        'luxuryFeatures'
      ) as FormGroup;
      for (const [key, value] of Object.entries(vehicle.luxuryFeatures)) {
        if (luxuryFeaturesGroup.get(key)) {
          luxuryFeaturesGroup.get(key)?.setValue(value);
        }
      }
    }

    if (vehicle.safetyFeatures) {
      const safetyFeaturesGroup = this.vehicleForm.get(
        'safetyFeatures'
      ) as FormGroup;
      for (const [key, value] of Object.entries(vehicle.safetyFeatures)) {
        if (safetyFeaturesGroup.get(key)) {
          safetyFeaturesGroup.get(key)?.setValue(value);
        }
      }
    }

    if (vehicle.technologyFeatures) {
      const techFeaturesGroup = this.vehicleForm.get(
        'technologyFeatures'
      ) as FormGroup;
      for (const [key, value] of Object.entries(vehicle.technologyFeatures)) {
        if (techFeaturesGroup.get(key)) {
          techFeaturesGroup.get(key)?.setValue(value);
        }
      }
    }
  }

  onSubmit(): void {
    if (this.vehicleForm.invalid) {
      this.markFormGroupTouched(this.vehicleForm);
      return;
    }

    this.submitting = true;
    const formData = this.prepareFormData();

    if (this.isEditMode && this.vehicleId) {
      // Update existing vehicle
      this.vehicleService.updateVehicle(this.vehicleId, formData).subscribe({
        next: (vehicle) => {
          this.notificationService.success('Vehicle updated successfully');
          this.router.navigate(['/vehicles', vehicle.id]);
        },
        error: (err) => {
          console.error('Error updating vehicle', err);
          this.error =
            'Failed to update vehicle. Please check the form and try again.';
          this.notificationService.error(this.error);
          this.submitting = false;
        },
      });
    } else {
      // Create new vehicle
      this.vehicleService
        .createVehicle(formData as CreateVehicleRequest)
        .subscribe({
          next: (vehicle) => {
            this.notificationService.success('Vehicle created successfully');
            this.router.navigate(['/vehicles', vehicle.id]);
          },
          error: (err) => {
            console.error('Error creating vehicle', err);
            this.error =
              'Failed to create vehicle. Please check the form and try again.';
            this.notificationService.error(this.error);
            this.submitting = false;
          },
        });
    }
  }

  prepareFormData(): any {
    const formValue = this.vehicleForm.value;

    // Convert imageUrls from string to array if needed
    if (typeof formValue.imageUrls === 'string') {
      formValue.imageUrls = formValue.imageUrls
        .split(',')
        .map((url: string) => url.trim())
        .filter((url: string) => url);
    }

    return formValue;
  }

  markFormGroupTouched(formGroup: FormGroup): void {
    Object.values(formGroup.controls).forEach((control) => {
      control.markAsTouched();

      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  resetForm(): void {
    if (this.isEditMode && this.vehicleId) {
      this.loadVehicle(this.vehicleId);
    } else {
      this.vehicleForm.reset(this.createForm().value);
    }
  }
}
