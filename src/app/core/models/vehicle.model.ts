import { RentalItem, RentalItemType } from './rental-item.model';

export enum VehicleType {
  SEDAN = 'sedan',
  SUV = 'suv',
  SPORTS_CAR = 'sports_car',
  CONVERTIBLE = 'convertible',
  LIMOUSINE = 'limousine'
}

export enum TransmissionType {
  AUTOMATIC = 'automatic',
  MANUAL = 'manual',
  SEMI_AUTOMATIC = 'semi_automatic'
}

export enum FuelType {
  GASOLINE = 'gasoline',
  DIESEL = 'diesel',
  ELECTRIC = 'electric',
  HYBRID = 'hybrid'
}

export enum DrivetrainType {
  AWD = 'awd', // All-Wheel Drive
  FWD = 'fwd', // Front-Wheel Drive
  RWD = 'rwd' // Rear-Wheel Drive
}

export interface Vehicle extends RentalItem {
  make: string;
  model: string;
  year: number;
  vehicleType: VehicleType;
  vin: string;
  licensePlate?: string;
  exteriorColor?: string;
  interiorColor?: string;
  mileage: number;
  transmissionType: TransmissionType;
  fuelType: FuelType;
  fuelEconomy?: string;
  drivetrain?: DrivetrainType;
  seatingCapacity: number;
  trunkCapacity?: string;
  engineType?: string;
  engineSpecs?: string;
  performanceStats?: string;
  luxuryFeatures?: Record<string, boolean>;
  safetyFeatures?: Record<string, boolean>;
  technologyFeatures?: Record<string, boolean>;
  currentLocation?: string;
  fuelLevel?: number;
  isLimitedEdition: boolean;
}

export interface CreateVehicleRequest {
  name: string;
  description: string;
  baseRate: number;
  securityDeposit?: number;
  location: string;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  mainImageUrl?: string;
  imageUrls?: string[];
  maximumCapacity: number;
  amenities?: Record<string, boolean>;
  make: string;
  model: string;
  year: number;
  vehicleType: VehicleType;
  vin: string;
  licensePlate?: string;
  exteriorColor?: string;
  interiorColor?: string;
  mileage?: number;
  transmissionType?: TransmissionType;
  fuelType: FuelType;
  fuelEconomy?: string;
  drivetrain?: DrivetrainType;
  seatingCapacity: number;
  trunkCapacity?: string;
  engineType?: string;
  engineSpecs?: string;
  performanceStats?: string;
  luxuryFeatures?: Record<string, boolean>;
  safetyFeatures?: Record<string, boolean>;
  technologyFeatures?: Record<string, boolean>;
  currentLocation?: string;
  fuelLevel?: number;
  isLimitedEdition?: boolean;
}
