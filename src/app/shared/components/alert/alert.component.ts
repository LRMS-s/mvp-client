import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

export type AlertType = 'success' | 'error' | 'warning' | 'info';

@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './alert.component.html',
  styleUrl: './alert.component.scss'
})
export class AlertComponent {
  @Input() type: AlertType = 'info';
  @Input() message = '';
  @Input() dismissible = true;
  @Input() icon = true;
  @Input() timeout = 0; // 0 means no auto-dismiss

  @Output() dismissed = new EventEmitter<void>();

  visible = true;
  timeoutId: any = null;

  ngOnInit(): void {
    if (this.timeout > 0) {
      this.timeoutId = setTimeout(() => {
        this.dismiss();
      }, this.timeout);
    }
  }

  ngOnDestroy(): void {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }
  }

  dismiss(): void {
    this.visible = false;
    this.dismissed.emit();
  }
}
