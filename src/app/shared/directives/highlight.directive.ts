import { Directive, ElementRef, Input, OnInit, Renderer2, HostListener } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true
})
export class HighlightDirective implements OnInit {
  @Input() appHighlight = 'bg-blue-50';
  @Input() highlightTextColor = 'text-blue-600';

  private defaultBgClass: string | null = null;
  private defaultTextClass: string | null = null;

  constructor(private el: ElementRef, private renderer: Renderer2) {}

  ngOnInit(): void {
    // Store default classes if they exist
    this.defaultBgClass = this.getBackgroundClass();
    this.defaultTextClass = this.getTextColorClass();
  }

  @HostListener('mouseenter') onMouseEnter(): void {
    // Remove any existing background classes
    this.removeClassesByPrefix('bg-');
    this.removeClassesByPrefix('text-');

    // Add highlight classes
    this.renderer.addClass(this.el.nativeElement, this.appHighlight);
    this.renderer.addClass(this.el.nativeElement, this.highlightTextColor);
  }

  @HostListener('mouseleave') onMouseLeave(): void {
    // Remove highlight classes
    this.renderer.removeClass(this.el.nativeElement, this.appHighlight);
    this.renderer.removeClass(this.el.nativeElement, this.highlightTextColor);

    // Restore default classes if they existed
    if (this.defaultBgClass) {
      this.renderer.addClass(this.el.nativeElement, this.defaultBgClass);
    }

    if (this.defaultTextClass) {
      this.renderer.addClass(this.el.nativeElement, this.defaultTextClass);
    }
  }

  private getBackgroundClass(): string | null {
    const classList = this.el.nativeElement.classList;
    for (let i = 0; i < classList.length; i++) {
      if (classList[i].startsWith('bg-')) {
        return classList[i];
      }
    }
    return null;
  }

  private getTextColorClass(): string | null {
    const classList = this.el.nativeElement.classList;
    for (let i = 0; i < classList.length; i++) {
      if (classList[i].startsWith('text-')) {
        return classList[i];
      }
    }
    return null;
  }

  private removeClassesByPrefix(prefix: string): void {
    const classList = this.el.nativeElement.classList;
    const classesToRemove = [];

    for (let i = 0; i < classList.length; i++) {
      if (classList[i].startsWith(prefix)) {
        classesToRemove.push(classList[i]);
      }
    }

    classesToRemove.forEach(className => {
      this.renderer.removeClass(this.el.nativeElement, className);
    });
  }
}
