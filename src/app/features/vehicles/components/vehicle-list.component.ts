import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { VehicleService } from '../services/vehicle.service';
import {
  Vehicle,
  VehicleType,
  TransmissionType,
  FuelType,
  DrivetrainType,
} from '../../../core/models/vehicle.model';
import { RentalItemStatus } from '../../../core/models/rental-item.model';
import { SearchBarComponent } from '../../../shared/components/search-bar/search-bar.component';
import { ReplacePipe } from '../../../shared/pipes/replace.pipe';

@Component({
  selector: 'app-vehicle-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ReactiveFormsModule,
    DatePipe,
    SearchBarComponent,
    ReplacePipe,
  ],
  templateUrl: './vehicle-list.component.html',
  styleUrl: './vehicle-list.component.scss',
})
export class VehicleListComponent implements OnInit {
  vehicles: Vehicle[] = [];
  filteredVehicles: Vehicle[] = [];
  loading = true;
  filterForm: FormGroup;

  // Enum values for filters
  vehicleTypes = Object.values(VehicleType);
  transmissionTypes = Object.values(TransmissionType);
  fuelTypes = Object.values(FuelType);
  drivetrainTypes = Object.values(DrivetrainType);
  vehicleStatuses = Object.values(RentalItemStatus);

  // Pagination
  currentPage = 1;
  itemsPerPage = 12;

  Math = Math;

  constructor(
    private vehicleService: VehicleService,
    private formBuilder: FormBuilder
  ) {
    this.filterForm = this.createFilterForm();
  }

  ngOnInit(): void {
    this.loadVehicles();

    // Apply filters when form values change
    this.filterForm.valueChanges.subscribe(() => {
      this.applyFilters();
    });
  }

  createFilterForm(): FormGroup {
    return this.formBuilder.group({
      searchTerm: [''],
      vehicleType: [''],
      transmissionType: [''],
      fuelType: [''],
      status: [''],
      minYear: [''],
      maxPrice: [''],
    });
  }

  loadVehicles(): void {
    this.loading = true;
    this.vehicleService.getVehicles().subscribe({
      next: (data) => {
        this.vehicles = data;
        this.filteredVehicles = data;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading vehicles', error);
        this.loading = false;
      },
    });
  }

  applyFilters(): void {
    const filters = this.filterForm.value;

    this.filteredVehicles = this.vehicles.filter((vehicle) => {
      // Search term filter
      if (filters.searchTerm) {
        const searchTerm = filters.searchTerm.toLowerCase();
        const matchesSearch =
          vehicle.name.toLowerCase().includes(searchTerm) ||
          vehicle.description.toLowerCase().includes(searchTerm) ||
          vehicle.make.toLowerCase().includes(searchTerm) ||
          vehicle.model.toLowerCase().includes(searchTerm);

        if (!matchesSearch) return false;
      }

      // Vehicle type filter
      if (filters.vehicleType && vehicle.vehicleType !== filters.vehicleType) {
        return false;
      }

      // Transmission type filter
      if (
        filters.transmissionType &&
        vehicle.transmissionType !== filters.transmissionType
      ) {
        return false;
      }

      // Fuel type filter
      if (filters.fuelType && vehicle.fuelType !== filters.fuelType) {
        return false;
      }

      // Status filter
      if (filters.status && vehicle.status !== filters.status) {
        return false;
      }

      // Min year filter
      if (filters.minYear && vehicle.year < parseInt(filters.minYear)) {
        return false;
      }

      // Max price filter
      if (filters.maxPrice && vehicle.baseRate > parseFloat(filters.maxPrice)) {
        return false;
      }

      return true;
    });

    // Reset to first page when applying filters
    this.currentPage = 1;
  }

  resetFilters(): void {
    this.filterForm.reset();
    this.filteredVehicles = this.vehicles;
  }

  get paginatedVehicles(): Vehicle[] {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    return this.filteredVehicles.slice(
      startIndex,
      startIndex + this.itemsPerPage
    );
  }

  get totalPages(): number {
    return Math.ceil(this.filteredVehicles.length / this.itemsPerPage);
  }

  changePage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }
}
