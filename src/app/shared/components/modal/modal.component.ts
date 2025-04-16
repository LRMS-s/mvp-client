import { Component, Input, Output, EventEmitter, TemplateRef, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-modal',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './modal.component.html',
  styleUrl: './modal.component.scss'
})
export class ModalComponent {
  @Input() title = '';
  @Input() size: 'sm' | 'md' | 'lg' | 'xl' = 'md';
  @Input() closable = true;
  @Input() contentTemplate: TemplateRef<any> | null = null;
  @Input() footerTemplate: TemplateRef<any> | null = null;

  @Output() closed = new EventEmitter<void>();

  private _visible = false;

  @Input()
  set visible(value: boolean) {
    this._visible = value;
    if (value) {
      document.body.classList.add('modal-open');
    } else {
      document.body.classList.remove('modal-open');
    }
  }

  get visible(): boolean {
    return this._visible;
  }

  constructor(private elementRef: ElementRef) {}

  close(): void {
    if (this.closable) {
      this.visible = false;
      this.closed.emit();
    }
  }

  onBackdropClick(event: MouseEvent): void {
    if (event.target === this.elementRef.nativeElement.querySelector('.modal-backdrop')) {
      this.close();
    }
  }
}
