# Maribel Wellness Centre App

Flutter app (Cubit/flutter_bloc + get_it + Dio). Two roles from one codebase via `isAdmin` in `lib/main.dart`: admin (web/desktop) and user/investor (mobile).

## Rules
- Read `docs/AI_CONTEXT.md` first, then the docs it lists for your task type; follow `docs/DEVELOPMENT_RULES.md` (15 rules) and `docs/AI_TASK_WORKFLOW.md`.
- Follow the architecture, state management (sealed Cubit states), design system and responsive rules; reuse existing widgets/services; no new packages without need.
- Preserve API contracts and existing behavior/UI; do not invent requirements or business rules; ask when ambiguous.
- Update docs when implementation changes. Source code beats docs on discrepancy.

## Commands
`flutter pub get` | `flutter analyze` | `flutter test` | `flutter run -d chrome` (admin)

## Quick facts
- DI: `lib/core/network/service_locator.dart` (`setupDi`); endpoints: `lib/core/constants/api_endpoints.dart`.
- Feature layout: `lib/<admin|user>/<feature>/{cubit,model,repository,screen,widgets}`.
- Tests are minimal (`test/`).
