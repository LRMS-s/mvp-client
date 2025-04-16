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
