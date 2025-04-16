import { Staff } from './staff.model';

export interface Department {
  id: number;
  name: string;
  description?: string;
  staff?: Staff[];
}
