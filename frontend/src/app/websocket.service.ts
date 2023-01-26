import { Injectable } from '@angular/core';
import { map, Observable, Observer, Subscriber } from 'rxjs';
import { AnonymousSubject, Subject } from 'rxjs/internal/Subject';
import { io, Socket } from 'socket.io-client';

const WEBSOCKET_URI =
  /*process?.env['WEBSOCKET_URI'] ||*/ 'ws://localhost:8082';

/**
 * source: https://stackoverflow.com/questions/67230791/websocket-with-nestjs-and-angular
 */
@Injectable({
  providedIn: 'root',
})
export class WebsocketService {
  private socket: Socket;

  constructor() {
    this.socket = io(WEBSOCKET_URI, {
      transports: ['websocket'],
      extraHeaders: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
    });
  }

  listen<T>(eventName: string) {
    return new Observable((subscriber: Subscriber<T>) => {
      this.socket.on(eventName, (data) => subscriber.next(data));
    });
  }

  emit(eventName: string, data: any) {
    this.socket.emit(eventName, data);
  }
}

// interface Message {
//   musicId: number;
//   likes: number;
//   views: number;
// }

// // https://stackoverflow.com/questions/67230791/websocket-with-nestjs-and-angular
// @Injectable({
//   providedIn: 'root',
// })
// export class WebsocketService {
//   private subject?: AnonymousSubject<MessageEvent>;
//   public messages: Subject<Message>;

//   constructor() {
//     this.messages = <Subject<Message>>this.connect(WEBSOCKET_URI).pipe(
//       map((response: MessageEvent): Message => {
//         console.log(response.data);
//         let data = JSON.parse(response.data);
//         return data;
//       })
//     );
//   }

//   public connect(url: string): AnonymousSubject<MessageEvent> {
//     if (!this.subject) {
//       this.subject = this.create(url);
//       console.log('Successfully connected: ' + url);
//     }
//     return this.subject;
//   }

//   private create(url: string): AnonymousSubject<MessageEvent> {
//     let ws = new WebSocket(url);
//     let observable = new Observable((obs: Observer<MessageEvent>) => {
//       ws.onmessage = obs.next.bind(obs);
//       ws.onerror = obs.error.bind(obs);
//       ws.onclose = obs.complete.bind(obs);
//       return ws.close.bind(ws);
//     });
//     let observer = {
//       error: (err: any) => {
//         if (err) console.error(err);
//       },
//       complete: () => {},
//       next: (data: Object) => {
//         console.log('Message sent to websocket: ', data);
//         if (ws.readyState === WebSocket.OPEN) {
//           ws.send(JSON.stringify(data));
//         }
//       },
//     };
//     return new AnonymousSubject<MessageEvent>(observer, observable);
//   }
// }
