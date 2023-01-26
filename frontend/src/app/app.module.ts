import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { PlaylistMenuComponent } from './playlist-menu/playlist-menu.component';
import { UserPageComponent } from './user-page/user-page.component';
import { SearchBarComponent } from './search-bar/search-bar.component';
import { MusicControllerComponent } from './music-controller/music-controller.component';
import { SlideBarComponent } from './slide-bar/slide-bar.component';
import { NavMenuComponent } from './nav-menu/nav-menu.component';
import { HomeMenuComponent } from './home-menu/home-menu.component';
import { FormsModule } from '@angular/forms';
import { CardComponent } from './card/card.component';
import { SkeletonCardComponent } from './skeleton-card/skeleton-card.component';
import { PlaylistPageComponent } from './playlist-page/playlist-page.component';
import { PopupComponent } from './popup/popup.component';
import { DurationToSPipe } from './duration-to-s.pipe';
import { GenrePageComponent } from './genre-page/genre-page.component';
import { ArtistsPageComponent } from './artists-page/artists-page.component';
import { MusicListComponent } from './music-list/music-list.component';
import { AuthPageComponent } from './auth-page/auth-page.component';
import { CommentComponent } from './comment/comment.component';
import { CapitalizePipe } from './capitalize.pipe';
import { MusicPageComponent } from './music-page/music-page.component';
import { AddFormPageComponent } from './add-form-page/add-form-page.component';
import { MultipleSelectComponent } from './multiple-select/multiple-select.component';
import { HttpClientModule } from '@angular/common/http';
import { ValidDurationPipe } from './valid-duration.pipe';
import { NotFoundPageComponent } from './not-found-page/not-found-page.component';
import { NoAutoPlaylistPipe } from './no-auto-playlist.pipe';

// TODO: https://medium.com/swlh/angular-spring-boot-kafka-how-to-stream-realtime-data-the-reactive-way-510a0f1e5881
@NgModule({
  declarations: [
    AppComponent,
    PlaylistMenuComponent,
    UserPageComponent,
    SearchBarComponent,
    MusicControllerComponent,
    SlideBarComponent,
    NavMenuComponent,
    HomeMenuComponent,
    CardComponent,
    SkeletonCardComponent,
    PlaylistPageComponent,
    PopupComponent,
    DurationToSPipe,
    GenrePageComponent,
    ArtistsPageComponent,
    MusicListComponent,
    AuthPageComponent,
    CommentComponent,
    CapitalizePipe,
    MusicPageComponent,
    AddFormPageComponent,
    MultipleSelectComponent,
    ValidDurationPipe,
    NotFoundPageComponent,
    NoAutoPlaylistPipe,
  ],
  imports: [BrowserModule, FormsModule, AppRoutingModule, HttpClientModule],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
