import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { PropertyService } from '../services/property.service';
import { Property, PropertyType, LocationType, CreatePropertyRequest } from '../../../core/models/property.model';
import { RentalItemStatus } from '../../../core/models/rental-item.model';

@Component({
  selector: 'app-property-form',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule],
  templateUrl: './property-form.component.html',
  styleUrl: './property-form.component.scss'
})
export class PropertyFormComponent implements OnInit {
  propertyForm: FormGroup;
  isEditMode = false;
  propertyId: number | null = null;
  loading = false;
  submitting = false;
  error = '';

  propertyTypes = Object.values(PropertyType);
  locationTypes = Object.values(LocationType);
  statuses = Object.values(RentalItemStatus);

  constructor(
    private formBuilder: FormBuilder,
    private propertyService: PropertyService,
    private route: ActivatedRoute,
    private router: Router
  ) {
    this.propertyForm = this.createForm();
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.propertyId = +id;
      this.loadProperty(this.propertyId);
    }
  }

  createForm(): FormGroup {
    return this.formBuilder.group({
      name: ['', [Validators.required, Validators.maxLength(100)]],
      description: ['', [Validators.required]],
      propertyType: [PropertyType.VILLA, [Validators.required]],
      locationType: [LocationType.CITY_CENTER, [Validators.required]],
      status: [RentalItemStatus.AVAILABLE, [Validators.required]],
      baseRate: [0, [Validators.required, Validators.min(0)]],
      securityDeposit: [0, [Validators.min(0)]],
      location: ['', [Validators.required]],
      addressLine1: [''],
      addressLine2: [''],
      city: [''],
      state: [''],
      country: [''],
      postalCode: [''],
      latitude: [null, [Validators.min(-90), Validators.max(90)]],
      longitude: [null, [Validators.min(-180), Validators.max(180)]],
      mainImageUrl: [''],
      imageUrls: [[]],
      maximumCapacity: [1, [Validators.required, Validators.min(1)]],
      totalArea: [0, [Validators.required, Validators.min(0)]],
      numberOfBedrooms: [1, [Validators.required, Validators.min(0)]],
      numberOfBathrooms: [1, [Validators.required, Validators.min(0)]],
      numberOfFloors: [1, [Validators.min(1)]],
      constructionYear: [null, [Validators.min(1800), Validators.max(new Date().getFullYear())]],
      hasPool: [false],
      hasGarden: [false],
      hasSpa: [false],
      hasGym: [false],
      parkingCapacity: [0, [Validators.min(0)]],
      kitchenSpecifications: [''],
      viewType: [''],
      notes: ['']
    });
  }

  loadProperty(id: number): void {
    this.loading = true;
    this.propertyService.getProperty(id).subscribe({
      next: (property) => {
        this.updateForm(property);
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading property', err);
        this.error = 'Failed to load property details. Please try again.';
        this.loading = false;
      }
    });
  }

  updateForm(property: Property): void {
    this.propertyForm.patchValue({
      name: property.name,
      description: property.description,
      propertyType: property.propertyType,
      locationType: property.locationType,
      status: property.status,
      baseRate: property.baseRate,
      securityDeposit: property.securityDeposit,
      location: property.location,
      addressLine1: property.addressLine1,
      addressLine2: property.addressLine2,
      city: property.city,
      state: property.state,
      country: property.country,
      postalCode: property.postalCode,
      latitude: property.latitude,
      longitude: property.longitude,
      mainImageUrl: property.mainImageUrl,
      imageUrls: property.imageUrls,
      maximumCapacity: property.maximumCapacity,
      totalArea: property.totalArea,
      numberOfBedrooms: property.numberOfBedrooms,
      numberOfBathrooms: property.numberOfBathrooms,
      numberOfFloors: property.numberOfFloors,
      constructionYear: property.constructionYear,
      hasPool: property.hasPool,
      hasGarden: property.hasGarden,
      hasSpa: property.hasSpa,
      hasGym: property.hasGym,
      parkingCapacity: property.parkingCapacity,
      kitchenSpecifications: property.kitchenSpecifications,
      viewType: property.viewType,
      notes: property.notes
    });
  }

  onSubmit(): void {
    if (this.propertyForm.invalid) {
      this.markFormGroupTouched(this.propertyForm);
      return;
    }

    this.submitting = true;
    const formData = this.propertyForm.value;

    // Convert imageUrls from string to array if needed
    if (typeof formData.imageUrls === 'string') {
      formData.imageUrls = formData.imageUrls
        .split(',')
        .map((url: string) => url.trim())
        .filter((url: string) => url);
    }

    if (this.isEditMode && this.propertyId) {
      this.propertyService.updateProperty(this.propertyId, formData).subscribe({
        next: (property) => {
          this.router.navigate(['/properties', property.id]);
        },
        error: (err) => {
          console.error('Error updating property', err);
          this.error = 'Failed to update property. Please check the form and try again.';
          this.submitting = false;
        }
      });
    } else {
      this.propertyService.createProperty(formData as CreatePropertyRequest).subscribe({
        next: (property) => {
          this.router.navigate(['/properties', property.id]);
        },
        error: (err) => {
          console.error('Error creating property', err);
          this.error = 'Failed to create property. Please check the form and try again.';
          this.submitting = false;
        }
      });
    }
  }

  markFormGroupTouched(formGroup: FormGroup): void {
    Object.values(formGroup.controls).forEach(control => {
      control.markAsTouched();
      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }

  resetForm(): void {
    if (this.isEditMode && this.propertyId) {
      this.loadProperty(this.propertyId);
    } else {
      this.propertyForm.reset({
        propertyType: PropertyType.VILLA,
        locationType: LocationType.CITY_CENTER,
        status: RentalItemStatus.AVAILABLE,
        baseRate: 0,
        securityDeposit: 0,
        maximumCapacity: 1,
        totalArea: 0,
        numberOfBedrooms: 1,
        numberOfBathrooms: 1,
        numberOfFloors: 1,
        parkingCapacity: 0,
        hasPool: false,
        hasGarden: false,
        hasSpa: false,
        hasGym: false
      });
    }
  }
}
