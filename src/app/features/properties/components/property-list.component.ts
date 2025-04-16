import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { PropertyService } from '../services/property.service';
import { Property, PropertyType, LocationType } from '../../../core/models/property.model';
import { RentalItemStatus } from '../../../core/models/rental-item.model';

@Component({
  selector: 'app-property-list',
  standalone: true,
  imports: [CommonModule, RouterModule, ReactiveFormsModule, DatePipe],
  templateUrl: './property-list.component.html',
  styleUrl: './property-list.component.scss'
})
export class PropertyListComponent implements OnInit {
  properties: Property[] = [];
  filteredProperties: Property[] = [];
  loading = true;
  filterForm: FormGroup;
  propertyTypes = Object.values(PropertyType);
  locationTypes = Object.values(LocationType);
  propertyStatuses = Object.values(RentalItemStatus);

  constructor(
    private propertyService: PropertyService,
    private formBuilder: FormBuilder
  ) {
    this.filterForm = this.formBuilder.group({
      searchTerm: [''],
      propertyType: [''],
      locationType: [''],
      status: [''],
      minBedrooms: [''],
      maxPrice: ['']
    });
  }

  ngOnInit(): void {
    this.loadProperties();

    // Apply filters when form values change
    this.filterForm.valueChanges.subscribe(() => {
      this.applyFilters();
    });
  }

  loadProperties(): void {
    this.loading = true;
    this.propertyService.getProperties().subscribe({
      next: (data) => {
        this.properties = data;
        this.filteredProperties = data;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading properties', error);
        this.loading = false;
      }
    });
  }

  applyFilters(): void {
    const filters = this.filterForm.value;

    this.filteredProperties = this.properties.filter(property => {
      // Search term filter
      if (filters.searchTerm) {
        const searchTerm = filters.searchTerm.toLowerCase();
        const matchesSearch =
          property.name.toLowerCase().includes(searchTerm) ||
          property.description.toLowerCase().includes(searchTerm) ||
          property.location.toLowerCase().includes(searchTerm);

        if (!matchesSearch) return false;
      }

      // Property type filter
      if (filters.propertyType && property.propertyType !== filters.propertyType) {
        return false;
      }

      // Location type filter
      if (filters.locationType && property.locationType !== filters.locationType) {
        return false;
      }

      // Status filter
      if (filters.status && property.status !== filters.status) {
        return false;
      }

      // Min bedrooms filter
      if (filters.minBedrooms && property.numberOfBedrooms < parseInt(filters.minBedrooms)) {
        return false;
      }

      // Max price filter
      if (filters.maxPrice && property.baseRate > parseFloat(filters.maxPrice)) {
        return false;
      }

      return true;
    });
  }

  resetFilters(): void {
    this.filterForm.reset();
    this.filteredProperties = this.properties;
  }
}
