import { Component, EventEmitter, Input, OnInit, Output } from '@angular/core';

export type OptionType = { value: any; display: String };

@Component({
  selector: 'app-multiple-select',
  templateUrl: './multiple-select.component.html',
  styleUrls: ['./multiple-select.component.scss'],
})
export class MultipleSelectComponent implements OnInit {
  @Input('options') options: OptionType[] = [];
  @Input('placeholder') placholder: string = '';

  @Output('update') updateEvent = new EventEmitter<OptionType[]>();

  protected selectionList: OptionType[] = [];
  protected expanded = false;

  get selected(): string {
    return this.selectionList.map((a) => a.display).join(', ');
  }

  ngOnInit(): void {}

  isSelected(option: OptionType): boolean {
    return this.selectionList.map((a) => a.value).includes(option.value);
  }

  checkedChoice(option: OptionType): void {
    if (!this.isSelected(option)) {
      this.selectionList.push(option);
      return;
    }

    const idx = this.selectionList.map((a) => a.value).indexOf(option.value);
    this.selectionList.splice(idx, 1);
  }

  switchExpansion() {
    this.expanded = !this.expanded;

    if (this.expanded === false) this.updateEvent.emit(this.selectionList);
  }
}
