import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule, ActivatedRoute, Router } from '@angular/router';
import { StaffService } from '../services/staff.service';
import { Staff } from '../../../core/models/staff.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';
import { NotificationService } from '../../../core/services/notification.service';
import { ReplacePipe } from '../../../core/pipes/replace.pipe';

@Component({
  selector: 'app-staff-detail',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe, ReplacePipe],
  templateUrl: './staff-detail.component.html',
  styleUrl: './staff-detail.component.scss',
})
export class StaffDetailComponent implements OnInit {
  staff: Staff | null = null;
  loading = true;
  error = false;
  isAdmin = false;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private staffService: StaffService,
    private authService: AuthService,
    private notificationService: NotificationService
  ) {}

  ngOnInit(): void {
    this.checkUserPermissions();
    this.loadStaffMember();
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    this.isAdmin = currentUser?.userType === UserType.ADMIN;
  }

  loadStaffMember(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.error = true;
      this.loading = false;
      return;
    }

    this.staffService.getStaffMember(+id).subscribe({
      next: (data) => {
        this.staff = data;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error loading staff member', err);
        this.error = true;
        this.loading = false;
        this.notificationService.error('Failed to load staff member details');
      },
    });
  }

  deleteStaffMember(): void {
    if (!this.staff || !this.isAdmin) return;

    if (
      confirm(
        'Are you sure you want to delete this staff member? This action cannot be undone.'
      )
    ) {
      this.staffService.deleteStaff(this.staff.id).subscribe({
        next: () => {
          this.notificationService.success('Staff member deleted successfully');
          this.router.navigate(['/staff']);
        },
        error: (err) => {
          console.error('Error deleting staff member', err);
          this.notificationService.error('Failed to delete staff member');
        },
      });
    }
  }

  toggleStaffStatus(): void {
    if (!this.staff || !this.isAdmin) return;

    const action = this.staff.isActive
      ? this.staffService.deactivateStaff(this.staff.id)
      : this.staffService.activateStaff(this.staff.id);

    action.subscribe({
      next: (updatedStaff) => {
        this.staff = updatedStaff;
        const message = updatedStaff.isActive
          ? 'Staff member activated successfully'
          : 'Staff member deactivated successfully';
        this.notificationService.success(message);
      },
      error: (err) => {
        console.error('Error updating staff status', err);
        this.notificationService.error('Failed to update staff status');
      },
    });
  }
}
