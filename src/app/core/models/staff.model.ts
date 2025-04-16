import { User } from './user.model';
import { Department } from './department.model';

export enum EmploymentType {
  FULL_TIME = 'full_time',
  PART_TIME = 'part_time',
  CONTRACT = 'contract',
  SEASONAL = 'seasonal'
}

export interface Staff {
  id: number;
  employmentType: EmploymentType;
  hireDate: Date;
  position: string;
  qualification?: string;
  emergencyContact?: string;
  salary?: number;
  isActive: boolean;
  user: User;
  department: Department;
}

export interface CreateStaffRequest {
  staff: {
    employmentType: EmploymentType;
    hireDate: Date;
    position: string;
    qualification?: string;
    emergencyContact?: string;
    salary?: number;
    departmentId: number;
  };
  user: {
    username: string;
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phone?: string;
    address?: string;
    city?: string;
    state?: string;
    country?: string;
    postalCode?: string;
    userType: string;
  };
}
