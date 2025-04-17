import { Component, OnInit } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { StaffService } from '../services/staff.service';
import { DepartmentService } from '../services/department.service';
import { Staff, EmploymentType } from '../../../core/models/staff.model';
import { Department } from '../../../core/models/department.model';
import { AuthService } from '../../../core/auth/services/auth.service';
import { UserType } from '../../../core/models/user.model';
import { ReplacePipe } from '../../../core/pipes/replace.pipe';

@Component({
  selector: 'app-staff-list',
  standalone: true,
  imports: [
    CommonModule,
    RouterModule,
    ReactiveFormsModule,
    DatePipe,
    ReplacePipe,
  ],
  templateUrl: './staff-list.component.html',
  styleUrl: './staff-list.component.scss',
})
export class StaffListComponent implements OnInit {
  staff: Staff[] = [];
  filteredStaff: Staff[] = [];
  departments: Department[] = [];
  loading = true;
  filterForm: FormGroup;

  // Enum values for filters
  employmentTypes = Object.values(EmploymentType);

  // Pagination
  currentPage = 1;
  itemsPerPage = 10;

  // User permissions
  isAdmin = false;

  Math = Math;
  constructor(
    private formBuilder: FormBuilder,
    private staffService: StaffService,
    private departmentService: DepartmentService,
    private authService: AuthService
  ) {
    this.filterForm = this.createFilterForm();
    this.checkUserPermissions();
  }

  ngOnInit(): void {
    this.loadDepartments();
    this.loadStaff();

    // Apply filters when form values change
    this.filterForm.valueChanges.subscribe(() => {
      this.applyFilters();
    });
  }

  createFilterForm(): FormGroup {
    return this.formBuilder.group({
      searchTerm: [''],
      departmentId: [''],
      employmentType: [''],
      isActive: [''],
      hiredFrom: [''],
      hiredTo: [''],
    });
  }

  checkUserPermissions(): void {
    const currentUser = this.authService.getCurrentUser();
    this.isAdmin = currentUser?.userType === UserType.ADMIN;
  }

  loadDepartments(): void {
    this.departmentService.getDepartments().subscribe({
      next: (departments) => {
        this.departments = departments;
      },
      error: (error) => {
        console.error('Error loading departments', error);
      },
    });
  }

  loadStaff(): void {
    this.loading = true;
    this.staffService.getStaffMembers().subscribe({
      next: (data) => {
        this.staff = data;
        this.applyFilters();
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading staff', error);
        this.loading = false;
      },
    });
  }

  applyFilters(): void {
    const filters = this.filterForm.value;

    this.filteredStaff = this.staff.filter((staffMember) => {
      // Search term filter
      if (filters.searchTerm) {
        const searchTerm = filters.searchTerm.toLowerCase();
        const matchesSearch =
          staffMember.user.firstName.toLowerCase().includes(searchTerm) ||
          staffMember.user.lastName.toLowerCase().includes(searchTerm) ||
          staffMember.position.toLowerCase().includes(searchTerm) ||
          staffMember.user.email.toLowerCase().includes(searchTerm);

        if (!matchesSearch) return false;
      }

      // Department filter
      if (
        filters.departmentId &&
        staffMember.department.id !== parseInt(filters.departmentId)
      ) {
        return false;
      }

      // Employment type filter
      if (
        filters.employmentType &&
        staffMember.employmentType !== filters.employmentType
      ) {
        return false;
      }

      // Active status filter
      if (
        filters.isActive !== '' &&
        staffMember.isActive !== (filters.isActive === 'true')
      ) {
        return false;
      }

      // Hire date from filter
      if (filters.hiredFrom) {
        const hiredFrom = new Date(filters.hiredFrom);
        if (new Date(staffMember.hireDate) < hiredFrom) return false;
      }

      // Hire date to filter
      if (filters.hiredTo) {
        const hiredTo = new Date(filters.hiredTo);
        if (new Date(staffMember.hireDate) > hiredTo) return false;
      }

      return true;
    });

    // Reset pagination when filters change
    this.currentPage = 1;
  }

  resetFilters(): void {
    this.filterForm.reset();
    this.applyFilters();
  }

  get paginatedStaff(): Staff[] {
    const startIndex = (this.currentPage - 1) * this.itemsPerPage;
    return this.filteredStaff.slice(startIndex, startIndex + this.itemsPerPage);
  }

  get totalPages(): number {
    return Math.ceil(this.filteredStaff.length / this.itemsPerPage);
  }

  changePage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
    }
  }

  toggleStaffStatus(staffMember: Staff): void {
    if (!this.isAdmin) return;

    const action = staffMember.isActive
      ? this.staffService.deactivateStaff(staffMember.id)
      : this.staffService.activateStaff(staffMember.id);

    action.subscribe({
      next: (updatedStaff) => {
        const index = this.staff.findIndex((s) => s.id === staffMember.id);
        if (index !== -1) {
          this.staff[index] = updatedStaff;
          this.applyFilters();
        }
      },
      error: (error) => {
        console.error('Error updating staff status', error);
      },
    });
  }
}
