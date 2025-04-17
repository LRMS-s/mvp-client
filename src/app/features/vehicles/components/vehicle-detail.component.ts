import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { VehicleService } from '../services/vehicle.service';
import { Vehicle } from '../../../core/models/vehicle.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';
import { ReplacePipe } from '../../../shared/pipes/replace.pipe';

@Component({
  selector: 'app-vehicle-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe, ReplacePipe],
  templateUrl: './vehicle-detail.component.html',
  styleUrl: './vehicle-detail.component.scss',
})
export class VehicleDetailComponent implements OnInit {
  vehicle: Vehicle | null = null;
  loading = true;
  error = false;
  activeImageUrl: string | null = null;
  isAdmin = false;
  isStaff = false;
  objectKeys = Object.keys;

  constructor(
    private vehicleService: VehicleService,
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadVehicle(+id);
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

  loadVehicle(id: number): void {
    this.loading = true;
    this.vehicleService.getVehicle(id).subscribe({
      next: (data) => {
        this.vehicle = data;
        this.activeImageUrl = data.mainImageUrl || null;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading vehicle', err);
        this.error = true;
        this.loading = false;
      },
    });
  }

  setActiveImage(url: string): void {
    this.activeImageUrl = url;
  }

  deleteVehicle(): void {
    if (
      !this.vehicle ||
      !confirm('Are you sure you want to delete this vehicle?')
    ) {
      return;
    }

    this.vehicleService.deleteVehicle(this.vehicle.id).subscribe({
      next: () => {
        this.router.navigate(['/vehicles']);
      },
      error: (err) => {
        console.error('Error deleting vehicle', err);
        alert('Failed to delete vehicle. Please try again.');
      },
    });
  }
}
