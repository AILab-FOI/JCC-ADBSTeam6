import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AddFormPageComponent } from './add-form-page/add-form-page.component';
import { ArtistsPageComponent } from './artists-page/artists-page.component';
import { AuthPageComponent } from './auth-page/auth-page.component';
import { GenrePageComponent } from './genre-page/genre-page.component';
import { HomeMenuComponent } from './home-menu/home-menu.component';
import { MusicPageComponent } from './music-page/music-page.component';
import { NotFoundPageComponent } from './not-found-page/not-found-page.component';
import { PlaylistMenuComponent } from './playlist-menu/playlist-menu.component';
import { PlaylistPageComponent } from './playlist-page/playlist-page.component';
import { UserPageComponent } from './user-page/user-page.component';

const routes: Routes = [
  { path: 'not-found', component: NotFoundPageComponent },
  { path: '', component: HomeMenuComponent },
  { path: 'playlist/:id', component: PlaylistPageComponent },
  { path: 'playlist', component: PlaylistMenuComponent },
  { path: 'user/:id', component: UserPageComponent },
  { path: 'music/:id', component: MusicPageComponent },
  { path: 'artists/:id', component: ArtistsPageComponent },
  { path: 'genres', component: GenrePageComponent },
  { path: 'auth', component: AuthPageComponent },
  { path: 'add-form', component: AddFormPageComponent },
  { path: '**', redirectTo: 'not-found' },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
