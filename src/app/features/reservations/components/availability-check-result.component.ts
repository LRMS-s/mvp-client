import { Component, Input } from '@angular/core';
import { CommonModule, DatePipe } from '@angular/common';
import { RouterModule } from '@angular/router';
import { RentalItemCardComponent } from '../../../shared/components/rental-item-card/rental-item-card.component';

interface AvailabilityCheckResult {
  available: boolean;
  item: any;
  requestedDates: {
    start: string;
    end: string;
  };
  conflicts: Array<{
    id: number;
    reservationNumber: string;
    status: string;
    paymentStatus: string;
    startDate: string;
    endDate: string;
    totalAmount: string;
    paidAmount: string;
    notes: string;
    itemType: string;
    propertyId: number | null;
    vehicleId: number | null;
    clientId: number;
    createdAt: string;
    updatedAt: string;
    additionalServices: string;
    guestInformation: any;
  }>;
  nextAvailableDate: string;
  alternativeDateRanges: Array<{
    start: string;
    end: string;
  }>;
  prediction: string;
}

@Component({
  selector: 'app-availability-check-result',
  standalone: true,
  imports: [CommonModule, RouterModule, DatePipe, RentalItemCardComponent],
  template: `
    <div class="availability-result" [class.unavailable]="!result.available">
      <!-- Item Details -->
      <div class="item-details">
        <app-rental-item-card [rentalItem]="result.item"></app-rental-item-card>
      </div>

      <!-- Availability Status -->
      <div class="availability-status">
        <div
          class="status-badge"
          [class.available]="result.available"
          [class.unavailable]="!result.available"
        >
          {{ result.available ? 'Available' : 'Unavailable' }}
        </div>
        <div class="requested-dates">
          <p>Requested Dates:</p>
          <p>
            {{ result.requestedDates.start | date : 'mediumDate' }} -
            {{ result.requestedDates.end | date : 'mediumDate' }}
          </p>
        </div>
      </div>

      <!-- Conflicts Section (if unavailable) -->
      <div
        class="conflicts-section"
        *ngIf="!result.available && result.conflicts.length > 0"
      >
        <h3>Existing Reservations</h3>
        <div class="conflicts-list">
          <div class="conflict-item" *ngFor="let conflict of result.conflicts">
            <div class="conflict-header">
              <span class="reservation-number"
                >#{{ conflict.reservationNumber }}</span
              >
              <span class="status-badge" [class]="conflict.status">{{
                conflict.status
              }}</span>
            </div>
            <div class="conflict-dates">
              {{ conflict.startDate | date : 'mediumDate' }} -
              {{ conflict.endDate | date : 'mediumDate' }}
            </div>
            <div class="conflict-details">
              <span class="payment-status" [class]="conflict.paymentStatus">
                {{ conflict.paymentStatus }}
              </span>
              <span class="amount">{{ conflict.totalAmount | currency }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Alternative Dates Section -->
      <div
        class="alternative-dates"
        *ngIf="!result.available && result.alternativeDateRanges.length > 0"
      >
        <h3>Alternative Dates Available</h3>
        <div class="date-ranges">
          <div
            class="date-range"
            *ngFor="let range of result.alternativeDateRanges"
          >
            {{ range.start | date : 'mediumDate' }} -
            {{ range.end | date : 'mediumDate' }}
          </div>
        </div>
        <p class="prediction">{{ result.prediction }}</p>
      </div>

      <!-- Next Available Date -->
      <div
        class="next-available"
        *ngIf="!result.available && result.nextAvailableDate"
      >
        <h3>Next Available Date</h3>
        <p>{{ result.nextAvailableDate | date : 'mediumDate' }}</p>
      </div>
    </div>
  `,
  styles: [
    `
      .availability-result {
        padding: 1.5rem;
        background: white;
        border-radius: 0.5rem;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        margin-bottom: 2rem;

        &.unavailable {
          border-left: 4px solid #f44336;
        }
      }

      .availability-status {
        margin: 1.5rem 0;
        padding: 1rem;
        background: #f8f9fa;
        border-radius: 0.25rem;

        .status-badge {
          display: inline-block;
          padding: 0.5rem 1rem;
          border-radius: 0.25rem;
          font-weight: 500;
          margin-bottom: 1rem;

          &.available {
            background: #e8f5e9;
            color: #2e7d32;
          }

          &.unavailable {
            background: #ffebee;
            color: #c62828;
          }
        }

        .requested-dates {
          color: #666;
          font-size: 0.9rem;
        }
      }

      .conflicts-section {
        margin: 1.5rem 0;

        h3 {
          font-size: 1.2rem;
          margin-bottom: 1rem;
          color: #333;
        }

        .conflicts-list {
          display: grid;
          gap: 1rem;
        }

        .conflict-item {
          padding: 1rem;
          background: #f8f9fa;
          border-radius: 0.25rem;
          border-left: 4px solid #f44336;

          .conflict-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;

            .reservation-number {
              font-weight: 500;
              color: #333;
            }
          }

          .conflict-dates {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
          }

          .conflict-details {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.9rem;

            .payment-status {
              padding: 0.25rem 0.5rem;
              border-radius: 0.25rem;
              font-size: 0.8rem;

              &.pending {
                background: #fff3e0;
                color: #ef6c00;
              }

              &.paid {
                background: #e8f5e9;
                color: #2e7d32;
              }
            }

            .amount {
              font-weight: 500;
              color: #333;
            }
          }
        }
      }

      .alternative-dates {
        margin: 1.5rem 0;
        padding: 1rem;
        background: #e3f2fd;
        border-radius: 0.25rem;

        h3 {
          font-size: 1.2rem;
          margin-bottom: 1rem;
          color: #1565c0;
        }

        .date-ranges {
          display: grid;
          gap: 0.5rem;
          margin-bottom: 1rem;
        }

        .date-range {
          padding: 0.5rem;
          background: white;
          border-radius: 0.25rem;
          color: #1565c0;
          font-weight: 500;
        }

        .prediction {
          color: #1565c0;
          font-style: italic;
        }
      }

      .next-available {
        margin: 1.5rem 0;
        padding: 1rem;
        background: #e8f5e9;
        border-radius: 0.25rem;

        h3 {
          font-size: 1.2rem;
          margin-bottom: 0.5rem;
          color: #2e7d32;
        }

        p {
          color: #2e7d32;
          font-weight: 500;
        }
      }
    `,
  ],
})
export class AvailabilityCheckResultComponent {
  @Input() result!: AvailabilityCheckResult;
}
