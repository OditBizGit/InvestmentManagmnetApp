# Diagrams Index

| Diagram | Location |
|---|---|
| Architecture (layers, 2 diagrams) | [ARCHITECTURE.md](ARCHITECTURE.md) |
| App initialization | below |
| Authentication sequence | [AUTHENTICATION.md](AUTHENTICATION.md), [modules/AUTH_AND_ACCOUNT.md](modules/AUTH_AND_ACCOUNT.md) |
| State flow | [STATE_MANAGEMENT.md](STATE_MANAGEMENT.md) |
| API request sequence | [API_CLIENT_CORE.md](API_CLIENT_CORE.md) |
| Navigation map | [NAVIGATION.md](NAVIGATION.md), [ADMIN_NAVIGATION](modules/ADMIN_NAVIGATION.md), [USER_NAVIGATION](modules/USER_NAVIGATION.md) |
| Module dependency | below |
| Business workflows | per module in `docs/modules/*.md` (all 17 module docs contain at least one diagram) |

## App initialization
```mermaid
sequenceDiagram
  participant M as main()
  participant DI as setupDi()
  participant FB as Firebase/Notifications
  M->>DI: await setupDi()
  DI->>DI: LocalStorage.init, AccountBlockCubit, Dio + auth interceptor
  DI->>DI: register repositories (lazy) and cubits (factory)
  alt not isAdmin and Android/iOS
    M->>FB: Firebase.initializeApp, background handler, NotificationService.initialize
    M->>M: lock portraitUp
  end
  M->>M: runApp(MyApp) with Repository/Bloc providers
```

## Module dependency
```mermaid
flowchart TD
  main[main.dart / MyApp] --> DI[core/network/service_locator]
  DI --> Dio[Dio + LocalStorage token]
  main --> auth[auth: LoginCubit]
  main --> admin[admin/* features]
  main --> user[user/* features]
  admin --> core[core/utils, constants]
  user --> core
  admin --> repo[feature repositories]
  user --> repo
  repo --> Dio
  Dio --> API[(REST API)]
  user --> acct[core/account block guard]
```
