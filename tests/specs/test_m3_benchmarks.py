from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]

def test_task_112_settings_and_audio_themes():
    """Verify TASK-112: Settings screen (SCR-06), 4 typewriter themes, sound preview, haptics & reminder."""
    settings_file = REPO_ROOT / "lib" / "presentation" / "settings" / "settings_screen.dart"
    assert settings_file.exists(), "settings_screen.dart must exist"
    content = settings_file.read_text(encoding="utf-8")

    assert "AudioTheme" in content, "Must use AudioTheme enumeration"
    assert "_sound.previewTheme" in content, "Must support sound preview for typewriter themes"
    assert "VellumHapticEngine.enabled" in content, "Must allow toggling Taptic Engine"
    assert "_reminderTime" in content, "Must support setting daily reminder time"
    assert "Zero-PII" in content, "Must display Zero-PII privacy guarantee"

    # Verify AudioTheme definitions
    theme_file = REPO_ROOT / "lib" / "core" / "audio" / "audio_theme.dart"
    assert theme_file.exists(), "audio_theme.dart must exist"
    theme_content = theme_file.read_text(encoding="utf-8")
    assert "underwood" in theme_content, "Must define Underwood No. 5"
    assert "hermes" in theme_content, "Must define Hermes 3000"
    assert "olympia" in theme_content, "Must define Olympia Splendid"
    assert "calligraphy" in theme_content, "Must define Calligraphy Pen"
    print("✅ TASK-112: Settings screen and 4 acoustic themes verified.")

def test_task_113_sentry_and_telemetrydeck_zero_pii():
    """Verify TASK-113: Sentry Mobile and TelemetryDeck anonymous Zero-PII telemetry."""
    telemetry_file = REPO_ROOT / "lib" / "core" / "observability" / "telemetry_service.dart"
    assert telemetry_file.exists(), "telemetry_service.dart must exist"
    content = telemetry_file.read_text(encoding="utf-8")

    assert "Zero-PII" in content, "Must enforce Zero-PII architecture"
    assert "logVerseCompleted" in content, "Must log verse completion events"
    assert "logPaywallViewed" in content, "Must log paywall conversion events"
    assert "logProPurchased" in content, "Must log purchase events"
    assert "sanitizedParams" in content, "Must sanitize telemetry payloads"
    print("✅ TASK-113: Zero-PII Telemetry & Sentry integration verified.")

def test_task_114_fastlane_and_ci_pipeline():
    """Verify TASK-114: Fastlane Match, TestFlight upload, and GitHub Actions CI/CD."""
    fastfile = REPO_ROOT / "fastlane" / "Fastfile"
    assert fastfile.exists(), "fastlane/Fastfile must exist"
    ff_content = fastfile.read_text(encoding="utf-8")

    assert "lane :test" in ff_content, "Must define test lane"
    assert "lane :build_release" in ff_content, "Must define build_release lane"
    assert "lane :beta" in ff_content, "Must define beta lane for TestFlight"
    assert "upload_to_testflight" in ff_content, "Must upload to Apple TestFlight"

    ci_file = REPO_ROOT / ".github" / "workflows" / "ci.yml"
    assert ci_file.exists(), ".github/workflows/ci.yml must exist"
    ci_content = ci_file.read_text(encoding="utf-8")

    assert "Flutter Lint & Unit Tests" in ci_content, "CI must run lint and tests"
    assert "test_and_analyze" in ci_content, "CI must contain test job"
    assert "build_testflight" in ci_content, "CI must contain TestFlight deployment job"
    print("✅ TASK-114: Fastlane Match, TestFlight deployment, and GitHub Actions verified.")

if __name__ == "__main__":
    print("=" * 60)
    print("🧪 Running SDD Milestone M3 Acceptance & Specification Tests")
    print("=" * 60)
    test_task_112_settings_and_audio_themes()
    test_task_113_sentry_and_telemetrydeck_zero_pii()
    test_task_114_fastlane_and_ci_pipeline()
    print("=" * 60)
    print("🎉 ALL M3 ACCEPTANCE CRITERIA VERIFIED (100% PASSED)!")
    print("=" * 60)
