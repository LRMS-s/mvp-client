import { RentalItem, RentalItemType } from './rental-item.model';

export enum PropertyType {
  VILLA = 'villa',
  MANSION = 'mansion',
  PENTHOUSE = 'penthouse',
  APARTMENT = 'apartment',
  CHALET = 'chalet'
}

export enum LocationType {
  BEACHFRONT = 'beachfront',
  CITY_CENTER = 'city_center',
  COUNTRYSIDE = 'countryside',
  MOUNTAIN = 'mountain',
  LAKEFRONT = 'lakefront'
}

export interface Property extends RentalItem {
  propertyType: PropertyType;
  locationType: LocationType;
  totalArea: number;
  numberOfBedrooms: number;
  numberOfBathrooms: number;
  numberOfFloors?: number;
  constructionYear?: number;
  hasPool: boolean;
  hasGarden: boolean;
  hasSpa: boolean;
  hasGym: boolean;
  parkingCapacity?: number;
  kitchenSpecifications?: string;
  viewType?: string;
  securityFeatures?: Record<string, boolean>;
  outdoorFeatures?: Record<string, boolean>;
  entertainmentFacilities?: Record<string, boolean>;
  floorPlanUrl?: string;
}

export interface CreatePropertyRequest {
  name: string;
  description: string;
  propertyType: PropertyType;
  locationType: LocationType;
  baseRate: number;
  securityDeposit?: number;
  location: string;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  state?: string;
  country?: string;
  postalCode?: string;
  latitude?: number;
  longitude?: number;
  mainImageUrl?: string;
  imageUrls?: string[];
  maximumCapacity: number;
  amenities?: Record<string, boolean>;
  totalArea: number;
  numberOfBedrooms: number;
  numberOfBathrooms: number;
  numberOfFloors?: number;
  constructionYear?: number;
  hasPool?: boolean;
  hasGarden?: boolean;
  hasSpa?: boolean;
  hasGym?: boolean;
  parkingCapacity?: number;
  kitchenSpecifications?: string;
  viewType?: string;
  securityFeatures?: Record<string, boolean>;
  outdoorFeatures?: Record<string, boolean>;
  entertainmentFacilities?: Record<string, boolean>;
  floorPlanUrl?: string;
}
