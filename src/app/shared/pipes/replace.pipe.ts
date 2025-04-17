import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'replace',
})
export class ReplacePipe implements PipeTransform {
  transform(value: string, args: string, rest: string): string {
    if (value && args && rest) {
      return value.replace(args, rest);
    }
    return value;
  }
}
