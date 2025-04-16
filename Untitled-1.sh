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
#!/bin/bash

# --- CONTINUING THE PROPERTIES FEATURE ---
# Continuing the property-list.component.scss file

cat >> src/app/features/properties/components/property-list.component.scss << 'EOF'
.feature {
  display: flex;
  align-items: center;
  font-size: 0.875rem;
  color: #555;
}

.feature-icon {
  display: inline-block;
  width: 16px;
  height: 16px;
  margin-right: 0.25rem;
  background-size: contain;
  background-repeat: no-repeat;
}

.beds-icon {
  background-image: url('/assets/icons/bed.svg');
}

.baths-icon {
  background-image: url('/assets/icons/bath.svg');
}

.area-icon {
  background-image: url('/assets/icons/area.svg');
}

.property-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid #eee;
  padding-top: 0.75rem;
  margin-top: 0.5rem;
}

.property-price {
  font-weight: 600;
  color: #007bff;
}

.btn-view {
  padding: 0.375rem 0.75rem;
  background-color: #f0f7ff;
  color: #007bff;
  border: 1px solid #007bff;
  border-radius: 4px;
  text-decoration: none;
  font-size: 0.875rem;
  transition: background-color 0.2s;
}

.btn-view:hover {
  background-color: #e0f0ff;
}

@media (max-width: 768px) {
  .filter-fields {
    flex-direction: column;
  }

  .filter-field {
    width: 100%;
  }

  .property-grid {
    grid-template-columns: 1fr;
  }
}
EOF

# Property Detail Component
cat > src/app/features/properties/components/property-detail.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { PropertyService } from '../services/property.service';
import { Property } from '../../../core/models/property.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';

@Component({
  selector: 'app-property-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe],
  templateUrl: './property-detail.component.html',
  styleUrl: './property-detail.component.scss'
})
export class PropertyDetailComponent implements OnInit {
  property: Property | null = null;
  loading = true;
  error = false;
  activeImageUrl: string | null = null;
  isAdmin = false;
  isStaff = false;

  constructor(
    private propertyService: PropertyService,
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadProperty(+id);
    } else {
      this.error = true;
      this.loading = false;
    }

    // Check user permissions
    const currentUser = this.authService.getCurrentUser();
    if (currentUser) {
      this.isAdmin = currentUser.userType === UserType.ADMIN;
      this.isStaff = currentUser.userType === UserType.STAFF;
    }
  }

  loadProperty(id: number): void {
    this.loading = true;
    this.propertyService.getProperty(id).subscribe({
      next: (data) => {
        this.property = data;
        this.activeImageUrl = data.mainImageUrl || null;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading property', err);
        this.error = true;
        this.loading = false;
      }
    });
  }

  setActiveImage(url: string): void {
    this.activeImageUrl = url;
  }

  deleteProperty(): void {
    if (!this.property || !confirm('Are you sure you want to delete this property?')) {
      return;
    }

    this.propertyService.deleteProperty(this.property.id).subscribe({
      next: () => {
        this.router.navigate(['/properties']);
      },
      error: (err) => {
        console.error('Error deleting property', err);
        alert('Failed to delete property. Please try again.');
      }
    });
  }
}
EOF

cat > src/app/features/properties/components/property-detail.component.html << 'EOF'
<div class="property-detail-container">
  <div *ngIf="loading" class="loading-state">
    <p>Loading property details...</p>
  </div>

  <div *ngIf="error" class="error-state">
    <p>Error loading property details. The property might not exist or has been removed.</p>
    <button routerLink="/properties" class="btn-primary">Back to Properties</button>
  </div>

  <div *ngIf="!loading && !error && property" class="property-detail">
    <div class="property-header">
      <div class="header-content">
        <h1>{{ property.name }}</h1>
        <p class="property-location">{{ property.location }}</p>
        <div class="property-badge" [ngClass]="'status-' + property.status">
          {{ property.status }}
        </div>
      </div>
      <div class="header-actions" *ngIf="isAdmin || isStaff">
        <a [routerLink]="['/properties', property.id, 'edit']" class="btn-edit">Edit</a>
        <button class="btn-delete" *ngIf="isAdmin" (click)="deleteProperty()">Delete</button>
      </div>
    </div>

    <div class="property-gallery">
      <div class="main-image">
        <img [src]="activeImageUrl || property.mainImageUrl || '/assets/images/property-placeholder.jpg'" [alt]="property.name">
      </div>
      <div class="thumbnail-container" *ngIf="property.imageUrls && property.imageUrls.length > 0">
        <div
          *ngFor="let imageUrl of property.imageUrls"
          class="thumbnail"
          [class.active]="activeImageUrl === imageUrl"
          (click)="setActiveImage(imageUrl)"
        >
          <img [src]="imageUrl" alt="Property thumbnail">
        </div>
      </div>
    </div>

    <div class="property-body">
      <div class="property-main">
        <div class="property-section">
          <h2>Description</h2>
          <p>{{ property.description }}</p>
        </div>

        <div class="property-section">
          <h2>Property Details</h2>
          <div class="property-features-grid">
            <div class="feature-item">
              <span class="feature-label">Type</span>
              <span class="feature-value">{{ property.propertyType | titlecase }}</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Location</span>
              <span class="feature-value">{{ property.locationType.replace('_', ' ') | titlecase }}</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Total Area</span>
              <span class="feature-value">{{ property.totalArea }} m²</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Bedrooms</span>
              <span class="feature-value">{{ property.numberOfBedrooms }}</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Bathrooms</span>
              <span class="feature-value">{{ property.numberOfBathrooms }}</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Floors</span>
              <span class="feature-value">{{ property.numberOfFloors || 'N/A' }}</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Construction Year</span>
              <span class="feature-value">{{ property.constructionYear || 'N/A' }}</span>
            </div>
            <div class="feature-item">
              <span class="feature-label">Parking</span>
              <span class="feature-value">{{ property.parkingCapacity || 'None' }}</span>
            </div>
          </div>
        </div>

        <div class="property-section">
          <h2>Amenities</h2>
          <div class="amenities-list" *ngIf="property.amenities">
            <div *ngFor="let item of property.amenities | keyvalue" class="amenity-item" [class.available]="item.value">
              <span class="amenity-icon" [class.checked]="item.value">✓</span>
              <span class="amenity-name">{{ item.key | titlecase }}</span>
            </div>
          </div>
          <div *ngIf="!property.amenities || objectKeys(property.amenities).length === 0" class="no-data">
            No amenities listed for this property.
          </div>
        </div>

        <div class="property-section" *ngIf="property.hasPool || property.hasGarden || property.hasSpa || property.hasGym">
          <h2>Special Features</h2>
          <div class="special-features">
            <div class="feature-badge" *ngIf="property.hasPool">Swimming Pool</div>
            <div class="feature-badge" *ngIf="property.hasGarden">Garden</div>
            <div class="feature-badge" *ngIf="property.hasSpa">Spa</div>
            <div class="feature-badge" *ngIf="property.hasGym">Gym</div>
          </div>
        </div>

        <div class="property-section" *ngIf="property.notes">
          <h2>Additional Notes</h2>
          <p>{{ property.notes }}</p>
        </div>
      </div>

      <div class="property-sidebar">
        <div class="price-card">
          <h3>Pricing</h3>
          <div class="price-value">{{ property.baseRate | currency }} <span class="price-period">per night</span></div>
          <div class="price-detail" *ngIf="property.securityDeposit">
            Security Deposit: {{ property.securityDeposit | currency }}
          </div>
          <a routerLink="/reservations/new" [queryParams]="{propertyId: property.id}" class="btn-reserve">Make Reservation</a>
        </div>

        <div class="location-card">
          <h3>Location</h3>
          <p class="address">
            {{ property.addressLine1 }}<br *ngIf="property.addressLine1">
            {{ property.addressLine2 }}<br *ngIf="property.addressLine2">
            {{ property.city }}{{ property.city && property.state ? ', ' : '' }}{{ property.state }}<br *ngIf="property.city || property.state">
            {{ property.postalCode }} {{ property.country }}
          </p>
          <div class="map-container" *ngIf="property.latitude && property.longitude">
            <!-- Placeholder for map - in a real application, you would integrate with a mapping API -->
            <div class="map-placeholder">
              Map would be displayed here
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
EOF

cat > src/app/features/properties/components/property-detail.component.scss << 'EOF'
.property-detail-container {
  padding: 1rem;
}

.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background-color: #f9f9f9;
  border-radius: 8px;
  text-align: center;
}

.btn-primary {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.property-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1.5rem;
}

.header-content h1 {
  margin-top: 0;
  margin-bottom: 0.5rem;
  font-size: 1.75rem;
}

.property-location {
  margin-top: 0;
  margin-bottom: 0.5rem;
  color: #666;
}

.property-badge {
  display: inline-block;
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

.header-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-edit, .btn-delete {
  padding: 0.375rem 0.75rem;
  border-radius: 4px;
  font-size: 0.875rem;
  cursor: pointer;
  text-decoration: none;
}

.btn-edit {
  background-color: #f0f7ff;
  color: #007bff;
  border: 1px solid #007bff;
}

.btn-edit:hover {
  background-color: #e0f0ff;
}

.btn-delete {
  background-color: #fff5f5;
  color: #dc3545;
  border: 1px solid #dc3545;
}

.btn-delete:hover {
  background-color: #ffe0e0;
}

.property-gallery {
  margin-bottom: 1.5rem;
}

.main-image {
  width: 100%;
  height: 400px;
  border-radius: 8px;
  overflow: hidden;
  margin-bottom: 0.5rem;
}

.main-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.thumbnail-container {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.5rem;
}

.thumbnail {
  width: 80px;
  height: 60px;
  border-radius: 4px;
  overflow: hidden;
  cursor: pointer;
  opacity: 0.7;
  transition: opacity 0.2s;
}

.thumbnail:hover, .thumbnail.active {
  opacity: 1;
}

.thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.property-body {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 1.5rem;
}

.property-section {
  background-color: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.property-section h2 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.25rem;
  color: #333;
}

.property-features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}

.feature-item {
  display: flex;
  flex-direction: column;
}

.feature-label {
  font-size: 0.75rem;
  color: #666;
}

.feature-value {
  font-size: 1rem;
  font-weight: 500;
}

.amenities-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 0.5rem;
}

.amenity-item {
  display: flex;
  align-items: center;
  padding: 0.5rem;
  background-color: #f9f9f9;
  border-radius: 4px;
}

.amenity-item.available {
  background-color: #f0f7ff;
}

.amenity-icon {
  display: inline-flex;
  justify-content: center;
  align-items: center;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  margin-right: 0.5rem;
  background-color: #eee;
  color: transparent;
}

.amenity-icon.checked {
  background-color: #007bff;
  color: white;
}

.special-features {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.feature-badge {
  background-color: #f0f7ff;
  color: #007bff;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  font-size: 0.875rem;
}

.price-card, .location-card {
  background-color: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.price-card h3, .location-card h3 {
  margin-top: 0;
  margin-bottom: 1rem;
  font-size: 1.25rem;
  color: #333;
}

.price-value {
  font-size: 1.5rem;
  font-weight: 600;
  color: #007bff;
  margin-bottom: 0.5rem;
}

.price-period {
  font-size: 0.875rem;
  font-weight: normal;
  color: #666;
}

.price-detail {
  margin-bottom: 1rem;
  font-size: 0.875rem;
  color: #666;
}

.btn-reserve {
  display: block;
  width: 100%;
  padding: 0.75rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  text-align: center;
  text-decoration: none;
  font-weight: 500;
  cursor: pointer;
}

.btn-reserve:hover {
  background-color: #0069d9;
}

.address {
  margin-bottom: 1rem;
  line-height: 1.4;
}

.map-container {
  height: 200px;
  background-color: #f9f9f9;
  border-radius: 4px;
  overflow: hidden;
}

.map-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #666;
  font-style: italic;
}

.no-data {
  color: #666;
  font-style: italic;
}

@media (max-width: 768px) {
  .property-body {
    grid-template-columns: 1fr;
  }

  .main-image {
    height: 300px;
  }
}
EOF

# Property Form Component
cat > src/app/features/properties/components/property-form.component.ts << 'EOF'
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
EOF
#!/bin/bash

# --- CONTINUING THE PROPERTY FORM COMPONENT ---
# Continuing the property-form.component.html file

cat >> src/app/features/properties/components/property-form.component.html << 'EOF'
            [ngClass]="{'is-invalid': propertyForm.get('description')?.touched && propertyForm.get('description')?.invalid}"
          ></textarea>
          <div class="invalid-feedback" *ngIf="propertyForm.get('description')?.touched && propertyForm.get('description')?.errors">
            <span *ngIf="propertyForm.get('description')?.errors?.['required']">Description is required</span>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="propertyType">Property Type *</label>
            <select
              id="propertyType"
              formControlName="propertyType"
              class="form-control"
              [ngClass]="{'is-invalid': propertyForm.get('propertyType')?.touched && propertyForm.get('propertyType')?.invalid}"
            >
              <option *ngFor="let type of propertyTypes" [value]="type">
                {{ type | titlecase }}
              </option>
            </select>
            <div class="invalid-feedback" *ngIf="propertyForm.get('propertyType')?.touched && propertyForm.get('propertyType')?.errors">
              <span *ngIf="propertyForm.get('propertyType')?.errors?.['required']">Property type is required</span>
            </div>
          </div>

          <div class="form-group">
            <label for="locationType">Location Type *</label>
            <select
              id="locationType"
              formControlName="locationType"
              class="form-control"
              [ngClass]="{'is-invalid': propertyForm.get('locationType')?.touched && propertyForm.get('locationType')?.invalid}"
            >
              <option *ngFor="let type of locationTypes" [value]="type">
                {{ type.replace('_', ' ') | titlecase }}
              </option>
            </select>
            <div class="invalid-feedback" *ngIf="propertyForm.get('locationType')?.touched && propertyForm.get('locationType')?.errors">
              <span *ngIf="propertyForm.get('locationType')?.errors?.['required']">Location type is required</span>
            </div>
          </div>

          <div class="form-group">
            <label for="status">Status *</label>
            <select
              id="status"
              formControlName="status"
              class="form-control"
              [ngClass]="{'is-invalid': propertyForm.get('status')?.touched && propertyForm.get('status')?.invalid}"
            >
              <option *ngFor="let status of statuses" [value]="status">
                {{ status | titlecase }}
              </option>
            </select>
            <div class="invalid-feedback" *ngIf="propertyForm.get('status')?.touched && propertyForm.get('status')?.errors">
              <span *ngIf="propertyForm.get('status')?.errors?.['required']">Status is required</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Pricing Section -->
      <div class="form-section">
        <h2>Pricing</h2>

        <div class="form-row">
          <div class="form-group">
            <label for="baseRate">Base Rate (per night) *</label>
            <input
              type="number"
              id="baseRate"
              formControlName="baseRate"
              class="form-control"
              min="0"
              [ngClass]="{'is-invalid': propertyForm.get('baseRate')?.touched && propertyForm.get('baseRate')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('baseRate')?.touched && propertyForm.get('baseRate')?.errors">
              <span *ngIf="propertyForm.get('baseRate')?.errors?.['required']">Base rate is required</span>
              <span *ngIf="propertyForm.get('baseRate')?.errors?.['min']">Base rate must be a positive number</span>
            </div>
          </div>

          <div class="form-group">
            <label for="securityDeposit">Security Deposit</label>
            <input
              type="number"
              id="securityDeposit"
              formControlName="securityDeposit"
              class="form-control"
              min="0"
              [ngClass]="{'is-invalid': propertyForm.get('securityDeposit')?.touched && propertyForm.get('securityDeposit')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('securityDeposit')?.touched && propertyForm.get('securityDeposit')?.errors">
              <span *ngIf="propertyForm.get('securityDeposit')?.errors?.['min']">Security deposit must be a positive number</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Location Section -->
      <div class="form-section">
        <h2>Location & Address</h2>

        <div class="form-group">
          <label for="location">Location (Area/Region) *</label>
          <input
            type="text"
            id="location"
            formControlName="location"
            class="form-control"
            [ngClass]="{'is-invalid': propertyForm.get('location')?.touched && propertyForm.get('location')?.invalid}"
          >
          <div class="invalid-feedback" *ngIf="propertyForm.get('location')?.touched && propertyForm.get('location')?.errors">
            <span *ngIf="propertyForm.get('location')?.errors?.['required']">Location is required</span>
          </div>
        </div>

        <div class="form-group">
          <label for="addressLine1">Address Line 1</label>
          <input type="text" id="addressLine1" formControlName="addressLine1" class="form-control">
        </div>

        <div class="form-group">
          <label for="addressLine2">Address Line 2</label>
          <input type="text" id="addressLine2" formControlName="addressLine2" class="form-control">
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="city">City</label>
            <input type="text" id="city" formControlName="city" class="form-control">
          </div>

          <div class="form-group">
            <label for="state">State/Province</label>
            <input type="text" id="state" formControlName="state" class="form-control">
          </div>

          <div class="form-group">
            <label for="country">Country</label>
            <input type="text" id="country" formControlName="country" class="form-control">
          </div>

          <div class="form-group">
            <label for="postalCode">Postal Code</label>
            <input type="text" id="postalCode" formControlName="postalCode" class="form-control">
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="latitude">Latitude</label>
            <input
              type="number"
              id="latitude"
              formControlName="latitude"
              class="form-control"
              [ngClass]="{'is-invalid': propertyForm.get('latitude')?.touched && propertyForm.get('latitude')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('latitude')?.touched && propertyForm.get('latitude')?.errors">
              <span *ngIf="propertyForm.get('latitude')?.errors?.['min'] || propertyForm.get('latitude')?.errors?.['max']">Latitude must be between -90 and 90</span>
            </div>
          </div>

          <div class="form-group">
            <label for="longitude">Longitude</label>
            <input
              type="number"
              id="longitude"
              formControlName="longitude"
              class="form-control"
              [ngClass]="{'is-invalid': propertyForm.get('longitude')?.touched && propertyForm.get('longitude')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('longitude')?.touched && propertyForm.get('longitude')?.errors">
              <span *ngIf="propertyForm.get('longitude')?.errors?.['min'] || propertyForm.get('longitude')?.errors?.['max']">Longitude must be between -180 and 180</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Images Section -->
      <div class="form-section">
        <h2>Images</h2>

        <div class="form-group">
          <label for="mainImageUrl">Main Image URL</label>
          <input type="text" id="mainImageUrl" formControlName="mainImageUrl" class="form-control">
          <small class="form-text text-muted">URL to the main image of the property</small>
        </div>

        <div class="form-group">
          <label for="imageUrls">Additional Image URLs</label>
          <textarea
            id="imageUrls"
            formControlName="imageUrls"
            class="form-control"
            rows="3"
            placeholder="Enter URLs separated by commas"
          ></textarea>
          <small class="form-text text-muted">Enter multiple image URLs separated by commas</small>
        </div>

        <!-- File upload functionality would be added here in a real application -->
      </div>

      <!-- Property Details Section -->
      <div class="form-section">
        <h2>Property Details</h2>

        <div class="form-row">
          <div class="form-group">
            <label for="maximumCapacity">Maximum Capacity *</label>
            <input
              type="number"
              id="maximumCapacity"
              formControlName="maximumCapacity"
              class="form-control"
              min="1"
              [ngClass]="{'is-invalid': propertyForm.get('maximumCapacity')?.touched && propertyForm.get('maximumCapacity')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('maximumCapacity')?.touched && propertyForm.get('maximumCapacity')?.errors">
              <span *ngIf="propertyForm.get('maximumCapacity')?.errors?.['required']">Maximum capacity is required</span>
              <span *ngIf="propertyForm.get('maximumCapacity')?.errors?.['min']">Maximum capacity must be at least 1</span>
            </div>
          </div>

          <div class="form-group">
            <label for="totalArea">Total Area (m²) *</label>
            <input
              type="number"
              id="totalArea"
              formControlName="totalArea"
              class="form-control"
              min="0"
              [ngClass]="{'is-invalid': propertyForm.get('totalArea')?.touched && propertyForm.get('totalArea')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('totalArea')?.touched && propertyForm.get('totalArea')?.errors">
              <span *ngIf="propertyForm.get('totalArea')?.errors?.['required']">Total area is required</span>
              <span *ngIf="propertyForm.get('totalArea')?.errors?.['min']">Total area must be a positive number</span>
            </div>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="numberOfBedrooms">Number of Bedrooms *</label>
            <input
              type="number"
              id="numberOfBedrooms"
              formControlName="numberOfBedrooms"
              class="form-control"
              min="0"
              [ngClass]="{'is-invalid': propertyForm.get('numberOfBedrooms')?.touched && propertyForm.get('numberOfBedrooms')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('numberOfBedrooms')?.touched && propertyForm.get('numberOfBedrooms')?.errors">
              <span *ngIf="propertyForm.get('numberOfBedrooms')?.errors?.['required']">Number of bedrooms is required</span>
              <span *ngIf="propertyForm.get('numberOfBedrooms')?.errors?.['min']">Number of bedrooms must be a non-negative number</span>
            </div>
          </div>

          <div class="form-group">
            <label for="numberOfBathrooms">Number of Bathrooms *</label>
            <input
              type="number"
              id="numberOfBathrooms"
              formControlName="numberOfBathrooms"
              class="form-control"
              min="0"
              [ngClass]="{'is-invalid': propertyForm.get('numberOfBathrooms')?.touched && propertyForm.get('numberOfBathrooms')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('numberOfBathrooms')?.touched && propertyForm.get('numberOfBathrooms')?.errors">
              <span *ngIf="propertyForm.get('numberOfBathrooms')?.errors?.['required']">Number of bathrooms is required</span>
              <span *ngIf="propertyForm.get('numberOfBathrooms')?.errors?.['min']">Number of bathrooms must be a non-negative number</span>
            </div>
          </div>

          <div class="form-group">
            <label for="numberOfFloors">Number of Floors</label>
            <input
              type="number"
              id="numberOfFloors"
              formControlName="numberOfFloors"
              class="form-control"
              min="1"
              [ngClass]="{'is-invalid': propertyForm.get('numberOfFloors')?.touched && propertyForm.get('numberOfFloors')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('numberOfFloors')?.touched && propertyForm.get('numberOfFloors')?.errors">
              <span *ngIf="propertyForm.get('numberOfFloors')?.errors?.['min']">Number of floors must be at least 1</span>
            </div>
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="constructionYear">Construction Year</label>
            <input
              type="number"
              id="constructionYear"
              formControlName="constructionYear"
              class="form-control"
              [ngClass]="{'is-invalid': propertyForm.get('constructionYear')?.touched && propertyForm.get('constructionYear')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('constructionYear')?.touched && propertyForm.get('constructionYear')?.errors">
              <span *ngIf="propertyForm.get('constructionYear')?.errors?.['min'] || propertyForm.get('constructionYear')?.errors?.['max']">
                Construction year must be between 1800 and {{ new Date().getFullYear() }}
              </span>
            </div>
          </div>

          <div class="form-group">
            <label for="parkingCapacity">Parking Capacity</label>
            <input
              type="number"
              id="parkingCapacity"
              formControlName="parkingCapacity"
              class="form-control"
              min="0"
              [ngClass]="{'is-invalid': propertyForm.get('parkingCapacity')?.touched && propertyForm.get('parkingCapacity')?.invalid}"
            >
            <div class="invalid-feedback" *ngIf="propertyForm.get('parkingCapacity')?.touched && propertyForm.get('parkingCapacity')?.errors">
              <span *ngIf="propertyForm.get('parkingCapacity')?.errors?.['min']">Parking capacity must be a non-negative number</span>
            </div>
          </div>
        </div>

        <div class="form-group">
          <label for="kitchenSpecifications">Kitchen Specifications</label>
          <textarea id="kitchenSpecifications" formControlName="kitchenSpecifications" class="form-control" rows="2"></textarea>
        </div>

        <div class="form-group">
          <label for="viewType">View Type</label>
          <input type="text" id="viewType" formControlName="viewType" class="form-control">
          <small class="form-text text-muted">E.g., Ocean view, Mountain view, City view, etc.</small>
        </div>
      </div>

      <!-- Amenities Section -->
      <div class="form-section">
        <h2>Amenities & Features</h2>

        <div class="checkbox-group">
          <div class="form-check">
            <input type="checkbox" id="hasPool" formControlName="hasPool" class="form-check-input">
            <label for="hasPool" class="form-check-label">Swimming Pool</label>
          </div>

          <div class="form-check">
            <input type="checkbox" id="hasGarden" formControlName="hasGarden" class="form-check-input">
            <label for="hasGarden" class="form-check-label">Garden</label>
          </div>

          <div class="form-check">
            <input type="checkbox" id="hasSpa" formControlName="hasSpa" class="form-check-input">
            <label for="hasSpa" class="form-check-label">Spa</label>
          </div>

          <div class="form-check">
            <input type="checkbox" id="hasGym" formControlName="hasGym" class="form-check-input">
            <label for="hasGym" class="form-check-label">Gym</label>
          </div>
        </div>

        <!-- Additional amenities would be added here in a real application -->
      </div>

      <!-- Additional Information Section -->
      <div class="form-section">
        <h2>Additional Information</h2>

        <div class="form-group">
          <label for="notes">Notes</label>
          <textarea id="notes" formControlName="notes" class="form-control" rows="3"></textarea>
          <small class="form-text text-muted">Any additional information about the property</small>
        </div>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn-primary" [disabled]="submitting">
        {{ submitting ? 'Saving...' : (isEditMode ? 'Update Property' : 'Add Property') }}
      </button>
      <a routerLink="/properties" class="btn-link">Cancel</a>
    </div>
  </form>
</div>
EOF

cat > src/app/features/properties/components/property-form.component.scss << 'EOF'
.property-form-container {
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

.header-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-secondary, .btn-link {
  padding: 0.5rem 1rem;
  border-radius: 4px;
  text-decoration: none;
  font-size: 0.875rem;
}

.btn-secondary {
  background-color: #6c757d;
  color: white;
  border: none;
  cursor: pointer;
}

.btn-secondary:hover {
  background-color: #5a6268;
}

.btn-link {
  color: #6c757d;
}

.loading-state {
  padding: 2rem;
  text-align: center;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.error-alert {
  padding: 1rem;
  margin-bottom: 1rem;
  background-color: #ffebee;
  color: #d32f2f;
  border-radius: 4px;
  border-left: 4px solid #d32f2f;
}

.property-form {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.form-sections {
  padding: 1.5rem;
}

.form-section {
  margin-bottom: 2rem;
}

.form-section h2 {
  font-size: 1.25rem;
  margin-top: 0;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
}

.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  flex: 1;
  min-width: 200px;
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.25rem;
  font-weight: 500;
}

.form-control {
  display: block;
  width: 100%;
  padding: 0.5rem;
  font-size: 0.875rem;
  line-height: 1.5;
  color: #495057;
  background-color: #fff;
  border: 1px solid #ced4da;
  border-radius: 0.25rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.form-control:focus {
  color: #495057;
  background-color: #fff;
  border-color: #80bdff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.form-control.is-invalid {
  border-color: #dc3545;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='none' stroke='%23dc3545' viewBox='0 0 12 12'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right calc(0.375em + 0.1875rem) center;
  background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
}

.form-control.is-invalid:focus {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

.invalid-feedback {
  display: block;
  width: 100%;
  margin-top: 0.25rem;
  font-size: 80%;
  color: #dc3545;
}

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 80%;
}

.text-muted {
  color: #6c757d;
}

.checkbox-group {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.form-check {
  display: flex;
  align-items: center;
  margin-bottom: 0.5rem;
}

.form-check-input {
  margin-right: 0.5rem;
}

.form-actions {
  padding: 1.5rem;
  background-color: #f9f9f9;
  border-top: 1px solid #eee;
  border-radius: 0 0 8px 8px;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.btn-primary {
  padding: 0.5rem 1rem;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
}

.btn-primary:hover {
  background-color: #0069d9;
}

.btn-primary:disabled {
  background-color: #8bbafe;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
  }

  .form-group {
    width: 100%;
  }
}
EOF

# --- VEHICLES FEATURE ---
echo -e "${BLUE}Creating vehicles feature...${NC}"

mkdir -p src/app/features/vehicles/{components,services,models}

# Vehicle routes
cat > src/app/features/vehicles/vehicles.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const VEHICLES_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/vehicle-list.component')
      .then(c => c.VehicleListComponent)
  },
  {
    path: 'new',
    loadComponent: () => import('./components/vehicle-form.component')
      .then(c => c.VehicleFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id',
    loadComponent: () => import('./components/vehicle-detail.component')
      .then(c => c.VehicleDetailComponent)
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/vehicle-form.component')
      .then(c => c.VehicleFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  }
];
EOF

# Vehicle service
cat > src/app/features/vehicles/services/vehicle.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Vehicle, CreateVehicleRequest } from '../../../core/models/vehicle.model';

@Injectable({
  providedIn: 'root'
})
export class VehicleService {
  private readonly endpoint = 'vehicles';

  constructor(private apiService: ApiService) { }

  getVehicles(params: any = {}): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(this.endpoint, params);
  }

  getVehicle(id: number): Observable<Vehicle> {
    return this.apiService.get<Vehicle>(`${this.endpoint}/${id}`);
  }

  createVehicle(vehicle: CreateVehicleRequest): Observable<Vehicle> {
    return this.apiService.post<Vehicle>(this.endpoint, vehicle);
  }

  updateVehicle(id: number, vehicle: Partial<CreateVehicleRequest>): Observable<Vehicle> {
    return this.apiService.patch<Vehicle>(`${this.endpoint}/${id}`, vehicle);
  }

  deleteVehicle(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getVehicleTypes(): Observable<string[]> {
    return this.apiService.get<string[]>(`${this.endpoint}/types`);
  }

  searchVehicles(query: string): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/search`, { q: query });
  }

  getVehiclesByType(type: string): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/type/${type}`);
  }

  getVehiclesByMakeModel(make: string, model?: string): Observable<Vehicle[]> {
    const params: any = { make };
    if (model) {
      params.model = model;
    }
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/make-model`, params);
  }

  getVehiclesByYearRange(minYear: number, maxYear: number): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`${this.endpoint}/year-range`, { minYear, maxYear });
  }

  getAvailableVehicles(startDate: string, endDate: string, params: any = {}): Observable<Vehicle[]> {
    return this.apiService.get<Vehicle[]>(`rental-items/available`, {
      itemType: 'vehicle',
      startDate,
      endDate,
      ...params
    });
  }
}
EOF

# --- CLIENTS FEATURE ---
echo -e "${BLUE}Creating clients feature...${NC}"

mkdir -p src/app/features/clients/{components,services,models}
#!/bin/bash

# --- CONTINUING CLIENTS FEATURE ---
# Continuing the clients.routes.ts file

cat >> src/app/features/clients/clients.routes.ts << 'EOF'
  {
    path: 'profile',
    loadComponent: () => import('./components/client-profile.component')
      .then(c => c.ClientProfileComponent),
    canActivate: [authGuard]
  },
  {
    path: ':id',
    loadComponent: () => import('./components/client-detail.component')
      .then(c => c.ClientDetailComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/client-form.component')
      .then(c => c.ClientFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  }
];
EOF

# Clients service
cat > src/app/features/clients/services/client.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Client, CreateClientRequest } from '../../../core/models/client.model';

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  private readonly endpoint = 'clients';

  constructor(private apiService: ApiService) { }

  getClients(params: any = {}): Observable<Client[]> {
    return this.apiService.get<Client[]>(this.endpoint, params);
  }

  getClient(id: number): Observable<Client> {
    return this.apiService.get<Client>(`${this.endpoint}/${id}`);
  }

  getClientByUserId(userId: number): Observable<Client> {
    return this.apiService.get<Client>(`${this.endpoint}/users/${userId}`);
  }

  getCurrentClientProfile(): Observable<Client> {
    return this.apiService.get<Client>(`${this.endpoint}/profile`);
  }

  createClient(client: CreateClientRequest): Observable<Client> {
    return this.apiService.post<Client>(this.endpoint, client);
  }

  updateClient(id: number, client: Partial<Client>): Observable<Client> {
    return this.apiService.patch<Client>(`${this.endpoint}/${id}`, client);
  }

  updateClientByUserId(userId: number, client: Partial<Client>): Observable<Client> {
    return this.apiService.patch<Client>(`${this.endpoint}/users/${userId}`, client);
  }

  deleteClient(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  searchClients(query: string): Observable<Client[]> {
    return this.apiService.get<Client[]>(`${this.endpoint}/search`, { q: query });
  }

  getClientStatistics(): Observable<any> {
    return this.apiService.get<any>(`${this.endpoint}/statistics`);
  }
}
EOF

# --- RESERVATIONS FEATURE ---
echo -e "${BLUE}Creating reservations feature...${NC}"

mkdir -p src/app/features/reservations/{components,services,models}

# Reservation routes
cat > src/app/features/reservations/reservations.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const RESERVATIONS_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/reservation-list.component')
      .then(c => c.ReservationListComponent),
    canActivate: [authGuard]
  },
  {
    path: 'new',
    loadComponent: () => import('./components/reservation-form.component')
      .then(c => c.ReservationFormComponent),
    canActivate: [authGuard]
  },
  {
    path: 'calendar',
    loadComponent: () => import('./components/calendar-view.component')
      .then(c => c.CalendarViewComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id',
    loadComponent: () => import('./components/reservation-detail.component')
      .then(c => c.ReservationDetailComponent),
    canActivate: [authGuard]
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/reservation-form.component')
      .then(c => c.ReservationFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  }
];
EOF

# Reservation service
cat > src/app/features/reservations/services/reservation.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import {
  Reservation,
  CreateReservationRequest,
  ReservationStatus,
  PaymentStatus
} from '../../../core/models/reservation.model';

@Injectable({
  providedIn: 'root'
})
export class ReservationService {
  private readonly endpoint = 'reservations';

  constructor(private apiService: ApiService) { }

  getReservations(params: any = {}): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(this.endpoint, params);
  }

  getReservation(id: number): Observable<Reservation> {
    return this.apiService.get<Reservation>(`${this.endpoint}/${id}`);
  }

  getReservationByNumber(reservationNumber: string): Observable<Reservation> {
    return this.apiService.get<Reservation>(`${this.endpoint}/number/${reservationNumber}`);
  }

  createReservation(reservation: CreateReservationRequest): Observable<Reservation> {
    return this.apiService.post<Reservation>(this.endpoint, reservation);
  }

  updateReservation(id: number, reservation: Partial<CreateReservationRequest>): Observable<Reservation> {
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}`, reservation);
  }

  updateReservationStatus(id: number, status: ReservationStatus): Observable<Reservation> {
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}/status`, { status });
  }

  updatePaymentStatus(id: number, paymentStatus: PaymentStatus, paidAmount?: number): Observable<Reservation> {
    const data: any = { paymentStatus };
    if (paidAmount !== undefined) {
      data.paidAmount = paidAmount;
    }
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}/payment`, data);
  }

  cancelReservation(id: number): Observable<Reservation> {
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}/cancel`, {});
  }

  checkInReservation(id: number): Observable<Reservation> {
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}/check-in`, {});
  }

  checkOutReservation(id: number): Observable<Reservation> {
    return this.apiService.patch<Reservation>(`${this.endpoint}/${id}/check-out`, {});
  }

  markAsPaid(id: number): Observable<Reservation> {
    return this.apiService.post<Reservation>(`${this.endpoint}/${id}/pay-full`, {});
  }

  refundReservation(id: number): Observable<Reservation> {
    return this.apiService.post<Reservation>(`${this.endpoint}/${id}/refund`, {});
  }

  deleteReservation(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getClientReservations(clientId: number): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/client/${clientId}`);
  }

  getPropertyReservations(propertyId: number): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/property/${propertyId}`);
  }

  getVehicleReservations(vehicleId: number): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/vehicle/${vehicleId}`);
  }

  getReservationsInDateRange(startDate: Date, endDate: Date, itemType?: string): Observable<Reservation[]> {
    const params: any = {
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString()
    };

    if (itemType) {
      params.itemType = itemType;
    }

    return this.apiService.get<Reservation[]>(`${this.endpoint}/date-range`, params);
  }

  getUpcomingReservations(days: number = 7): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/upcoming`, { days });
  }

  getCurrentReservations(): Observable<Reservation[]> {
    return this.apiService.get<Reservation[]>(`${this.endpoint}/current`);
  }

  getReservationStatistics(): Observable<any> {
    return this.apiService.get<any>(`${this.endpoint}/statistics`);
  }
}
EOF

# --- STAFF FEATURE ---
echo -e "${BLUE}Creating staff feature...${NC}"

mkdir -p src/app/features/staff/{components,services,models}

# Staff routes
cat > src/app/features/staff/staff.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const STAFF_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/staff-list.component')
      .then(c => c.StaffListComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: 'new',
    loadComponent: () => import('./components/staff-form.component')
      .then(c => c.StaffFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  },
  {
    path: 'profile',
    loadComponent: () => import('./components/staff-profile.component')
      .then(c => c.StaffProfileComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: 'departments',
    loadComponent: () => import('./components/department-list.component')
      .then(c => c.DepartmentListComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  },
  {
    path: ':id',
    loadComponent: () => import('./components/staff-detail.component')
      .then(c => c.StaffDetailComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN, UserType.STAFF] }
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/staff-form.component')
      .then(c => c.StaffFormComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  }
];
EOF

# Staff service
cat > src/app/features/staff/services/staff.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Staff, CreateStaffRequest } from '../../../core/models/staff.model';

@Injectable({
  providedIn: 'root'
})
export class StaffService {
  private readonly endpoint = 'staff';

  constructor(private apiService: ApiService) { }

  getStaffMembers(params: any = {}): Observable<Staff[]> {
    return this.apiService.get<Staff[]>(this.endpoint, params);
  }

  getStaffMember(id: number): Observable<Staff> {
    return this.apiService.get<Staff>(`${this.endpoint}/${id}`);
  }

  getStaffMemberByUserId(userId: number): Observable<Staff> {
    return this.apiService.get<Staff>(`${this.endpoint}/users/${userId}`);
  }

  getStaffByDepartment(departmentId: number): Observable<Staff[]> {
    return this.apiService.get<Staff[]>(`${this.endpoint}/departments/${departmentId}`);
  }

  createStaff(staff: CreateStaffRequest): Observable<Staff> {
    return this.apiService.post<Staff>(this.endpoint, staff);
  }

  updateStaff(id: number, staff: Partial<Staff>): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/${id}`, staff);
  }

  updateStaffByUserId(userId: number, staff: Partial<Staff>): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/users/${userId}`, staff);
  }

  activateStaff(id: number): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/${id}/activate`, {});
  }

  deactivateStaff(id: number): Observable<Staff> {
    return this.apiService.patch<Staff>(`${this.endpoint}/${id}/deactivate`, {});
  }

  deleteStaff(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getStaffStatistics(): Observable<any> {
    return this.apiService.get<any>(`${this.endpoint}/statistics`);
  }
}
EOF

# Department service
cat > src/app/features/staff/services/department.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';
import { Department } from '../../../core/models/department.model';

@Injectable({
  providedIn: 'root'
})
export class DepartmentService {
  private readonly endpoint = 'departments';

  constructor(private apiService: ApiService) { }

  getDepartments(): Observable<Department[]> {
    return this.apiService.get<Department[]>(this.endpoint);
  }

  getDepartment(id: number): Observable<Department> {
    return this.apiService.get<Department>(`${this.endpoint}/${id}`);
  }

  createDepartment(department: Partial<Department>): Observable<Department> {
    return this.apiService.post<Department>(this.endpoint, department);
  }

  updateDepartment(id: number, department: Partial<Department>): Observable<Department> {
    return this.apiService.patch<Department>(`${this.endpoint}/${id}`, department);
  }

  deleteDepartment(id: number): Observable<void> {
    return this.apiService.delete<void>(`${this.endpoint}/${id}`);
  }

  getDepartmentWithStaff(id: number): Observable<Department> {
    return this.apiService.get<Department>(`${this.endpoint}/${id}/staff`);
  }
}
EOF

# --- SETTINGS FEATURE ---
echo -e "${BLUE}Creating settings feature...${NC}"

mkdir -p src/app/features/settings/{components,services}

# Settings routes
cat > src/app/features/settings/settings.routes.ts << 'EOF'
import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/guards/auth.guard';
import { UserType } from '../../core/models/user.model';

export const SETTINGS_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/settings.component')
      .then(c => c.SettingsComponent),
    canActivate: [authGuard],
    data: { roles: [UserType.ADMIN] }
  },
  {
    path: 'profile',
    loadComponent: () => import('./components/profile.component')
      .then(c => c.ProfileComponent),
    canActivate: [authGuard]
  }
];
EOF

# Settings service
cat > src/app/features/settings/services/settings.service.ts << 'EOF'
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from '../../../core/services/api.service';

@Injectable({
  providedIn: 'root'
})
export class SettingsService {
  private readonly endpoint = 'settings';

  constructor(private apiService: ApiService) { }

  getSystemSettings(): Observable<any> {
    return this.apiService.get<any>(this.endpoint);
  }

  updateSystemSettings(settings: any): Observable<any> {
    return this.apiService.patch<any>(this.endpoint, settings);
  }

  getUserPreferences(userId: number, category?: string): Observable<any> {
    const params: any = {};
    if (category) {
      params.category = category;
    }
    return this.apiService.get<any>(`users/${userId}/preferences`, params);
  }

  setUserPreference(userId: number, category: string, key: string, value: string): Observable<any> {
    return this.apiService.post<any>(`users/${userId}/preferences`, { category, key, value });
  }

  deleteUserPreference(userId: number, category: string, key: string): Observable<void> {
    return this.apiService.delete<void>(`users/${userId}/preferences/${category}/${key}`);
  }
}
EOF

# --- LAYOUT COMPONENTS ---
echo -e "${BLUE}Creating layout components...${NC}"

# Navbar component
cat > src/app/layout/navbar/navbar.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../core/auth/services/auth.service';
import { User, UserType } from '../../core/models/user.model';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.scss'
})
export class NavbarComponent implements OnInit {
  currentUser: User | null = null;
  isAdmin = false;
  isStaff = false;
  isClient = false;
  showUserMenu = false;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.currentUser$.subscribe(user => {
      this.currentUser = user;
      this.isAdmin = user?.userType === UserType.ADMIN;
      this.isStaff = user?.userType === UserType.STAFF;
      this.isClient = user?.userType === UserType.CLIENT;
    });
  }

  toggleUserMenu(): void {
    this.showUserMenu = !this.showUserMenu;
  }

  logout(): void {
    this.authService.logout();
  }
}
EOF

cat > src/app/layout/navbar/navbar.component.html << 'EOF'
<header class="navbar">
  <div class="navbar-container">
    <div class="navbar-left">
      <a routerLink="/" class="navbar-logo">
        <span class="logo-text">LRMS</span>
      </a>

      <nav class="main-nav" *ngIf="currentUser">
        <a routerLink="/" routerLinkActive="active" [routerLinkActiveOptions]="{exact: true}" class="nav-link">Dashboard</a>
        <a routerLink="/properties" routerLinkActive="active" class="nav-link">Properties</a>
        <a routerLink="/vehicles" routerLinkActive="active" class="nav-link">Vehicles</a>
        <a routerLink="/reservations" routerLinkActive="active" class="nav-link">Reservations</a>
        <a routerLink="/clients" routerLinkActive="active" class="nav-link" *ngIf="isAdmin || isStaff">Clients</a>
        <a routerLink="/staff" routerLinkActive="active" class="nav-link" *ngIf="isAdmin || isStaff">Staff</a>
      </nav>
    </div>

    <div class="navbar-right">
      <div class="user-menu" *ngIf="currentUser">
        <button (click)="toggleUserMenu()" class="user-menu-btn">
          <div class="user-avatar">
            <img *ngIf="currentUser.profileImageUrl" [src]="currentUser.profileImageUrl" alt="User avatar">
            <div *ngIf="!currentUser.profileImageUrl" class="avatar-placeholder">
              {{ currentUser.firstName?.charAt(0) }}{{ currentUser.lastName?.charAt(0) }}
            </div>
          </div>
          <span class="user-name">{{ currentUser.firstName }} {{ currentUser.lastName }}</span>
          <span class="dropdown-icon">▾</span>
        </button>

        <div class="dropdown-menu" [class.show]="showUserMenu">
          <div class="dropdown-header">
            <strong>{{ currentUser.fullName }}</strong>
            <small>{{ currentUser.email }}</small>
            <div class="user-role">{{ currentUser.userType | titlecase }}</div>
          </div>

          <div class="dropdown-items">
            <a routerLink="/settings/profile" class="dropdown-item">
              <i class="icon profile-icon"></i>
              <span>My Profile</span>
            </a>
            <a routerLink="/settings" class="dropdown-item" *ngIf="isAdmin">
              <i class="icon settings-icon"></i>
              <span>Settings</span>
            </a>
            <a routerLink="/clients/profile" class="dropdown-item" *ngIf="isClient">
              <i class="icon client-icon"></i>
              <span>Client Dashboard</span>
            </a>
            <a routerLink="/staff/profile" class="dropdown-item" *ngIf="isStaff">
              <i class="icon staff-icon"></i>
              <span>Staff Dashboard</span>
            </a>
            <div class="dropdown-divider"></div>
            <button (click)="logout()" class="dropdown-item">
              <i class="icon logout-icon"></i>
              <span>Logout</span>
            </button>
          </div>
        </div>
      </div>

      <div class="auth-links" *ngIf="!currentUser">
        <a routerLink="/auth/login" class="btn-link">Login</a>
        <a routerLink="/auth/register" class="btn-primary">Register</a>
      </div>
    </div>
  </div>
</header>
EOF

cat > src/app/layout/navbar/navbar.component.scss << 'EOF'
.navbar {
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.navbar-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem 1rem;
  max-width: 1440px;
  margin: 0 auto;
}

.navbar-left {
  display: flex;
  align-items: center;
}

.navbar-logo {
  display: flex;
  align-items: center;
  text-decoration: none;
  margin-right: 2rem;
}

.logo-text {
  font-size: 1.5rem;
  font-weight: 700;
  color: #007bff;
}

.main-nav {
  display: flex;
  gap: 1rem;
}

.nav-link {
  color: #555;
  text-decoration: none;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.nav-link:hover {
  background-color: #f5f5f5;
}

.nav-link.active {
  color: #007bff;
  font-weight: 500;
}

.navbar-right {
  display: flex;
  align-items: center;
}

.user-menu {
  position: relative;
}

.user-menu-btn {
  display: flex;
  align-items: center;
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  border-radius: 4px;
}

.user-menu-btn:hover {
  background-color: #f5f5f5;
}

.user-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 0.5rem;
  background-color: #007bff;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 500;
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  font-size: 0.875rem;
  text-transform: uppercase;
}

.user-name {
  margin-right: 0.25rem;
  font-size: 0.875rem;
}

.dropdown-icon {
  font-size: 0.75rem;
  color: #666;
}

.dropdown-menu {
  position: absolute;
  top: calc(100% + 0.5rem);
  right: 0;
  background-color: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  width: 250px;
  z-index: 100;
  opacity: 0;
  transform: translateY(-10px);
  pointer-events: none;
  transition: opacity 0.2s, transform 0.2s;
}

.dropdown-menu.show {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}

.dropdown-header {
  padding: 1rem;
  border-bottom: 1px solid #eee;
  display: flex;
  flex-direction: column;
}

.dropdown-header strong {
  margin-bottom: 0.25rem;
}

.dropdown-header small {
  color: #666;
  margin-bottom: 0.25rem;
}

.user-role {
  background-color: #e6f7ff;
  color: #007bff;
  font-size: 0.75rem;
  padding: 0.125rem 0.5rem;
  border-radius: 4px;
  display: inline-block;
}

.dropdown-items {
  padding: 0.5rem 0;
}

.dropdown-item {
  display: flex;
  align-items: center;
  padding: 0.5rem 1rem;
  color: #333;
  text-decoration: none;
  transition: background-color 0.2s;
  cursor: pointer;
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  font-size: 0.875rem;
}

.dropdown-item:hover {
  background-color: #f5f5f5;
}

.dropdown-divider {
  height: 1px;
  background-color: #eee;
  margin: 0.5rem 0;
}

.icon {
  width: 16px;
  height: 16px;
  margin-right: 0.75rem;
  opacity: 0.7;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
}

.profile-icon {
  background-image: url("/assets/icons/user.svg");
}

.settings-icon {
  background-image: url("/assets/icons/settings.svg");
}

.client-icon {
  background-image: url("/assets/icons/user-check.svg");
}

.staff-icon {
  background-image: url("/assets/icons/briefcase.svg");
}

.logout-icon {
  background-image: url("/assets/icons/log-out.svg");
}

.auth-links {
  display: flex;
  gap: 0.5rem;
}

.btn-link {
  color: #007bff;
  text-decoration: none;
  padding: 0.5rem 0.75rem;
}

.btn-primary {
  background-color: #007bff;
  color: white;
  padding: 0.5rem 0.75rem;
  border-radius: 4px;
  text-decoration: none;
}

@media (max-width: 768px) {
  .main-nav {
    display: none;
  }

  .user-name {
    display: none;
  }
}
EOF#!/bin/bash

# --- CONTINUING THE SIDEBAR COMPONENT ---
# Completing the sidebar.component.ts file

cat >> src/app/layout/sidebar/sidebar.component.ts << 'EOF'
  toggleSidebar(): void {
    this.isCollapsed = !this.isCollapsed;
  }
}
EOF

cat > src/app/layout/sidebar/sidebar.component.html << 'EOF'
<aside class="sidebar" [class.collapsed]="isCollapsed">
  <div class="sidebar-header">
    <button class="collapse-btn" (click)="toggleSidebar()">
      <i class="icon menu-icon"></i>
    </button>
  </div>

  <nav class="sidebar-nav">
    <div class="nav-section">
      <div class="section-title">Management</div>
      <ul class="nav-list">
        <li class="nav-item">
          <a routerLink="/" routerLinkActive="active" [routerLinkActiveOptions]="{exact: true}" class="nav-link">
            <i class="icon dashboard-icon"></i>
            <span *ngIf="!isCollapsed">Dashboard</span>
          </a>
        </li>

        <li class="nav-item">
          <a routerLink="/properties" routerLinkActive="active" class="nav-link">
            <i class="icon property-icon"></i>
            <span *ngIf="!isCollapsed">Properties</span>
          </a>
        </li>

        <li class="nav-item">
          <a routerLink="/vehicles" routerLinkActive="active" class="nav-link">
            <i class="icon vehicle-icon"></i>
            <span *ngIf="!isCollapsed">Vehicles</span>
          </a>
        </li>

        <li class="nav-item">
          <a routerLink="/reservations" routerLinkActive="active" class="nav-link">
            <i class="icon reservation-icon"></i>
            <span *ngIf="!isCollapsed">Reservations</span>
          </a>
        </li>
      </ul>
    </div>

    <div class="nav-section" *ngIf="isAdmin || isStaff">
      <div class="section-title">People</div>
      <ul class="nav-list">
        <li class="nav-item">
          <a routerLink="/clients" routerLinkActive="active" class="nav-link">
            <i class="icon client-icon"></i>
            <span *ngIf="!isCollapsed">Clients</span>
          </a>
        </li>

        <li class="nav-item">
          <a routerLink="/staff" routerLinkActive="active" class="nav-link">
            <i class="icon staff-icon"></i>
            <span *ngIf="!isCollapsed">Staff</span>
          </a>
        </li>
      </ul>
    </div>

    <div class="nav-section">
      <div class="section-title">Account</div>
      <ul class="nav-list">
        <li class="nav-item">
          <a routerLink="/settings/profile" routerLinkActive="active" class="nav-link">
            <i class="icon profile-icon"></i>
            <span *ngIf="!isCollapsed">My Profile</span>
          </a>
        </li>

        <li class="nav-item" *ngIf="isAdmin">
          <a routerLink="/settings" routerLinkActive="active" class="nav-link">
            <i class="icon settings-icon"></i>
            <span *ngIf="!isCollapsed">Settings</span>
          </a>
        </li>

        <li class="nav-item">
          <a (click)="authService.logout()" class="nav-link">
            <i class="icon logout-icon"></i>
            <span *ngIf="!isCollapsed">Logout</span>
          </a>
        </li>
      </ul>
    </div>
  </nav>
</aside>
EOF

cat > src/app/layout/sidebar/sidebar.component.scss << 'EOF'
.sidebar {
  display: flex;
  flex-direction: column;
  background-color: #1a1c23;
  color: #a0aec0;
  width: 240px;
  height: 100%;
  transition: width 0.3s;
  overflow-x: hidden;
  z-index: 10;
}

.sidebar.collapsed {
  width: 60px;
}

.sidebar-header {
  padding: 1rem;
  display: flex;
  justify-content: flex-end;
}

.collapse-btn {
  background: transparent;
  border: none;
  color: #a0aec0;
  cursor: pointer;
  padding: 0.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
}

.collapse-btn:hover {
  background-color: #2d3748;
}

.icon {
  width: 20px;
  height: 20px;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
}

.menu-icon {
  background-image: url("/assets/icons/menu.svg");
}

.sidebar-nav {
  padding: 0 0.5rem;
  flex: 1;
  overflow-y: auto;
}

.nav-section {
  margin-bottom: 1.5rem;
}

.section-title {
  padding: 0.5rem 1rem;
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: #718096;
  opacity: 0.6;
}

.sidebar.collapsed .section-title {
  text-align: center;
  padding: 0.5rem 0;
  font-size: 0.6rem;
}

.nav-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.nav-item {
  margin-bottom: 0.25rem;
}

.nav-link {
  display: flex;
  align-items: center;
  padding: 0.75rem 1rem;
  border-radius: 4px;
  color: #a0aec0;
  text-decoration: none;
  transition: background-color 0.2s;
  cursor: pointer;
}

.nav-link:hover {
  background-color: #2d3748;
}

.nav-link.active {
  background-color: #2c5282;
  color: white;
}

.nav-link i {
  margin-right: 1rem;
  opacity: 0.7;
}

.sidebar.collapsed .nav-link {
  justify-content: center;
  padding: 0.75rem 0;
}

.sidebar.collapsed .nav-link i {
  margin-right: 0;
}

.dashboard-icon {
  background-image: url("/assets/icons/home.svg");
}

.property-icon {
  background-image: url("/assets/icons/home.svg");
}

.vehicle-icon {
  background-image: url("/assets/icons/car.svg");
}

.reservation-icon {
  background-image: url("/assets/icons/calendar.svg");
}

.client-icon {
  background-image: url("/assets/icons/users.svg");
}

.staff-icon {
  background-image: url("/assets/icons/briefcase.svg");
}

.profile-icon {
  background-image: url("/assets/icons/user.svg");
}

.settings-icon {
  background-image: url("/assets/icons/settings.svg");
}

.logout-icon {
  background-image: url("/assets/icons/log-out.svg");
}

@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    top: 60px;
    left: 0;
    height: calc(100vh - 60px);
    transform: translateX(-100%);
    transition: transform 0.3s;
  }

  .sidebar.show {
    transform: translateX(0);
  }
}
EOF

# Footer component
cat > src/app/layout/footer/footer.component.ts << 'EOF'
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-footer',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './footer.component.html',
  styleUrl: './footer.component.scss'
})
export class FooterComponent {
  currentYear = new Date().getFullYear();
}
EOF

cat > src/app/layout/footer/footer.component.html << 'EOF'
<footer class="footer">
  <div class="footer-container">
    <div class="footer-content">
      <div class="copyright">
        &copy; {{ currentYear }} Luxury Rental Management System. All rights reserved.
      </div>
      <div class="version">
        Version 1.0.0
      </div>
    </div>
  </div>
</footer>
EOF

cat > src/app/layout/footer/footer.component.scss << 'EOF'
.footer {
  background-color: white;
  border-top: 1px solid #eee;
  padding: 1rem 0;
}

.footer-container {
  max-width: 1440px;
  margin: 0 auto;
  padding: 0 1rem;
}

.footer-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.875rem;
  color: #666;
}

.copyright, .version {
  margin: 0;
}

@media (max-width: 768px) {
  .footer-content {
    flex-direction: column;
    gap: 0.5rem;
    text-align: center;
  }
}
EOF

# --- SHARED COMPONENTS ---
echo -e "${BLUE}Creating shared components...${NC}"

# Data Table Component
mkdir -p src/app/shared/components/data-table

cat > src/app/shared/components/data-table/data-table.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export interface Column {
  key: string;
  label: string;
  sortable?: boolean;
  format?: (value: any) => string;
}

export interface SortEvent {
  column: string;
  direction: 'asc' | 'desc';
}

@Component({
  selector: 'app-data-table',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './data-table.component.html',
  styleUrl: './data-table.component.scss'
})
export class DataTableComponent {
  @Input() columns: Column[] = [];
  @Input() data: any[] = [];
  @Input() loading = false;
  @Input() sortable = true;
  @Input() pagination = true;
  @Input() pageSize = 10;
  @Input() currentPage = 1;
  @Input() totalItems = 0;
  @Input() emptyMessage = 'No data available';
  @Input() selectable = false;
  @Input() selectedItems: any[] = [];

  @Output() sort = new EventEmitter<SortEvent>();
  @Output() page = new EventEmitter<number>();
  @Output() selectItem = new EventEmitter<any>();
  @Output() selectAll = new EventEmitter<boolean>();
  @Output() rowClick = new EventEmitter<any>();

  sortColumn = '';
  sortDirection: 'asc' | 'desc' = 'asc';
  allSelected = false;

  onSort(column: Column): void {
    if (!column.sortable || !this.sortable) return;

    if (this.sortColumn === column.key) {
      this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
    } else {
      this.sortColumn = column.key;
      this.sortDirection = 'asc';
    }

    this.sort.emit({
      column: this.sortColumn,
      direction: this.sortDirection
    });
  }

  onPageChange(page: number): void {
    if (page < 1 || page > this.totalPages) return;
    this.page.emit(page);
  }

  get totalPages(): number {
    return Math.ceil(this.totalItems / this.pageSize);
  }

  get pages(): number[] {
    const pageCount = this.totalPages;
    const maxPages = 5;
    const halfMaxPages = Math.floor(maxPages / 2);

    let startPage = Math.max(this.currentPage - halfMaxPages, 1);
    let endPage = startPage + maxPages - 1;

    if (endPage > pageCount) {
      endPage = pageCount;
      startPage = Math.max(endPage - maxPages + 1, 1);
    }

    return Array.from({ length: endPage - startPage + 1 }, (_, i) => startPage + i);
  }

  onSelectAll(event: Event): void {
    const isChecked = (event.target as HTMLInputElement).checked;
    this.allSelected = isChecked;
    this.selectAll.emit(isChecked);
  }

  onSelectItem(event: Event, item: any): void {
    event.stopPropagation();
    this.selectItem.emit(item);
  }

  isSelected(item: any): boolean {
    return this.selectedItems.some(selectedItem => selectedItem.id === item.id);
  }

  onRowClick(item: any): void {
    this.rowClick.emit(item);
  }

  getValue(item: any, column: Column): any {
    const keys = column.key.split('.');
    let value = item;

    for (const key of keys) {
      if (value === null || value === undefined) return '';
      value = value[key];
    }

    return value;
  }

  getFormattedValue(item: any, column: Column): string {
    const value = this.getValue(item, column);

    if (column.format) {
      return column.format(value);
    }

    return value !== null && value !== undefined ? String(value) : '';
  }
}
EOF

cat > src/app/shared/components/data-table/data-table.component.html << 'EOF'
<div class="data-table-wrapper">
  <div class="table-responsive">
    <table class="data-table">
      <thead>
        <tr>
          <th *ngIf="selectable" class="select-column">
            <input
              type="checkbox"
              [checked]="allSelected"
              (change)="onSelectAll($event)"
            >
          </th>
          <th
            *ngFor="let column of columns"
            [class.sortable]="column.sortable && sortable"
            [class.sorted]="sortColumn === column.key"
            [class.asc]="sortColumn === column.key && sortDirection === 'asc'"
            [class.desc]="sortColumn === column.key && sortDirection === 'desc'"
            (click)="onSort(column)"
          >
            {{ column.label }}
            <span class="sort-icon" *ngIf="column.sortable && sortable"></span>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr *ngIf="loading">
          <td [attr.colspan]="selectable ? columns.length + 1 : columns.length" class="loading-cell">
            <div class="loading-indicator">Loading...</div>
          </td>
        </tr>

        <tr *ngIf="!loading && (!data || data.length === 0)">
          <td [attr.colspan]="selectable ? columns.length + 1 : columns.length" class="empty-cell">
            {{ emptyMessage }}
          </td>
        </tr>

        <tr
          *ngFor="let item of data"
          [class.selected]="isSelected(item)"
          (click)="onRowClick(item)"
        >
          <td *ngIf="selectable" class="select-column" (click)="$event.stopPropagation()">
            <input
              type="checkbox"
              [checked]="isSelected(item)"
              (change)="onSelectItem($event, item)"
            >
          </td>
          <td *ngFor="let column of columns">
            {{ getFormattedValue(item, column) }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="pagination" *ngIf="pagination && totalItems > 0">
    <div class="pagination-info">
      Showing {{ (currentPage - 1) * pageSize + 1 }} to {{ Math.min(currentPage * pageSize, totalItems) }} of {{ totalItems }} items
    </div>

    <div class="pagination-controls">
      <button
        class="pagination-btn"
        [disabled]="currentPage === 1"
        (click)="onPageChange(1)"
      >
        &laquo;
      </button>

      <button
        class="pagination-btn"
        [disabled]="currentPage === 1"
        (click)="onPageChange(currentPage - 1)"
      >
        &lsaquo;
      </button>

      <button
        *ngFor="let page of pages"
        class="pagination-btn"
        [class.active]="page === currentPage"
        (click)="onPageChange(page)"
      >
        {{ page }}
      </button>

      <button
        class="pagination-btn"
        [disabled]="currentPage === totalPages"
        (click)="onPageChange(currentPage + 1)"
      >
        &rsaquo;
      </button>

      <button
        class="pagination-btn"
        [disabled]="currentPage === totalPages"
        (click)="onPageChange(totalPages)"
      >
        &raquo;
      </button>
    </div>
  </div>
</div>
EOF

cat > src/app/shared/components/data-table/data-table.component.scss << 'EOF'
.data-table-wrapper {
  width: 100%;
}

.table-responsive {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
  border-spacing: 0;
  background-color: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.data-table thead th {
  background-color: #f9fafb;
  color: #374151;
  font-weight: 600;
  padding: 0.75rem 1rem;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
  font-size: 0.875rem;
  white-space: nowrap;
}

.data-table tbody td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #e5e7eb;
  color: #1f2937;
  font-size: 0.875rem;
}

.data-table tbody tr:last-child td {
  border-bottom: none;
}

.data-table tbody tr {
  transition: background-color 0.2s;
  cursor: pointer;
}

.data-table tbody tr:hover {
  background-color: #f9fafb;
}

.data-table tbody tr.selected {
  background-color: #ebf5ff;
}

.select-column {
  width: 40px;
  text-align: center;
}

.loading-cell, .empty-cell {
  text-align: center;
  padding: 2rem !important;
  color: #6b7280 !important;
}

.loading-indicator {
  display: inline-block;
  position: relative;
  padding-left: 24px;
}

.loading-indicator::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 16px;
  height: 16px;
  border: 2px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: translateY(-50%) rotate(360deg); }
}

.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background-color: #f9fafb;
  border-top: 1px solid #e5e7eb;
  font-size: 0.875rem;
}

.pagination-info {
  color: #6b7280;
}

.pagination-controls {
  display: flex;
  gap: 0.25rem;
}

.pagination-btn {
  padding: 0.375rem 0.625rem;
  border: 1px solid #e5e7eb;
  background-color: white;
  color: #4b5563;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.pagination-btn:hover:not(:disabled) {
  background-color: #f3f4f6;
}

.pagination-btn.active {
  background-color: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.sortable {
  cursor: pointer;
  position: relative;
  padding-right: 1.5rem !important;
}

.sort-icon {
  position: absolute;
  right: 0.5rem;
  top: 50%;
  transform: translateY(-50%);
  width: 0.5rem;
  height: 1rem;
}

.sort-icon::before,
.sort-icon::after {
  content: '';
  position: absolute;
  right: 0;
  width: 0;
  height: 0;
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
}

.sort-icon::before {
  top: 0;
  border-bottom: 4px solid #d1d5db;
}

.sort-icon::after {
  bottom: 0;
  border-top: 4px solid #d1d5db;
}

.sorted.asc .sort-icon::before {
  border-bottom-color: #3b82f6;
}

.sorted.desc .sort-icon::after {
  border-top-color: #3b82f6;
}

@media (max-width: 768px) {
  .pagination {
    flex-direction: column;
    gap: 0.5rem;
    align-items: flex-start;
  }
}
EOF

# Pagination Component
mkdir -p src/app/shared/components/pagination

cat > src/app/shared/components/pagination/pagination.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-pagination',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './pagination.component.html',
  styleUrl: './pagination.component.scss'
})
export class PaginationComponent {
  @Input() currentPage = 1;
  @Input() totalItems = 0;
  @Input() pageSize = 10;
  @Input() showInfo = true;

  @Output() pageChange = new EventEmitter<number>();

  onPageChange(page: number): void {
    if (page < 1 || page > this.totalPages) return;
    this.pageChange.emit(page);
  }

  get totalPages(): number {
    return Math.ceil(this.totalItems / this.pageSize);
  }

  get pages(): number[] {
    const pageCount = this.totalPages;
    const maxPages = 5;
    const halfMaxPages = Math.floor(maxPages / 2);

    let startPage = Math.max(this.currentPage - halfMaxPages, 1);
    let endPage = startPage + maxPages - 1;

    if (endPage > pageCount) {
      endPage = pageCount;
      startPage = Math.max(endPage - maxPages + 1, 1);
    }

    return Array.from({ length: endPage - startPage + 1 }, (_, i) => startPage + i);
  }

  get startItem(): number {
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get endItem(): number {
    return Math.min(this.currentPage * this.pageSize, this.totalItems);
  }
}
EOF

cat > src/app/shared/components/pagination/pagination.component.html << 'EOF'
<div class="pagination-container">
  <div class="pagination-info" *ngIf="showInfo && totalItems > 0">
    Showing {{ startItem }} to {{ endItem }} of {{ totalItems }} items
  </div>

  <div class="pagination-controls">
    <button
      class="pagination-btn"
      [disabled]="currentPage === 1"
      (click)="onPageChange(1)"
    >
      &laquo;
    </button>

    <button
      class="pagination-btn"
      [disabled]="currentPage === 1"
      (click)="onPageChange(currentPage - 1)"
    >
      &lsaquo;
    </button>

    <button
      *ngFor="let page of pages"
      class="pagination-btn"
      [class.active]="page === currentPage"
      (click)="onPageChange(page)"
    >
      {{ page }}
    </button>

    <button
      class="pagination-btn"
      [disabled]="currentPage === totalPages"
      (click)="onPageChange(currentPage + 1)"
    >
      &rsaquo;
    </button>

    <button
      class="pagination-btn"
      [disabled]="currentPage === totalPages"
      (click)="onPageChange(totalPages)"
    >
      &raquo;
    </button>
  </div>
</div>
EOF

cat > src/app/shared/components/pagination/pagination.component.scss << 'EOF'
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  font-size: 0.875rem;
}

.pagination-info {
  color: #6b7280;
}

.pagination-controls {
  display: flex;
  gap: 0.25rem;
}

.pagination-btn {
  padding: 0.375rem 0.625rem;
  border: 1px solid #e5e7eb;
  background-color: white;
  color: #4b5563;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.pagination-btn:hover:not(:disabled) {
  background-color: #f3f4f6;
}

.pagination-btn.active {
  background-color: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .pagination-container {
    flex-direction: column;
    gap: 0.5rem;
    align-items: flex-start;
  }
}
EOF

# Alert Component
mkdir -p src/app/shared/components/alert

cat > src/app/shared/components/alert/alert.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export type AlertType = 'success' | 'error' | 'warning' | 'info';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './alert.component.html',
  styleUrl: './alert.component.scss'
})
export class AlertComponent {
  @Input() type: AlertType = 'info';
  @Input() message = '';
  @Input() dismissible = true;
  @Input() icon = true;
  @Input() timeout = 0; // 0 means no auto-dismiss

  @Output() dismissed = new EventEmitter<void>();

  visible = true;
  timeoutId: any = null;

  ngOnInit(): void {
    if (this.timeout > 0) {
      this.timeoutId = setTimeout(() => {
        this.dismiss();
      }, this.timeout);
    }
  }

  ngOnDestroy(): void {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }
  }

  dismiss(): void {
    this.visible = false;
    this.dismissed.emit();
  }
}
EOF

cat > src/app/shared/components/alert/alert.component.html << 'EOF'
<div
  *ngIf="visible"
  class="alert"
  [ngClass]="'alert-' + type"
>
  <div class="alert-content">
    <span class="alert-icon" *ngIf="icon"></span>
    <span class="alert-message">{{ message }}</span>
  </div>

  <button
    *ngIf="dismissible"
    class="alert-close"
    (click)="dismiss()"
    aria-label="Close"
  >
    &times;
  </button>
</div>
EOF
#!/bin/bash

# --- CONTINUING ALERT COMPONENT STYLES ---
# Completing the alert.component.scss file

cat >> src/app/shared/components/alert/alert.component.scss << 'EOF'
.alert-success {
  background-color: #ecfdf5;
  color: #047857;
  border-left: 4px solid #10b981;
}

.alert-success .alert-icon {
  background-image: url('/assets/icons/check-circle.svg');
}

.alert-error {
  background-color: #fef2f2;
  color: #b91c1c;
  border-left: 4px solid #ef4444;
}

.alert-error .alert-icon {
  background-image: url('/assets/icons/x-circle.svg');
}

.alert-warning {
  background-color: #fffbeb;
  color: #b45309;
  border-left: 4px solid #f59e0b;
}

.alert-warning .alert-icon {
  background-image: url('/assets/icons/exclamation-circle.svg');
}

.alert-info {
  background-color: #eff6ff;
  color: #1e40af;
  border-left: 4px solid #3b82f6;
}

.alert-info .alert-icon {
  background-image: url('/assets/icons/information-circle.svg');
}

.alert-message {
  font-size: 0.875rem;
}

.alert-close {
  background: none;
  border: none;
  font-size: 1.25rem;
  line-height: 1;
  cursor: pointer;
  opacity: 0.5;
  padding: 0;
  color: currentColor;
  margin-left: 0.75rem;
}

.alert-close:hover {
  opacity: 0.75;
}
EOF

# Modal Component
mkdir -p src/app/shared/components/modal

cat > src/app/shared/components/modal/modal.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter, TemplateRef, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-modal',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './modal.component.html',
  styleUrl: './modal.component.scss'
})
export class ModalComponent {
  @Input() title = '';
  @Input() size: 'sm' | 'md' | 'lg' | 'xl' = 'md';
  @Input() closable = true;
  @Input() contentTemplate: TemplateRef<any> | null = null;
  @Input() footerTemplate: TemplateRef<any> | null = null;

  @Output() closed = new EventEmitter<void>();

  private _visible = false;

  @Input()
  set visible(value: boolean) {
    this._visible = value;
    if (value) {
      document.body.classList.add('modal-open');
    } else {
      document.body.classList.remove('modal-open');
    }
  }

  get visible(): boolean {
    return this._visible;
  }

  constructor(private elementRef: ElementRef) {}

  close(): void {
    if (this.closable) {
      this.visible = false;
      this.closed.emit();
    }
  }

  onBackdropClick(event: MouseEvent): void {
    if (event.target === this.elementRef.nativeElement.querySelector('.modal-backdrop')) {
      this.close();
    }
  }
}
EOF

cat > src/app/shared/components/modal/modal.component.html << 'EOF'
<div
  class="modal-backdrop"
  [class.show]="visible"
  (click)="onBackdropClick($event)"
>
  <div class="modal-dialog" [ngClass]="'modal-' + size">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">{{ title }}</h5>
        <button
          *ngIf="closable"
          class="modal-close"
          (click)="close()"
          aria-label="Close"
        >
          &times;
        </button>
      </div>

      <div class="modal-body">
        <ng-container *ngIf="contentTemplate">
          <ng-container *ngTemplateOutlet="contentTemplate"></ng-container>
        </ng-container>
      </div>

      <div class="modal-footer" *ngIf="footerTemplate">
        <ng-container *ngTemplateOutlet="footerTemplate"></ng-container>
      </div>
    </div>
  </div>
</div>
EOF

cat > src/app/shared/components/modal/modal.component.scss << 'EOF'
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s;
}

.modal-backdrop.show {
  opacity: 1;
  pointer-events: auto;
}

.modal-dialog {
  width: 100%;
  max-width: 500px;
  background-color: white;
  border-radius: 6px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  margin: 1.75rem;
  transform: translateY(-20px);
  transition: transform 0.3s;
}

.modal-backdrop.show .modal-dialog {
  transform: translateY(0);
}

.modal-sm {
  max-width: 300px;
}

.modal-md {
  max-width: 500px;
}

.modal-lg {
  max-width: 800px;
}

.modal-xl {
  max-width: 1140px;
}

.modal-content {
  display: flex;
  flex-direction: column;
  width: 100%;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  opacity: 0.5;
  padding: 0;
  color: #6b7280;
}

.modal-close:hover {
  opacity: 0.75;
}

.modal-body {
  padding: 1rem;
  overflow-y: auto;
  max-height: calc(100vh - 200px);
}

.modal-footer {
  padding: 1rem;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

@media (max-width: 768px) {
  .modal-dialog {
    margin: 1rem;
    max-width: calc(100% - 2rem);
  }
}

:host-context(body.modal-open) {
  overflow: hidden;
}
EOF

# Loading Spinner Component
mkdir -p src/app/shared/components/loading-spinner

cat > src/app/shared/components/loading-spinner/loading-spinner.component.ts << 'EOF'
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-loading-spinner',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './loading-spinner.component.html',
  styleUrl: './loading-spinner.component.scss'
})
export class LoadingSpinnerComponent {
  @Input() size: 'sm' | 'md' | 'lg' = 'md';
  @Input() color = '#3b82f6';
  @Input() fullscreen = false;
  @Input() overlay = false;
  @Input() text = '';
}
EOF

cat > src/app/shared/components/loading-spinner/loading-spinner.component.html << 'EOF'
<div
  class="spinner-container"
  [class.fullscreen]="fullscreen"
  [class.overlay]="overlay"
>
  <div class="spinner-wrapper">
    <div
      class="spinner"
      [ngClass]="'spinner-' + size"
      [style.border-top-color]="color"
    ></div>

    <div class="spinner-text" *ngIf="text">
      {{ text }}
    </div>
  </div>
</div>
EOF

cat > src/app/shared/components/loading-spinner/loading-spinner.component.scss << 'EOF'
.spinner-container {
  display: flex;
  align-items: center;
  justify-content: center;
}

.spinner-container.fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1060;
  background-color: rgba(255, 255, 255, 0.8);
}

.spinner-container.overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(255, 255, 255, 0.8);
}

.spinner-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.spinner {
  border-style: solid;
  border-color: #e5e7eb;
  border-radius: 50%;
  border-top-color: #3b82f6;
  animation: spin 1s linear infinite;
}

.spinner-sm {
  width: 1.5rem;
  height: 1.5rem;
  border-width: 2px;
}

.spinner-md {
  width: 2.5rem;
  height: 2.5rem;
  border-width: 3px;
}

.spinner-lg {
  width: 3.5rem;
  height: 3.5rem;
  border-width: 4px;
}

.spinner-text {
  margin-top: 1rem;
  font-size: 0.875rem;
  color: #6b7280;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
EOF

# Search Bar Component
mkdir -p src/app/shared/components/search-bar

cat > src/app/shared/components/search-bar/search-bar.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-search-bar',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './search-bar.component.html',
  styleUrl: './search-bar.component.scss'
})
export class SearchBarComponent {
  @Input() placeholder = 'Search...';
  @Input() value = '';
  @Input() debounceTime = 300;
  @Input() minLength = 1;

  @Output() search = new EventEmitter<string>();
  @Output() valueChange = new EventEmitter<string>();
  @Output() clear = new EventEmitter<void>();

  private debounceTimer: any = null;

  onInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.valueChange.emit(value);

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer);
    }

    if (value.length >= this.minLength) {
      this.debounceTimer = setTimeout(() => {
        this.search.emit(value);
      }, this.debounceTime);
    }
  }

  onClear(): void {
    this.value = '';
    this.valueChange.emit('');
    this.clear.emit();
  }
}
EOF

cat > src/app/shared/components/search-bar/search-bar.component.html << 'EOF'
<div class="search-bar">
  <div class="search-icon"></div>

  <input
    type="text"
    class="search-input"
    [placeholder]="placeholder"
    [(ngModel)]="value"
    (input)="onInput($event)"
  >

  <button
    *ngIf="value"
    class="clear-button"
    (click)="onClear()"
    aria-label="Clear search"
  >
    &times;
  </button>
</div>
EOF

cat > src/app/shared/components/search-bar/search-bar.component.scss << 'EOF'
.search-bar {
  display: flex;
  align-items: center;
  background-color: white;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  padding: 0.5rem;
  transition: border-color 0.2s;
  position: relative;
}

.search-bar:focus-within {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-icon {
  width: 20px;
  height: 20px;
  background-image: url('/assets/icons/search.svg');
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
  opacity: 0.5;
  margin-right: 0.5rem;
}

.search-input {
  flex: 1;
  border: none;
  outline: none;
  font-size: 0.875rem;
  background: transparent;
}

.clear-button {
  background: none;
  border: none;
  color: #6b7280;
  font-size: 1.25rem;
  line-height: 1;
  cursor: pointer;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  opacity: 0.5;
  transition: opacity 0.2s;
}

.clear-button:hover {
  opacity: 0.75;
}
EOF

# File Upload Component
mkdir -p src/app/shared/components/file-upload

cat > src/app/shared/components/file-upload/file-upload.component.ts << 'EOF'
import { Component, Input, Output, EventEmitter, ElementRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-file-upload',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './file-upload.component.html',
  styleUrl: './file-upload.component.scss'
})
export class FileUploadComponent {
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  @Input() multiple = false;
  @Input() accept = '';
  @Input() maxSize = 5 * 1024 * 1024; // 5MB default
  @Input() label = 'Choose file';
  @Input() placeholder = 'No file chosen';
  @Input() showPreview = true;
  @Input() dragDrop = true;

  @Output() filesSelected = new EventEmitter<File[]>();
  @Output() fileError = new EventEmitter<string>();

  selectedFiles: File[] = [];
  isDragging = false;
  previews: string[] = [];

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.processFiles(input.files);
    }
  }

  onDragOver(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = true;
  }

  onDragLeave(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = false;
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = false;

    if (event.dataTransfer?.files) {
      this.processFiles(event.dataTransfer.files);
    }
  }

  triggerFileInput(): void {
    this.fileInput.nativeElement.click();
  }

  removeFile(index: number): void {
    this.selectedFiles.splice(index, 1);
    this.previews.splice(index, 1);
    this.filesSelected.emit(this.selectedFiles);
  }

  clearFiles(): void {
    this.selectedFiles = [];
    this.previews = [];
    this.fileInput.nativeElement.value = '';
    this.filesSelected.emit(this.selectedFiles);
  }

  private processFiles(files: FileList): void {
    const validFiles: File[] = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];

      // Check file size
      if (file.size > this.maxSize) {
        this.fileError.emit(`File ${file.name} exceeds maximum size of ${this.formatSize(this.maxSize)}`);
        continue;
      }

      // Check file type if accept is specified
      if (this.accept && !this.isFileTypeValid(file)) {
        this.fileError.emit(`File ${file.name} is not a valid file type`);
        continue;
      }

      validFiles.push(file);

      // Generate preview for image files
      if (this.showPreview && file.type.startsWith('image/')) {
        this.createImagePreview(file);
      }
    }

    if (!this.multiple) {
      this.selectedFiles = validFiles.slice(0, 1);
      this.previews = this.previews.slice(0, 1);
    } else {
      this.selectedFiles = [...this.selectedFiles, ...validFiles];
    }

    this.filesSelected.emit(this.selectedFiles);
  }

  private isFileTypeValid(file: File): boolean {
    const acceptedTypes = this.accept.split(',').map(type => type.trim());
    const fileType = file.type;

    return acceptedTypes.some(type => {
      if (type.startsWith('.')) {
        // Check file extension
        return file.name.toLowerCase().endsWith(type.toLowerCase());
      } else if (type.endsWith('/*')) {
        // Check MIME type group (e.g., "image/*")
        const group = type.substring(0, type.length - 2);
        return fileType.startsWith(group);
      } else {
        // Check exact MIME type
        return fileType === type;
      }
    });
  }

  private createImagePreview(file: File): void {
    const reader = new FileReader();
    reader.onload = (e: any) => {
      this.previews.push(e.target.result);
    };
    reader.readAsDataURL(file);
  }

  private formatSize(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
}
EOF

cat > src/app/shared/components/file-upload/file-upload.component.html << 'EOF'
<div class="file-upload">
  <input
    #fileInput
    type="file"
    class="file-input"
    [multiple]="multiple"
    [accept]="accept"
    (change)="onFileSelected($event)"
  >

  <div
    class="upload-area"
    [class.is-dragging]="isDragging"
    [class.has-files]="selectedFiles.length > 0"
    [class.drag-drop]="dragDrop"
    (click)="triggerFileInput()"
    (dragover)="dragDrop && onDragOver($event)"
    (dragleave)="dragDrop && onDragLeave($event)"
    (drop)="dragDrop && onDrop($event)"
  >
    <div class="upload-icon"></div>

    <div class="upload-content">
      <div class="upload-label">{{ label }}</div>

      <div class="upload-info" *ngIf="selectedFiles.length === 0">
        {{ placeholder }}
      </div>

      <div class="upload-info" *ngIf="selectedFiles.length > 0">
        {{ selectedFiles.length }} {{ selectedFiles.length === 1 ? 'file' : 'files' }} selected
      </div>

      <div class="drag-instruction" *ngIf="dragDrop">
        or drag and drop here
      </div>
    </div>
  </div>

  <div class="file-list" *ngIf="selectedFiles.length > 0">
    <div class="file-list-header">
      <div class="file-count">
        {{ selectedFiles.length }} {{ selectedFiles.length === 1 ? 'file' : 'files' }} selected
      </div>

      <button class="clear-all-btn" (click)="clearFiles()">
        Clear all
      </button>
    </div>

    <div class="file-items">
      <div
        *ngFor="let file of selectedFiles; let i = index"
        class="file-item"
      >
        <div class="file-preview" *ngIf="showPreview && i < previews.length">
          <img [src]="previews[i]" alt="Preview">
        </div>

        <div class="file-icon" *ngIf="!showPreview || i >= previews.length"></div>

        <div class="file-info">
          <div class="file-name">{{ file.name }}</div>
          <div class="file-size">{{ file.size | number }} bytes</div>
        </div>

        <button class="remove-file-btn" (click)="removeFile(i)">
          &times;
        </button>
      </div>
    </div>
  </div>
</div>
EOF

cat > src/app/shared/components/file-upload/file-upload.component.scss << 'EOF'
.file-upload {
  width: 100%;
}

.file-input {
  display: none;
}

.upload-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  border: 2px dashed #e5e7eb;
  border-radius: 6px;
  background-color: #f9fafb;
  text-align: center;
  cursor: pointer;
  transition: border-color 0.2s, background-color 0.2s;
}

.upload-area:hover {
  border-color: #d1d5db;
  background-color: #f3f4f6;
}

.upload-area.is-dragging {
  border-color: #3b82f6;
  background-color: #eff6ff;
}

.upload-area.has-files {
  border-color: #10b981;
  background-color: #ecfdf5;
}

.upload-icon {
  width: 48px;
  height: 48px;
  margin-bottom: 1rem;
  background-image: url('/assets/icons/upload.svg');
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
}

.upload-label {
  font-weight: 500;
  margin-bottom: 0.5rem;
  font-size: 1rem;
  color: #374151;
}

.upload-info {
  color: #6b7280;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.drag-instruction {
  color: #6b7280;
  font-size: 0.75rem;
  font-style: italic;
}

.file-list {
  margin-top: 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  overflow: hidden;
}

.file-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background-color: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}

.file-count {
  font-size: 0.875rem;
  color: #374151;
}

.clear-all-btn {
  border: none;
  background: none;
  color: #ef4444;
  font-size: 0.75rem;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
}

.clear-all-btn:hover {
  background-color: #fee2e2;
}

.file-items {
  max-height: 300px;
  overflow-y: auto;
}

.file-item {
  display: flex;
  align-items: center;
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #e5e7eb;
}

.file-item:last-child {
  border-bottom: none;
}

.file-preview {
  width: 40px;
  height: 40px;
  margin-right: 0.75rem;
  border-radius: 4px;
  overflow: hidden;
  border: 1px solid #e5e7eb;
}

.file-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.file-icon {
  width: 40px;
  height: 40px;
  margin-right: 0.75rem;
  background-image: url('/assets/icons/file.svg');
  background-size: 24px;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.6;
}

.file-info {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-size: 0.875rem;
  color: #374151;
  margin-bottom: 0.25rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-size {
  font-size: 0.75rem;
  color: #6b7280;
}

.remove-file-btn {
  background: none;
  border: none;
  color: #6b7280;
  font-size: 1.25rem;
  line-height: 1;
  padding: 0;
  cursor: pointer;
  margin-left: 0.5rem;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.5;
  transition: opacity 0.2s;
}

.remove-file-btn:hover {
  opacity: 0.75;
}
EOF

# --- ENVIRONMENT FILES ---
echo -e "${BLUE}Creating environment files...${NC}"

cat > src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api'
};
EOF

cat > src/environments/environment.prod.ts << 'EOF'
export const environment = {
  production: true,
  apiUrl: '/api'
};
EOF

# --- CUSTOM DIRECTIVES ---
echo -e "${BLUE}Creating directives...${NC}"

cat > src/app/shared/directives/highlight.directive.ts << 'EOF'
import { Directive, ElementRef, Input, OnInit, Renderer2, HostListener } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true
})
export class HighlightDirective implements OnInit {
  @Input() appHighlight = '#eff6ff';
  @Input() highlightColor = '#3b82f6';

  private defaultColor: string | null = null;

  constructor(private el: ElementRef, private renderer: Renderer2) {}

  ngOnInit(): void {
    this.defaultColor = this.el.nativeElement.style.backgroundColor || null;
  }

  @HostListener('mouseenter') onMouseEnter(): void {
    this.renderer.setStyle(this.el.nativeElement, 'backgroundColor', this.appHighlight);
    this.renderer.setStyle(this.el.nativeElement, 'color', this.highlightColor);
    this.renderer.setStyle(this.el.nativeElement, 'transition', 'background-color 0.2s, color 0.2s');
  }

  @HostListener('mouseleave') onMouseLeave(): void {
    this.renderer.setStyle(this.el.nativeElement, 'backgroundColor', this.defaultColor);
    this.renderer.removeStyle(this.el.nativeElement, 'color');
  }
}
EOF

cat > src/app/shared/directives/click-outside.directive.ts << 'EOF'
import { Directive, ElementRef, EventEmitter, HostListener, Output } from '@angular/core';

@Directive({
  selector: '[appClickOutside]',
  standalone: true
})
export class ClickOutsideDirective {
  @Output() appClickOutside = new EventEmitter<void>();

  constructor(private elementRef: ElementRef) {}

  @HostListener('document:click', ['$event.target'])
  onClick(target: any): void {
    const clickedInside = this.elementRef.nativeElement.contains(target);
    if (!clickedInside) {
      this.appClickOutside.emit();
    }
  }
}
EOF

# --- CUSTOM PIPES ---
echo -e "${BLUE}Creating pipes...${NC}"
#!/bin/bash

# --- CUSTOM PIPES ---
echo -e "${BLUE}Creating pipes...${NC}"

cat > src/app/shared/pipes/filter.pipe.ts << 'EOF'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filter',
  standalone: true
})
export class FilterPipe implements PipeTransform {
  transform<T>(
    items: T[],
    searchText: string,
    properties: (keyof T)[] | ((item: T) => any)[] = []
  ): T[] {
    if (!items || !searchText || !properties.length) {
      return items;
    }

    searchText = searchText.toLowerCase();

    return items.filter(item => {
      return properties.some(property => {
        let value: any;

        if (typeof property === 'function') {
          value = property(item);
        } else {
          value = item[property];

          // Handle nested properties
          if (typeof property === 'string' && property.includes('.')) {
            const props = property.split('.');
            value = props.reduce((obj, prop) => obj?.[prop], item);
          }
        }

        if (value === null || value === undefined) {
          return false;
        }

        // Convert value to string for comparison
        return String(value).toLowerCase().includes(searchText);
      });
    });
  }
}
EOF

cat > src/app/shared/pipes/format-date.pipe.ts << 'EOF'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'formatDate',
  standalone: true
})
export class FormatDatePipe implements PipeTransform {
  transform(value: Date | string, format: string = 'medium'): string {
    if (!value) {
      return '';
    }

    const date = typeof value === 'string' ? new Date(value) : value;

    if (isNaN(date.getTime())) {
      return '';
    }

    switch (format) {
      case 'short':
        return date.toLocaleDateString();
      case 'medium':
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      case 'long':
        return date.toLocaleDateString(undefined, {
          weekday: 'long',
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        });
      case 'date':
        return date.toLocaleDateString();
      case 'time':
        return date.toLocaleTimeString();
      case 'relative':
        return this.getRelativeTime(date);
      default:
        return date.toLocaleString();
    }
  }

  private getRelativeTime(date: Date): string {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSec = Math.round(diffMs / 1000);

    if (diffSec < 60) {
      return diffSec + ' second' + (diffSec === 1 ? '' : 's') + ' ago';
    }

    const diffMin = Math.round(diffSec / 60);
    if (diffMin < 60) {
      return diffMin + ' minute' + (diffMin === 1 ? '' : 's') + ' ago';
    }

    const diffHour = Math.round(diffMin / 60);
    if (diffHour < 24) {
      return diffHour + ' hour' + (diffHour === 1 ? '' : 's') + ' ago';
    }

    const diffDay = Math.round(diffHour / 24);
    if (diffDay < 30) {
      return diffDay + ' day' + (diffDay === 1 ? '' : 's') + ' ago';
    }

    const diffMonth = Math.round(diffDay / 30);
    if (diffMonth < 12) {
      return diffMonth + ' month' + (diffMonth === 1 ? '' : 's') + ' ago';
    }

    const diffYear = Math.round(diffMonth / 12);
    return diffYear + ' year' + (diffYear === 1 ? '' : 's') + ' ago';
  }
}
EOF

cat > src/app/shared/pipes/truncate.pipe.ts << 'EOF'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'truncate',
  standalone: true
})
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit: number = 100, completeWords: boolean = false, ellipsis: string = '...'): string {
    if (!value) {
      return '';
    }

    if (value.length <= limit) {
      return value;
    }

    if (completeWords) {
      limit = value.substring(0, limit).lastIndexOf(' ');
    }

    return value.substring(0, limit) + ellipsis;
  }
}
EOF

# --- VALIDATORS ---
echo -e "${BLUE}Creating validators...${NC}"

cat > src/app/shared/validators/password.validator.ts << 'EOF'
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
EOF

cat > src/app/shared/validators/date.validator.ts << 'EOF'
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function dateRangeValidator(startDateControlName: string, endDateControlName: string): ValidatorFn {
  return (formGroup: AbstractControl): ValidationErrors | null => {
    const startDateControl = formGroup.get(startDateControlName);
    const endDateControl = formGroup.get(endDateControlName);

    if (!startDateControl || !endDateControl) {
      return null;
    }

    const startDate = startDateControl.value;
    const endDate = endDateControl.value;

    if (!startDate || !endDate) {
      return null;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start > end) {
      return { dateRange: { startDate, endDate } };
    }

    return null;
  };
}

export function minDateValidator(minDate: Date | string | (() => Date)): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const controlDate = new Date(control.value);

    if (isNaN(controlDate.getTime())) {
      return { invalidDate: { value: control.value } };
    }

    const compareDate = typeof minDate === 'function'
      ? minDate()
      : new Date(minDate);

    if (controlDate < compareDate) {
      return { minDate: { required: compareDate, actual: controlDate } };
    }

    return null;
  };
}

export function maxDateValidator(maxDate: Date | string | (() => Date)): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const controlDate = new Date(control.value);

    if (isNaN(controlDate.getTime())) {
      return { invalidDate: { value: control.value } };
    }

    const compareDate = typeof maxDate === 'function'
      ? maxDate()
      : new Date(maxDate);

    if (controlDate > compareDate) {
      return { maxDate: { required: compareDate, actual: controlDate } };
    }

    return null;
  };
}
EOF

# --- GLOBAL STYLES ---
echo -e "${BLUE}Creating global styles...${NC}"

mkdir -p src/styles

cat > src/styles/variables.scss << 'EOF'
// Colors
$primary: #3b82f6;
$primary-light: #eff6ff;
$primary-dark: #1d4ed8;

$secondary: #6b7280;
$secondary-light: #f3f4f6;
$secondary-dark: #4b5563;

$success: #10b981;
$success-light: #ecfdf5;
$success-dark: #047857;

$danger: #ef4444;
$danger-light: #fee2e2;
$danger-dark: #b91c1c;

$warning: #f59e0b;
$warning-light: #fffbeb;
$warning-dark: #b45309;

$info: #3b82f6;
$info-light: #eff6ff;
$info-dark: #1e40af;

$light: #f9fafb;
$dark: #1f2937;

// Typography
$font-family-base: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
$font-size-base: 1rem;
$font-size-sm: 0.875rem;
$font-size-lg: 1.125rem;
$font-weight-normal: 400;
$font-weight-medium: 500;
$font-weight-bold: 600;
$line-height-base: 1.5;

// Spacing
$spacer: 1rem;
$spacers: (
  0: 0,
  1: $spacer * 0.25,
  2: $spacer * 0.5,
  3: $spacer,
  4: $spacer * 1.5,
  5: $spacer * 3,
  6: $spacer * 4,
  7: $spacer * 5,
  8: $spacer * 6,
);

// Border radius
$border-radius-sm: 0.25rem;
$border-radius: 0.375rem;
$border-radius-lg: 0.5rem;
$border-radius-xl: 0.75rem;
$border-radius-2xl: 1rem;

// Shadows
$shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
$shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
$shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
$shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
$shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);

// Breakpoints
$breakpoints: (
  xs: 0,
  sm: 576px,
  md: 768px,
  lg: 992px,
  xl: 1200px,
  xxl: 1400px
);

// Grid
$grid-columns: 12;
$grid-gutter-width: 1.5rem;
$container-padding-x: 1rem;

// Z-index
$z-index-dropdown: 1000;
$z-index-sticky: 1020;
$z-index-fixed: 1030;
$z-index-modal-backdrop: 1040;
$z-index-modal: 1050;
$z-index-popover: 1060;
$z-index-tooltip: 1070;
EOF

cat > src/styles/mixins.scss << 'EOF'
@import 'variables';

// Breakpoint mixins
@mixin media-breakpoint-up($breakpoint) {
  $min: map-get($breakpoints, $breakpoint);
  @if $min {
    @media (min-width: $min) {
      @content;
    }
  } @else {
    @content;
  }
}

@mixin media-breakpoint-down($breakpoint) {
  $max: map-get($breakpoints, $breakpoint);
  @if $max {
    @media (max-width: $max - 0.02) {
      @content;
    }
  } @else {
    @content;
  }
}

// Typography mixins
@mixin font-size($size, $weight: null, $line-height: null) {
  font-size: $size;
  @if $weight {
    font-weight: $weight;
  }
  @if $line-height {
    line-height: $line-height;
  }
}

@mixin truncate($lines: 1) {
  @if $lines == 1 {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  } @else {
    display: -webkit-box;
    -webkit-line-clamp: $lines;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
}

// Flex mixins
@mixin flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

@mixin flex-between {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

@mixin flex-column {
  display: flex;
  flex-direction: column;
}

// Shadow mixins
@mixin shadow($level: 'md') {
  @if $level == 'sm' {
    box-shadow: $shadow-sm;
  } @else if $level == 'md' {
    box-shadow: $shadow-md;
  } @else if $level == 'lg' {
    box-shadow: $shadow-lg;
  } @else if $level == 'xl' {
    box-shadow: $shadow-xl;
  } @else {
    box-shadow: $shadow;
  }
}

// Card mixin
@mixin card($padding: $spacer, $border-radius: $border-radius, $shadow: true) {
  background-color: white;
  border-radius: $border-radius;
  padding: $padding;
  @if $shadow {
    @include shadow;
  } @else {
    border: 1px solid #e5e7eb;
  }
}

// Button mixins
@mixin button-base {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: $font-weight-medium;
  text-align: center;
  vertical-align: middle;
  cursor: pointer;
  user-select: none;
  border: 1px solid transparent;
  padding: 0.5rem 1rem;
  font-size: $font-size-sm;
  border-radius: $border-radius;
  transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out, border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;

  &:disabled {
    opacity: 0.65;
    pointer-events: none;
  }
}

@mixin button-variant($background, $border, $hover-background, $hover-border, $active-background, $active-border) {
  background-color: $background;
  border-color: $border;

  &:hover {
    background-color: $hover-background;
    border-color: $hover-border;
  }

  &:focus, &:active {
    background-color: $active-background;
    border-color: $active-border;
  }
}

@mixin button-outline-variant($color, $color-hover) {
  color: $color;
  border-color: $color;
  background-color: transparent;

  &:hover {
    color: $color-hover;
    background-color: $color;
    border-color: $color;
  }
}

// Form control mixin
@mixin form-control {
  display: block;
  width: 100%;
  padding: 0.5rem 0.75rem;
  font-size: $font-size-sm;
  font-weight: $font-weight-normal;
  line-height: 1.5;
  color: $dark;
  background-color: white;
  border: 1px solid #d1d5db;
  border-radius: $border-radius;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;

  &:focus {
    border-color: $primary;
    outline: 0;
    box-shadow: 0 0 0 0.2rem rgba($primary, 0.25);
  }

  &:disabled {
    background-color: #f3f4f6;
    opacity: 1;
  }
}
EOF

cat > src/styles/global.scss << 'EOF'
@import 'variables';
@import 'mixins';

// Reset and base styles
*, *::before, *::after {
  box-sizing: border-box;
}

html, body {
  margin: 0;
  padding: 0;
  height: 100%;
}

body {
  font-family: $font-family-base;
  font-size: $font-size-base;
  font-weight: $font-weight-normal;
  line-height: $line-height-base;
  color: $dark;
  background-color: #f5f7fa;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

// Typography
h1, h2, h3, h4, h5, h6 {
  margin-top: 0;
  margin-bottom: 0.5rem;
  font-weight: $font-weight-bold;
  line-height: 1.2;
}

h1 { font-size: 2rem; }
h2 { font-size: 1.75rem; }
h3 { font-size: 1.5rem; }
h4 { font-size: 1.25rem; }
h5 { font-size: 1.125rem; }
h6 { font-size: 1rem; }

p {
  margin-top: 0;
  margin-bottom: 1rem;
}

a {
  color: $primary;
  text-decoration: none;

  &:hover {
    color: $primary-dark;
    text-decoration: underline;
  }
}

// Buttons
.btn {
  @include button-base;
}

.btn-primary {
  @include button-variant($primary, $primary, $primary-dark, $primary-dark, $primary-dark, $primary-dark);
  color: white;
}

.btn-secondary {
  @include button-variant($secondary, $secondary, $secondary-dark, $secondary-dark, $secondary-dark, $secondary-dark);
  color: white;
}

.btn-success {
  @include button-variant($success, $success, $success-dark, $success-dark, $success-dark, $success-dark);
  color: white;
}

.btn-danger {
  @include button-variant($danger, $danger, $danger-dark, $danger-dark, $danger-dark, $danger-dark);
  color: white;
}

.btn-warning {
  @include button-variant($warning, $warning, $warning-dark, $warning-dark, $warning-dark, $warning-dark);
  color: white;
}

.btn-info {
  @include button-variant($info, $info, $info-dark, $info-dark, $info-dark, $info-dark);
  color: white;
}

.btn-outline-primary {
  @include button-outline-variant($primary, white);
}

.btn-outline-secondary {
  @include button-outline-variant($secondary, white);
}

.btn-outline-success {
  @include button-outline-variant($success, white);
}

.btn-outline-danger {
  @include button-outline-variant($danger, white);
}

.btn-outline-warning {
  @include button-outline-variant($warning, white);
}

.btn-outline-info {
  @include button-outline-variant($info, white);
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.75rem;
  border-radius: $border-radius-sm;
}

.btn-lg {
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  border-radius: $border-radius-lg;
}

// Form controls
.form-control {
  @include form-control;
}

.form-label {
  display: inline-block;
  margin-bottom: 0.5rem;
  font-weight: $font-weight-medium;
}

.form-group {
  margin-bottom: 1rem;
}

.form-text {
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: $secondary;
}

.invalid-feedback {
  display: block;
  width: 100%;
  margin-top: 0.25rem;
  font-size: 0.75rem;
  color: $danger;
}

// Utility classes
.text-center { text-align: center; }
.text-right { text-align: right; }
.text-left { text-align: left; }

.text-primary { color: $primary; }
.text-secondary { color: $secondary; }
.text-success { color: $success; }
.text-danger { color: $danger; }
.text-warning { color: $warning; }
.text-info { color: $info; }
.text-muted { color: $secondary; }

.bg-primary { background-color: $primary; }
.bg-primary-light { background-color: $primary-light; }
.bg-secondary { background-color: $secondary; }
.bg-secondary-light { background-color: $secondary-light; }
.bg-success { background-color: $success; }
.bg-success-light { background-color: $success-light; }
.bg-danger { background-color: $danger; }
.bg-danger-light { background-color: $danger-light; }
.bg-warning { background-color: $warning; }
.bg-warning-light { background-color: $warning-light; }
.bg-info { background-color: $info; }
.bg-info-light { background-color: $info-light; }
.bg-light { background-color: $light; }
.bg-dark { background-color: $dark; }

.d-none { display: none; }
.d-block { display: block; }
.d-flex { display: flex; }
.d-inline { display: inline; }
.d-inline-block { display: inline-block; }

.flex-row { flex-direction: row; }
.flex-column { flex-direction: column; }
.flex-wrap { flex-wrap: wrap; }
.flex-nowrap { flex-wrap: nowrap; }
.flex-grow-1 { flex-grow: 1; }
.flex-shrink-0 { flex-shrink: 0; }
.justify-content-start { justify-content: flex-start; }
.justify-content-end { justify-content: flex-end; }
.justify-content-center { justify-content: center; }
.justify-content-between { justify-content: space-between; }
.justify-content-around { justify-content: space-around; }
.align-items-start { align-items: flex-start; }
.align-items-end { align-items: flex-end; }
.align-items-center { align-items: center; }
.align-items-baseline { align-items: baseline; }
.align-items-stretch { align-items: stretch; }

.w-100 { width: 100%; }
.h-100 { height: 100%; }

.m-0 { margin: 0; }
.mt-0 { margin-top: 0; }
.mr-0 { margin-right: 0; }
.mb-0 { margin-bottom: 0; }
.ml-0 { margin-left: 0; }

.m-1 { margin: map-get($spacers, 1); }
.mt-1 { margin-top: map-get($spacers, 1); }
.mr-1 { margin-right: map-get($spacers, 1); }
.mb-1 { margin-bottom: map-get($spacers, 1); }
.ml-1 { margin-left: map-get($spacers, 1); }

.m-2 { margin: map-get($spacers, 2); }
.mt-2 { margin-top: map-get($spacers, 2); }
.mr-2 { margin-right: map-get($spacers, 2); }
.mb-2 { margin-bottom: map-get($spacers, 2); }
.ml-2 { margin-left: map-get($spacers, 2); }

.m-3 { margin: map-get($spacers, 3); }
.mt-3 { margin-top: map-get($spacers, 3); }
.mr-3 { margin-right: map-get($spacers, 3); }
.mb-3 { margin-bottom: map-get($spacers, 3); }
.ml-3 { margin-left: map-get($spacers, 3); }

.m-4 { margin: map-get($spacers, 4); }
.mt-4 { margin-top: map-get($spacers, 4); }
.mr-4 { margin-right: map-get($spacers, 4); }
.mb-4 { margin-bottom: map-get($spacers, 4); }
.ml-4 { margin-left: map-get($spacers, 4); }

.m-5 { margin: map-get($spacers, 5); }
.mt-5 { margin-top: map-get($spacers, 5); }
.mr-5 { margin-right: map-get($spacers, 5); }
.mb-5 { margin-bottom: map-get($spacers, 5); }
.ml-5 { margin-left: map-get($spacers, 5); }

.p-0 { padding: 0; }
.pt-0 { padding-top: 0; }
.pr-0 { padding-right: 0; }
.pb-0 { padding-bottom: 0; }
.pl-0 { padding-left: 0; }

.p-1 { padding: map-get($spacers, 1); }
.pt-1 { padding-top: map-get($spacers, 1); }
.pr-1 { padding-right: map-get($spacers, 1); }
.pb-1 { padding-bottom: map-get($spacers, 1); }
.pl-1 { padding-left: map-get($spacers, 1); }

.p-2 { padding: map-get($spacers, 2); }
.pt-2 { padding-top: map-get($spacers, 2); }
.pr-2 { padding-right: map-get($spacers, 2); }
.pb-2 { padding-bottom: map-get($spacers, 2); }
.pl-2 { padding-left: map-get($spacers, 2); }

.p-3 { padding: map-get($spacers, 3); }
.pt-3 { padding-top: map-get($spacers, 3); }
.pr-3 { padding-right: map-get($spacers, 3); }
.pb-3 { padding-bottom: map-get($spacers, 3); }
.pl-3 { padding-left: map-get($spacers, 3); }

.p-4 { padding: map-get($spacers, 4); }
.pt-4 { padding-top: map-get($spacers, 4); }
.pr-4 { padding-right: map-get($spacers, 4); }
.pb-4 { padding-bottom: map-get($spacers, 4); }
.pl-4 { padding-left: map-get($spacers, 4); }

.p-5 { padding: map-get($spacers, 5); }
.pt-5 { padding-top: map-get($spacers, 5); }
.pr-5 { padding-right: map-get($spacers, 5); }
.pb-5 { padding-bottom: map-get($spacers, 5); }
.pl-5 { padding-left: map-get($spacers, 5); }

.m-auto { margin: auto; }
.mt-auto { margin-top: auto; }
.mr-auto { margin-right: auto; }
.mb-auto { margin-bottom: auto; }
.ml-auto { margin-left: auto; }

.p-auto { padding: auto; }
.pt-auto { padding-top: auto; }
.pr-auto { padding-right: auto; }
.pb-auto { padding-bottom: auto; }
.pl-auto { padding-left: auto; }

.text-center { text-align: center; }
.text-right { text-align: right; }
.text-left { text-align: left; }

.text-bold { font-weight: bold; }

.text-italic { font-style: italic; }

.text-underline { text-decoration: underline; }

.text-underline-hover {
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
}

.text-primary { color: $primary; }
.text-secondary { color: $secondary; }
.text-success { color: $success; }
.text-info { color: $info; }
.text-warning { color: $warning; }

.text-danger { color: $danger; }

.text-light { color: $light; }
.text-dark { color: $dark; }

.text-white { color: $white; }

.text-black { color: $black; }

.text-muted { color: $muted; }

.text-lowercase { text-transform: lowercase; }
.text-uppercase { text-transform: uppercase; }
.text-capitalize { text-transform: capitalize; }

.text-break {
  overflow-wrap: break-word;
  word-break: break-word;
}

.text-truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
EOF

#!/bin/bash

# --- CUSTOM PIPES ---
echo -e "${BLUE}Creating pipes...${NC}"

cat > src/app/shared/pipes/filter.pipe.ts << 'EOF'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filter',
  standalone: true
})
export class FilterPipe implements PipeTransform {
  transform<T>(
    items: T[],
    searchText: string,
    properties: (keyof T)[] | ((item: T) => any)[] = []
  ): T[] {
    if (!items || !searchText || !properties.length) {
      return items;
    }

    searchText = searchText.toLowerCase();

    return items.filter(item => {
      return properties.some(property => {
        let value: any;

        if (typeof property === 'function') {
          value = property(item);
        } else {
          value = item[property];

          // Handle nested properties
          if (typeof property === 'string' && property.includes('.')) {
            const props = property.split('.');
            value = props.reduce((obj, prop) => obj?.[prop], item);
          }
        }

        if (value === null || value === undefined) {
          return false;
        }

        // Convert value to string for comparison
        return String(value).toLowerCase().includes(searchText);
      });
    });
  }
}
EOF

cat > src/app/shared/pipes/format-date.pipe.ts << 'EOF'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'formatDate',
  standalone: true
})
export class FormatDatePipe implements PipeTransform {
  transform(value: Date | string, format: string = 'medium'): string {
    if (!value) {
      return '';
    }

    const date = typeof value === 'string' ? new Date(value) : value;

    if (isNaN(date.getTime())) {
      return '';
    }

    switch (format) {
      case 'short':
        return date.toLocaleDateString();
      case 'medium':
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      case 'long':
        return date.toLocaleDateString(undefined, {
          weekday: 'long',
          year: 'numeric',
          month: 'long',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        });
      case 'date':
        return date.toLocaleDateString();
      case 'time':
        return date.toLocaleTimeString();
      case 'relative':
        return this.getRelativeTime(date);
      default:
        return date.toLocaleString();
    }
  }

  private getRelativeTime(date: Date): string {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSec = Math.round(diffMs / 1000);

    if (diffSec < 60) {
      return diffSec + ' second' + (diffSec === 1 ? '' : 's') + ' ago';
    }

    const diffMin = Math.round(diffSec / 60);
    if (diffMin < 60) {
      return diffMin + ' minute' + (diffMin === 1 ? '' : 's') + ' ago';
    }

    const diffHour = Math.round(diffMin / 60);
    if (diffHour < 24) {
      return diffHour + ' hour' + (diffHour === 1 ? '' : 's') + ' ago';
    }

    const diffDay = Math.round(diffHour / 24);
    if (diffDay < 30) {
      return diffDay + ' day' + (diffDay === 1 ? '' : 's') + ' ago';
    }

    const diffMonth = Math.round(diffDay / 30);
    if (diffMonth < 12) {
      return diffMonth + ' month' + (diffMonth === 1 ? '' : 's') + ' ago';
    }

    const diffYear = Math.round(diffMonth / 12);
    return diffYear + ' year' + (diffYear === 1 ? '' : 's') + ' ago';
  }
}
EOF

cat > src/app/shared/pipes/truncate.pipe.ts << 'EOF'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'truncate',
  standalone: true
})
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit: number = 100, completeWords: boolean = false, ellipsis: string = '...'): string {
    if (!value) {
      return '';
    }

    if (value.length <= limit) {
      return value;
    }

    if (completeWords) {
      limit = value.substring(0, limit).lastIndexOf(' ');
    }

    return value.substring(0, limit) + ellipsis;
  }
}
EOF

# --- VALIDATORS ---
echo -e "${BLUE}Creating validators...${NC}"

cat > src/app/shared/validators/password.validator.ts << 'EOF'
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
EOF

cat > src/app/shared/validators/date.validator.ts << 'EOF'
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function dateRangeValidator(startDateControlName: string, endDateControlName: string): ValidatorFn {
  return (formGroup: AbstractControl): ValidationErrors | null => {
    const startDateControl = formGroup.get(startDateControlName);
    const endDateControl = formGroup.get(endDateControlName);

    if (!startDateControl || !endDateControl) {
      return null;
    }

    const startDate = startDateControl.value;
    const endDate = endDateControl.value;

    if (!startDate || !endDate) {
      return null;
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start > end) {
      return { dateRange: { startDate, endDate } };
    }

    return null;
  };
}

export function minDateValidator(minDate: Date | string | (() => Date)): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const controlDate = new Date(control.value);

    if (isNaN(controlDate.getTime())) {
      return { invalidDate: { value: control.value } };
    }

    const compareDate = typeof minDate === 'function'
      ? minDate()
      : new Date(minDate);

    if (controlDate < compareDate) {
      return { minDate: { required: compareDate, actual: controlDate } };
    }

    return null;
  };
}

export function maxDateValidator(maxDate: Date | string | (() => Date)): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const controlDate = new Date(control.value);

    if (isNaN(controlDate.getTime())) {
      return { invalidDate: { value: control.value } };
    }

    const compareDate = typeof maxDate === 'function'
      ? maxDate()
      : new Date(maxDate);

    if (controlDate > compareDate) {
      return { maxDate: { required: compareDate, actual: controlDate } };
    }

    return null;
  };
}
EOF

# --- ENVIRONMENT FILES ---
echo -e "${BLUE}Creating environment files...${NC}"

cat > src/environments/environment.ts << 'EOF'
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api'
};
EOF

cat > src/environments/environment.prod.ts << 'EOF'
export const environment = {
  production: true,
  apiUrl: '/api'
};
EOF

# --- CUSTOM DIRECTIVES ---
echo -e "${BLUE}Creating directives...${NC}"

cat > src/app/shared/directives/highlight.directive.ts << 'EOF'
import { Directive, ElementRef, Input, OnInit, Renderer2, HostListener } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true
})
export class HighlightDirective implements OnInit {
  @Input() appHighlight = 'bg-blue-50';
  @Input() highlightTextColor = 'text-blue-600';

  private defaultBgClass: string | null = null;
  private defaultTextClass: string | null = null;

  constructor(private el: ElementRef, private renderer: Renderer2) {}

  ngOnInit(): void {
    // Store default classes if they exist
    this.defaultBgClass = this.getBackgroundClass();
    this.defaultTextClass = this.getTextColorClass();
  }

  @HostListener('mouseenter') onMouseEnter(): void {
    // Remove any existing background classes
    this.removeClassesByPrefix('bg-');
    this.removeClassesByPrefix('text-');

    // Add highlight classes
    this.renderer.addClass(this.el.nativeElement, this.appHighlight);
    this.renderer.addClass(this.el.nativeElement, this.highlightTextColor);
  }

  @HostListener('mouseleave') onMouseLeave(): void {
    // Remove highlight classes
    this.renderer.removeClass(this.el.nativeElement, this.appHighlight);
    this.renderer.removeClass(this.el.nativeElement, this.highlightTextColor);

    // Restore default classes if they existed
    if (this.defaultBgClass) {
      this.renderer.addClass(this.el.nativeElement, this.defaultBgClass);
    }

    if (this.defaultTextClass) {
      this.renderer.addClass(this.el.nativeElement, this.defaultTextClass);
    }
  }

  private getBackgroundClass(): string | null {
    const classList = this.el.nativeElement.classList;
    for (let i = 0; i < classList.length; i++) {
      if (classList[i].startsWith('bg-')) {
        return classList[i];
      }
    }
    return null;
  }

  private getTextColorClass(): string | null {
    const classList = this.el.nativeElement.classList;
    for (let i = 0; i < classList.length; i++) {
      if (classList[i].startsWith('text-')) {
        return classList[i];
      }
    }
    return null;
  }

  private removeClassesByPrefix(prefix: string): void {
    const classList = this.el.nativeElement.classList;
    const classesToRemove = [];

    for (let i = 0; i < classList.length; i++) {
      if (classList[i].startsWith(prefix)) {
        classesToRemove.push(classList[i]);
      }
    }

    classesToRemove.forEach(className => {
      this.renderer.removeClass(this.el.nativeElement, className);
    });
  }
}
EOF

cat > src/app/shared/directives/click-outside.directive.ts << 'EOF'
import { Directive, ElementRef, EventEmitter, HostListener, Output } from '@angular/core';

@Directive({
  selector: '[appClickOutside]',
  standalone: true
})
export class ClickOutsideDirective {
  @Output() appClickOutside = new EventEmitter<void>();

  constructor(private elementRef: ElementRef) {}

  @HostListener('document:click', ['$event.target'])
  onClick(target: any): void {
    const clickedInside = this.elementRef.nativeElement.contains(target);
    if (!clickedInside) {
      this.appClickOutside.emit();
    }
  }
}
EOF

# --- NAVBAR COMPONENT (TAILWIND VERSION) ---
echo -e "${BLUE}Creating Navbar component with Tailwind CSS...${NC}"

cat > src/app/layout/navbar/navbar.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../core/auth/services/auth.service';
import { User, UserType } from '../../core/models/user.model';
import { ClickOutsideDirective } from '../../shared/directives/click-outside.directive';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule, ClickOutsideDirective],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.scss'
})
export class NavbarComponent implements OnInit {
  currentUser: User | null = null;
  isAdmin = false;
  isStaff = false;
  isClient = false;
  showUserMenu = false;
  showMobileMenu = false;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.authService.currentUser$.subscribe(user => {
      this.currentUser = user;
      this.isAdmin = user?.userType === UserType.ADMIN;
      this.isStaff = user?.userType === UserType.STAFF;
      this.isClient = user?.userType === UserType.CLIENT;
    });
  }

  toggleUserMenu(): void {
    this.showUserMenu = !this.showUserMenu;
  }

  closeUserMenu(): void {
    this.showUserMenu = false;
  }

  toggleMobileMenu(): void {
    this.showMobileMenu = !this.showMobileMenu;
  }

  logout(): void {
    this.authService.logout();
    this.showUserMenu = false;
  }
}
EOF

cat > src/app/layout/navbar/navbar.component.html << 'EOF'
<header class="bg-white shadow-sm">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between h-16">
      <div class="flex">
        <div class="flex-shrink-0 flex items-center">
          <a routerLink="/" class="text-xl font-bold text-blue-600">LRMS</a>
        </div>

        <nav class="hidden sm:ml-6 sm:flex sm:space-x-4" *ngIf="currentUser">
          <a routerLink="/" routerLinkActive="text-blue-600 border-blue-500" [routerLinkActiveOptions]="{exact: true}"
            class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
            Dashboard
          </a>
          <a routerLink="/properties" routerLinkActive="text-blue-600 border-blue-500"
            class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
            Properties
          </a>
          <a routerLink="/vehicles" routerLinkActive="text-blue-600 border-blue-500"
            class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
            Vehicles
          </a>
          <a routerLink="/reservations" routerLinkActive="text-blue-600 border-blue-500"
            class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
            Reservations
          </a>
          <a *ngIf="isAdmin || isStaff" routerLink="/clients" routerLinkActive="text-blue-600 border-blue-500"
            class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
            Clients
          </a>
          <a *ngIf="isAdmin || isStaff" routerLink="/staff" routerLinkActive="text-blue-600 border-blue-500"
            class="border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium">
            Staff
          </a>
        </nav>
      </div>

      <div class="hidden sm:ml-6 sm:flex sm:items-center">
        <div class="relative" *ngIf="currentUser">
          <button (click)="toggleUserMenu()" type="button" class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
            <div *ngIf="!currentUser.profileImageUrl" class="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center text-white">
              {{ currentUser.firstName?.charAt(0) }}{{ currentUser.lastName?.charAt(0) }}
            </div>
            <img *ngIf="currentUser.profileImageUrl" class="h-8 w-8 rounded-full" [src]="currentUser.profileImageUrl" alt="">
            <span class="ml-2 text-gray-700">{{ currentUser.firstName }} {{ currentUser.lastName }}</span>
            <svg class="ml-1 h-5 w-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>

          <div *ngIf="showUserMenu"
               (appClickOutside)="closeUserMenu()"
               class="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 focus:outline-none"
               role="menu">
            <div class="px-4 py-2 border-b">
              <p class="text-sm font-medium">{{ currentUser.fullName }}</p>
              <p class="text-xs text-gray-500">{{ currentUser.email }}</p>
              <span class="mt-1 inline-block px-2 py-0.5 text-xs rounded-full bg-blue-100 text-blue-800">{{ currentUser.userType | titlecase }}</span>
            </div>

            <a routerLink="/settings/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">
              My Profile
            </a>
            <a *ngIf="isAdmin" routerLink="/settings" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">
              Settings
            </a>
            <a *ngIf="isClient" routerLink="/clients/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">
              Client Dashboard
            </a>
            <a *ngIf="isStaff" routerLink="/staff/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">
              Staff Dashboard
            </a>

            <div class="border-t border-gray-100"></div>

            <button (click)="logout()" class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" role="menuitem">
              Logout
            </button>
          </div>
        </div>

        <div class="flex items-center space-x-4" *ngIf="!currentUser">
          <a routerLink="/auth/login" class="text-blue-600 hover:text-blue-800">
            Login
          </a>
          <a routerLink="/auth/register" class="bg-blue-600 text-white hover:bg-blue-700 px-3 py-2 rounded-md text-sm font-medium">
            Register
          </a>
        </div>
      </div>

      <!-- Mobile menu button -->
      <div class="flex items-center sm:hidden">
        <button (click)="toggleMobileMenu" type="button" class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500">
          <span class="sr-only">Open main menu</span>
          <svg class="h-6 w-6" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>
    </div>
  </div>

  <!-- Mobile menu -->
  <div class="sm:hidden" [ngClass]="{'block': showMobileMenu, 'hidden': !showMobileMenu}">
    <div class="pt-2 pb-3 space-y-1" *ngIf="currentUser">
      <a routerLink="/" routerLinkActive="bg-blue-50 border-blue-500 text-blue-700" [routerLinkActiveOptions]="{exact: true}"
        class="border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium">
        Dashboard
      </a>
      <a routerLink="/properties" routerLinkActive="bg-blue-50 border-blue-500 text-blue-700"
        class="border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium">
        Properties
      </a>
      <a routerLink="/vehicles" routerLinkActive="bg-blue-50 border-blue-500 text-blue-700"
        class="border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium">
        Vehicles
      </a>
      <a routerLink="/reservations" routerLinkActive="bg-blue-50 border-blue-500 text-blue-700"
        class="border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium">
        Reservations
      </a>
      <a *ngIf="isAdmin || isStaff" routerLink="/clients" routerLinkActive="bg-blue-50 border-blue-500 text-blue-700"
        class="border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium">
        Clients
      </a>
      <a *ngIf="isAdmin || isStaff" routerLink="/staff" routerLinkActive="bg-blue-50 border-blue-500 text-blue-700"
        class="border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 block pl-3 pr-4 py-2 border-l-4 text-base font-medium">
        Staff
      </a>
    </div>

    <div class="pt-4 pb-3 border-t border-gray-200" *ngIf="currentUser">
      <div class="flex items-center px-4">
        <div class="flex-shrink-0">
          <div *ngIf="!currentUser.profileImageUrl" class="h-10 w-10 rounded-full bg-blue-500 flex items-center justify-center text-white">
            {{ currentUser.firstName?.charAt(0) }}{{ currentUser.lastName?.charAt(0) }}
          </div>
          <img *ngIf="currentUser.profileImageUrl" class="h-10 w-10 rounded-full" [src]="currentUser.profileImageUrl" alt="">
        </div>
        <div class="ml-3">
          <div class="text-base font-medium text-gray-800">{{ currentUser.firstName }} {{ currentUser.lastName }}</div>
          <div class="text-sm font-medium text-gray-500">{{ currentUser.email }}</div>
        </div>
      </div>
      <div class="mt-3 space-y-1">
        <a routerLink="/settings/profile" class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100">
          My Profile
        </a>
        <a *ngIf="isAdmin" routerLink="/settings" class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100">
          Settings
        </a>
        <a *ngIf="isClient" routerLink="/clients/profile" class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100">
          Client Dashboard
        </a>
        <a *ngIf="isStaff" routerLink="/staff/profile" class="block px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100">
          Staff Dashboard
        </a>
        <button (click)="logout()" class="block w-full text-left px-4 py-2 text-base font-medium text-gray-500 hover:text-gray-800 hover:bg-gray-100">
          Logout
        </button>
      </div>
    </div>

    <div class="pt-4 pb-3 border-t border-gray-200" *ngIf="!currentUser">
      <div class="flex items-center justify-between px-4">
        <a routerLink="/auth/login" class="text-blue-600 hover:text-blue-800">
          Login
        </a>
        <a routerLink="/auth/register" class="bg-blue-600 text-white hover:bg-blue-700 px-3 py-2 rounded-md text-sm font-medium">
          Register
        </a>
      </div>
    </div>
  </div>
</header>
EOF

cat > src/app/layout/navbar/navbar.component.scss << 'EOF'
/* No additional styles needed - using Tailwind classes */
EOF

# --- SIDEBAR COMPONENT (TAILWIND VERSION) ---
echo -e "${BLUE}Creating Sidebar component with Tailwind CSS...${NC}"

cat > src/app/layout/sidebar/sidebar.component.ts << 'EOF'
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../core/auth/services/auth.service';
import { User, UserType } from '../../core/models/user.model';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent implements OnInit {
  currentUser: User | null = null;
  isAdmin: boolean = false;
  isClient: boolean = false;
  isStaff: boolean = false;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.isAdmin = this.currentUser?.userType === UserType.Admin;
    this.isClient = this.currentUser?.userType === UserType.Client;
    this.isStaff = this.currentUser?.userType === UserType.Staff;
  }

  logout(): void {
    this.authService.logout();
  }
}
EOF
