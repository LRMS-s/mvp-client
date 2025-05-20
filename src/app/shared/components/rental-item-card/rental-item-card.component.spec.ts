import { ComponentFixture, TestBed } from '@angular/core/testing';

import { RentalItemCardComponent } from './rental-item-card.component';

describe('RentalItemCardComponent', () => {
  let component: RentalItemCardComponent;
  let fixture: ComponentFixture<RentalItemCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RentalItemCardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(RentalItemCardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
