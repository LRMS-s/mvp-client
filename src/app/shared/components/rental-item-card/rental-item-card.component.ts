import { Component, Input } from '@angular/core';
import { Vehicle } from '../../../core/models/vehicle.model';
import { Property } from '../../../core/models/property.model';
import {
  RentalItem,
  RentalItemType,
} from '../../../core/models/rental-item.model';
import { RouterLink } from '@angular/router';
import { CurrencyPipe, NgClass, NgIf, TitleCasePipe } from '@angular/common';
import { ReplacePipe } from '../../pipes/replace.pipe';

@Component({
  selector: 'app-rental-item-card',
  imports: [
    RouterLink,
    CurrencyPipe,
    NgClass,
    TitleCasePipe,
    ReplacePipe,
    NgIf,
  ],
  templateUrl: './rental-item-card.component.html',
  styleUrl: './rental-item-card.component.scss',
})
export class RentalItemCardComponent {
  @Input() rentalItem: RentalItem = {} as RentalItem;

  get isVehicle(): boolean {
    return this.rentalItem.itemType === RentalItemType.VEHICLE;
  }

  get isProperty(): boolean {
    return this.rentalItem.itemType === RentalItemType.PROPERTY;
  }

  get asVehicle(): Vehicle {
    return this.rentalItem as Vehicle;
  }

  get asProperty(): Property {
    return this.rentalItem as Property;
  }
}
