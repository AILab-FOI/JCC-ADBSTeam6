import { Column, Entity, Index, JoinColumn, ManyToOne } from 'typeorm';
import { Users } from '@/users/entities/user.entity';

// @Index('subscriptions_pkey', ['subscribetoid', 'userid'], { unique: true })
@Entity('subscriptions', { schema: 'public' })
export class Subscriptions {
  @Column('integer', { primary: true, name: 'userid' })
  userid: number;

  @Column('integer', { primary: true, name: 'subscribetoid' })
  subscribetoid: number;

  @ManyToOne(() => Users, (users) => users.subscriptions, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'subscribetoid', referencedColumnName: 'userid' }])
  subscribeto: Users;

  @ManyToOne(() => Users, (users) => users.subscriptions2, {
    onDelete: 'CASCADE',
    onUpdate: 'CASCADE',
  })
  @JoinColumn([{ name: 'userid', referencedColumnName: 'userid' }])
  user: Users;
}
