# TakeHealth Proxy

Hooks `CTFPlayer::TakeHealth()`, allowing other plugins to overwrite the healing amount given to
the target player.

A private project required the use of a lot of this very hook more than a few times, so I've
moved it into its own little library so I don't have to find it again each time.

## Dependencies

* [DHooks with detour support][dhooks]

[dhooks]: https://forums.alliedmods.net/showpost.php?p=2588686&postcount=589