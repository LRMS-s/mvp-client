#!/bin/bash

# Script to generate feature module content for LRMS Angular application
# This will create basic implementations for dashboard, properties, vehicles,
# reservations, clients, and staff features

# Set text colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Generating content for LRMS feature modules...${NC}"

# --- DASHBOARD FEATURE ---
echo -e "${BLUE}Creating dashboard feature...${NC}"

# Dashboard component
mkdir -p src/app/features/dashboard/services

cat > src/app/features/dashboard/dashboard.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { DashboardService } from './services/dashboard.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit {
  stats: any = {};
  loading = true;
  error = false;

  constructor(private dashboardService: DashboardService) {}

  ngOnInit(): void {
    this.loadDashboardData();
  }

  loadDashboardData(): void {
    this.loading = true;
    this.dashboardService.getDashboardStats().subscribe({
      next: (data) => {
        this.stats = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading dashboard data', err);
        this.error = true;
        this.loading = false;
      }
    });
  }
}
EOF

cat > src/app/features/dashboard/dashboard.component.html << 'EOF'
<div class="dashboard-container">
  <h1 class="dashboard-title">Dashboard</h1>

  <div *ngIf="loading" class="loading-state">
    <p>Loading dashboard data...</p>
  </div>

  <div *ngIf="error" class="error-state">
    <p>Error loading dashboard data. Please try again later.</p>
    <button (click)="loadDashboardData()">Retry</button>
  </div>

  <div *ngIf="!loading && !error" class="dashboard-content">
    <!-- Overview Cards -->
    <div class="stats-cards">
      <div class="card">
        <h3>Properties</h3>
        <div class="card-value">{{ stats.propertyStats?.totalProperties || 0 }}</div>
        <div class="card-detail">
          Available: {{ stats.propertyStats?.availableProperties || 0 }}
        </div>
      </div>

      <div class="card">
        <h3>Vehicles</h3>
        <div class="card-value">{{ stats.vehicleStats?.totalVehicles || 0 }}</div>
        <div class="card-detail">
          Available: {{ stats.vehicleStats?.availableVehicles || 0 }}
        </div>
      </div>

      <div class="card">
        <h3>Reservations</h3>
        <div class="card-value">{{ stats.reservationStats?.totalReservations || 0 }}</div>
        <div class="card-detail">
          Active: {{ stats.reservationStats?.activeReservations || 0 }}
        </div>
      </div>

      <div class="card">
        <h3>Clients</h3>
        <div class="card-value">{{ stats.clientStats?.totalClients || 0 }}</div>
        <div class="card-detail">
          New This Month: {{ stats.clientStats?.newClientsThisMonth || 0 }}
        </div>
      </div>
    </div>

    <!-- Recent Reservations Section -->
    <div class="section">
      <h2>Recent Reservations</h2>
      <div class="table-container">
        <table *ngIf="stats.recentReservations?.length; else noReservations">
          <thead>
            <tr>
              <th>Reservation #</th>
              <th>Client</th>
              <th>Item</th>
              <th>Dates</th>
              <th>Status</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let reservation of stats.recentReservations">
              <td>{{ reservation.reservationNumber }}</td>
              <td>{{ reservation.client.user.firstName }} {{ reservation.client.user.lastName }}</td>
              <td>
                {{ reservation.itemType === 'property' ? reservation.property?.name : reservation.vehicle?.name }}
              </td>
              <td>{{ reservation.startDate | date:'MMM d' }} - {{ reservation.endDate | date:'MMM d, y' }}</td>
              <td>
                <span class="status-badge status-{{ reservation.status }}">
                  {{ reservation.status }}
                </span>
              </td>
              <td>{{ reservation.totalAmount | currency }}</td>
            </tr>
          </tbody>
        </table>
        <ng-template #noReservations>
          <p class="no-data">No recent reservations found.</p>
        </ng-template>
      </div>
      <div class="view-all">
        <a routerLink="/reservations">View All Reservations</a>
      </div>
    </div>

    <!-- Upcoming Maintenance Section -->
    <div class="section">
      <h2>Upcoming Maintenance</h2>
      <div class="table-container">
        <table *ngIf="stats.upcomingMaintenance?.length; else noMaintenance">
          <thead>
            <tr>
              <th>Item</th>
              <th>Type</th>
              <th>Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let maintenance of stats.upcomingMaintenance">
              <td>{{ maintenance.itemName }}</td>
              <td>{{ maintenance.itemType }}</td>
              <td>{{ maintenance.scheduledDate | date:'MMM d, y' }}</td>
              <td>
                <span class="status-badge status-{{ maintenance.status }}">
                  {{ maintenance.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
        <ng-template #noMaintenance>
          <p class="no-data">No upcoming maintenance scheduled.</p>
        </ng-template>
      </div>
    </div>

    <!-- Quick Links -->
    <div class="quick-links">
      <h2>Quick Actions</h2>
      <div class="links-container">
        <a routerLink="/reservations/new" class="quick-link">New Reservation</a>
        <a routerLink="/clients/new" class="quick-link">New Client</a>
        <a routerLink="/properties/new" class="quick-link">Add Property</a>
        <a routerLink="/vehicles/new" class="quick-link">Add Vehicle</a>
      </div>
    </div>
  </div>
</div>
EOF

cat > src/app/features/dashboard/dashboard.component.scss << 'EOF'
.dashboard-container {
  padding: 1rem;
}

.dashboard-title {
  margin-bottom: 1.5rem;
  font-size: 1.75rem;
  font-weight: 600;
}

.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.error-state button {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.card {
  background-color: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.card h3 {
  margin-top: 0;
  margin-bottom: 0.5rem;
  font-size: 1rem;
  color: #666;
}

.card-value {
  font-size: 2rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.card-detail {
  font-size: 0.875rem;
  color: #666;
}

.section {
  background-color: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.section h2 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.table-container {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #eee;
}

th {
  font-weight: 600;
  color: #555;
}

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: capitalize;
}

.status-pending {
  background-color: #FFF8E1;
  color: #FF8F00;
}

.status-confirmed {
  background-color: #E3F2FD;
  color: #1976D2;
}

.status-checked_in {
  background-color: #E8F5E9;
  color: #388E3C;
}

.status-cancelled {
  background-color: #FFEBEE;
  color: #D32F2F;
}

.status-completed {
  background-color: #E0F2F1;
  color: #00796B;
}

.no-data {
  padding: 1rem;
  text-align: center;
  color: #666;
  font-style: italic;
}

.view-all {
  margin-top: 1rem;
  text-align: right;
}

.view-all a {
  color: #007bff;
  text-decoration: none;
  font-weight: 500;
}

.view-all a:hover {
  text-decoration: underline;
}

.quick-links {
  background-color: white;
  border-radius: 8px;
  padding: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.links-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}

.quick-link {
  display: block;
  text-align: center;
  padding: 1rem;
  background-color: #f0f7ff;
  color: #007bff;
  border-radius: 6px;
  text-decoration: none;
  font-weight: 500;
  transition: background-color 0.2s;
}

.quick-link:hover {
  background-color: #e0f0ff;
}
EOF

cat > src/app/features/dashboard/services/dashboard.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { forkJoin, Observable, of } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiService } from '../../../core/services/api.service';

@Injectable({
  providedIn: 'root'
})
export class DashboardService {
  constructor(private apiService: ApiService) { }

  getDashboardStats(): Observable<any> {
    // Create a combined request for all dashboard data
    return forkJoin({
      propertyStats: this.getPropertyStats(),
      vehicleStats: this.getVehicleStats(),
      reservationStats: this.getReservationStats(),
      clientStats: this.getClientStats(),
      recentReservations: this.getRecentReservations(),
      upcomingMaintenance: this.getUpcomingMaintenance()
    });
  }

  private getPropertyStats(): Observable<any> {
    return this.apiService.get('properties/statistics');
  }

  private getVehicleStats(): Observable<any> {
    return this.apiService.get('vehicles/statistics');
  }

  private getReservationStats(): Observable<any> {
    return this.apiService.get('reservations/statistics');
  }

  private getClientStats(): Observable<any> {
    return this.apiService.get('clients/statistics');
  }

  private getRecentReservations(): Observable<any> {
    return this.apiService.get('reservations', { limit: 5, sort: 'createdAt,desc' });
  }

  private getUpcomingMaintenance(): Observable<any> {
    // This might need to be adjusted based on your API
    return this.apiService.get('maintenance/upcoming');
  }
}
EOF

# --- PROPERTIES FEATURE ---
echo -e "${BLUE}Creating properties feature...${NC}"

mkdir -p src/app/features/properties/{components,services,models}

# Property routes
cat > src/app/features/properties/properties.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const PROPERTIES_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/property-list.component')
      .then(c => c.PropertyListComponent)
  },
  {
    path: 'new',
    loadComponent: () => import('./components/property-form.component')
      .then(c => c.PropertyFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id',
    loadComponent: () => import('./components/property-detail.component')
      .then(c => c.PropertyDetailComponent)
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/property-form.component')
      .then(c => c.PropertyFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  }
];
EOF

# Property service
cat > src/app/features/properties/services/property.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Property, CreatePropertyRequest } from '../../../core/models/property.model';

@Injectable({
  providedIn: 'root'
})
export class PropertyService {
  private readonly endpoint = 'properties';

  constructor(private apiService: ApiService) { }

  getProperties(params: any = {}): Observable<Property[]> {
    return this.apiService.get<Property[]>(this.endpoint, params);
  }

  getProperty(id: number): Observable<Property> {
    return this.apiService.get<Property>(`${this.endpoint}/${id}`);
  }

  createProperty(property: CreatePropertyRequest): Observable<Property> {
    return this.apiService.post<Property>(this.endpoint, property);
  }

  updateProperty(id: number, property: Partial<CreatePropertyRequest>): Observable<Property> {
    return this.apiService.patch<Property>(`${this.endpoint}/${id}`, property);
  }

  deleteProperty(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getPropertyTypes(): Observable<string[]> {
    return this.apiService.get<string[]>(`${this.endpoint}/types`);
  }

  getLocationTypes(): Observable<string[]> {
    return this.apiService.get<string[]>(`${this.endpoint}/location-types`);
  }

  searchProperties(query: string): Observable<Property[]> {
    return this.apiService.get<Property[]>(`${this.endpoint}/search`, { q: query });
  }

  getPropertiesByType(type: string): Observable<Property[]> {
    return this.apiService.get<Property[]>(`${this.endpoint}/type/${type}`);
  }

  getPropertiesByLocation(location: string): Observable<Property[]> {
    return this.apiService.get<Property[]>(`${this.endpoint}/location/${location}`);
  }

  getAvailableProperties(startDate: string, endDate: string, params: any = {}): Observable<Property[]> {
    return this.apiService.get<Property[]>(`rental-items/available`, {
      itemType: 'property',
      startDate,
      endDate,
      ...params
    });
  }
}
EOF

# Property List Component
cat > src/app/features/properties/components/property-list.component.ts << 'EOF'
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
EOF

cat > src/app/features/properties/components/property-list.component.html << 'EOF'
<div class="properties-container">
  <header class="page-header">
    <h1>Properties</h1>
    <a routerLink="/properties/new" class="btn-primary">Add New Property</a>
  </header>

  <div class="filters-section">
    <form [formGroup]="filterForm" class="filter-form">
      <div class="search-field">
        <input
          type="text"
          formControlName="searchTerm"
          placeholder="Search properties..."
          class="form-control"
        >
      </div>

      <div class="filter-fields">
        <div class="filter-field">
          <label for="propertyType">Type</label>
          <select id="propertyType" formControlName="propertyType" class="form-control">
            <option value="">All Types</option>
            <option *ngFor="let type of propertyTypes" [value]="type">
              {{ type | titlecase }}
            </option>
          </select>
        </div>

        <div class="filter-field">
          <label for="locationType">Location</label>
          <select id="locationType" formControlName="locationType" class="form-control">
            <option value="">All Locations</option>
            <option *ngFor="let type of locationTypes" [value]="type">
              {{ type.replace('_', ' ') | titlecase }}
            </option>
          </select>
        </div>

        <div class="filter-field">
          <label for="status">Status</label>
          <select id="status" formControlName="status" class="form-control">
            <option value="">All Statuses</option>
            <option *ngFor="let status of propertyStatuses" [value]="status">
              {{ status | titlecase }}
            </option>
          </select>
        </div>

        <div class="filter-field">
          <label for="minBedrooms">Min Bedrooms</label>
          <input
            type="number"
            id="minBedrooms"
            formControlName="minBedrooms"
            min="0"
            class="form-control"
          >
        </div>

        <div class="filter-field">
          <label for="maxPrice">Max Price</label>
          <input
            type="number"
            id="maxPrice"
            formControlName="maxPrice"
            min="0"
            class="form-control"
          >
        </div>

        <button type="button" class="btn-secondary" (click)="resetFilters()">Reset</button>
      </div>
    </form>
  </div>

  <div *ngIf="loading" class="loading-state">
    <p>Loading properties...</p>
  </div>

  <div *ngIf="!loading && filteredProperties.length === 0" class="empty-state">
    <p>No properties found matching your criteria.</p>
  </div>

  <div *ngIf="!loading && filteredProperties.length > 0" class="property-grid">
    <div *ngFor="let property of filteredProperties" class="property-card">
      <div class="property-img">
        <img [src]="property.mainImageUrl || '/assets/images/property-placeholder.jpg'" [alt]="property.name">
        <div class="property-badge" [ngClass]="'status-' + property.status">
          {{ property.status }}
        </div>
      </div>

      <div class="property-content">
        <h2 class="property-title">{{ property.name }}</h2>
        <p class="property-location">{{ property.location }}</p>

        <div class="property-features">
          <span class="feature">
            <i class="feature-icon beds-icon"></i>
            {{ property.numberOfBedrooms }} Bedrooms
          </span>
          <span class="feature">
            <i class="feature-icon baths-icon"></i>
            {{ property.numberOfBathrooms }} Bathrooms
          </span>
          <span class="feature">
            <i class="feature-icon area-icon"></i>
            {{ property.totalArea }} m²
          </span>
        </div>

        <div class="property-footer">
          <div class="property-price">
            {{ property.baseRate | currency }} / night
          </div>
          <a [routerLink]="['/properties', property.id]" class="btn-view">View Details</a>
        </div>
      </div>
    </div>
  </div>
</div>
EOF

cat > src/app/features/properties/components/property-list.component.scss << 'EOF'
.properties-container {
  padding: 1rem;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

h1 {
  margin: 0;
  font-size: 1.75rem;
}

.btn-primary {
  padding: 0.5rem 1rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  text-decoration: none;
  font-weight: 500;
}

.btn-primary:hover {
  background-color: #0069d9;
}

.filters-section {
  background-color: white;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.filter-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.search-field {
  width: 100%;
}

.filter-fields {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
}

.filter-field {
  flex: 1;
  min-width: 150px;
}

.form-control {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.875rem;
}

label {
  display: block;
  margin-bottom: 0.25rem;
  font-size: 0.75rem;
  color: #666;
}

.btn-secondary {
  padding: 0.5rem 1rem;
  background-color: #6c757d;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.875rem;
  height: 36px;
}

.btn-secondary:hover {
  background-color: #5a6268;
}

.loading-state, .empty-state {
  padding: 2rem;
  text-align: center;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.property-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.property-card {
  background-color: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s, box-shadow 0.2s;
}

.property-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.property-img {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.property-img img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.property-badge {
  position: absolute;
  top: 10px;
  right: 10px;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
  text-transform: capitalize;
}

.status-available {
  background-color: #E8F5E9;
  color: #388E3C;
}

.status-reserved {
  background-color: #FFF8E1;
  color: #FF8F00;
}

.status-occupied {
  background-color: #E3F2FD;
  color: #1976D2;
}

.status-maintenance {
  background-color: #FBE9E7;
  color: #D84315;
}

.status-inactive {
  background-color: #EEEEEE;
  color: #757575;
}

.property-content {
  padding: 1rem;
}

.property-title {
  margin-top: 0;
  margin-bottom: 0.25rem;
  font-size: 1.25rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.property-location {
  margin-top: 0;
  margin-bottom: 1rem;
  color: #666;
  font-size: 0.875rem;
}

.property-features {
  display: flex;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.feature {
  display: flex;
  align-items: center;
  font-size: 0.875rem;
  color: #666;
}

.feature-icon {
  margin-right: 0.5rem;
  font-size: 1rem;
  color: #9E9E9E;

}
