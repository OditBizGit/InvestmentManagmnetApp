# AI Task Workflow

1. **Discovery**: read AI_CONTEXT.md, DEVELOPMENT_RULES.md, then the task-type docs. Grep `lib/` for existing implementations (endpoint names, widget names, similar screens). Use CODEBASE_MAP.md and FEATURE_MODULES.md to locate code.
2. **Requirements**: restate the task; list unknowns (API contract, roles, copy). Do not invent business rules; ask when ambiguous.
3. **Reuse**: prefer existing widgets/services in `lib/core/utils`, existing cubit patterns, `ApiEndpoints`, the shared Dio.
4. **Impact analysis**: find usages of anything you change; check admin vs user (`isAdmin`), permissions (`admin_nav_permissions.dart`), `service_locator.dart` registrations, state consumers, and PDF/Excel export paths. Do not touch unrelated modules.
5. **Implement** in small steps using FEATURE_IMPLEMENTATION_GUIDE.md.
6. **Verify**:
   - `flutter pub get`
   - `flutter analyze` (do not introduce new warnings)
   - `flutter test` (existing: `test/widget_test.dart`; `test/admin/settings` and `test/core/constants` folders. Coverage is minimal, so also verify manually)
   - `flutter run -d chrome` for the admin build (`isAdmin = true`); a device/emulator for the user build (flip `isAdmin` in `lib/main.dart` only locally and revert).
7. **Docs**: update the matching `docs/modules/*.md`, and API_INTEGRATION / DATA_MODELS / DIAGRAMS / DOC_COVERAGE when endpoints, models or flows change. Source beats docs on conflict; fix the doc.
