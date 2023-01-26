import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../auth-services/auth.service';
import { EventBusService } from '../event-bus.service';
import { EventData, EventDataEnum } from '../event-data';

@Component({
  selector: 'app-auth-page',
  templateUrl: './auth-page.component.html',
  styleUrls: ['./auth-page.component.scss'],
})
export class AuthPageComponent {
  protected displayLoggingForm = true;
  protected isLoading = false;
  protected errorMessage = '';

  protected username = '';
  protected firstName = '';
  protected lastName = '';
  protected password = '';
  protected repassword = '';
  protected email = '';

  constructor(
    private authService: AuthService,
    private router: Router,
    private eventBus: EventBusService,
    private route: ActivatedRoute
  ) {}

  switchToLogin() {
    this.displayLoggingForm = true;
  }

  switchToRegister() {
    this.displayLoggingForm = false;
  }

  submit() {
    if (this.displayLoggingForm) {
      this.login();
    } else {
      this.register();
    }
  }

  login() {
    this.errorMessage = '';
    if (!this.email) this.errorMessage = 'Email field is empty.';
    if (!this.validateEmail(this.email))
      this.errorMessage = 'Email is not valid.';
    if (!this.password) this.errorMessage = 'Password could not be empty.';

    if (this.errorMessage) return;

    this.isLoading = true;
    this.authService
      .login({ email: this.email, password: this.password })
      .then((user) => {
        const nextQP = this.route.snapshot.queryParamMap.get('next');

        if (nextQP) {
          this.router.navigateByUrl(nextQP);
        } else this.router.navigate(['/']);
        this.eventBus.emit(
          new EventData(
            EventDataEnum.INFO_POPUP,
            `You've succefully logged in as ${user.username}.`
          )
        );
      })
      .catch((err) => {
        this.errorMessage = err;
      });

    this.isLoading = false;
  }

  private validateEmail(email: string): boolean {
    return /[\w-\.]+@([\w-]+\.)+[\w-]{2,4}/.test(email);
  }

  register() {
    this.errorMessage = '';
    if (this.password !== this.repassword) {
      this.errorMessage = "Password don't correspond to each other";
    }

    if (!this.lastName) this.errorMessage = 'Last name field is empty.';
    if (!this.firstName) this.errorMessage = 'First name field is empty.';
    if (!this.username) this.errorMessage = 'Username field is empty.';
    if (!this.email) this.errorMessage = 'Email field is empty.';
    if (!this.validateEmail(this.email))
      this.errorMessage = 'Email is not valid.';
    if (!this.password) this.errorMessage = 'Password field is empty.';

    if (this.errorMessage) return;

    this.isLoading = true;
    this.authService
      .register({
        lastName: this.lastName,
        firstName: this.firstName,
        username: this.username,
        password: this.password,
        email: this.email,
      })
      .then((user) => {
        this.isLoading = false;
        this.displayLoggingForm = true;
      })
      .catch((err) => {
        this.errorMessage = err;
      });
  }
}
